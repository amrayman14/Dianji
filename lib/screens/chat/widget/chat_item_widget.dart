import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/chat_message_model.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/extensions/string_extentions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/common_file_placeholders.dart';
import '../../../component/view_image_widget.dart';

class ChatItemWidget extends StatefulWidget {
  final ChatMessageModel? chatItemData;

  ChatItemWidget({this.chatItemData});

  @override
  _ChatItemWidgetState createState() => _ChatItemWidgetState();
}

class _ChatItemWidgetState extends State<ChatItemWidget> {
  void initState() {
    super.initState();
    init();
  }

  init() async {}

  ///TODO Code incomplete for receiver message deletion feature
  void deleteMessage() async {
    bool? res = await showConfirmDialog(
      context,
      language.lblConfirmationForDeleteMsg,
      positiveText: language.lblYes,
      negativeText: language.lblNo,
      buttonColor: primaryColor,
    );
    if (res ?? false) {
      hideKeyboard(context);
      chatServices.deleteSingleMessage(senderId: appStore.uid, receiverId: widget.chatItemData!.receiverId!, documentId: widget.chatItemData!.uid.validate()).then((value) {
        chatServices.deleteFiles(widget.chatItemData!.attachmentfiles.validate());
      }).catchError((e) {
        log(e.toString());
      });
    }
  }

  void copyMessage() {
    widget.chatItemData!.message.validate().copyToClipboard();
    toast(language.copied);
  }

  @override
  Widget build(BuildContext context) {
    String time;
    String currentDateTime = widget.chatItemData!.createdAtTime != null ? widget.chatItemData!.createdAtTime!.toDate().toString() : widget.chatItemData!.createdAt.validate().toString();

    DateTime date = widget.chatItemData!.createdAtTime != null ? widget.chatItemData!.createdAtTime!.toDate() : DateTime.fromMicrosecondsSinceEpoch(widget.chatItemData!.createdAt! * 1000);
    if (date.day == DateTime.now().day) {
      time = formatDate(currentDateTime, isFromMicrosecondsSinceEpoch: widget.chatItemData!.createdAtTime == null);
    } else {
      time = formatDate(currentDateTime, isFromMicrosecondsSinceEpoch: widget.chatItemData!.createdAtTime == null);
    }

    Widget chatItem(String messageTypes) {
      return messageTypes == MessageType.TEXT.name
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: widget.chatItemData!.isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatItemData!.message!,
                  style: primaryTextStyle(color: widget.chatItemData!.isMe! ? Colors.white : textPrimaryColorGlobal),
                  maxLines: null,
                ),
                1.height,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: primaryTextStyle(
                        color: !widget.chatItemData!.isMe.validate() ? Colors.blueGrey.withOpacity(0.6) : whiteColor.withOpacity(0.6),
                        size: 10,
                      ),
                    ),
                    2.width,
                    widget.chatItemData!.isMe.validate()
                        ? !widget.chatItemData!.isMessageRead.validate()
                            ? Icon(Icons.done, size: 12, color: Colors.white60)
                            : Icon(Icons.done_all, size: 12, color: Colors.white60)
                        : Offstage()
                  ],
                ),
              ],
            )
          : messageTypes == MessageType.Files.name
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: widget.chatItemData!.isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    ...filesComponent(),
                    Text(
                      widget.chatItemData!.message!,
                      style: primaryTextStyle(color: widget.chatItemData!.isMe! ? Colors.white : textPrimaryColorGlobal),
                      maxLines: null,
                    ).paddingTop(2).visible(widget.chatItemData!.message!.trim().isNotEmpty),
                    1.height,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: primaryTextStyle(
                            color: !widget.chatItemData!.isMe.validate() ? Colors.blueGrey.withOpacity(0.6) : whiteColor.withOpacity(0.6),
                            size: 10,
                          ),
                        ),
                        2.width,
                        widget.chatItemData!.isMe.validate()
                            ? !widget.chatItemData!.isMessageRead.validate()
                                ? Icon(Icons.done, size: 12, color: Colors.white60)
                                : Icon(Icons.done_all, size: 12, color: Colors.white60)
                            : Offstage()
                      ],
                    ),
                  ],
                )
              : Offstage();
    }

    EdgeInsetsGeometry customPadding(String? messageTypes) {
      switch (messageTypes) {
        case TEXT:
          return EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        default:
          return EdgeInsets.symmetric(horizontal: 4, vertical: 4);
      }
    }

    return GestureDetector(
      onLongPress: () async {
        int? res = await showInDialog(
          context,
          contentPadding: EdgeInsets.zero,
          builder: (_) {
            return Container(
              width: context.width(),
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      language.copyMessage,
                      style: primaryTextStyle(),
                    ).onTap(() {
                      finish(context, 1);
                    }),
                  ),
                  if (widget.chatItemData!.isMe.validate())
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        language.messageDelete,
                        style: primaryTextStyle(),
                      ).onTap(() {
                        finish(context, 2);
                      }),
                    ),
                ],
              ),
            );
          },
        );

        if (res == 1) {
          copyMessage();
        } else if (res == 2) {
          deleteMessage();
        }
      },
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.chatItemData!.isMe.validate() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment: widget.chatItemData!.isMe! ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              margin: widget.chatItemData!.isMe.validate()
                  ? EdgeInsets.only(top: 0.0, bottom: 0.0, left: isRTL ? 0 : context.width() * 0.25, right: 8)
                  : EdgeInsets.only(top: 2.0, bottom: 2.0, left: 8, right: isRTL ? 0 : context.width() * 0.25),
              padding: customPadding(widget.chatItemData!.messageType),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: gray, blurRadius: 0.1, spreadRadius: 0.2), //BoxShadow
                ],
                color: widget.chatItemData!.isMe.validate() ? primaryColor : context.cardColor,
                borderRadius: widget.chatItemData!.isMe.validate() ? radiusOnly(bottomLeft: 12, topLeft: 12, bottomRight: 0, topRight: 12) : radiusOnly(bottomLeft: 0, topLeft: 12, bottomRight: 12, topRight: 12),
              ),
              child: chatItem(widget.chatItemData!.messageType ?? ""),
            ),
          ],
        ),
        margin: EdgeInsets.only(top: 2, bottom: 2),
      ),
    );
  }

  List<Widget> filesComponent() {
    return widget.chatItemData != null && widget.chatItemData!.attachmentfiles.validate().isNotEmpty
        ? [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.chatItemData!.attachmentfiles.validate().map((file) {
                  // int index = _eventFiles.indexOf(eventFile);
                  return GestureDetector(
                    onTap: () {
                      if (file.contains(RegExp(r'\.jpeg|\.jpg|\.gif|\.png|\.bmp'))) {
                        ViewSingleImg(url: file).launch(context);
                      } else {
                        viewFiles(file);
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Loader(),
                        ),
                        file.contains(RegExp(r'\.jpeg|\.jpg|\.gif|\.png|\.bmp'))
                            ? CachedImageWidget(
                                url: file,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                radius: 8,
                              )
                            : Container(
                                padding: EdgeInsets.all(4),
                                decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt(), backgroundColor: widget.chatItemData!.isMe.validate() ? context.cardColor : lightPrimaryColor),
                                child: CommonPdfPlaceHolder(
                                  text: "${file.getChatFileName}",
                                  fileExt: file.getFileExtension,
                                ),
                              ),
                      ],
                    ).paddingRight(8),
                  );
                }).toList(),
              ),
            ),
          ]
        : [];
  }
}
