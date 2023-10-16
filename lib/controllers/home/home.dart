import 'dart:io';

import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/home/home_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/home/dashboard/banner.dart';
import 'package:behn_meyer_flutter/models/home/dashboard/home.dart';
import 'package:behn_meyer_flutter/models/home/dashboard/video.dart';
import 'package:behn_meyer_flutter/models/page_argument/web_browser_argument.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  Home() : super();

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final controller = PageController();

  Future<HomeDTO> fetchDashboard(BuildContext ctx) {
    HomeApi homeApi = HomeApi(ctx);
    return homeApi.call();
  }

  Future<void> _getData() async {
    setState(() {});
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

  String mapBanner1ToMYLanguage(String code){
    switch(code){
      case Constants.LANGUAGE_CODE_BM:
        return Constants.ASSET_IMAGES + "bm_banner_1.png";
      case Constants.LANGUAGE_CODE_CN:
        return Constants.ASSET_IMAGES + "chi_banner_1.png";
      default:
        return Constants.ASSET_IMAGES + "eng_banner_1.png";
    }
  }

    String mapBanner2ToMYLanguage(String code){
    switch(code){
      case Constants.LANGUAGE_CODE_BM:
        return Constants.ASSET_IMAGES + "bm_banner_2.png";
      case Constants.LANGUAGE_CODE_CN:
        return Constants.ASSET_IMAGES + "chi_banner_2.png";
      default:
        return Constants.ASSET_IMAGES + "eng_banner_2.png";
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_tab_home);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          child: appLogo(),
        ),
        body: FutureBuilder(
          future: fetchDashboard(context),
          builder: (BuildContext context, AsyncSnapshot<HomeDTO> snapshot) {
            if (snapshot.hasData) {
              Util.printInfo(snapshot.data.banners.length);
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: RefreshIndicator(
                  color: AppColor.appBlue(),
                  onRefresh: _getData,
                  child: ListView(
                    children: [
                      homeBanner(context, snapshot.data),
                      SizedBox(height: 20),
                      searchTitle(),
                      SizedBox(height: 20),
                      searchWrapper(context),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0),
                        child: dottedLineSeperator(
                            height: 1.5, color: AppColor.appBlue()),
                      ),
                      SizedBox(height: 20),
                      viewCropCommanIssue(context),
                      (snapshot.data.hasCropProgramme != null &&
                              snapshot.data.hasCropProgramme)
                          ? SizedBox(height: 20)
                          : Container(),
                      (snapshot.data.hasCropProgramme != null &&
                              snapshot.data.hasCropProgramme)
                          ? viewCropProgramme(context)
                          : Container(),
                      SizedBox(height: 20),
                      videosTitle(context),
                      videoList(context, snapshot.data),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              if (snapshot.error is DioError) {
                DioError dioError = snapshot.error;
                if (dioError.response != null) {
                  if (dioError.response.data != null) {
                    ErrorDTO errorDTO =
                        ErrorDTO.fromJson(dioError.response.data);
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

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget appLogo() {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          Constants.ASSET_IMAGES + "s_behn_meyer_logo.png",
        ),
      ),
    );
  }

  Widget homeBanner(BuildContext context, HomeDTO homeDTO) {
    if (homeDTO != null) {
      if (homeDTO.banners != null && homeDTO.banners.length > 0) {
        return Container(
          margin: EdgeInsets.only(left: 16, right: 16.0, top: 20.0),
          width: MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: 2 / 1,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: PageView.builder(
                      controller: controller,
                      itemCount: homeDTO.banners.length,
                      itemBuilder: (contex, index) =>
                          bannerItem(context, homeDTO.banners[index]),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 20, bottom: 20),
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: homeDTO.banners.length,
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
            ),
          ),
        );
      }
    }
    return Container();
  }

  Widget bannerItem(BuildContext context, BannerDTO bannerDTO) {
    return GestureDetector(
      onTap: () {
        Util.printInfo(bannerDTO.url);
        Navigator.pushNamed(context, MyRoute.webBrowserRoute,
            arguments: WebBrowserArgument(bannerDTO.url));
      },
      child: DisplayImage(bannerDTO.image, 'placeholder_2.png'),
      // child: FadeInImage.assetNetwork(
      //   placeholder: Constants.ASSET_IMAGES + 'banner_placeholder.png',
      //   image: bannerDTO.image,
      //   width: double.infinity,
      //   fit: BoxFit.cover,
      // ),
    );
  }

  Widget searchTitle() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16),
      child: Text(
        Util.getTranslated(context, "home_search_title"),
        style: AppFont.bold(
          26,
          color: AppColor.appBlue(),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget searchWrapper(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.homeSearchRoute);
      },
      child: Container(
        margin: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Constants.ASSET_IMAGES + "search_icon.png",
              width: 30,
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                Util.getTranslated(context, "home_search_hint_text"),
                style: AppFont.regular(
                  24,
                  color: AppColor.appHintTextGreyColor(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget viewCropCommanIssue(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16.0),
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, MyRoute.cropListRoute);
        },
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  AppCache.me != null ? 
                    AppCache.me.country == Constants.COUNTRY_CODE_MALAYSIA ? mapBanner1ToMYLanguage(AppCache.me.language) : Constants.ASSET_IMAGES+'viet_banner_1.png'
                  : Constants.ASSET_IMAGES+'eng_banner_1.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Align(
              //   alignment: Alignment.bottomLeft,
              //   child: Padding(
              //     padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
              //     child: Text(
              //       Util.getTranslated(
              //           context, "home_crop_common_issue_text"),
              //       style: AppFont.bold(
              //         20,
              //         color: Colors.white,
              //         decoration: TextDecoration.none,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget viewCropProgramme(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16.0),
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, MyRoute.cropProgrammeCropTypeListRoute);
        },
        child: Container(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  AppCache.me != null ? 
                    AppCache.me.country == Constants.COUNTRY_CODE_MALAYSIA ? mapBanner2ToMYLanguage(AppCache.me.language) : Constants.ASSET_IMAGES+'viet_banner_2.png'
                  : Constants.ASSET_IMAGES+'eng_banner_2.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Positioned(
              //   bottom: 0.0,
              //   right: 0.0,
              //   left: 0.0,
              //   child: Padding(
              //     padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              //     child: Container(
              //       child: Text(
              //         Util.getTranslated(context, "crop_programme_text"),
              //         style: AppFont.bold(
              //           20,
              //           color: Colors.white,
              //           decoration: TextDecoration.none,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget videosTitle(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              Util.getTranslated(context, "home_videos_title"),
              style: AppFont.bold(
                16,
                color: AppColor.appBlue(),
                decoration: TextDecoration.none,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, MyRoute.videoListRoute);
            },
            child: Text(
              Util.getTranslated(context, "home_videos_view_more_text"),
              style: AppFont.regular(
                14,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget videoItem(BuildContext context, VideoDTO videoDTO, int index) {
    return GestureDetector(
      onTap: () {
        Util.printInfo(videoDTO.url);
        _launchBrowser(videoDTO.url);
        // Navigator.pushNamed(context, MyRoute.webBrowserRoute,
        //     arguments: WebBrowserArgument(videoDTO.url));
      },
      child: Wrap(
        children: [
          Container(
            width: 160.0,
            height: 160.0,
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
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.3),
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
          if (index < 4) SizedBox(height: 160.0, width: 16.0),
        ],
      ),
    );
  }

  Widget videoList(BuildContext context, HomeDTO homeDTO) {
    if (homeDTO != null) {
      if (homeDTO.videos != null && homeDTO.videos.length > 0) {
        return Container(
          margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
          height: 160.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return videoItem(context, homeDTO.videos[index], index);
            },
          ),
        );
      }
    }

    return Container();
  }
}
