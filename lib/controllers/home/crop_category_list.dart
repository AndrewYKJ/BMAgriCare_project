import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/home/crop_category_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_category.dart';
import 'package:behn_meyer_flutter/models/page_argument/page_arguments.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/floating_button_scroll_to_top.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CropCategoryList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CropCategoryList();
  }
}

class _CropCategoryList extends State<CropCategoryList> {
  final scrollController = ScrollController();
  double scrollMark;
  bool isReversing = false;
  bool isScroll = false;

  Future<List<dynamic>> fetchCropCategory(BuildContext ctx) {
    CropCategoryApi cropCategoryApi = CropCategoryApi(ctx);
    return cropCategoryApi.call(false);
  }

  Future<void> _getData() async {
    setState(() {
      isScroll = false;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_crop_item_list);

    scrollController.addListener(() {
      isScroll = true;
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
        appBar: CustomAppBar(
          child: backButton(context),
        ),
        floatingActionButton:
            floatingButtonScrollToTop(scrollController, isReversing),
        body: FutureBuilder(
          future: !isScroll ? fetchCropCategory(context) : null,
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null && snapshot.data.length > 0) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  margin: EdgeInsets.only(left: 16, right: 16),
                  child: RefreshIndicator(
                    color: AppColor.appBlue(),
                    onRefresh: _getData,
                    child: ListView(
                      controller: scrollController,
                      children: [
                        labelText(
                          Util.getTranslated(context, "crop_common_issue_text"),
                          AppFont.bold(
                            24,
                            color: AppColor.appBlue(),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 20),
                        cropDeficiencyLocator(context),
                        SizedBox(height: 20),
                        cropCategory(context, snapshot.data),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  margin: EdgeInsets.only(left: 16, right: 16),
                  child: RefreshIndicator(
                    color: AppColor.appBlue(),
                    onRefresh: _getData,
                    child: ListView(
                      children: [
                        labelText(
                          Util.getTranslated(context, "crop_common_issue_text"),
                          AppFont.bold(
                            24,
                            color: AppColor.appBlue(),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 20),
                        cropDeficiencyLocator(context),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              }
            } else if (snapshot.hasError) {
              if (snapshot.error is DioError) {
                DioError dioError = snapshot.error;
                if (dioError.response != null){
                  if (dioError.response.data != null) {
                    ErrorDTO errorDTO = ErrorDTO.fromJson(dioError.response.data);
                    return Center(
                      child: Text(
                        errorDTO.message,
                        style: AppFont.regular(
                          18,
                          color: AppColor.appBlack(),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    );
                  }
                } else {
                  return Center(
                    child: Text(
                      Util.getTranslated(
                          context, "general_alert_message_error_response"),
                      style: AppFont.regular(
                        18,
                        color: AppColor.appBlack(),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  );
                }
              }
              return Center(
                child: Text(
                  Util.getTranslated(
                      context, "general_alert_message_error_response"),
                  style: AppFont.regular(
                    18,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none,
                  ),
                ),
              );
            }

            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(left: 16, right: 16),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelText(
                    Util.getTranslated(context, "crop_common_issue_text"),
                    AppFont.bold(
                      24,
                      color: AppColor.appBlue(),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 20),
                  cropDeficiencyLocator(context),
                  SizedBox(height: 20),
                  Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              ),
            );
          },
        ),
      ),
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

  Widget cropDeficiencyLocator(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.cropListSelectionRoute);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          color: AppColor.appBlue(),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: labelText(
                    Util.getTranslated(context, "crop_deficiency_locator"),
                    AppFont.bold(
                      16,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Image.asset(
                  Constants.ASSET_IMAGES + "white_right_arrow_icon.png",
                  width: 30,
                  height: 30,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget cropCategory(BuildContext context, List<dynamic> cropCategoryList) {
    if (cropCategoryList != null && cropCategoryList.length > 0) {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: cropCategoryList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          crossAxisCount: 2,
          childAspectRatio: 1 / 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          return cropCategoryItem(
              context, CropCategoryDTO.fromJson(cropCategoryList[index]));
        },
      );
    }
    return Container();
  }

  Widget cropCategoryItem(BuildContext context, CropCategoryDTO categoryDTO) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.cropIssueListRoute,
            arguments: PageArguments(categoryDTO.id));
      },
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            child: Stack(
              children: [
                // FadeInImage.assetNetwork(
                //   placeholder:
                //       Constants.ASSET_IMAGES + 'common_issue_placeholder.png',
                //   image: categoryDTO.image,
                //   width: double.infinity,
                //   height: double.infinity,
                //   fit: BoxFit.cover,
                // ),
                DisplayImage(
                  categoryDTO.image,
                  'placeholder_1.png',
                  width: double.infinity,
                  height: double.infinity,
                  boxFit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.3),
                  width: double.infinity,
                  height: double.infinity,
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      categoryDTO.name,
                      style: AppFont.bold(
                        18,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
