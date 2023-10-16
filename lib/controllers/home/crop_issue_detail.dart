import 'dart:io';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/home/crop_issue_detail_api.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_issue_detail_deficiency.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_issue_detail_fertigation.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_issue_detail_fertigation_program.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_issue_detail_weed.dart';
import 'package:behn_meyer_flutter/models/page_argument/page_arguments.dart';
import 'package:behn_meyer_flutter/models/page_argument/photo_view_multiple_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/photo_view_single_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/web_browser_argument.dart';
import 'package:behn_meyer_flutter/models/product/product_item.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class CropIssueDetail extends StatefulWidget {
  final int issueId;
  final String issueType;

  CropIssueDetail({Key key, this.issueId, this.issueType}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CropIssueDetail();
  }
}

class _CropIssueDetail extends State<CropIssueDetail> {
  final controller = PageController();
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'deviceVersion': data.systemVersion,
      'model': data.model,
      'isPhysicalDevice': data.isPhysicalDevice,
      'uuid': data.identifierForVendor
    };
  }

  Future<Response> fetchIssueDetail(BuildContext ctx) {
    CropIssueDetailApi cropIssueDetailApi = CropIssueDetailApi(ctx);
    return cropIssueDetailApi.call(widget.issueId);
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_crop_issue_detail);
    Util.printInfo("***** IssueId: ${widget.issueId} *****");
    Util.printInfo("***** IssueType: ${widget.issueType} *****");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: fetchIssueDetail(context),
        builder: (BuildContext context, AsyncSnapshot<Response> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: showIssueTypeWidget(context, snapshot.data),
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
            return Center(
              child: Text('Something went wrong...'),
            );
          }

          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget showIssueTypeWidget(BuildContext context, Response responseData) {
    if (widget.issueType == Constants.ISSUE_TYPE_DEFICIENCY) {
      return deficiencyDetail(
          context, CropIssueDeficiencyDetailDTO.fromJson(responseData.data));
    } else if (widget.issueType == Constants.ISSUE_TYPE_FERTIGATION) {
      return fertigationDetail(
          context, CropIssueFertigationDetailDTO.fromJson(responseData.data));
    } else if (widget.issueType == Constants.ISSUE_TYPE_PEST_DISEASE_WEED) {
      return weedsDetail(
          context, CropIssueWeedsDetailDTO.fromJson(responseData.data));
    } else {
      return Container();
    }
  }

  Widget deficiencyDetail(
      BuildContext context, CropIssueDeficiencyDetailDTO deficiencyDetailDTO) {
    if (deficiencyDetailDTO != null) {
      return ListView(
        children: [
          issuePhotos(context, deficiencyDetailDTO.images),
          issueDescription(
              deficiencyDetailDTO.name, deficiencyDetailDTO.description),
          solution(context, deficiencyDetailDTO.products),
          askForCropDoctor(
              context,
              deficiencyDetailDTO.supportEmail,
              deficiencyDetailDTO.category != null
                  ? deficiencyDetailDTO.category.name
                  : "",
              deficiencyDetailDTO.name,
              Util.getTranslated(
                  context, "crop_issue_type_deficiency_lowercase")),
        ],
      );
    }

    return Container();
  }

  Widget fertigationDetail(BuildContext context,
      CropIssueFertigationDetailDTO fertigationDetailDTO) {
    if (fertigationDetailDTO != null) {
      return ListView(
        children: [
          issuePhotos(context, fertigationDetailDTO.images),
          issueDescription(
              fertigationDetailDTO.name, fertigationDetailDTO.description),
          cropPrograms(fertigationDetailDTO.programs),
          productRecommendation(context, fertigationDetailDTO.products),
          askForCropDoctor(
              context,
              fertigationDetailDTO.supportEmail,
              fertigationDetailDTO.category != null
                  ? fertigationDetailDTO.category.name
                  : "",
              fertigationDetailDTO.name,
              Util.getTranslated(
                  context, "crop_issue_type_fertigation_lowercase")),
        ],
      );
    }

    return Container();
  }

  Widget weedsDetail(
      BuildContext context, CropIssueWeedsDetailDTO weedsDetailDTO) {
    if (weedsDetailDTO != null) {
      return ListView(
        children: [
          issuePhotos(context, weedsDetailDTO.images),
          issueDescription(weedsDetailDTO.name, weedsDetailDTO.description),
          pestDiseaseWeedSolution(weedsDetailDTO.solution),
          usefulInformation(
              weedsDetailDTO.usefulInfo, weedsDetailDTO.usefulInfoLinks),
          askForCropDoctor(
              context,
              weedsDetailDTO.supportEmail,
              weedsDetailDTO.category != null
                  ? weedsDetailDTO.category.name
                  : "",
              weedsDetailDTO.name,
              Util.getTranslated(context, "crop_issue_type_weed_lowercase")),
        ],
      );
    }

    return Container();
  }

  Widget issuePhotos(BuildContext context, List<String> images) {
    return AspectRatio(
      aspectRatio: 2 / 1,
      child: Container(
        child: Stack(
          children: [
            imageViewPager(context, images),
            backButton(context),
            viewPagerIndicator(images),
          ],
        ),
      ),
    );
  }

  Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 20, left: 10),
        child: InkWell(
          child: Image.asset(
            Constants.ASSET_IMAGES + "black_back_icon.png",
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

  Widget imageViewPager(BuildContext context, List<String> images) {
    return PageView.builder(
      controller: controller,
      itemCount: images.length,
      itemBuilder: (contex, index) =>
          imageViewPagerItem(context, images[index], images, index),
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

  Widget viewPagerIndicator(List<String> images) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 20, bottom: 20),
        child: SmoothPageIndicator(
          controller: controller,
          count: images.length,
          effect: ExpandingDotsEffect(
            dotWidth: 10,
            dotHeight: 10,
            expansionFactor: 3,
            dotColor: AppColor.appViewPagerIndicatorUnselectedColor(),
            activeDotColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget labelText(
      String labelName, TextStyle labelTextStyle, EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: Text(
        labelName,
        style: labelTextStyle,
      ),
    );
  }

  Widget sectionTitle(String sectionTitle, TextStyle sectionTextStyle,
      EdgeInsetsGeometry padding) {
    return Container(
      width: double.infinity,
      color: AppColor.appSectionBlueColor(),
      child: labelText(sectionTitle, sectionTextStyle, padding),
    );
  }

  Widget issueDescription(String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        labelText(
          title,
          AppFont.bold(
            24,
            color: AppColor.appBlack(),
            decoration: TextDecoration.none,
          ),
          EdgeInsets.only(
            left: 16,
            right: 16,
          ),
        ),
        labelText(
          description,
          AppFont.medium(
            14,
            color: AppColor.appBlack(),
            decoration: TextDecoration.none,
          ),
          EdgeInsets.only(
            left: 16,
            top: 20,
            right: 16,
          ),
        ),
      ],
    );
  }

  Widget productItem(BuildContext context, ProductItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.productDetailsRoute,
            arguments: PageArguments(item.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColor.appLightGreyColor(),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: DisplayImage(
                      item.imageUrl,
                      'placeholder_3.png',
                      width: double.infinity,
                      height: double.infinity,
                      boxFit: BoxFit.cover,
                    ),
                  )
                  // child: FadeInImage.assetNetwork(
                  //   placeholder: Constants.ASSET_IMAGES + 'image_placeholder.png',
                  //   image: productDTO.image,
                  //   width: double.infinity,
                  //   height: double.infinity,
                  //   fit: BoxFit.cover,
                  // ),
                  ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
                child: Center(
                  child: Text(
                    item.name,
                    maxLines: 2,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.bold(
                      14,
                      color: AppColor.appBlack200(),
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cropProgramItem(CropIssueFertigationProgramDTO programDTO) {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          labelText(
            programDTO.title,
            AppFont.bold(
              16,
              color: AppColor.appBlack(),
              decoration: TextDecoration.none,
            ),
            EdgeInsets.zero,
          ),
          if (programDTO.content != null && programDTO.content.length > 0)
            labelText(
              programDTO.content,
              AppFont.regular(
                14,
                color: AppColor.appBlack(),
                decoration: TextDecoration.none,
              ),
              EdgeInsets.only(top: 16.0, bottom: 16.0),
            ),
          if (programDTO.image != null && programDTO.image.length > 0)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, MyRoute.photoViewSingleRoute,
                    arguments: PhotoViewSingleArgument(programDTO.image));
              },
              child: Center(
                child: DisplayImage(
                  programDTO.image,
                  'placeholder_3.png',
                  boxFit: BoxFit.cover,
                ),
                // child: FadeInImage.assetNetwork(
                //   placeholder: Constants.ASSET_IMAGES + 'image_placeholder.png',
                //   image: programDTO.image,
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
        ],
      ),
    );
  }

  Widget usefulInfoLink(BuildContext context, List<String> usefulInfoLinks) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: usefulInfoLinks
          .asMap()
          .map((key, value) =>
              MapEntry(key, usefulInfoLinkItem(context, key, value)))
          .values
          .toList(),
    );
  }

  Widget usefulInfoLinkItem(BuildContext context, int index, String link) {
    if (link != null && link.length > 0) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, MyRoute.webBrowserRoute,
              arguments: WebBrowserArgument(link));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelText(
              "${Util.getTranslated(context, "crop_issue_detail_weed_link_text")} $index",
              AppFont.bold(
                14,
                color: AppColor.appBlack(),
                decoration: TextDecoration.none,
              ),
              EdgeInsets.only(
                bottom: 10.0,
                left: 16.0,
                right: 16.0,
              ),
            ),
            labelText(
              link,
              AppFont.semibold(
                14,
                color: AppColor.appBlue(),
                decoration: TextDecoration.underline,
              ),
              EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            ),
          ],
        ),
      );
    }

    return Container();
  }

  Widget solution(BuildContext context, List<ProductItem> productList) {
    if (productList != null && productList.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          sectionTitle(
            Util.getTranslated(
                context, "crop_issue_detail_deficiency_solution"),
            AppFont.bold(
              12,
              color: AppColor.appBlue(),
              decoration: TextDecoration.none,
            ),
            EdgeInsets.all(16.0),
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: productList.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                crossAxisCount: 2,
                childAspectRatio: 1 / 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                return productItem(context, productList[index]);
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      );
    }
    return SizedBox(height: 20);
  }

  Widget cropPrograms(List<CropIssueFertigationProgramDTO> programsList) {
    if (programsList != null && programsList.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          sectionTitle(
            Util.getTranslated(
                context, "crop_issue_detail_fertigation_crop_program"),
            AppFont.bold(
              12,
              color: AppColor.appBlue(),
              decoration: TextDecoration.none,
            ),
            EdgeInsets.all(16.0),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                programsList.map((item) => cropProgramItem(item)).toList(),
          ),
        ],
      );
    }

    return SizedBox(height: 20);
  }

  Widget productRecommendation(
      BuildContext context, List<ProductItem> productList) {
    if (productList != null && productList.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          sectionTitle(
            Util.getTranslated(
                context, "crop_issue_detail_fertigation_product_recommanded"),
            AppFont.bold(
              12,
              color: AppColor.appBlue(),
              decoration: TextDecoration.none,
            ),
            EdgeInsets.all(16.0),
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: productList.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                crossAxisCount: 2,
                childAspectRatio: 1 / 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                return productItem(context, productList[index]);
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      );
    }
    return SizedBox(height: 20);
  }

  Widget pestDiseaseWeedSolution(String usefulInfo) {
    if (usefulInfo != null && usefulInfo.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          sectionTitle(
            Util.getTranslated(context, "crop_issue_detail_weed_solution"),
            AppFont.bold(
              12,
              color: AppColor.appBlue(),
              decoration: TextDecoration.none,
            ),
            EdgeInsets.all(16.0),
          ),
          labelText(
            usefulInfo,
            AppFont.regular(
              14,
              color: AppColor.appBlack(),
              decoration: TextDecoration.none,
            ),
            EdgeInsets.only(
              left: 16,
              top: 20,
              right: 16,
            ),
          ),
        ],
      );
    }
    return SizedBox(height: 20);
  }

  Widget usefulInformation(
      String usefulInfoContent, List<String> usefulInfoLinkList) {
    if (usefulInfoLinkList != null && usefulInfoLinkList.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          sectionTitle(
            Util.getTranslated(context, "crop_issue_detail_weed_useful_info"),
            AppFont.bold(
              12,
              color: AppColor.appBlue(),
              decoration: TextDecoration.none,
            ),
            EdgeInsets.all(16.0),
          ),
          labelText(
            usefulInfoContent,
            AppFont.regular(
              14,
              color: AppColor.appBlack(),
              decoration: TextDecoration.none,
            ),
            EdgeInsets.all(16.0),
          ),
          usefulInfoLink(context, usefulInfoLinkList),
          SizedBox(height: 20),
        ],
      );
    }
    return SizedBox(height: 20);
  }

  Widget askForCropDoctor(BuildContext ctx, String emailAddr, String cropType,
      String issueName, String issueType) {
    if (emailAddr != null && emailAddr.length > 0) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                callAskCropDoctor(
                    ctx, emailAddr, cropType, issueName, issueType);
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Constants.ASSET_IMAGES + 'ask_crop_doctor_icon.png',
                      width: 30,
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 5, 16, 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Util.getTranslated(ctx, 'ask_a_crop_doctor'),
                            style: AppFont.bold(
                              14,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            Util.getTranslated(ctx, 'get_a_diagosis'),
                            style: AppFont.regular(
                              12,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: AppColor.appBlue(),
                // textStyle: AppFont.bold(14, color: Colors.white),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(50.0)),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  callAskCropDoctor(BuildContext context, String emailAddr, String cropType,
      String issueName, String issueType) async {
    String emailSubject = "";
    String emailBody = "";
    String emailUrl = "";
    List<String> specialVersionList = [
      '14.4',
      '14.4.1',
      '14.4.2',
      '14.5',
      '14.5.1',
      '14.6',
      '14.7',
      '14.7.1',
      '14.8',
      '14.8.1'
    ];

    if (Platform.isIOS) {
      if (_deviceData != null) {
        if (specialVersionList
            .contains(_deviceData['deviceVersion'].toString())) {
          emailSubject = Util.getTranslated(
                  context, "ask_crop_doctor_email_subject") +
              " [${Util.getTranslated(context, "ask_crop_doctor_email_body_2")}: $cropType] [${Util.getTranslated(context, "ask_crop_doctor_email_body_3")}: $issueType ($issueName)]";
          emailBody =
              Util.getTranslated(context, "ask_crop_doctor_email_body_special");

          final Uri params = Uri(
              scheme: 'mailto',
              path: emailAddr,
              query: encodeQueryParameters(<String, String>{
                'subject': '$emailSubject',
                'body': '$emailBody'
              }));
          emailUrl = params.toString();
        } else {
          emailSubject =
              Util.getTranslated(context, "ask_crop_doctor_email_subject");
          emailBody =
              '''${Util.getTranslated(context, "ask_crop_doctor_email_body_1")}<br>
${Util.getTranslated(context, "ask_crop_doctor_email_body_2")}: $cropType\r\n${Util.getTranslated(context, "ask_crop_doctor_email_body_3")}: $issueType ($issueName)<br>
${Util.getTranslated(context, "ask_crop_doctor_email_body_4")}<br>
${Util.getTranslated(context, "ask_crop_doctor_email_body_5")}<br>
${Util.getTranslated(context, "ask_crop_doctor_email_body_6")}''';

          final Uri params = Uri(
              scheme: 'mailto',
              path: emailAddr,
              query: encodeQueryParameters(<String, String>{
                'subject': '$emailSubject',
                'body': '$emailBody'
              }));

          emailUrl =
              params.toString().replaceAll("%3Cbr%3E%0A", "%0D%0A%0D%0A");
        }
      }
    } else {
      emailSubject =
          Util.getTranslated(context, "ask_crop_doctor_email_subject");
      emailBody =
          '''${Util.getTranslated(context, "ask_crop_doctor_email_body_1")}<br>
${Util.getTranslated(context, "ask_crop_doctor_email_body_2")}: $cropType\r\n${Util.getTranslated(context, "ask_crop_doctor_email_body_3")}: $issueType ($issueName)<br>
${Util.getTranslated(context, "ask_crop_doctor_email_body_4")}<br>
${Util.getTranslated(context, "ask_crop_doctor_email_body_5")}<br>
${Util.getTranslated(context, "ask_crop_doctor_email_body_6")}''';

      final Uri params = Uri(
          scheme: 'mailto',
          path: emailAddr,
          query: encodeQueryParameters(<String, String>{
            'subject': '$emailSubject',
            'body': '$emailBody'
          }));

      emailUrl = params.toString().replaceAll("%3Cbr%3E%0A", "%0D%0A%0D%0A");
    }

//     String emailSubject =
//         Util.getTranslated(context, "ask_crop_doctor_email_subject");
//     String emailBody =
//         '''${Util.getTranslated(context, "ask_crop_doctor_email_body_1")}<br>
// ${Util.getTranslated(context, "ask_crop_doctor_email_body_2")}: $cropType\r\n${Util.getTranslated(context, "ask_crop_doctor_email_body_3")}: $issueType ($issueName)<br>
// ${Util.getTranslated(context, "ask_crop_doctor_email_body_4")}<br>
// ${Util.getTranslated(context, "ask_crop_doctor_email_body_5")}<br>
// ${Util.getTranslated(context, "ask_crop_doctor_email_body_6")}''';

//     String url = params.toString().replaceAll("%3Cbr%3E%0A", "%0D%0A%0D%0A");
//     String url = "mailto:$emailAddr?subject=$emailSubject&body=$emailBody";
    // String emailSubject =
    //     "Behn Meyer AgriCare Crop Doctor Support [Crop Type: $cropType] [Crop Issue: $issueType ($issueName)]";
    // String emailBody =
    //     "Dear Behn Meyer AgriCare Crop Doctor, (Kindly describe your crop issue and attach your crop of affected area photos to get a more detailed diagnosis and suggestion.) Thanks";
    // final Uri params = Uri(
    //     scheme: 'mailto',
    //     path: emailAddr,
    //     query: encodeQueryParameters(<String, String>{
    //       'subject': '$emailSubject',
    //       'body': '$emailBody'
    //     }));
    // String url = params.toString();
    Util.printInfo(emailUrl);
    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);
    } else {
      throw 'Could not launch $emailUrl';
    }
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // Widget showDeficiencyDetail(BuildContext context) {
  //   if (deficiencyDetailDTO != null) {
  //     return CustomScrollView(
  //       slivers: [
  //         SliverList(
  //           delegate: SliverChildListDelegate(
  //             [
  //               header(context, deficiencyDetailDTO.images),
  //               SizedBox(height: 20),
  //               labelText(
  //                 deficiencyDetailDTO.name,
  //                 AppFont.bold(
  //                   24,
  //                   color: AppColor.appBlack(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.only(
  //                   left: 16,
  //                   right: 16,
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //               labelText(
  //                 deficiencyDetailDTO.description,
  //                 AppFont.medium(
  //                   14,
  //                   color: AppColor.appBlack(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.only(
  //                   left: 16,
  //                   top: 20,
  //                   right: 16,
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //               sectionTitle(
  //                 Util.getTranslated(
  //                     context, "crop_issue_detail_deficiency_solution"),
  //                 AppFont.bold(
  //                   12,
  //                   color: AppColor.appBlue(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.all(16.0),
  //               ),
  //               SizedBox(height: 20),
  //             ],
  //           ),
  //         ),
  //         SliverGrid(
  //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //             mainAxisSpacing: 20,
  //             crossAxisSpacing: 20,
  //             crossAxisCount: 2,
  //             childAspectRatio: 1 / 1,
  //           ),
  //           delegate: SliverChildListDelegate(
  //             deficiencyDetailDTO.products
  //                 .map((item) => productItem(context, item))
  //                 .toList(),
  //           ),
  //         ),
  //         SliverList(
  //           delegate: SliverChildListDelegate(
  //             [
  //               SizedBox(height: 20),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  //   return Container();
  // }

  // Widget showFertigationDetail(BuildContext context) {
  //   if (fertigationDetailDTO != null) {
  //     return CustomScrollView(
  //       slivers: [
  //         SliverList(
  //           delegate: SliverChildListDelegate(
  //             [
  //               header(context, fertigationDetailDTO.images),
  //               SizedBox(height: 20),
  //               labelText(
  //                 fertigationDetailDTO.name,
  //                 AppFont.bold(
  //                   24,
  //                   color: AppColor.appBlack(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.only(
  //                   left: 16,
  //                   right: 16,
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //               labelText(
  //                 fertigationDetailDTO.description,
  //                 AppFont.medium(
  //                   14,
  //                   color: AppColor.appBlack(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.only(
  //                   left: 16,
  //                   top: 20,
  //                   right: 16,
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //               sectionTitle(
  //                 Util.getTranslated(
  //                     context, "crop_issue_detail_fertigation_crop_program"),
  //                 AppFont.bold(
  //                   12,
  //                   color: AppColor.appBlue(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.all(16.0),
  //               ),
  //             ],
  //           ),
  //         ),
  //         SliverList(
  //           delegate: SliverChildListDelegate(
  //             fertigationDetailDTO.programs
  //                 .map((item) => cropProgramItem(item))
  //                 .toList(),
  //           ),
  //         ),
  //         SliverList(
  //           delegate: SliverChildListDelegate(
  //             [
  //               SizedBox(height: 20),
  //               sectionTitle(
  //                 Util.getTranslated(context,
  //                     "crop_issue_detail_fertigation_product_recommanded"),
  //                 AppFont.bold(
  //                   12,
  //                   color: AppColor.appBlue(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.all(16.0),
  //               ),
  //               SizedBox(height: 20),
  //             ],
  //           ),
  //         ),
  //         SliverGrid(
  //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //             mainAxisSpacing: 20,
  //             crossAxisCount: 2,
  //             childAspectRatio: 1 / 1,
  //           ),
  //           delegate: SliverChildListDelegate(
  //             fertigationDetailDTO.products
  //                 .map((item) => productItem(context, item))
  //                 .toList(),
  //           ),
  //         ),
  //         SliverList(
  //           delegate: SliverChildListDelegate(
  //             [
  //               SizedBox(height: 20),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  //   return Container();
  // }

  // Widget showWeedsDetail(BuildContext context) {
  //   if (weedsDetailDTO != null) {
  //     return CustomScrollView(
  //       slivers: [
  //         SliverList(
  //           delegate: SliverChildListDelegate(
  //             [
  //               header(context, weedsDetailDTO.images),
  //               SizedBox(height: 20),
  //               labelText(
  //                 weedsDetailDTO.name,
  //                 AppFont.bold(
  //                   24,
  //                   color: AppColor.appBlack(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.only(
  //                   left: 16,
  //                   right: 16,
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //               labelText(
  //                 weedsDetailDTO.description,
  //                 AppFont.medium(
  //                   14,
  //                   color: AppColor.appBlack(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.only(
  //                   left: 16,
  //                   top: 20,
  //                   right: 16,
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //               sectionTitle(
  //                 Util.getTranslated(
  //                     context, "crop_issue_detail_weed_solution"),
  //                 AppFont.bold(
  //                   12,
  //                   color: AppColor.appBlue(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.all(16.0),
  //               ),
  //               labelText(
  //                 weedsDetailDTO.solution,
  //                 AppFont.regular(
  //                   14,
  //                   color: AppColor.appBlack(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.only(
  //                   left: 16,
  //                   top: 20,
  //                   right: 16,
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //               sectionTitle(
  //                 Util.getTranslated(
  //                     context, "crop_issue_detail_weed_useful_info"),
  //                 AppFont.bold(
  //                   12,
  //                   color: AppColor.appBlue(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.all(16.0),
  //               ),
  //               labelText(
  //                 weedsDetailDTO.usefulInfo,
  //                 AppFont.regular(
  //                   14,
  //                   color: AppColor.appBlack(),
  //                   decoration: TextDecoration.none,
  //                 ),
  //                 EdgeInsets.all(16.0),
  //               ),
  //               usefulInfoLink(context, weedsDetailDTO.usefulInfoLinks),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  //   return Container();
  // }
}
