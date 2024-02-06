import 'dart:io';

import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:planty_connect/utils/color_res.dart';

class VideoController extends GetxController{

  RxList<AssetEntity> selectedVideoList = RxList<AssetEntity>();

  onVideoSelect(AssetEntity assetEntity){
    if(selectedVideoList.contains(assetEntity)){
      selectedVideoList.remove(assetEntity);
    }else{
      if(selectedVideoList.length < 10){
        selectedVideoList.add(assetEntity);
      }else{
        Get.snackbar("Alert!", "You can't upload more than 10 videos ",backgroundColor: ColorRes.red.withOpacity(0.5));
      }
    }
  }

  void onSend(){
    List<File> fileList = [];
    selectedVideoList.forEach((element) async {
      await element.file.then((file){
        fileList.add(file);
        if(element == selectedVideoList.last){
          Get.back(result: fileList);
        }
      });

    });
  }
}