import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/repositories/chat_stream_repository.dart';

/// Speaks the backend's streaming `POST`: pydantic-ai's `VercelAIAdapter`,
/// i.e. the Vercel AI SDK UI-message-stream protocol over Server-Sent Events.
///
/// Request: `{id, trigger: 'submit-message', messages: [{id, role, parts}]}`.
/// Response: `data: {json}` events -- `start{messageId}`, `text-delta{delta}`,
/// `finish`, `error{errorText}`, then `data: [DONE]`. Every other chunk type
/// (steps, reasoning, tools, sources, files, `data-*`) is ignored, so the
/// backend can add kinds of output without breaking this client.
///
/// Not wired in yet -- `chatStreamRepositoryProvider` still names the mock.
/// The caller owns [client]'s lifecycle.
class HttpChatStreamRepository implements ChatStreamRepository {
  HttpChatStreamRepository({
    required this._client,
    required this._endpoint,
  });

  final http.Client _client;
  final Uri _endpoint;

  @override
  Stream<ChatMessageItem> streamReply({
    required String conversationId,
    required List<ChatMessageItem> messages,
  }) async* {
    final request = http.Request('POST', _endpoint)
      ..headers['content-type'] = 'application/json'
      ..headers['accept'] = 'text/event-stream'
      ..body = jsonEncode(_requestBody(conversationId, messages));

    try {
      final response = await _client.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await response.stream.bytesToString();
        throw ChatStreamException(
          body.isEmpty ? 'The request was rejected' : body,
          statusCode: response.statusCode,
        );
      }

      // Replaced by `start`'s messageId, which is always the first chunk, so
      // this is only ever seen if the backend omits it.
      var id = 'assistant-${DateTime.now().microsecondsSinceEpoch}';
      var text = '';
      var finished = false;

      ChatMessageItem snapshot(ChatMessageStatus status) => ChatMessageItem(
            id: id,
            message: text,
            isUser: false,
            status: status,
          );

      await for (final payload in _ssePayloads(response.stream)) {
        if (payload == '[DONE]') break;
        final chunk = _decodeChunk(payload);
        switch (chunk['type']) {
          case 'start':
            final messageId = chunk['messageId'];
            if (messageId is String) id = messageId;
            yield snapshot(ChatMessageStatus.streaming);
          case 'text-delta':
            final delta = chunk['delta'];
            if (delta is String) text += delta;
            yield snapshot(ChatMessageStatus.streaming);
          case 'finish':
            finished = true;
            yield snapshot(ChatMessageStatus.complete);
          case 'error':
            final errorText = chunk['errorText'];
            throw ChatStreamException(
              errorText is String ? errorText : 'The reply failed',
            );
          case 'abort':
            throw const ChatStreamException('The reply was aborted');
        }
      }
      if (!finished) {
        throw const ChatStreamException(
          'The stream ended before the reply finished',
        );
      }
    } on http.ClientException catch (error) {
      throw ChatStreamException(error.message);
    }
  }

  /// Only complete, non-empty messages go out: a streaming or failed reply is
  /// not part of the conversation the model should see.
  static Map<String, Object?> _requestBody(
    String conversationId,
    List<ChatMessageItem> messages,
  ) =>
      {
        'id': conversationId,
        'trigger': 'submit-message',
        'messages': [
          for (final m in messages)
            if (m.status == ChatMessageStatus.complete && m.message.isNotEmpty)
              {
                'id': m.id,
                'role': m.isUser ? 'user' : 'assistant',
                'parts': [
                  {'type': 'text', 'text': m.message},
                ],
              },
        ],
      };

  static Map<String, Object?> _decodeChunk(String payload) {
    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      throw const ChatStreamException('The stream sent a malformed chunk');
    }
    if (decoded is! Map<String, Object?>) {
      throw const ChatStreamException('The stream sent a malformed chunk');
    }
    return decoded;
  }

  /// The `data:` payload of each complete Server-Sent Event. Events are
  /// separated by a blank line; several `data:` lines in one event join with
  /// `\n`; comment lines and other fields (`event:`, `id:`, `retry:`) are
  /// ignored, since this protocol uses only `data:`. An event cut off by the
  /// end of the stream is dropped, as the SSE spec says.
  ///
  /// Hand-rolled rather than an EventSource client on purpose: those
  /// reconnect automatically, which here would re-POST the message and run the
  /// model a second time.
  static Stream<String> _ssePayloads(Stream<List<int>> bytes) async* {
    final data = <String>[];
    await for (final line
        in bytes.transform(utf8.decoder).transform(const LineSplitter())) {
      if (line.isEmpty) {
        if (data.isNotEmpty) {
          yield data.join('\n');
          data.clear();
        }
      } else if (line.startsWith('data:')) {
        final value = line.substring('data:'.length);
        data.add(value.startsWith(' ') ? value.substring(1) : value);
      }
    }
  }
}
