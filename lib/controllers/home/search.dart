import 'dart:io';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/home/search_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/home/search_model.dart';
import 'package:behn_meyer_flutter/models/page_argument/page_arguments.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class HomeSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeSearch();
  }
}

class _HomeSearch extends State<HomeSearch> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mySearchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int resultCount = 10;
  int pageNo = 1;
  int pageSize = 20;
  List<SearchDTO> cropIssueTypeList = [];
  bool isLoading = false;
  bool noMoreData = false;

  Future<void> _getData() async {
    setState(() {
      isLoading = true;
      pageNo = 1;
      noMoreData = false;
      cropIssueTypeList.clear();
      _callSearch(_scaffoldKey.currentContext);
    });
  }

  void _callSearch(BuildContext ctx) {
    SearchApi searchApi = SearchApi(ctx);
    searchApi
        .search(mySearchController.text, pageNo, pageSize)
        .then((response) {
      if (response.statusCode == HttpStatus.ok) {
        if (response.data != null) {
          List<dynamic> resultList = response.data;
          if (resultList.length == 0 || resultList.length < pageSize) {
            noMoreData = true;
          }
          if (resultList != null && resultList.length > 0) {
            resultList
                .map((data) => SearchDTO.fromJson(data))
                .forEach((element) {
              cropIssueTypeList.add(element);
            });

            pageNo++;
          }
        } else {
          noMoreData = true;
        }
      }
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      if (error is DioError) {
        if (error.response != null) {
          if (error.response.data != null){
            Util.showAlertDialog(
              _scaffoldKey.currentContext,
              Util.getTranslated(context, "alert_dialog_title_error_text"),
              ErrorDTO.fromJson(error.response.data).message +
                  "(${ErrorDTO.fromJson(error.response.data).code})");
          } else {
            Util.showAlertDialog(
              _scaffoldKey.currentContext,
              Util.getTranslated(context, "alert_dialog_title_error_text"),
              Util.getTranslated(
                  context, 'general_alert_message_error_response'));
          }
        } else {
          Util.showAlertDialog(
            _scaffoldKey.currentContext,
            Util.getTranslated(context, "alert_dialog_title_error_text"),
            Util.getTranslated(
                context, 'general_alert_message_error_response'));
        }
      } else {
        Util.showAlertDialog(
                  _scaffoldKey.currentContext,
                  Util.getTranslated(context, "alert_dialog_title_error_text"),
                  Util.getTranslated(
                      context, 'general_alert_message_error_response_2'));
      }
    });
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      print("##### Scroll reach bottom #####");
      if (noMoreData || cropIssueTypeList.length < pageSize) {
        return;
      }

      _callSearch(_scaffoldKey.currentContext);
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_home_search);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    mySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
          child: backButton(context),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            margin: EdgeInsets.only(left: 16, right: 16),
            child: searchResultListItem(),
          ),
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

  Widget searchWrapper(BuildContext ctx) {
    return TextField(
      controller: mySearchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        Util.printInfo("******* Search Value: $value");
        setState(() {
          isLoading = true;
          pageNo = 1;
          noMoreData = false;
          cropIssueTypeList.clear();
          _callSearch(ctx);
        });
      },
      style: AppFont.regular(
        24,
        color: AppColor.appBlack(),
        decoration: TextDecoration.none,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        icon: Image.asset(
          Constants.ASSET_IMAGES + "search_icon.png",
          width: 30,
          height: 30,
        ),
        hintText: Util.getTranslated(context, "home_search_hint_text"),
        hintStyle: AppFont.regular(
          24,
          color: AppColor.appHintTextGreyColor(),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget searchResultCount() {
    if (cropIssueTypeList != null && cropIssueTypeList.length > 0) {
      return RichText(
        text: TextSpan(
          text: Util.getTranslated(context, "home_search_result_text") + " ",
          style: AppFont.regular(
            14,
            color: AppColor.appBlack(),
            decoration: TextDecoration.none,
          ),
          children: <TextSpan>[
            TextSpan(
              text: "(${cropIssueTypeList.length})",
              style: AppFont.regular(
                14,
                color: AppColor.appDarkGreyColor(),
                decoration: TextDecoration.none,
              ),
            )
          ],
        ),
      );
    }
    return Container();
  }

  Widget searchHeader(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        labelText(
          Util.getTranslated(context, "home_search_title_text"),
          AppFont.bold(
            24,
            color: AppColor.appBlue(),
            decoration: TextDecoration.none,
          ),
        ),
        searchWrapper(context),
        dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
        SizedBox(height: 20),
        searchResultCount(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget searchResultListItem() {
    if (!isLoading) {
      return RefreshIndicator(
        onRefresh: _getData,
        color: AppColor.appBlue(),
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: cropIssueTypeList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return searchHeader(context);
            }

            if (index == cropIssueTypeList.length && !noMoreData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            index -= 1;
            return searchResultItem(context, cropIssueTypeList[index]);
          },
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        children: [
          searchHeader(context),
          Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget searchResultItem(BuildContext ctx, SearchDTO cropIssuesTypeDTO) {
    return GestureDetector(
      onTap: () {
        if (cropIssuesTypeDTO.type == "issue") {
          Navigator.pushNamed(context, MyRoute.cropIssueDetailRoute,
              arguments: PageArguments(cropIssuesTypeDTO.id,
                  cropIssueType: cropIssuesTypeDTO.refType));
        } else if (cropIssuesTypeDTO.type == "product") {
          Navigator.pushNamed(context, MyRoute.productDetailsRoute,
              arguments: PageArguments(cropIssuesTypeDTO.id));
        }
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
                        cropIssuesTypeDTO.title,
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
                        cropIssuesTypeDTO.content,
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
}
