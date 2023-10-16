import 'dart:convert';
import 'dart:io';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/home/crop_question_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_question.dart';
import 'package:behn_meyer_flutter/models/page_argument/crop_question_result_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/photo_view_multiple_argument.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CropQuestionList extends StatefulWidget {
  final int cropCategoryId;

  CropQuestionList({Key key, this.cropCategoryId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CropQuestionList();
  }
}

class _CropQuestionList extends State<CropQuestionList> {
  final controller = PageController();
  final imgController = PageController();
  double curPage = 0;
  List<Map<String, dynamic>> _cropQuestionIssueList = [];

  Future<List<dynamic>> fetchCropQuestions(BuildContext ctx) {
    CropQuestionApi cropQuestionApi = CropQuestionApi(ctx);
    return cropQuestionApi.call(widget.cropCategoryId);
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(
        screenName: Constants.analytics_crop_item_question_list);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            child: backButton(context),
          ),
          body: FutureBuilder(
            future: fetchCropQuestions(context),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null && snapshot.data.length > 0) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.white,
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: questionViewPager(context, snapshot.data),
                        ),
                        SizedBox(height: 10),
                        footer(snapshot.data),
                        SizedBox(height: 10),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.white,
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: backButton(context),
                  );
                }
              } else if (snapshot.hasError) {
                if (snapshot.error is DioError) {
                  DioError dioError = snapshot.error;
                  if (dioError.response != null){
                    if (dioError.response.data != null) {
                      ErrorDTO errorDTO =
                          ErrorDTO.fromJson(dioError.response.data);
                      showAlertDialog(
                          context,
                          Util.getTranslated(
                              context, "alert_dialog_title_error_text"),
                          errorDTO.message);
                    } else {
                      showAlertDialog(
                          context,
                          Util.getTranslated(
                              context, "alert_dialog_title_error_text"),
                          Util.getTranslated(
                              context, "general_alert_message_error_response_2"));
                    }
                  } else {
                    showAlertDialog(
                          context,
                          Util.getTranslated(
                              context, "alert_dialog_title_error_text"),
                          Util.getTranslated(
                              context, "general_alert_message_error_response_2"));
                  }
                } else {
                  showAlertDialog(
                      context,
                      Util.getTranslated(
                          context, "alert_dialog_title_error_text"),
                      Util.getTranslated(
                          context, "general_alert_message_error_response_2"));
                }

                return Container();
              }

              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                margin: EdgeInsets.only(left: 16, right: 16),
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      ),
      onWillPop: () async => false,
    );
  }

  Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: InkWell(
          child: Image.asset(
            Constants.ASSET_IMAGES + "grey_back_icon.png",
            width: 30,
            height: 30,
          ),
          onTap: () {
            if (controller.page != 0.0) {
              if (_cropQuestionIssueList != null &&
                  _cropQuestionIssueList.length > 0) {
                _cropQuestionIssueList.removeAt(controller.page.toInt() - 1);
              }

              controller.previousPage(
                  duration: Duration(milliseconds: 300), curve: Curves.easeOut);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget questionText(
      String text, TextStyle textStyle, EdgeInsetsGeometry margin) {
    return Container(
      margin: margin,
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }

  Widget questionViewPager(
      BuildContext context, List<dynamic> cropQuestionList) {
    return SizedBox(
      child: PageView.builder(
        controller: controller,
        itemCount: cropQuestionList.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return questionViewPagerItem(context,
              CropQuestionDTO.fromJson(cropQuestionList[index]), (index + 1));
        },
      ),
    );
  }

  Widget questionViewPagerItem(
      BuildContext context, CropQuestionDTO cropQuestionDTO, int index) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 1,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: PageView.builder(
                      controller: imgController,
                      itemCount: cropQuestionDTO.images.length,
                      itemBuilder: (contex, index) => imageViewPagerItem(
                          context,
                          cropQuestionDTO.images[index],
                          cropQuestionDTO.images,
                          index),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 20, bottom: 20),
                      child: SmoothPageIndicator(
                        controller: imgController,
                        count: cropQuestionDTO.images.length,
                        effect: ExpandingDotsEffect(
                          dotWidth: 10,
                          dotHeight: 10,
                          expansionFactor: 3,
                          dotColor:
                              AppColor.appViewPagerIndicatorUnselectedColor(),
                          activeDotColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // child: Container(
              //   child: GestureDetector(
              //     onTap: () {
              //       Navigator.pushNamed(context, MyRoute.photoViewSingleRoute,
              //           arguments:
              //               PhotoViewSingleArgument(cropQuestionDTO.image));
              //     },
              //     child: ClipRRect(
              //       borderRadius: BorderRadius.circular(10.0),
              //       child: DisplayImage(
              //         cropQuestionDTO.image,
              //         'banner_placeholder.png',
              //         width: double.infinity,
              //         height: double.infinity,
              //         boxFit: BoxFit.cover,
              //       ),
              //       // child: FadeInImage.assetNetwork(
              //       //   placeholder:
              //       //       Constants.ASSET_IMAGES + 'banner_placeholder.png',
              //       //   image: cropQuestionDTO.image,
              //       //   width: double.infinity,
              //       //   height: double.infinity,
              //       //   fit: BoxFit.cover,
              //       // ),
              //     ),
              //   ),
              // ),
            ),
            questionText(
              Util.getTranslated(context, "crop_deficiency_issue_question") +
                  " $index",
              AppFont.bold(15,
                  color: AppColor.appGreen(), decoration: TextDecoration.none),
              EdgeInsets.only(top: 20),
            ),
            questionText(
              cropQuestionDTO.title,
              AppFont.bold(20,
                  color: AppColor.appBlack(), decoration: TextDecoration.none),
              EdgeInsets.only(top: 20),
            ),
            questionText(
              cropQuestionDTO.content,
              AppFont.semibold(14,
                  color: AppColor.appBlack(), decoration: TextDecoration.none),
              EdgeInsets.only(top: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageViewPagerItem(
      BuildContext context, String imgUrl, List<String> images, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.photoViewMultipleRoute,
            arguments: PhotoViewMultipleArgument(images, index));
      },
      child: DisplayImage(
        imgUrl,
        'placeholder_3.png',
        boxFit: BoxFit.cover,
      ),
      // child: FadeInImage.assetNetwork(
      //   placeholder: Constants.ASSET_IMAGES + 'image_placeholder.png',
      //   image: imgUrl,
      //   fit: BoxFit.cover,
      // ),
    );
  }

  Widget footer(List<dynamic> cropQuestionList) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  CropQuestionDTO cropQuestionDTO = CropQuestionDTO.fromJson(
                      cropQuestionList[controller.page.toInt()]);
                  cropQuestionDTO.issue.isHaveIssue = false;
                  Util.printInfo(
                      "*** ${controller.page.toInt()} , ${_cropQuestionIssueList.length}");
                  if (controller.page.toInt() ==
                      _cropQuestionIssueList.length) {
                    _cropQuestionIssueList.insert(controller.page.toInt(),
                        cropQuestionDTO.issue.toJson());

                    if (controller.page < (cropQuestionList.length - 1)) {
                      controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    } else {
                      Navigator.pushReplacementNamed(
                          context, MyRoute.cropQuestionResultRoute,
                          arguments: CropQuestionResultArgument(
                              jsonEncode(_cropQuestionIssueList)));
                    }
                  }
                },
                child: Image.asset(
                  Constants.ASSET_IMAGES + "false_icon.png",
                  width: 60,
                  height: 60,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  CropQuestionDTO cropQuestionDTO = CropQuestionDTO.fromJson(
                      cropQuestionList[controller.page.toInt()]);
                  cropQuestionDTO.issue.isHaveIssue = true;
                  Util.printInfo(
                      "*** ${controller.page.toInt()} , ${_cropQuestionIssueList.length}");
                  if (controller.page.toInt() ==
                      _cropQuestionIssueList.length) {
                    _cropQuestionIssueList.insert(controller.page.toInt(),
                        cropQuestionDTO.issue.toJson());

                    if (controller.page < (cropQuestionList.length - 1)) {
                      controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    } else {
                      Navigator.pushReplacementNamed(
                          context, MyRoute.cropQuestionResultRoute,
                          arguments: CropQuestionResultArgument(
                              jsonEncode(_cropQuestionIssueList)));
                    }
                  }
                },
                child: Image.asset(
                  Constants.ASSET_IMAGES + "correct_icon.png",
                  width: 60,
                  height: 60,
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.only(top: 40, bottom: 10),
            child: SmoothPageIndicator(
              controller: controller,
              count: cropQuestionList.length,
              effect: ExpandingDotsEffect(
                dotWidth: 10,
                dotHeight: 10,
                expansionFactor: 3,
                dotColor: AppColor.appViewPagerIndicatorUnselectedColor(),
                activeDotColor: AppColor.appBlue(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    if (Platform.isIOS) {
      showDialog(
          barrierDismissible: false,
          builder: (context) => CupertinoAlertDialog(
                title: Text(
                  title,
                  style: AppFont.bold(
                    16,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none,
                  ),
                ),
                content: Text(
                  message,
                  style: AppFont.regular(
                    14,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none,
                  ),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                        Util.getTranslated(context, "alert_dialog_ok_text")),
                  ),
                ],
              ),
          context: context);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => new AlertDialog(
          title: new Text(
            title,
            style: AppFont.bold(
              16,
              color: AppColor.appBlack(),
              decoration: TextDecoration.none,
            ),
          ),
          content: new Text(
            message,
            style: AppFont.regular(
              14,
              color: AppColor.appBlack(),
              decoration: TextDecoration.none,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Util.getTranslated(context, "alert_dialog_ok_text")),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        ),
      );
    }
  }
}
