import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadGroupIcon(File image) async {
    try {
      Reference reference = _storage.ref().child(
          "GroupIcons/${DateTime.now().millisecondsSinceEpoch}${image.path.split("/").last}");
      UploadTask uploadTask = reference.putFile(image);
      TaskSnapshot location = await uploadTask;
      return await location.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> uploadImage(File image, String roomId) async {
    try {
      Reference reference = _storage.ref().child(
          "$roomId/images/${DateTime.now().millisecondsSinceEpoch}${image.path.split("/").last}");
      UploadTask uploadTask = reference.putFile(image);
      TaskSnapshot location = await uploadTask;
      return await location.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> uploadDocument(File doc, String roomId) async {
    try {
      Reference reference =
          _storage.ref().child("$roomId/documents/${doc.path.split("/").last}");
      UploadTask uploadTask = reference.putFile(doc);
      TaskSnapshot location = await uploadTask;
      return await location.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> uploadMusic(File music, String roomId) async {
    try {
      Reference reference =
          _storage.ref().child("$roomId/musics/${music.path.split("/").last}");
      UploadTask uploadTask = reference.putFile(music);
      TaskSnapshot location = await uploadTask;
      return await location.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> uploadVideo(File video, String roomId) async {
    try {
      Reference reference =
          _storage.ref().child("$roomId/videos/${video.path.split("/").last}");
      UploadTask uploadTask = reference.putFile(video);
      TaskSnapshot location = await uploadTask;
      return await location.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<FullMetadata> getData(String document) async {
    try {
      Reference reference = _storage.refFromURL(document);
      return await reference.getMetadata();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> downloadMedia(String document, String filePath) async {
    try {
      await _storage.refFromURL(document).writeToFile(File(filePath));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
