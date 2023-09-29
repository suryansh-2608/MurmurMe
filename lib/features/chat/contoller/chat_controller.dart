import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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


  void sendTextMessage(
      BuildContext context,
      String text,
      String recieverUserId,
      ) {
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
        context: context,
        text: text,
        recieverUserId: recieverUserId,
        senderUser: value!,
      ),
    );
  }
}