import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/enums/message_enum.dart';
import '../../../common/providers/message_reply_provider.dart';
import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import '../contoller/chat_controller.dart';
import 'message_reply_preview.dart';



class BottomChatField extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  const BottomChatField({
    required this.recieverUserId,
    required this.isGroupChat,

    super.key,

  });

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  bool isShowEmojiContainer = false;
  FocusNode focusNode = FocusNode();


  void sendTextMessage() async {
    if(isShowSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
          context,
          _messageController.text.trim(),
          widget.recieverUserId,
        widget.isGroupChat,
      );
      _messageController.text = ' ';
    }
  }

  void sendFileMessage(
      File file,
      MessageEnum messageEnum,
      ) {
    ref.read(chatControllerProvider).sendFileMessage(
      context,
      file,
      widget.recieverUserId,
      messageEnum,
      widget.isGroupChat,
    );
  }

  void selectGIF() async {
    final gif = await pickGIF(context);
    if (gif != null) {
      ref.read(chatControllerProvider).sendGIFMessage(
          context,
          gif.url,
          widget.recieverUserId,
        widget.isGroupChat,
      );
    }
  }


  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        isShowMessageReply ? const MessageReplyPreview() : const SizedBox(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                focusNode: focusNode,
                controller: _messageController,
                onChanged: (val) {
                  if(val.isNotEmpty){
                    setState(() {
                      isShowSendButton = true;
                    });
                  } else {
                    setState(() {
                      isShowSendButton = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: mobileChatBoxColor,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: toggleEmojiKeyboardContainer,
                            icon: const Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                            onPressed: selectGIF,
                            icon: const Icon(
                              Icons.gif,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: selectImage,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: selectVideo,
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  hintText: 'Type a message!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom:  8.0,
              right: 2.0,
              left: 2.0,),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF128c7E),
                radius: 25,
                child: GestureDetector(

                  child: Icon(
                    isShowSendButton ?
                    Icons.send : Icons.mic,
                    color: Colors.white,),
                  onTap: sendTextMessage,
                ),

              ),
            ),
          ],
        ),
        isShowEmojiContainer
            ? SizedBox(
          height: 310,
          child: EmojiPicker(
            onEmojiSelected: ((category, emoji) {
              setState(() {
                _messageController.text =
                    _messageController.text + emoji.emoji;
              });

              if (!isShowSendButton) {
                setState(() {
                  isShowSendButton = true;
                });
              }
            }),
          ),
        )
            : const SizedBox(),
      ],
    );
  }
}