import 'dart:io';

import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

class SignUpMobileApi extends DioRepo {
  SignUpMobileApi(BuildContext context) {
    dioContext = context;
  }

  Future<void> signUp(
      String name,
      File photo,
      String password,
      bool agreeMarketingUpdate,
      String otpCode,
      String phoneNo,
      String countryCode,
      {String area,
      String referralCode}) async {
    var resizedImg = await resizeImg(photo);

    var params = {
      'mobileNo': phoneNo,
      "password": password,
      "name": name,
      "photo": MultipartFile.fromBytes(img.encodeJpg(resizedImg),
          filename: 'resizedImg.jpg',
          contentType: MediaType.parse('image/jpeg')),
      "agreeMarketingUpdate": agreeMarketingUpdate,
      "otp": otpCode,
      "country": countryCode,
    };

    if (area != null && area.length > 0) {
      params['area'] = area;
    }

    if (referralCode != null && referralCode.length > 0) {
      params['referralCode'] = referralCode;
    }

    Util.printInfo(">>>>>>>> Mobile SignUp: " + params.toString());

    try {
      Response response =
          await mDio.post("register/mobile", data: FormData.fromMap(params));
      if (response.statusCode == 200) {
        Util.printInfo('SIGN UP SUCCESS');
      }
      return;
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
      if (image.width > 800) {
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
