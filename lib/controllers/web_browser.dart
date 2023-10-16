import 'dart:io';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebBrowser extends StatefulWidget {
  final String url;

  WebBrowser({Key key, this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WebBrowser();
  }
}

class _WebBrowser extends State<WebBrowser> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Container(
          color: Colors.white,
          child: SafeArea(
              child: Scaffold(
            appBar: CustomAppBar(
              child: backButton(context),
              height: 50,
            ),
            body: WebView(
              initialUrl: widget.url,
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
          )),
        ),
        onWillPop: () async {
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          return true;
        });
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
              splashColor: Colors.black.withOpacity(0.5), // inkwell color
              child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Icons.arrow_back_ios_rounded,
                      size: 20, color: Colors.white)),
              onTap: () {
                if (EasyLoading.isShow) {
                  EasyLoading.dismiss();
                }
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }
}
