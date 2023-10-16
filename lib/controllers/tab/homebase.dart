import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/controllers/dealer/dealer.dart';
import 'package:behn_meyer_flutter/controllers/news/news.dart';
import 'package:behn_meyer_flutter/controllers/product/product.dart';
import 'package:behn_meyer_flutter/controllers/qna/qna.dart';
import 'package:behn_meyer_flutter/dio/api/touch_api.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'tab_item.dart';
import '../settings/settings.dart';
import '../home/home.dart';
import '../product/product.dart';
import '../dealer/dealer.dart';

class HomeBase extends StatefulWidget {
  final RemoteConfig config;
  HomeBase({Key key, this.config}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeBaseState();
  }
}

class _HomeBaseState extends State<HomeBase> {
  var _currentTab = TabItem.home;

  String title;
  String description;
  String country;

  void getFcmToken() async {
    String token = await FirebaseMessaging.instance.getToken();
    Util.printInfo("FCM TOKEN: $token");
    var accessToken = await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    var refreshToken = await AppCache.containValue(AppCache.REFRESH_TOKEN_PREF);
    if (accessToken && refreshToken) {
      callTouch(token);
    }
  }

  void callTouch(String fcmToken) async {
    var bodyData = {'notificationToken': fcmToken};
    TouchApi touchApi = TouchApi(context, bodyData: bodyData);
    await touchApi.call().then((value) {}).catchError((error) {});
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_homebase);
    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage message) {
    //   if (message != null) {
    //     Util.printInfo("****** Get notification from open app ******");
    //     if (message.data != null) {
    //       Navigator.pushNamed(context, MyRoute.homebaseRoute);
    //     }
    //   }
    // });

    AppCache.getbooleanValue(AppCache.IS_HIDE_INTRO_PAGE_PREF).then((isHide) {
      if (!isHide) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => showIntroDialog(context));
      }
    });

    AppCache.getCountry().then((value) {
      setState(() {
        if (value != null && value.length > 0) {
          this.country = value;
        } else {
          this.country = Constants.COUNTRY_CODE_MALAYSIA;
        }
      });
    });

    if (widget.config != null) {
      Util.checkAppVersion(context, widget.config);
    }

    getFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildBody(context),
      // new SafeArea(
      //   child: _buildBody(context),
      // ),
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onSelectTab: _selectTab,
        country: country,
      ),
    );
  }

  void _selectTab(TabItem tabItem) {
    setState(() {
      _currentTab = tabItem;
    });
  }

  Widget _buildBody(BuildContext context) {
    if (_currentTab == TabItem.home) {
      return Home();
    } else if (_currentTab == TabItem.product) {
      return Product();
    } else if (_currentTab == TabItem.news) {
      return News();
    } else if (_currentTab == TabItem.dealer) {
      return Dealer(
        isFromProducts: false,
      );
    } else if (_currentTab == TabItem.qna) {
      return QnA();
    } else {
      return Settings();
    }
  }

  void showIntroDialog(BuildContext ctx) {
    showGeneralDialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      context: ctx,
      pageBuilder: (_, __, ___) {
        return ViewPagerDialog();
      },
    );
  }
}

class BottomNavigation extends StatelessWidget {
  BottomNavigation(
      {@required this.currentTab,
      @required this.onSelectTab,
      @required this.country});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;
  final String country;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: getCurrentIndex(),
      selectedItemColor: AppColor.appBlue(),
      unselectedItemColor: AppColor.appBlue(),
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(context, TabItem.home),
        _buildItem(context, TabItem.product),
        _buildItem(context, TabItem.news),
        _buildItem(
            context,
            country == Constants.COUNTRY_CODE_MALAYSIA
                ? TabItem.dealer
                : TabItem.qna),
        _buildItem(context, TabItem.settings),
      ],
      onTap: (index) {
        if (country == Constants.COUNTRY_CODE_VIETNAM) {
          if (index == 3) {
            onSelectTab(TabItem.qna);
          } else {
            onSelectTab(TabItem.values[index]);
          }
        } else {
          onSelectTab(TabItem.values[index]);
        }
      },
    );
  }

  int getCurrentIndex() {
    if (TabItem.values[currentTab.index] == TabItem.qna) {
      return 3;
    } else {
      return currentTab.index;
    }
  }

  BottomNavigationBarItem _buildItem(BuildContext context, TabItem tabItem) {
    return BottomNavigationBarItem(
      icon: _iconTabMatching(tabItem),
      label: Util.getTranslated(context, tabName[tabItem]),
    );
  }

  Image _iconTabMatching(TabItem item) {
    return currentTab == item ? tabIconSelected[item] : tabIconUnselected[item];
  }
}

class ViewPagerDialog extends StatefulWidget {
  @override
  _ViewPagerDialog createState() => new _ViewPagerDialog();
}

class _ViewPagerDialog extends State<ViewPagerDialog> {
  final controller = PageController();
  int currViewPage = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.page.round() != currViewPage) {
        setState(() {
          currViewPage = controller.page.round();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Image.asset(
                  Constants.ASSET_IMAGES + "s_behn_meyer_logo.png",
                ),
                SizedBox(height: 30),
                Expanded(
                  child: SizedBox(
                    child: PageView(
                      controller: controller,
                      children: [
                        introPage(
                            "onboard_icon_1.png",
                            Util.getTranslated(
                                context, "intro_page_1_description")),
                        introPage(
                            "onboard_icon_2.png",
                            Util.getTranslated(
                                context, "intro_page_2_description")),
                        introPage(
                            "onboard_icon_3.png",
                            Util.getTranslated(
                                context, "intro_page_3_description")),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, top: 10),
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        dotWidth: 10,
                        dotHeight: 10,
                        expansionFactor: 3,
                        dotColor:
                            AppColor.appViewPagerIndicatorUnselectedColor(),
                        activeDotColor:
                            AppColor.appViewPagerIndicatorSelectedColor(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 80),
                getStartedButton(context),
                SizedBox(height: 20),
              ],
            ),
            margin: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage(Constants.ASSET_IMAGES + "tutorial_bg.png"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      onWillPop: () async => false,
    );
  }

  Widget introPage(String introImage, String introDescription) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 2 / 1,
            child: Image.asset(
              Constants.ASSET_IMAGES + introImage,
              width: double.infinity,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Text(
              introDescription,
              style: AppFont.bold(
                16,
                color: AppColor.appBlack(),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: (currViewPage == 2)
            ? MaterialButton(
                onPressed: () {
                  AppCache.setBoolean(AppCache.IS_HIDE_INTRO_PAGE_PREF, true);
                  Navigator.pop(context);
                },
                color: AppColor.appBlue(),
                shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    Util.getTranslated(context, "intro_btn_start"),
                    style: AppFont.bold(
                      16,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
                child: Container(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      Util.getTranslated(context, "intro_btn_next"),
                      style: AppFont.bold(
                        16,
                        color: AppColor.appBlue(),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
