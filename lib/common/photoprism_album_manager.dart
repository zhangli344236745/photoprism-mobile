import 'dart:convert';

import 'package:photoprism/api/albums.dart';
import 'package:photoprism/api/api.dart';
import 'package:photoprism/api/photos.dart';
import 'package:photoprism/model/album.dart';
import 'package:photoprism/model/photo.dart';
import 'package:photoprism/model/photoprism_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoprismAlbumManager {
  PhotoprismModel photoprismModel;

  PhotoprismAlbumManager(PhotoprismModel photoprismModel) {
    this.photoprismModel = photoprismModel;
  }

  void setAlbumList(List<Album> albumList) {
    photoprismModel.albums =
        Map.fromIterable(albumList, key: (e) => e.id, value: (e) => e);
    saveAlbumListToSharedPrefs();
    photoprismModel.notifyListeners();
  }

  void setPhotoListOfAlbum(List<Photo> photoList, String albumId) {
    print("setPhotoListOfAlbum: albumId: " + albumId);
    photoprismModel.albums[albumId].photoList = photoList;
    savePhotoListToSharedPrefs('photosList' + albumId, photoList);
    photoprismModel.notifyListeners();
  }

  Future savePhotoListToSharedPrefs(key, photoList) async {
    print("savePhotoListToSharedPrefs: key: " + key);
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, json.encode(photoList));
  }

  Future saveAlbumListToSharedPrefs() async {
    print("saveAlbumListToSharedPrefs");
    var key = 'albumList';
    List<Album> albumList =
        photoprismModel.albums.entries.map((e) => e.value).toList();
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, json.encode(albumList));
  }

  void createAlbum() async {
    print("Creating new album");
    photoprismModel.photoprismLoadingScreen
        .showLoadingScreen("Creating new album..");
    var status =
        await Api.createAlbum('New album', photoprismModel.photoprismUrl);

    if (status == 0) {
      await Albums.loadAlbums(photoprismModel, photoprismModel.photoprismUrl);
      await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
      photoprismModel.photoprismMessage
          .showMessage("Album created successfully.");
    } else {
      await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
      photoprismModel.photoprismMessage.showMessage("Creating album failed.");
    }
  }

  void renameAlbum(
      String albumId, String oldAlbumName, String newAlbumName) async {
    if (oldAlbumName != newAlbumName) {
      print("Renaming album " + oldAlbumName + " to " + newAlbumName);
      photoprismModel.photoprismLoadingScreen
          .showLoadingScreen("Renaming album..");
      var status = await Api.renameAlbum(
          albumId, newAlbumName, photoprismModel.photoprismUrl);

      if (status == 0) {
        await Albums.loadAlbums(photoprismModel, photoprismModel.photoprismUrl);
        await Photos.loadPhotos(
            photoprismModel, photoprismModel.photoprismUrl, albumId);
        await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
        photoprismModel.photoprismMessage
            .showMessage("Renaming album successfully.");
      } else {
        await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
        photoprismModel.photoprismMessage.showMessage("Renaming album failed.");
      }
    } else {
      print("Renaming skipped: New and old album name identical.");
      photoprismModel.photoprismMessage
          .showMessage("Renaming skipped: New and old album name identical.");
    }
  }

  void deleteAlbum(String albumId) async {
    print("Deleting album " + albumId);
    photoprismModel.photoprismLoadingScreen
        .showLoadingScreen("Deleting album..");
    var status = await Api.deleteAlbum(albumId, photoprismModel.photoprismUrl);

    if (status == 0) {
      await Albums.loadAlbums(photoprismModel, photoprismModel.photoprismUrl);
      await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
      photoprismModel.photoprismMessage
          .showMessage("Album deleted successfully.");
    } else {
      await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
      photoprismModel.photoprismMessage.showMessage("Deleting album failed.");
    }
  }

  void addPhotosToAlbum(albumId, List<String> photoUUIDs) async {
    print("Adding photos to album " + albumId);
    photoprismModel.photoprismLoadingScreen
        .showLoadingScreen("Adding photos to album..");
    var status = await Api.addPhotosToAlbum(
        albumId, photoUUIDs, photoprismModel.photoprismUrl);

    if (status == 0) {
      await Albums.loadAlbums(photoprismModel, photoprismModel.photoprismUrl);
      await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
      photoprismModel.photoprismMessage
          .showMessage("Adding photos to album successfull.");
    } else {
      await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
      photoprismModel.photoprismMessage
          .showMessage("Adding photos to album failed.");
    }
  }
}