import 'dart:io';
import 'dart:math';

import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class UploadPhotoApi extends DioRepo {
  UploadPhotoApi(BuildContext context) {
    dioContext = context;
  }

  Future<int> uploadPhoto(File file) async {
    var resizedImg = await resizeImg(file);

    try {
      FormData formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(img.encodeJpg(resizedImg), filename: 'resizedImg.jpg', contentType: MediaType.parse('image/jpeg')),
      });
      Response response = await mDio.post("upload/photo", data: formData);
      
      return response.data['id'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> downloadPhoto(String url) async {
    try {
      Dio dio = new Dio(); 
      var dir = await getApplicationDocumentsDirectory();
      int random = new Random().nextInt(1000);
      var imageDownloadPath = '${dir.path}/image-$random.jpg';
      await dio.download(url, imageDownloadPath, onReceiveProgress: (received, total) {
        var progress = (received / total) * 100;
        debugPrint('Rec: $received , Total: $total, $progress%');
      });
      print("IMAGE PATH: $imageDownloadPath");
      // downloadFile function returns path where image has been downloaded
      return imageDownloadPath;
    } catch (e) {
      throw e;
    }
  }

  Future<img.Image> resizeImg(File fImg) async {
    var image = img.decodeImage(fImg.readAsBytesSync());
    Util.printInfo("Image Ori Size: W ${image.width} || H ${image.height}");

    // final img.Image orientedImage = img.bakeOrientation(image);
    if (image.width > image.height) {
      //image is landscape
      if (image.width > 800){
        image = img.copyResize(image, width: 800);
      }
    } else if (image.height > image.width) {
      //image is portrait
      if (image.height > 800) {
        image = img.copyResize(image, width: 0, height: 800);
      }
    } else if (image.width == image.height) {
      //image is square
      if (image.width > 800) {
        image = img.copyResize(image, width: 800);
      }
    }

    Util.printInfo("Image resize Size: W ${image.width} || H ${image.height}");

    // var dir = await getApplicationDocumentsDirectory();
    // int random = new Random().nextInt(1000);
    // var imagePath = '${dir.path}/avatar-$random.jpg';
    // var newImgFile = await File(imagePath).writeAsBytes(img.encodeJpg(image));
    return image;
  }
}