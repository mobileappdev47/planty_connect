import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stacked/stacked.dart';

class VideoPickerScreenViewModel extends BaseViewModel {
  void init() {
    fetchNewVideos();
    scrollController.addListener(() async {
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent){
        double position = scrollController.position.pixels;
        if(videoList.length < totalVideos){
          await fetchNewVideos().then((value){
            Future.delayed(Duration(milliseconds: 100),(){
              scrollController.jumpTo(position + 200);
            });
          });
        }
      }
    });
  }

  int currentPage = 0;
  int lastPage;
  int totalVideos = 0;
  List<AssetEntity> videoList = [];
  ScrollController scrollController = ScrollController();

  Future<void> fetchNewVideos() async {

    lastPage = currentPage;
    setBusy(true);
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true, type: RequestType.video);

    totalVideos = albums[0].assetCount;
    List<AssetEntity> media =
        await albums[0].getAssetListPaged(currentPage, 60);

    media.forEach((element) {
      if(element.size > Offset.zero){
        videoList.add(
          AssetEntity(
              id: element.id,
              typeInt: element.typeInt,
              width: element.width,
              height: element.height),
        );
      }
    });
    currentPage++;
    setBusy(false);
    notifyListeners();
  }

  handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage > lastPage) {
        fetchNewVideos();
      }
    }
  }

}
