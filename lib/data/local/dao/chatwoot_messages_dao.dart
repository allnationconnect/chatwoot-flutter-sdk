import 'dart:collection';

import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class ChatwootMessagesDao {
  Future<void> saveMessage(ChatwootMessage message);
  Future<void> saveAllMessages(List<ChatwootMessage> messages);
  ChatwootMessage? getMessage(int messageId);
  List<ChatwootMessage> getMessages({int? conversationId});
  Future<void> clear({int? conversationId});
  Future<void> deleteMessage(int messageId);
  Future<void> onDispose();

  Future<void> clearAll();
}

//Only used when persistence is enabled
enum ChatwootMessagesBoxNames {
  MESSAGES,
  MESSAGES_TO_CLIENT_INSTANCE_KEY,
  MESSAGE_ID_TO_CONVERSATION_ID
}

class PersistedChatwootMessagesDao extends ChatwootMessagesDao {
  // box containing all persisted messages
  final Box<ChatwootMessage> _box;

  final String _clientInstanceKey;

  //box with one to many relation
  final Box<String> _messageIdToClientInstanceKeyBox;

  // 修改类型为 int
  final Box<int> _messageIdToConversationIdBox;

  PersistedChatwootMessagesDao(this._box, this._messageIdToClientInstanceKeyBox,
      this._clientInstanceKey, this._messageIdToConversationIdBox);

  @override
  Future<void> clear({int? conversationId}) async {
    //filter current client instance message ids
    Iterable clientMessageIds = _messageIdToClientInstanceKeyBox.keys.where(
        (key) =>
            _messageIdToClientInstanceKeyBox.get(key) == _clientInstanceKey);

    if (conversationId != null) {
      clientMessageIds = clientMessageIds.where((messageId) =>
          _messageIdToConversationIdBox.get(messageId) == conversationId);
    }

    await _box.deleteAll(clientMessageIds);
    await _messageIdToClientInstanceKeyBox.deleteAll(clientMessageIds);
    await _messageIdToConversationIdBox.deleteAll(clientMessageIds);
  }

  @override
  Future<void> saveMessage(ChatwootMessage message) async {
    await _box.put(message.id, message);
    await _messageIdToClientInstanceKeyBox.put(message.id, _clientInstanceKey);
    // 直接使用 int 类型的 conversationId
    await _messageIdToConversationIdBox.put(message.id, message.conversationId!);
    print("saved");
  }

  @override
  Future<void> saveAllMessages(List<ChatwootMessage> messages) async {
    for (ChatwootMessage message in messages) await saveMessage(message);
  }

  @override
  List<ChatwootMessage> getMessages({int? conversationId}) {
    if (conversationId != null) {
      // 如果指定了会话 ID，进一步过滤
      final messageClientInstancekey = _clientInstanceKey;
      Set<int> clientMessageIds = _messageIdToClientInstanceKeyBox.keys
          .map((e) => e as int)
          .where((key) =>
              _messageIdToClientInstanceKeyBox.get(key) ==
              messageClientInstancekey)
          .toSet();

      // 使用 int 类型比较
      clientMessageIds = clientMessageIds
          .where((messageId) =>
              _messageIdToConversationIdBox.get(messageId) == conversationId)
          .toSet();

      //retrieve messages with ids
      List<ChatwootMessage> sortedMessages = _box.values
          .where((message) => clientMessageIds.contains(message.id))
          .toList(growable: false);

      //sort message using creation dates
      sortedMessages.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });

      return sortedMessages;
    } else {
      // 如果未指定会话 ID，获取所有消息
      return getMessages();
    }
  }

  @override
  Future<void> onDispose() async {}

  @override
  Future<void> deleteMessage(int messageId) async {
    await _box.delete(messageId);
    await _messageIdToClientInstanceKeyBox.delete(messageId);
    await _messageIdToConversationIdBox.delete(messageId);
  }

  @override
  ChatwootMessage? getMessage(int messageId) {
    return _box.get(messageId, defaultValue: null);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _messageIdToClientInstanceKeyBox.clear();
    await _messageIdToConversationIdBox.clear();
  }

  static Future<void> openDB() async {
    await Hive.openBox<ChatwootMessage>(
        ChatwootMessagesBoxNames.MESSAGES.toString());
    await Hive.openBox<String>(
        ChatwootMessagesBoxNames.MESSAGES_TO_CLIENT_INSTANCE_KEY.toString());
    // 修改为 int 类型的 box
    await Hive.openBox<int>(
        ChatwootMessagesBoxNames.MESSAGE_ID_TO_CONVERSATION_ID.toString());
  }
}

class NonPersistedChatwootMessagesDao extends ChatwootMessagesDao {
  HashMap<int, ChatwootMessage> _messages = new HashMap();

  @override
  Future<void> clear({int? conversationId}) async {
    if (conversationId != null) {
      _messages
          .removeWhere((key, value) => value.conversationId == conversationId);
    } else {
      _messages.clear();
    }
  }

  @override
  Future<void> deleteMessage(int messageId) async {
    _messages.remove(messageId);
  }

  @override
  ChatwootMessage? getMessage(int messageId) {
    return _messages[messageId];
  }

  @override
  List<ChatwootMessage> getMessages({int? conversationId}) {
    List<ChatwootMessage> sortedMessages = _messages.values
        .where((message) =>
            conversationId == null || message.conversationId == conversationId)
        .toList(growable: false);

    sortedMessages.sort((a, b) {
      return a.createdAt.compareTo(b.createdAt);
    });
    return sortedMessages;
  }

  @override
  Future<void> onDispose() async {
    _messages.clear();
  }

  @override
  Future<void> saveAllMessages(List<ChatwootMessage> messages) async {
    messages.forEach((element) async {
      await saveMessage(element);
    });
  }

  @override
  Future<void> saveMessage(ChatwootMessage message) async {
    _messages.update(message.id, (value) => message, ifAbsent: () => message);
  }

  @override
  Future<void> clearAll() async {
    _messages.clear();
  }
}
