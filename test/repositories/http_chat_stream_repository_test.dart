import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/repositories/chat_stream_repository.dart';
import 'package:radiologist_helper/repositories/http_chat_stream_repository.dart';

final _endpoint = Uri.parse('https://backend.test/chat');

const _question = ChatMessageItem(
  id: 'user-1',
  message: 'Any effusion?',
  isUser: true,
);

/// One Server-Sent Event carrying [payload] as its `data:` line.
String _event(Object payload) =>
    'data: ${payload is String ? payload : jsonEncode(payload)}\n\n';

/// What the backend sends for a plain text reply, as chunk maps.
List<Map<String, Object?>> _reply(List<String> deltas, {String id = 'msg_1'}) =>
    [
      {'type': 'start', 'messageId': id},
      {'type': 'start-step'},
      {'type': 'text-start', 'id': 't1'},
      for (final d in deltas) {'type': 'text-delta', 'id': 't1', 'delta': d},
      {'type': 'text-end', 'id': 't1'},
      {'type': 'finish-step'},
      {'type': 'finish'},
    ];

String _sse(List<Object> payloads, {bool done = true}) =>
    payloads.map(_event).join() + (done ? _event('[DONE]') : '');

Stream<List<int>> _bytes(String body, {int? chunkSize}) {
  final all = utf8.encode(body);
  if (chunkSize == null) return Stream.value(all);
  return Stream.fromIterable([
    for (var i = 0; i < all.length; i += chunkSize)
      all.sublist(i, i + chunkSize > all.length ? all.length : i + chunkSize),
  ]);
}

HttpChatStreamRepository _repository(
  Stream<List<int>> Function() body, {
  int status = 200,
  void Function(http.BaseRequest request, String body)? onRequest,
}) =>
    HttpChatStreamRepository(
      client: MockClient.streaming((request, bodyStream) async {
        onRequest?.call(request, await bodyStream.bytesToString());
        return http.StreamedResponse(body(), status);
      }),
      endpoint: _endpoint,
    );

Stream<ChatMessageItem> _stream(
  HttpChatStreamRepository repository, [
  List<ChatMessageItem> messages = const [_question],
]) =>
    repository.streamReply(conversationId: 'conv-1', messages: messages);

void main() {
  group('request', () {
    late http.BaseRequest sent;
    late Map<String, Object?> sentBody;

    Future<void> send(List<ChatMessageItem> messages) async {
      await _stream(
        _repository(
          () => _bytes(_sse(_reply(['ok']))),
          onRequest: (request, body) {
            sent = request;
            sentBody = jsonDecode(body) as Map<String, Object?>;
          },
        ),
        messages,
      ).drain<void>();
    }

    test('is a POST to the endpoint', () async {
      await send(const [_question]);
      expect(sent.method, 'POST');
      expect(sent.url, _endpoint);
    });

    test('says it sends JSON and wants an event stream', () async {
      await send(const [_question]);
      expect(sent.headers['content-type'], startsWith('application/json'));
      expect(sent.headers['accept'], 'text/event-stream');
    });

    test('carries the conversation id and the submit-message trigger', () async {
      await send(const [_question]);
      expect(sentBody['id'], 'conv-1');
      expect(sentBody['trigger'], 'submit-message');
    });

    test('sends each message as an AI SDK UIMessage with one text part', () async {
      await send(const [
        _question,
      ]);
      expect(sentBody['messages'], [
        {
          'id': 'user-1',
          'role': 'user',
          'parts': [
            {'type': 'text', 'text': 'Any effusion?'},
          ],
        },
      ]);
    });

    test('maps isUser to the user and assistant roles, in order', () async {
      await send(const [
        ChatMessageItem(id: 'a', message: 'one', isUser: true),
        ChatMessageItem(id: 'b', message: 'two', isUser: false),
        ChatMessageItem(id: 'c', message: 'three', isUser: true),
      ]);
      final messages = sentBody['messages'] as List<Object?>;
      expect(
        messages.map((m) => (m as Map<String, Object?>)['role']),
        ['user', 'assistant', 'user'],
      );
      expect(
        messages.map((m) => (m as Map<String, Object?>)['id']),
        ['a', 'b', 'c'],
      );
    });

    test('leaves out streaming, failed and empty messages', () async {
      await send(const [
        ChatMessageItem(id: 'a', message: 'kept', isUser: true),
        ChatMessageItem(
          id: 'b',
          message: 'half a repl',
          isUser: false,
          status: ChatMessageStatus.streaming,
        ),
        ChatMessageItem(
          id: 'c',
          message: 'broken',
          isUser: false,
          status: ChatMessageStatus.failed,
        ),
        ChatMessageItem(id: 'd', message: '', isUser: false),
        ChatMessageItem(id: 'e', message: 'also kept', isUser: true),
      ]);
      final ids = (sentBody['messages'] as List<Object?>)
          .map((m) => (m as Map<String, Object?>)['id']);
      expect(ids, ['a', 'e']);
    });
  });

  group('reply', () {
    test('streams the reply: id from start, text growing, then complete',
        () async {
      final snapshots = await _stream(
        _repository(() => _bytes(_sse(_reply(['Hel', 'lo', ' there'])))),
      ).toList();

      expect(
        snapshots.map((s) => (s.id, s.message, s.status)),
        [
          ('msg_1', '', ChatMessageStatus.streaming),
          ('msg_1', 'Hel', ChatMessageStatus.streaming),
          ('msg_1', 'Hello', ChatMessageStatus.streaming),
          ('msg_1', 'Hello there', ChatMessageStatus.streaming),
          ('msg_1', 'Hello there', ChatMessageStatus.complete),
        ],
      );
    });

    test('every snapshot is an assistant message', () async {
      final snapshots =
          await _stream(_repository(() => _bytes(_sse(_reply(['x']))))).toList();
      expect(snapshots.every((s) => !s.isUser), isTrue);
    });

    test('joins several text blocks in order', () async {
      final snapshots = await _stream(
        _repository(
          () => _bytes(
            _sse([
              {'type': 'start', 'messageId': 'm'},
              {'type': 'text-start', 'id': 'a'},
              {'type': 'text-delta', 'id': 'a', 'delta': 'First. '},
              {'type': 'text-end', 'id': 'a'},
              {'type': 'text-start', 'id': 'b'},
              {'type': 'text-delta', 'id': 'b', 'delta': 'Second.'},
              {'type': 'text-end', 'id': 'b'},
              {'type': 'finish'},
            ]),
          ),
        ),
      ).toList();
      expect(snapshots.last.message, 'First. Second.');
    });

    test('without a start chunk, still keeps one id across the whole reply',
        () async {
      final snapshots = await _stream(
        _repository(
          () => _bytes(
            _sse([
              {'type': 'text-delta', 'id': 't', 'delta': 'a'},
              {'type': 'text-delta', 'id': 't', 'delta': 'b'},
              {'type': 'finish'},
            ]),
          ),
        ),
      ).toList();
      expect(snapshots.map((s) => s.id).toSet(), hasLength(1));
      expect(snapshots.first.id, startsWith('assistant-'));
      expect(snapshots.last.message, 'ab');
    });

    test('ignores chunk types it does not use', () async {
      final snapshots = await _stream(
        _repository(
          () => _bytes(
            _sse([
              {'type': 'start', 'messageId': 'm'},
              {'type': 'message-metadata', 'messageMetadata': {'a': 1}},
              {'type': 'reasoning-start', 'id': 'r'},
              {'type': 'reasoning-delta', 'id': 'r', 'delta': 'thinking'},
              {'type': 'tool-input-available', 'toolCallId': 'x', 'input': {}},
              {'type': 'data-caseReferences', 'data': ['case-1']},
              {'type': 'source-url', 'sourceId': 's', 'url': 'https://x.test'},
              {'type': 'some-future-chunk', 'whatever': true},
              {'type': 'text-delta', 'id': 't', 'delta': 'Answer'},
              {'type': 'finish'},
            ]),
          ),
        ),
      ).toList();

      expect(snapshots.map((s) => s.message), ['', 'Answer', 'Answer']);
    });
  });

  group('server-sent events framing', () {
    final payloads = _reply(['Hello — élan']);

    Future<ChatMessageItem> lastOf(Stream<List<int>> Function() body) async =>
        (await _stream(_repository(body)).toList()).last;

    test('survives the network splitting the bytes anywhere', () async {
      // 3-byte chunks cut through events, lines and the multi-byte characters.
      final last = await lastOf(() => _bytes(_sse(payloads), chunkSize: 3));
      expect(last.message, 'Hello — élan');
      expect(last.status, ChatMessageStatus.complete);
    });

    test('survives one byte at a time', () async {
      final last = await lastOf(() => _bytes(_sse(payloads), chunkSize: 1));
      expect(last.message, 'Hello — élan');
    });

    test('accepts CRLF line endings', () async {
      final body = _sse(payloads).replaceAll('\n', '\r\n');
      expect((await lastOf(() => _bytes(body))).message, 'Hello — élan');
    });

    test('accepts data: with no space after the colon', () async {
      final body = _sse(payloads).replaceAll('data: ', 'data:');
      expect((await lastOf(() => _bytes(body))).message, 'Hello — élan');
    });

    test('joins several data lines of one event with a newline', () async {
      final body = 'data: {"type":"start",\n'
          'data: "messageId":"m"}\n\n'
          '${_sse([
            {'type': 'text-delta', 'id': 't', 'delta': 'x'},
            {'type': 'finish'},
          ])}';
      final snapshots = await _stream(_repository(() => _bytes(body))).toList();
      expect(snapshots.first.id, 'm');
      expect(snapshots.last.message, 'x');
    });

    test('ignores comments and fields other than data', () async {
      final body = ': keep-alive\n\n'
          'event: message\nid: 7\nretry: 1000\n'
          '${_sse(payloads)}';
      expect((await lastOf(() => _bytes(body))).message, 'Hello — élan');
    });

    test('stops at [DONE] and does not read past it', () async {
      final body = '${_sse(payloads)}${_event({'type': 'error', 'errorText': 'late'})}';
      expect((await lastOf(() => _bytes(body))).status, ChatMessageStatus.complete);
    });
  });

  group('failure', () {
    Future<void> expectFailure(
      HttpChatStreamRepository repository,
      Matcher matcher,
    ) =>
        expectLater(_stream(repository).drain<void>(), throwsA(matcher));

    test('an error chunk fails with its errorText, keeping earlier snapshots',
        () async {
      final seen = <ChatMessageItem>[];
      final repository = _repository(
        () => _bytes(
          _sse([
            {'type': 'start', 'messageId': 'm'},
            {'type': 'text-delta', 'id': 't', 'delta': 'partial'},
            {'type': 'error', 'errorText': 'model overloaded'},
          ], done: false),
        ),
      );

      await expectLater(
        _stream(repository).forEach(seen.add),
        throwsA(
          isA<ChatStreamException>()
              .having((e) => e.message, 'message', 'model overloaded')
              .having((e) => e.statusCode, 'statusCode', isNull),
        ),
      );
      expect(seen.last.message, 'partial');
      expect(seen.last.status, ChatMessageStatus.streaming);
    });

    test('an error chunk with no text still fails', () async {
      await expectFailure(
        _repository(() => _bytes(_sse([{'type': 'error'}]))),
        isA<ChatStreamException>(),
      );
    });

    test('an abort chunk fails', () async {
      await expectFailure(
        _repository(() => _bytes(_sse([{'type': 'abort'}]))),
        isA<ChatStreamException>()
            .having((e) => e.message, 'message', contains('aborted')),
      );
    });

    test('a non-2xx response fails with its status and body', () async {
      await expectFailure(
        _repository(
          () => _bytes('{"detail":"bad trigger"}'),
          status: 422,
        ),
        isA<ChatStreamException>()
            .having((e) => e.statusCode, 'statusCode', 422)
            .having((e) => e.message, 'message', contains('bad trigger')),
      );
    });

    test('a non-2xx response with an empty body still explains itself', () async {
      await expectFailure(
        _repository(() => _bytes(''), status: 500),
        isA<ChatStreamException>()
            .having((e) => e.statusCode, 'statusCode', 500)
            .having((e) => e.message, 'message', isNotEmpty),
      );
    });

    test('a stream that ends before finish fails', () async {
      await expectFailure(
        _repository(
          () => _bytes(
            _sse([
              {'type': 'start', 'messageId': 'm'},
              {'type': 'text-delta', 'id': 't', 'delta': 'cut'},
            ], done: false),
          ),
        ),
        isA<ChatStreamException>()
            .having((e) => e.message, 'message', contains('before')),
      );
    });

    test('[DONE] without a finish chunk fails', () async {
      await expectFailure(
        _repository(
          () => _bytes(_sse([{'type': 'start', 'messageId': 'm'}])),
        ),
        isA<ChatStreamException>(),
      );
    });

    test('an event cut off mid-way is dropped, so its finish never counts',
        () async {
      // No blank line after the last event: per the SSE spec it is discarded.
      final body = '${_event({'type': 'start', 'messageId': 'm'})}'
          'data: {"type":"finish"}\n';
      await expectFailure(
        _repository(() => _bytes(body)),
        isA<ChatStreamException>(),
      );
    });

    test('a chunk that is not JSON fails', () async {
      await expectFailure(
        _repository(() => _bytes(_event('not json'))),
        isA<ChatStreamException>()
            .having((e) => e.message, 'message', contains('malformed')),
      );
    });

    test('a chunk that is JSON but not an object fails', () async {
      await expectFailure(
        _repository(() => _bytes(_event('[1,2]'))),
        isA<ChatStreamException>()
            .having((e) => e.message, 'message', contains('malformed')),
      );
    });

    test('a transport error before the response becomes a ChatStreamException',
        () async {
      final repository = HttpChatStreamRepository(
        client: MockClient.streaming(
          (_, _) async => throw http.ClientException('connection refused'),
        ),
        endpoint: _endpoint,
      );
      await expectFailure(
        repository,
        isA<ChatStreamException>()
            .having((e) => e.message, 'message', 'connection refused'),
      );
    });

    test('a transport error mid-stream becomes a ChatStreamException', () async {
      final controller = StreamController<List<int>>();
      final repository = _repository(() => controller.stream);
      final future = expectLater(
        _stream(repository).drain<void>(),
        throwsA(
          isA<ChatStreamException>()
              .having((e) => e.message, 'message', 'connection lost'),
        ),
      );
      controller
        ..add(utf8.encode(_event({'type': 'start', 'messageId': 'm'})))
        ..addError(http.ClientException('connection lost'));
      await controller.close();
      await future;
    });
  });

  test('cancelling the stream stops reading the response', () async {
    final controller = StreamController<List<int>>();
    final cancelled = Completer<void>();
    controller.onCancel = cancelled.complete;
    final repository = _repository(() => controller.stream);

    final firstSnapshot = Completer<ChatMessageItem>();
    final subscription = _stream(repository).listen(firstSnapshot.complete);
    controller.add(utf8.encode(_event({'type': 'start', 'messageId': 'm'})));
    await firstSnapshot.future;

    await subscription.cancel();

    // The connection closes rather than the reply running on unobserved.
    await cancelled.future.timeout(const Duration(seconds: 2));
  });
}
