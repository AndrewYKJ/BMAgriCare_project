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
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class CropCategoryQuestionSelection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CropCategoryQuestionSelection();
  }
}

class _CropCategoryQuestionSelection
    extends State<CropCategoryQuestionSelection> {
  int checkedIndex = -1;
  int cropCategoryId = -1;
  bool isChecked = false;
  Future<List<dynamic>> futureCropCategoryList;

  Future<List<dynamic>> fetchCropCategory(BuildContext ctx) {
    CropCategoryApi cropCategoryApi = CropCategoryApi(ctx);
    return cropCategoryApi.call(true);
  }

  Future<void> _getData() async {
    setState(() {
      checkedIndex = -1;
      cropCategoryId = -1;
      futureCropCategoryList = fetchCropCategory(context);
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(
        screenName: Constants.analytics_crop_item_list_selection);
    futureCropCategoryList = fetchCropCategory(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          child: closeButton(context),
        ),
        body: FutureBuilder(
          future: futureCropCategoryList,
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
                    child: Column(
                      children: [
                        Expanded(
                          child: cropCategoryList(context, snapshot.data),
                        ),
                        SizedBox(height: 10),
                        startButton(context),
                        SizedBox(height: 10),
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
                        header(),
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
                  header(),
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

  Widget labelText(String labelName, TextStyle labelTextStyle) {
    return Text(
      labelName,
      style: labelTextStyle,
    );
  }

  Widget header() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        labelText(
          Util.getTranslated(
              context, "crop_deficiency_issue_category_selection_title"),
          AppFont.bold(
            24,
            color: AppColor.appBlue(),
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 20),
        labelText(
          Util.getTranslated(
              context, "crop_deficiency_issue_category_selection_desc"),
          AppFont.regular(
            14,
            color: AppColor.appDarkGreyColor(),
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget cropCategoryList(
      BuildContext context, List<dynamic> cropCategoryList) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        header(),
        GridView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: cropCategoryList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            crossAxisCount: 2,
            childAspectRatio: 1 / 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            return cropCategoryItem(
                index, CropCategoryDTO.fromJson(cropCategoryList[index]));
          },
        ),
      ],
    );
  }

  Widget cropCategoryItem(int index, CropCategoryDTO cropCategoryDTO) {
    bool checked = index == checkedIndex;
    return InkWell(
      onTap: () {
        setState(() {
          checkedIndex = index;
          isChecked = true;
          cropCategoryId = cropCategoryDTO.id;
        });
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
                //   image: cropCategoryDTO.image,
                //   width: double.infinity,
                //   height: double.infinity,
                //   fit: BoxFit.cover,
                // ),
                DisplayImage(
                  cropCategoryDTO.image,
                  'placeholder_1.png',
                  width: double.infinity,
                  height: double.infinity,
                  boxFit: BoxFit.cover,
                ),
                Container(
                  color: checked
                      ? AppColor.appGreen().withOpacity(0.8)
                      : Colors.black.withOpacity(0.3),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        cropCategoryDTO.name,
                        style: AppFont.bold(
                          18,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: checked
                      ? Positioned(
                          top: 10,
                          right: 10,
                          child: Image.asset(
                            Constants.ASSET_IMAGES +
                                "white_select_tick_icon.png",
                            width: 20,
                            height: 20,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget startButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        onPressed: () {
          if (isChecked) {
            Navigator.pushNamed(context, MyRoute.cropQuestionListRoute,
                arguments: PageArguments(cropCategoryId));
          }
        },
        color: isChecked ? AppColor.appBlue() : AppColor.appAirForceBlue(),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Text(
            Util.getTranslated(context, "start_btn"),
            style: AppFont.bold(
              16,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
