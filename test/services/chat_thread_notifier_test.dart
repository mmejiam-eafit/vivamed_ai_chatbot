import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/repositories/chat_stream_repository.dart';
import 'package:radiologist_helper/repositories/conversation_repository.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/services/providers.dart';

import '../support/fake_chat_stream_repository.dart';

class _FakeConversationRepository implements ConversationRepository {
  _FakeConversationRepository(this.history);

  final Future<List<ChatMessageItem>> history;

  @override
  Future<List<ConversationItem>> getConversations() =>
      throw UnimplementedError();

  @override
  Future<List<ChatMessageItem>> getMessages(String conversationId) => history;

  @override
  Future<ChatMessageItem> sendMessage({
    required String conversationId,
    required String text,
  }) =>
      throw UnimplementedError();
}

const _history = [
  ChatMessageItem(id: 'h1', message: 'Earlier question', isUser: true),
  ChatMessageItem(id: 'h2', message: 'Earlier answer', isUser: false),
];

ChatMessageItem _snapshot(
  String message, {
  String id = 'server-1',
  ChatMessageStatus status = ChatMessageStatus.streaming,
}) =>
    ChatMessageItem(id: id, message: message, isUser: false, status: status);

void main() {
  late FakeChatStreamRepository stream;
  late ProviderContainer container;

  ProviderContainer makeContainer({Future<List<ChatMessageItem>>? history}) {
    final created = ProviderContainer(
      overrides: [
        conversationRepositoryProvider.overrideWithValue(
          _FakeConversationRepository(history ?? Future.value(_history)),
        ),
        chatStreamRepositoryProvider.overrideWithValue(stream),
      ],
    );
    addTearDown(created.dispose);
    return created;
  }

  /// A loaded thread, read the way a page would.
  Future<_Thread> loaded() async {
    container = makeContainer();
    await container.read(messagesProvider('conv-1').future);
    return _Thread(container);
  }

  setUp(() => stream = FakeChatStreamRepository());

  group('history', () {
    test('starts as the fetched history', () async {
      final thread = await loaded();
      expect(thread.messages, _history);
    });

    test('stays loading until the history arrives', () async {
      final pending = Completer<List<ChatMessageItem>>();
      container = makeContainer(history: pending.future);
      container.read(messagesProvider('conv-1'));

      expect(container.read(messagesProvider('conv-1')).isLoading, isTrue);

      pending.complete(_history);
      await container.read(messagesProvider('conv-1').future);
      expect(container.read(messagesProvider('conv-1')).hasValue, isTrue);
    });

    test('keeps one thread per conversation', () async {
      container = makeContainer();
      await container.read(messagesProvider('conv-1').future);
      await container.read(messagesProvider('conv-2').future);

      container.read(messagesProvider('conv-1').notifier).send('Only here');

      expect(
        container.read(messagesProvider('conv-1')).value!.length,
        _history.length + 2,
      );
      expect(
        container.read(messagesProvider('conv-2')).value!.length,
        _history.length,
      );
    });
  });

  group('send: accepted', () {
    test('returns true', () async {
      final thread = await loaded();
      expect(thread.send('Any effusion?'), isTrue);
    });

    test('appends the question and an empty streaming reply at once', () async {
      final thread = await loaded();

      thread.send('Any effusion?');

      // Before the stream has said anything.
      final messages = thread.messages;
      expect(messages.length, _history.length + 2);
      expect(messages.take(_history.length), _history);

      final question = messages[_history.length];
      expect(question.message, 'Any effusion?');
      expect(question.isUser, isTrue);
      expect(question.status, ChatMessageStatus.complete);

      final reply = messages.last;
      expect(reply.message, isEmpty);
      expect(reply.isUser, isFalse);
      expect(reply.status, ChatMessageStatus.streaming);
    });

    test('streams the whole thread, question last, for this conversation',
        () async {
      final thread = await loaded();

      thread.send('Any effusion?');

      expect(stream.lastConversationId, 'conv-1');
      final sent = stream.lastMessages!;
      expect(sent.length, _history.length + 1);
      expect(sent.take(_history.length), _history);
      expect(sent.last.message, 'Any effusion?');
      // The same message the page is showing -- same id the backend will store.
      expect(sent.last.id, thread.messages[_history.length].id);
    });

    test('gives every message a distinct id', () async {
      final thread = await loaded();
      thread.send('Any effusion?');
      final ids = thread.messages.map((m) => m.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });
  });

  group('send: the reply streams in place', () {
    test('each snapshot replaces the reply instead of adding a message',
        () async {
      final thread = await loaded();
      thread.send('Any effusion?');
      final expectedLength = thread.messages.length;

      stream.latest.add(_snapshot('No'));
      await pumpEventQueue();
      expect(thread.messages.last.message, 'No');
      expect(thread.messages.length, expectedLength);

      stream.latest.add(_snapshot('No effusion'));
      await pumpEventQueue();
      expect(thread.messages.last.message, 'No effusion');
      expect(thread.messages.length, expectedLength);
    });

    test("the first snapshot swaps the placeholder id for the server's",
        () async {
      final thread = await loaded();
      thread.send('Any effusion?');
      final placeholderId = thread.messages.last.id;

      stream.latest.add(_snapshot('No', id: 'server-1'));
      await pumpEventQueue();

      expect(thread.messages.last.id, 'server-1');
      expect(thread.messages.any((m) => m.id == placeholderId), isFalse);
    });

    test('keeps following the reply by its server id on later snapshots',
        () async {
      final thread = await loaded();
      thread.send('Any effusion?');

      stream.latest
        ..add(_snapshot('a', id: 'server-1'))
        ..add(_snapshot('ab', id: 'server-1'))
        ..add(_snapshot('abc', id: 'server-1'));
      await pumpEventQueue();

      expect(thread.messages.where((m) => !m.isUser && m.id == 'server-1'),
          hasLength(1));
      expect(thread.messages.last.message, 'abc');
    });

    test('a complete snapshot ends the streaming state', () async {
      final thread = await loaded();
      thread.send('Any effusion?');

      stream.latest
        ..add(_snapshot('No effusion'))
        ..add(_snapshot('No effusion', status: ChatMessageStatus.complete));
      await stream.latest.close();
      await pumpEventQueue();

      expect(thread.messages.last.status, ChatMessageStatus.complete);
      expect(thread.messages.last.message, 'No effusion');
    });

    test('leaves the earlier messages and the question untouched', () async {
      final thread = await loaded();
      thread.send('Any effusion?');
      final before = thread.messages.take(_history.length + 1).toList();

      stream.latest.add(_snapshot('No effusion'));
      await pumpEventQueue();

      expect(thread.messages.take(_history.length + 1).toList(), before);
    });

    test('a finished reply lets the next message be sent', () async {
      final thread = await loaded();
      thread.send('First');
      stream.latest.add(_snapshot('Done', status: ChatMessageStatus.complete));
      await stream.latest.close();
      await pumpEventQueue();

      expect(thread.send('Second'), isTrue);
      expect(stream.controllers, hasLength(2));
    });
  });

  group('send: failure', () {
    test('a stream error marks the reply failed and keeps its text', () async {
      final thread = await loaded();
      thread.send('Any effusion?');
      stream.latest.add(_snapshot('No effu'));
      await pumpEventQueue();

      stream.latest.addError(const ChatStreamException('boom'));
      await pumpEventQueue();

      expect(thread.messages.last.status, ChatMessageStatus.failed);
      expect(thread.messages.last.message, 'No effu');
      expect(thread.messages.last.id, 'server-1');
    });

    test('an error before any text fails the placeholder', () async {
      final thread = await loaded();
      thread.send('Any effusion?');

      stream.latest.addError(const ChatStreamException('rejected'));
      await pumpEventQueue();

      expect(thread.messages.last.status, ChatMessageStatus.failed);
      expect(thread.messages.last.message, isEmpty);
    });

    test('an error leaves the question in the thread', () async {
      final thread = await loaded();
      thread.send('Any effusion?');
      stream.latest.addError(const ChatStreamException('boom'));
      await pumpEventQueue();

      expect(thread.messages[_history.length].message, 'Any effusion?');
    });

    test('a stream that closes without completing is a failure, not a hang',
        () async {
      final thread = await loaded();
      thread.send('Any effusion?');
      stream.latest.add(_snapshot('Half'));
      await stream.latest.close();
      await pumpEventQueue();

      expect(thread.messages.last.status, ChatMessageStatus.failed);
      expect(thread.messages.last.message, 'Half');
    });

    test('a failed reply does not block the next send', () async {
      final thread = await loaded();
      thread.send('First');
      stream.latest.addError(const ChatStreamException('boom'));
      await pumpEventQueue();

      expect(thread.send('Second'), isTrue);
      expect(stream.controllers, hasLength(2));
    });

    test('passes a failed reply on to the repository, which keeps it out of '
        'the request', () async {
      final thread = await loaded();
      thread.send('First');
      stream.latest.addError(const ChatStreamException('boom'));
      await pumpEventQueue();

      thread.send('Second');

      // The notifier hands over the thread as it is; dropping non-complete
      // messages from the request body is the repository's job.
      expect(
        stream.lastMessages!.where((m) => m.status == ChatMessageStatus.failed),
        hasLength(1),
      );
      expect(stream.lastMessages!.last.message, 'Second');
    });
  });

  group('send: refused', () {
    test('empty text', () async {
      final thread = await loaded();

      expect(thread.send(''), isFalse);

      expect(stream.controllers, isEmpty);
      expect(thread.messages, _history);
    });

    test('a second message while a reply is streaming', () async {
      final thread = await loaded();
      thread.send('First');
      final during = thread.messages;

      expect(thread.send('Second'), isFalse);

      expect(stream.controllers, hasLength(1));
      expect(thread.messages, during);
    });

    test('while the history is still loading', () async {
      final pending = Completer<List<ChatMessageItem>>();
      container = makeContainer(history: pending.future);
      container.read(messagesProvider('conv-1'));

      final accepted =
          container.read(messagesProvider('conv-1').notifier).send('Too soon');

      expect(accepted, isFalse);
      expect(stream.controllers, isEmpty);

      pending.complete(_history);
      await container.read(messagesProvider('conv-1').future);
    });

    test('when the history failed to load', () async {
      container = makeContainer(history: Future.error(StateError('offline')));
      await expectLater(
        container.read(messagesProvider('conv-1').future),
        throwsStateError,
      );

      final accepted =
          container.read(messagesProvider('conv-1').notifier).send('Hello');

      expect(accepted, isFalse);
      expect(stream.controllers, isEmpty);
    });
  });

  group('lifecycle', () {
    test('disposing the container cancels a stream in flight', () async {
      final thread = await loaded();
      thread.send('Any effusion?');
      expect(stream.latest.hasListener, isTrue);
      expect(stream.cancelCount, 0);

      container.dispose();

      expect(stream.cancelCount, 1);
      expect(stream.latest.hasListener, isFalse);
    });

    test('a rebuild cancels the previous build\'s stream and resets the thread',
        () async {
      final thread = await loaded();
      thread.send('Any effusion?');
      stream.latest.add(_snapshot('Half'));
      await pumpEventQueue();

      container.invalidate(messagesProvider('conv-1'));
      await container.read(messagesProvider('conv-1').future);

      expect(stream.cancelCount, 1);
      expect(stream.latest.hasListener, isFalse);
      expect(thread.messages, _history);
    });
  });
}

/// What a page sees and does for one conversation, over a [ProviderContainer].
class _Thread {
  _Thread(this._container);

  final ProviderContainer _container;

  List<ChatMessageItem> get messages =>
      _container.read(messagesProvider('conv-1')).value!;

  bool send(String text) =>
      _container.read(messagesProvider('conv-1').notifier).send(text);
}
