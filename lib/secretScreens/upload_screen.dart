import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart' as fireStorage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reminder_pro/widgets/alert_widget.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({
    Key? key,
    required this.userId,
    required this.files,
  }) : super(key: key);

  final String userId;
  final List<PlatformFile> files;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? downloadURL;
  bool isButton = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isPop = await showExit(context);
        return isPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff27466e),
          title: Text('Upload Files'),
          actions: [
            TextButton(
              onPressed: () {
                  setState(() {
                    uploadFiles(widget.files);
                  });

              },
              child: Text(
                'upload',
                style: TextStyle(
                    fontSize: 20.0,
                    color: isButton ? Colors.white : Colors.grey),
              ),
            ),
            Icon(Icons.cloud_upload)
          ],
        ),
        body: ListView.builder(
            itemCount: widget.files.length,
            itemBuilder: (context, index) {
              final files = widget.files[index];
              return buildName(files);
            }),
      ),
    );
  }

  Widget buildName(PlatformFile file) {
    return ListTile(
      leading: Icon(Icons.file_upload),
      title: Text(file.name),
      subtitle: Text(filesize(file.size.toStringAsFixed(0))),
      trailing: Text(file.extension.toString()),
    );
  }

  //     if (result != null) {
  //       setState(() {
  //        List<File> files = result.paths.map((path) => File(result.paths)).toList();
  //       });
  //     } else {
  //       setState(() {
  //         isSelectButton = true;
  //       });
  //       Fluttertoast.showToast(
  //           msg: 'No files selected', toastLength: Toast.LENGTH_SHORT);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  Future uploadFiles(List<PlatformFile> files) async {
    var fileUrl = await Future.wait(files.map((_files) => uploadFile(_files)));
    return fileUrl;
  }

  Future uploadFile(PlatformFile file) async {
    File files = File(file.path!);
    setState(() {
      isButton = false;
    });
    final firestore = FirebaseFirestore.instance
        .collection('images')
        .doc(widget.userId)
        .collection('files');
    final postID = DateTime.now().millisecondsSinceEpoch.toString();
    fireStorage.Reference ref = fireStorage.FirebaseStorage.instance
        .ref()
        .child('${widget.userId}/files')
        .child('post_$postID');
    await ref.putFile(files);

    downloadURL = await ref.getDownloadURL();

    await firestore.add({'downloadURL': downloadURL}).whenComplete(() {
      Fluttertoast.showToast(
          msg: widget.files.length == 1
              ? 'File uploaded successfully'
              : 'Files uploaded successfully',
          toastLength: Toast.LENGTH_SHORT);
    }).then((value) => Navigator.pop(context, true));;;
  }

  Future<bool?> showExit(context) async {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AppAlert(
              title: Text('Image not uploaded!'),
              content: 'Exit without upload?',
              cancel: 'Cancel',
              exit: 'Exit',
              onTap: () => Navigator.pop(context, true));
        });
  }
}
