import 'dart:convert';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TermsAndConditions();
  }
}

class _TermsAndConditions extends State<TermsAndConditions> {
  WebViewController _controller;
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_terms_and_conditions);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
          child: backButton(context),
        ),
        body: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          color: Colors.white,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                Text(
                  Util.getTranslated(context, "setting_terms_and_conditions"),
                  style: AppFont.bold(
                    17,
                    color: AppColor.appBlue(),
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: WebView(
                    initialUrl: 'about:blank',
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                      _loadHtmlFromAssets();
                    },
                  ),
                ),
              ],
            ),
            // child: SingleChildScrollView(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       SizedBox(height: 10.0),
            // Text(
            //   Util.getTranslated(context, "setting_terms_and_conditions"),
            //   style: AppFont.bold(
            //     20,
            //     color: AppColor.appBlue(),
            //     decoration: TextDecoration.none,
            //   ),
            // ),
            // SizedBox(height: 20),
            //       WebView(
            //         initialUrl: 'about:blank',
            //         onWebViewCreated: (WebViewController webViewController) {
            //           _controller = webViewController;
            //           _loadHtmlFromAssets();
            //         },
            //       ),
            //       // Text(
            //       //   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ullamcorper velit sed ullamcorper morbi tincidunt ornare. Molestie nunc non blandit massa enim nec dui nunc. Rutrum quisque non tellus orci ac. Id aliquet risus feugiat in. Tristique et egestas quis ipsum suspendisse. Amet justo donec enim diam vulputate ut pharetra. Ultrices eros in cursus turpis massa tincidunt dui ut ornare. Duis at tellus at urna. Consequat mauris nunc congue nisi vitae suscipit tellus mauris a. Fringilla est ullamcorper eget nulla facilisi etiam dignissim. Sed arcu non odio euismod lacinia at. Consequat interdum varius sit amet. Vulputate enim nulla aliquet porttitor lacus luctus accumsan. Convallis posuere morbi leo urna molestie at elementum.\n\n\n\n\n\n\nVel pretium lectus quam id leo in vitae turpis massa. Tristique et egestas quis ipsum suspendisse ultrices gravida. Phasellus egestas tellus rutrum tellus pellentesque eu tincidunt tortor. Cras semper auctor neque vitae tempus quam. Pellentesque elit ullamcorper dignissim cras tincidunt lobortis. Augue lacus viverra vitae congue eu consequat ac. Scelerisque purus semper eget duis at tellus at urna condimentum. Donec adipiscing tristique risus nec feugiat in. Lectus magna fringilla urna porttitor rhoncus. Auctor elit sed vulputate mi. Aliquet lectus proin nibh nisl condimentum id. Natoque penatibus et magnis dis.",
            //       //   style: AppFont.regular(
            //       //     16,
            //       //     color: AppColor.appBlack(),
            //       //     decoration: TextDecoration.none,
            //       //   ),
            //       // ),
            //       SizedBox(height: 20),
            //     ],
            //   ),
            // ),
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
        child: ClipOval(
          child: Material(
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
        ),
      ),
    );
  }

  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('assets/html/terms_2.html');
    _controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
