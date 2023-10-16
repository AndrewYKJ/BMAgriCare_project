import 'dart:io';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/controllers/authentication/auth_widgets.dart';
import 'package:behn_meyer_flutter/dio/api/news/news_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/news/article.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class News extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsState();
  }
}

class _NewsState extends State<News> {
  List articles = [];
  ScrollController _sc = new ScrollController();
  static int page = 1;
  final int size = 20;
  bool noMore = false;
  bool isLoading = false;

  _launchBrowser(String website) async {
    String url = website;
    if (await canLaunch(url)) {
      if (Platform.isIOS) {
        await launch(url, forceSafariVC: false);
      } else {
        await launch(url);
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    page = 1;
    this._getMoreData(page);
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_tab_news);

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        if (!noMore) {
          _getMoreData(page);
        }
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  Future<List<Article>> fetchNews(
      BuildContext context, String page, String size) async {
    NewsApi newsApi = NewsApi(context);
    return newsApi.fetchNewsList(page, size);
  }

  // Future<void> _getData() async {
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      child: SafeArea(
          child: Scaffold(
        resizeToAvoidBottomInset: false,
        primary: true,
        appBar: CustomAppBar(
          child: appBarIcon(context),
        ),
        body: Container(
          color: Colors.white,
          child: RefreshIndicator(
            onRefresh: refresh,
            color: AppColor.appBlue(),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: EdgeInsets.zero,
              itemCount: articles.length + 1,
              itemBuilder: (BuildContext context, int index) {
                // return row
                if (index == articles.length) {
                  return _buildProgressIndicator();
                } else {
                  var item = articles[index];
                  return InkWell(
                      onTap: () {
                        setState(() {
                          Util.printInfo(
                              'Selected : $index Item: ${item.title}');
                          _launchBrowser(item.url);
                          // Navigator.pushNamed(context, MyRoute.newsArticleRoute,
                          //     arguments: item);
                        });
                      },
                      child: Container(
                          width: screenWidth,
                          height: 130,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              expandedList(context, item),
                              SizedBox(height: 8),
                              SizedBox(
                                width: screenWidth - 16,
                                child: const MySeparator(
                                    color: Color.fromRGBO(18, 51, 119, 1.0)),
                              ),
                            ],
                          )));
                }
              },
              controller: _sc,
            ),
          ),
        ),
      )),
    );
  }

  void _getMoreData(int index) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      List tList = [];
      await fetchNews(context, page.toString(), size.toString()).then((value) {
        if (value.length > 0) {
          value.forEach((news) {
            tList.add(news);
          });
        } else {
          setState(() {
            noMore = true;
          });
        }
      }, onError: (error) {
        if (error is DioError) {
          if (error.response != null) {
            if (error.response.data != null) {
              ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
              Util.showAlertDialog(
                  context,
                  Util.getTranslated(context, 'alert_dialog_title_error_text'),
                  errorDTO.message);
            } else {
              Util.showAlertDialog(
                  context,
                  Util.getTranslated(context, 'alert_dialog_title_error_text'),
                  Util.getTranslated(
                      context, 'general_alert_message_error_response'));
            }
          } else {
            Util.showAlertDialog(
                context,
                Util.getTranslated(context, 'alert_dialog_title_error_text'),
                Util.getTranslated(
                    context, 'general_alert_message_error_response'));
          }
        } else {
          Util.showAlertDialog(
              context,
              Util.getTranslated(context, 'alert_dialog_title_error_text'),
              Util.getTranslated(
                  context, 'general_alert_message_error_response_2'));
        }
        Util.printInfo('FETCH NEWS ERROR: $error');
      });

      setState(() {
        isLoading = false;
        articles.addAll(tList);
        page++;
      });
    }
  }

  Future<void> refresh() async {
    setState(() {
      page = 1;
      noMore = false;
      articles.clear();
    });
    _getMoreData(page);
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget articleImage(BuildContext context, String imageUrl) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: DisplayImage(
          imageUrl,
          'placeholder_1.png',
          boxFit: BoxFit.cover,
        )
        // FadeInImage.assetNetwork(
        //       placeholder: Constants.ASSET_IMAGES + 'common_issue_placeholder.png',
        //       image: imageUrl,
        //       fit: BoxFit.cover,
        //     )
        );
  }

  Widget appBarIcon(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      // color: Colors.white,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          Constants.ASSET_IMAGES + "s_behn_meyer_logo.png",
        ),
      ),
    );
  }

  Widget expandedList(BuildContext context, Article item) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Expanded(
        flex: 3,
        child: Container(
          width: screenWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColor.appLightGreyColor(), width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: articleImage(context, item.image)),
              SizedBox(width: 12),
              Expanded(
                // flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      style: AppFont.bold(16,
                          color: AppColor.appBlue(),
                          decoration: TextDecoration.none),
                    ),
                    Text(
                      DateFormat("dd MMMM yyyy")
                          .format(parseStringToDate(item.date)),
                      style: AppFont.italic(10,
                          color: AppColor.appBlack(),
                          decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  DateTime parseStringToDate(String date) {
    return DateTime.parse(date);
  }
}
