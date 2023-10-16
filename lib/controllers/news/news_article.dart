import 'dart:io';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/models/news/article.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsArticle extends StatefulWidget {
  final Article article;

  NewsArticle({Key key, this.article}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NewsArticleState();
  }
}

class _NewsArticleState extends State<NewsArticle> {  
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    
    FirebaseAnalytics()
      .setCurrentScreen(screenName: Constants.analytics_news_details);
  }

  @override
  Widget build(BuildContext context) {
    // final article = ModalRoute.of(context).settings.arguments as Article;
    Util.printInfo("ARTICLE: ${widget.article}");
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(child: backButton(context), height: 50,),
          body: WebView(
            initialUrl: widget.article.url,
            javascriptMode: JavascriptMode.unrestricted,
             onWebViewCreated: (WebViewController webViewController) async {
              await EasyLoading.show(maskType: EasyLoadingMaskType.black);
            },
            onPageStarted: (String url) async {
              Util.printInfo('Page started loading: $url');
            },
            onPageFinished: (String url) async {
              await EasyLoading.dismiss();
              Util.printInfo('Page finished loading: $url');
            },
          ),
        )
      ),
    );
  }

  Widget backButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
          child: ClipOval(
            child: Material(
              color: Colors.black.withOpacity(0.5), // button color
              child: InkWell(
                splashColor:  Colors.black.withOpacity(0.5), // inkwell color
                child: SizedBox(width: 30, height: 30, 
                  child: Icon(Icons.arrow_back_ios_rounded, size: 20, color: Colors.white)),
                  onTap: () {
                    EasyLoading.dismiss();
                    Navigator.of(context).pop();
                  },
              ),
            ),
          ),
        ),
    );
  }
}