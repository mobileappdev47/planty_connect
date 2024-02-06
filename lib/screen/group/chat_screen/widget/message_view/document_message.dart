import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:open_file/open_file.dart';

class DocumentMessage extends StatefulWidget {
  final MessageModel message;
  final Function(String, String) downloadDocument;
  final bool sender;
  final bool selectionMode;

  DocumentMessage(
    this.message,
    this.downloadDocument,
    this.sender,
    this.selectionMode,
  );

  @override
  _DocumentMessageState createState() => _DocumentMessageState();
}

class _DocumentMessageState extends State<DocumentMessage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          widget.sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        widget.sender
            ? Container()
            : Container(
                constraints: BoxConstraints(
                  maxWidth: Get.width / 3,
                  minWidth: Get.width / 4,
                ),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.message.senderName ?? "Unknown",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle(
                    color: ColorRes.black,
                    weight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
        Container(
          decoration: BoxDecoration(
            color: ColorRes.green,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.only(
            left: widget.sender ? 10 : 0,
            right: widget.sender ? 0 : 10,
            bottom: 10,
          ),
          height: 70,
          child: FutureBuilder<FullMetadata>(
            future: storageService.getData(widget.message.content),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                FullMetadata document = snapshot.data;
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: FutureBuilder<bool>(
                        future: widget.sender
                            ? checkForSenderExist(
                                document.name, widget.message.type)
                            : checkForExist(document.name, widget.message.type),
                        builder: (_, snapshot) {
                          if (snapshot.hasData) {
                            return InkWell(
                              onTap: widget.selectionMode
                                  ? null
                                  : () async {
                                      if (snapshot.data) {
                                        String filePath;
                                        if (widget.sender) {
                                          filePath = await getUploadPath(
                                              document.name,
                                              widget.message.type);
                                        } else {
                                          filePath = await getDownloadPath(
                                              document.name,
                                              widget.message.type);
                                        }
                                        if (filePath != null) {
                                          OpenResult openRes =
                                              await OpenFile.open(filePath);
                                          if (openRes.type != ResultType.done) {
                                            showErrorToast(openRes.message,
                                                title: "Opps!");
                                          }
                                        }
                                      } else {
                                        setState(() {
                                          widget.message.isDownloading = true;
                                        });
                                        await widget.downloadDocument.call(
                                            widget.message.content,
                                            widget.sender
                                                ? await getUploadPath(
                                                    document.name,
                                                    widget.message.type,
                                                  )
                                                : await getDownloadPath(
                                                    document.name,
                                                    widget.message.type,
                                                  ));
                                        setState(() {
                                          widget.message.isDownloading = false;
                                        });
                                      }
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ColorRes.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    topLeft: Radius.circular(8),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        document.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyle(
                                          fontSize: 14,
                                          color: ColorRes.black,
                                        ),
                                      ),
                                    ),
                                    snapshot.data
                                        ? Container()
                                        : widget.message.isDownloading
                                            ? Container(
                                                height: 25.h,
                                                width: 25.h,
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : Icon(
                                                Icons.download_rounded,
                                                size: 25.h,
                                              )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return SizedBox(height: 30);
                          }
                        },
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${typeEmoji(widget.message.type)} ${convertSize(document.size)}",
                            style: AppTextStyle(
                              color: ColorRes.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            hFormat(DateTime.fromMillisecondsSinceEpoch(
                                widget.message.sendTime)),
                            style: AppTextStyle(
                              color: ColorRes.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    )
                  ],
                );
              } else {
                return SizedBox(height: 30);
              }
            },
          ),
          width: 220.h,
        ),
      ],
    );
  }

  // ignore: missing_return
  String typeEmoji(String type) {
    switch (type) {
      case "photo":
        return "📷";
        break;
      case "document":
        return "📄";
        break;
      case "music":
        return "🎵";
        break;
      case "video":
        return "🎥";
        break;
    }
  }
}
