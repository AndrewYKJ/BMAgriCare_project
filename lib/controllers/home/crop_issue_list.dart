import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/home/crop_issue_api.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_issue_list.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_issues_type.dart';
import 'package:behn_meyer_flutter/models/page_argument/page_arguments.dart';
import 'package:behn_meyer_flutter/models/page_argument/photo_view_single_argument.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:behn_meyer_flutter/widget/floating_button_scroll_to_top.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CropIssueList extends StatefulWidget {
  final int id;

  CropIssueList({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CropIssueList();
  }
}

class _CropIssueList extends State<CropIssueList> {
  final scrollController = ScrollController();
  double scrollMark;
  bool isReversing = false;

  Future<CropIssuesDTO> fetchCropIssues(BuildContext ctx) {
    CropIssueApi cropIssueApi = CropIssueApi(ctx);
    return cropIssueApi.call(widget.id);
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_crop_issue_list);
    Util.printInfo("CROP CATEGORY ID:: ${widget.id}");

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if ((scrollMark - scrollController.position.pixels) > 50.0) {
          setState(() {
            isReversing = true;
          });
        }
      } else {
        scrollMark = scrollController.position.pixels;
        setState(() {
          isReversing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton:
            floatingButtonScrollToTop(scrollController, isReversing),
        body: FutureBuilder(
          future: fetchCropIssues(context),
          builder:
              (BuildContext context, AsyncSnapshot<CropIssuesDTO> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: ListView(
                    controller: scrollController,
                    children: [
                      header(context, snapshot.data),
                      getDeficiencyWidget(context, snapshot.data),
                      getFertigationsWidget(context, snapshot.data),
                      getWeedsWidget(context, snapshot.data),
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
      ),
    );
  }

  Widget header(BuildContext context, CropIssuesDTO cropIssuesDTO) {
    if (cropIssuesDTO.category != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 1,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, MyRoute.photoViewSingleRoute,
                          arguments: PhotoViewSingleArgument(
                              cropIssuesDTO.category.image));
                    },
                    child: DisplayImage(
                      cropIssuesDTO.category.image,
                      'placeholder_3.png',
                      width: double.infinity,
                      boxFit: BoxFit.cover,
                    ),
                    // child: FadeInImage.assetNetwork(
                    //   placeholder:
                    //       Constants.ASSET_IMAGES + 'image_placeholder.png',
                    //   image: cropIssuesDTO.category.image,
                    //   width: double.infinity,
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                  backButton(context),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: labelText(
              cropIssuesDTO.category.name,
              AppFont.bold(
                24,
                color: AppColor.appBlack(),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 20, left: 16),
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

  Widget labelText(String labelName, TextStyle labelTextStyle) {
    return Text(
      labelName,
      style: labelTextStyle,
    );
  }

  Widget issueTypeLabel(String labelName, TextStyle labelTextStyle) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
      child: Text(
        labelName,
        style: labelTextStyle,
      ),
    );
  }

  Widget issueItem(BuildContext context, CropIssuesTypeDTO cropIssuesTypeDTO) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.cropIssueDetailRoute,
            arguments: PageArguments(cropIssuesTypeDTO.id,
                cropIssueType: cropIssuesTypeDTO.type));
      },
      child: Container(
        margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
        color: Colors.white,
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
                    cropIssuesTypeDTO.image,
                    'placeholder_1.png',
                    width: 80.0,
                    height: 80.0,
                    boxFit: BoxFit.cover,
                  ),
                  // child: FadeInImage.assetNetwork(
                  //   placeholder:
                  //       Constants.ASSET_IMAGES + 'common_issue_placeholder.png',
                  //   image: cropIssuesTypeDTO.image,
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
                          cropIssuesTypeDTO.name,
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
                          cropIssuesTypeDTO.description,
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
          ],
        ),
      ),
    );
  }

  Widget getDeficiencyWidget(
      BuildContext context, CropIssuesDTO cropIssuesDTO) {
    if (cropIssuesDTO.deficiencies != null &&
        cropIssuesDTO.deficiencies.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          issueTypeLabel(
            Util.getTranslated(context, "crop_issue_type_deficiency"),
            AppFont.bold(
              12,
              color: AppColor.appBlue(),
              decoration: TextDecoration.none,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cropIssuesDTO.deficiencies
                .map((item) => issueItem(context, item))
                .toList(),
          )
        ],
      );
    }

    return Container();
  }

  Widget getFertigationsWidget(
      BuildContext context, CropIssuesDTO cropIssuesDTO) {
    if (cropIssuesDTO.fertigations != null &&
        cropIssuesDTO.fertigations.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          issueTypeLabel(
            Util.getTranslated(context, "crop_issue_type_fertigation"),
            AppFont.bold(
              12,
              color: AppColor.appBlue(),
              decoration: TextDecoration.none,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cropIssuesDTO.fertigations
                .map((item) => issueItem(context, item))
                .toList(),
          ),
        ],
      );
    }
    return Container();
  }

  Widget getWeedsWidget(BuildContext context, CropIssuesDTO cropIssuesDTO) {
    if (cropIssuesDTO.weeds != null && cropIssuesDTO.weeds.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          issueTypeLabel(
            Util.getTranslated(context, "crop_issue_type_weed"),
            AppFont.bold(
              12,
              color: AppColor.appBlue(),
              decoration: TextDecoration.none,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cropIssuesDTO.weeds
                .map((item) => issueItem(context, item))
                .toList(),
          ),
        ],
      );
    }

    return Container();
  }
}
