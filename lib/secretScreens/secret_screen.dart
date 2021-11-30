import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reminder_pro/secretScreens/upload_screen.dart';
import 'package:reminder_pro/widgets/alert_widget.dart';

String newPath = '';

class SecretScreen extends StatefulWidget {
  final String userId;
  const SecretScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SecretScreen> createState() => _SecretScreenState();
}

class _SecretScreenState extends State<SecretScreen> {
  final user = FirebaseAuth.instance.currentUser!.uid;
  int progress = 0;
  bool loading = false;
  List<File>? files;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff27466e),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        child: Icon(
          Icons.add_a_photo,
          size: 35.0,
        ),
        onPressed: () {
          selectFile();
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('images')
            .doc(widget.userId)
            .collection('files')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot> data = snapshot.data!.docs;

            return GridView(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              children: data.map((data) {
                final image = data['downloadURL'];
                return InkWell(
                  onTap: () async {
                    return await showDialog(
                        context: context,
                        builder: (context) {
                          return AppAlert(
                              title: Text('Download'),
                              content: 'download image?',
                              cancel: 'Cancel',
                              exit: 'Download',
                              onTap: () async {
                                downloadFile(image);
                                Fluttertoast.showToast(
                                    msg: 'Image saved to gallery',
                                    toastLength: Toast.LENGTH_SHORT);
                                Navigator.pop(context);
                              });
                        });
                  },
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AppAlert(
                              title: Text('Confirm Delete?'),
                              content: '',
                              cancel: 'Cancel',
                              exit: 'Delete',
                              onTap: () {
                                setState(() {
                                  final id = data.id;
                                  deleteFile(id);
                                  Navigator.pop(context);
                                });
                              });
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:Image.network(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            );
          } else {
            return (const Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }

  Future deleteFile(String id) async {
    final firestore = FirebaseFirestore.instance
        .collection('images')
        .doc(widget.userId)
        .collection('files');
    await firestore.doc(id).delete().then((value) {
      Fluttertoast.showToast(
          msg: 'Image Deleted successfully', toastLength: Toast.LENGTH_SHORT);
    });
  }

  downloadFile(String url) async {
    var status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        var appDocDir = await getTemporaryDirectory();
        String savePath = appDocDir.path + "/temp.mp4";
        await Dio().download(url, savePath);
        final result = await ImageGallerySaver.saveFile(savePath);
        return result;
      } catch (e) {
        print(e);
      }
    }
  }

  void showDownloadProgress(int received, int total) {
    setState(() {
      if (total != -1) {
        progress = received ~/ total * 100;
        print(progress);
      } else
        return;
    });
  }

  Future selectFile() async {
    try {
      var status = await Permission.storage.request();

      if (status.isDenied) {
        return showDialog(
            context: context,
            builder: (context) {
              return AppAlert(
                title: Text('Permission Denied'),
                content: 'Goto app settings?',
                cancel: 'Cancel',
                exit: 'Allow',
                onTap: () => AppSettings.openAppSettings()
                    .whenComplete(() => Navigator.pop(context)),
              );
            });
      }

      final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image);
      print(result);

      if (result != null) {
        showFile(result.files);
      } else {
        Fluttertoast.showToast(
            msg: 'No files selected', toastLength: Toast.LENGTH_SHORT);
      }
    } catch (e) {
      print(e);
    }
  }

  void showFile(List<PlatformFile> files) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => UploadScreen(
              userId: user,
              files: files,
            )));
  }
}
