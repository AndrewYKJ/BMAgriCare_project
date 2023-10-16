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

class PrivacyPolicy extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PrivacyPolicy();
  }
}

class _PrivacyPolicy extends State<PrivacyPolicy> {
  WebViewController _controller;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_privacy_policy);
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
                  Util.getTranslated(context, "setting_privacy_policy"),
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
            //       Text(
            //         Util.getTranslated(context, "setting_privacy_policy"),
            //         style: AppFont.bold(
            //           20,
            //           color: AppColor.appBlue(),
            //           decoration: TextDecoration.none,
            //         ),
            //       ),
            //       SizedBox(height: 20),
            //       privacyContent(),
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
    String fileText =
        await rootBundle.loadString('assets/html/policy_3.html');
    _controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  Widget privacyContent() {
    String content =
        '''Behn Meyer respects the confidentiality of your information. We conduct our business in full compliance with applicable laws and regulations on data privacy protection and security, including the European Union’s General Data Protection Regulation (GDPR) 2016 that came into force on 25 May 2018.


Personal Data
“Personal data” means data relating to an individual who can be identified from that data (or from that data together with other information in our possession). Behn Meyer does not collect or store any personal data through our website unless it is explicitly and voluntarily provided (via filling up the form on the Contact Us or Careers page). Any information that is received through the form on the Contact Us or Careers page will only be used for internal purposes and will not be used for any marketing purposes or sold to any third parties.

Cookies
“Cookies” are small text files that are stored on your device when you access a website through your browser. They collect usage data such as your browser information and the pages that you visit and are deleted as soon as you close your browser or power off your device. Behn Meyer’s website uses cookies to understand and save your preferences for future visits. Cookies also help us compile aggregate data on website traffic and interaction which we use to enhance user experience. If you would like to stop the tracking of your preferences through cookies, you may opt out by deleting them from your hard disk, block future cookies or set your device to display a notification before cookies are saved by changing your browser settings.

Analytics
This website uses Google Analytics to analyse how users use our site through the use of cookies. The information that is collected includes the domain name of the website whence you came and your IP address. This information is stored anonymously in Google’s servers in the United States. As we actively anonymise your IP address, however, it will be shortened by Google beforehand within Member States of the European Union or in other states party to the European Economic Area (EEA). Only in a few exceptional cases will a full IP address be sent to a Google server in the USA and shortened there. Google will use this information for the purpose of evaluating your use of the website, compiling reports on website activity for website operators and providing other services relating to website activity and internet usage. Google may also transfer this information to third parties where required to do so by law, or where such third parties process the information on Google's behalf. You may refuse the use of cookies by selecting the appropriate settings on your browser, however please note that if you do this you may not be able to use the full functionality of this website. By using this website, you consent to the processing of data about you by Google in the manner and for the purposes set out above.

For more information about Google Analytics, visit https://tools.google.com/dlpage/gaoptout

You may find further details concerning Google Analytics’s compliance with the GDPR by visiting https://www.google.com/intl/en_uk/analytics/privacyoverview

Purpose of Use & Limitations
We may use your personal data to answer your enquiries submitted through the Contact Us and Careers page unless you choose to revoke your consent to this usage. All non-personal data gathered will only be used for internal purposes, to improve the functionality of our website and to better tailor the website to your needs. None of the data retrieved will be sold to third parties.

Data Retention
Any personal data retrieved is stored on our servers purely for processing purposes. This data is erased after a period in compliance with the data protection acts that are currently in effect. Data collected may be stored on servers outside of the EU.

Job Postings
This website updates periodically with job postings for our various offices around the world. You have the opportunity to apply for these jobs by filling up the online form on the Careers page. Your application, containing your personal information, will typically be received by the human resources team overseeing the region for which you have applied, along with your cover letter and resume. All of this information will be stored in email servers that may be outside the EU.

Application
This Privacy Policy applies only to information collected through the Behn Meyer website.

Security
We undertake multiple security measures in order to maintain the security of your personal information against loss, destruction, falsification, manipulation and unauthorised access or disclosure.

Right to be Forgotten
You reserve the right to withdraw your consent to the processing of your personal data as well as to request its deletion from our servers. If you would like to exercise your right to be forgotten, simply notify us by sending us an email at: contact [@] behnmeyer.com.my

Terms of Use
You may visit our Terms of Use page where you may find disclaimers and limitations of liability governing the use of this website: https://www.behnmeyer.com/terms-of-use. 

Your Acceptance of These Terms
By using our website, you consent to the collection and use of your information by us as set out in this Privacy Policy. This Privacy Policy is subject to changes at the sole discretion of the Behn Meyer Group.

Contacting Us
If you have any questions regarding this Privacy Policy, you may contact us using the information below.

Behn Meyer Deutschland Holding AG & Co. KG
Ballindamm 1
20095 Hamburg, Germany
Tel.: +49-40 30299 0
Fax: +49-40 30299 319
contact [@] behnmeyer.com.my
https://www.behnmeyer.com/''';
    return Text(
      content,
      style: AppFont.regular(
        15,
        color: AppColor.appBlack(),
        decoration: TextDecoration.none,
      ),
      textAlign: TextAlign.justify,
    );
  }
}
