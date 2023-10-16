import 'dart:io';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/home/home_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/home/dashboard/home.dart';
import 'package:behn_meyer_flutter/models/home/dashboard/video.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VideoList();
  }
}

class _VideoList extends State<VideoList> {
  Future<void> _getData() async {
    setState(() {});
  }

  Future<HomeDTO> fetchDashboard(BuildContext ctx) {
    HomeApi homeApi = HomeApi(ctx);
    return homeApi.call();
  }

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
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_video_list);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          child: backButton(context),
        ),
        body: FutureBuilder(
          future: fetchDashboard(context),
          builder: (BuildContext context, AsyncSnapshot<HomeDTO> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.videos != null &&
                  snapshot.data.videos.length > 0) {
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
                        labelText(context),
                        SizedBox(height: 20),
                        videoList(context, snapshot.data.videos),
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
                  child: labelText(context),
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
                  labelText(context),
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

  Widget labelText(BuildContext context) {
    return Text(
      Util.getTranslated(context, "home_videos_title"),
      style: AppFont.bold(
        24,
        color: AppColor.appBlue(),
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget videoList(BuildContext context, List<VideoDTO> videoList) {
    return GridView.builder(
      itemCount: videoList.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        crossAxisCount: 2,
        childAspectRatio: 1 / 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return videoItem(context, videoList[index]);
      },
    );
  }

  Widget videoItem(BuildContext context, VideoDTO videoDTO) {
    return GestureDetector(
      onTap: () {
        Util.printInfo(videoDTO.url);
        _launchBrowser(videoDTO.url);
        // Navigator.pushNamed(context, MyRoute.webBrowserRoute,
        //     arguments: WebBrowserArgument(videoDTO.url));
      },
      child: Container(
        color: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Stack(
            children: [
              FadeInImage.assetNetwork(
                placeholder: Constants.ASSET_IMAGES + 'placeholder_1.png',
                image: videoDTO.image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.3),
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        Constants.ASSET_IMAGES + "play_icon.png",
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 10),
                      Text(
                        videoDTO.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.bold(
                          15,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
