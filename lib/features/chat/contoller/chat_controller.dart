import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../common/enums/message_enum.dart';
import '../../../common/providers/message_reply_provider.dart';
import '../../../model/chat_contact.dart';
import '../../../model/message.dart';
import '../../auth/controller/auth_controller.dart';
import '../repositories/chat_repository.dart';


final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});


class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<Message>> chatStream(String recieverUserId) {
    return chatRepository.getChatStream(recieverUserId);
  }


  void sendTextMessage(BuildContext context,
      String text,
      String recieverUserId,) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) =>
          chatRepository.sendTextMessage(
            context: context,
            text: text,
            recieverUserId: recieverUserId,
            senderUser: value!,
            messageReply: messageReply,
          ),
    );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendFileMessage(BuildContext context,
      File file,
      String recieverUserId,
      MessageEnum messageEnum,) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) =>
          chatRepository.sendFileMessage(
            context: context,
            file: file,
            recieverUserId: recieverUserId,
            senderUserData: value!,
            messageEnum: messageEnum,
            ref: ref,
            messageReply: messageReply,
          ),
    );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendGIFMessage(
      BuildContext context,
      String gifUrl,
      String recieverUserId,
      ) {
    final messageReply = ref.read(messageReplyProvider);
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';

    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendGIFMessage(
        context: context,
        gifUrl: newgifUrl,
        recieverUserId: recieverUserId,
        senderUser: value!,
        messageReply: messageReply,
      ),
    );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void setChatMessageSeen(
      BuildContext context,
      String recieverUserId,
      String messageId,
      ) {
    chatRepository.setChatMessageSeen(
      context,
      recieverUserId,
      messageId,
    );
  }
}

