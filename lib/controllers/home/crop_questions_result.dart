import 'dart:convert';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_question_issue.dart';
import 'package:behn_meyer_flutter/models/page_argument/page_arguments.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class CropQuestionsResult extends StatefulWidget {
  final String cropQuesstionResult;

  CropQuestionsResult({Key key, this.cropQuesstionResult}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CropQuestionsResult();
  }
}

class _CropQuestionsResult extends State<CropQuestionsResult> {
  List<dynamic> cropQuestionResultList = [];

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(
        screenName: Constants.analytics_crop_item_question_result);
    Util.printInfo("Result: ${widget.cropQuesstionResult}");
    var results = jsonDecode(widget.cropQuesstionResult);
    cropQuestionResultList = results != null ? List.from(results) : [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          child: closeButton(context),
        ),
        body: Container(
          color: Colors.white,
          margin: EdgeInsets.only(left: 16, right: 16),
          child: deficiencyIssueResult(),
        ),
      ),
    );
  }

  Widget closeButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: 16),
        child: InkWell(
          child: Image.asset(
            Constants.ASSET_IMAGES + "grey_close_icon.png",
            width: 30,
            height: 30,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget deficiencyIssueResult() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: cropQuestionResultList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return resultHeader(context);
        }

        index -= 1;
        return issueItem(context,
            CropQuestionIssueDTO.fromJson(cropQuestionResultList[index]));
      },
    );
  }

  Widget resultHeader(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Util.getTranslated(
              context, "crop_deficiency_issue_question_result_title"),
          style: AppFont.bold(
            24,
            color: AppColor.appBlue(),
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 10),
        Text(
          Util.getTranslated(
              context, "crop_deficiency_issue_question_result_subtitle"),
          style: AppFont.regular(
            14,
            color: AppColor.appBlack(),
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget issueItem(
      BuildContext context, CropQuestionIssueDTO cropQuestionIssueDTO) {
    if (cropQuestionIssueDTO.isHaveIssue) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, MyRoute.cropIssueDetailRoute,
              arguments: PageArguments(cropQuestionIssueDTO.id,
                  cropIssueType: cropQuestionIssueDTO.type));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: DisplayImage(
                    cropQuestionIssueDTO.image,
                    'placeholder_1.png',
                    width: 80.0,
                    height: 80.0,
                    boxFit: BoxFit.cover,
                  ),
                  // child: FadeInImage.assetNetwork(
                  //   placeholder:
                  //       Constants.ASSET_IMAGES + 'common_issue_placeholder.png',
                  //   image: cropQuestionIssueDTO.image,
                  //   height: 80,
                  //   width: 80,
                  //   fit: BoxFit.cover,
                  // ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cropQuestionIssueDTO.name,
                          maxLines: 2,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: AppFont.bold(
                            16,
                            color: AppColor.appBlack(),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          cropQuestionIssueDTO.description,
                          maxLines: 2,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: AppFont.regular(
                            14,
                            color: AppColor.appBlack(),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
                  height: 20,
                  width: 20,
                ),
              ],
            ),
            SizedBox(height: 20),
            dottedLineSeperator(
              height: 1.5,
              color: AppColor.appBlue(),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    }
    return Container();
  }
}
