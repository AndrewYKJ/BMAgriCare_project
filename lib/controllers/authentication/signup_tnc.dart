import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:flutter/material.dart';

import 'auth_widgets.dart';

class SignUpTnc extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUpTncState();
  }
}

class _SignUpTncState extends State<SignUpTnc> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
            // Container(
            //   color: Colors.white,
            //   child:
            SafeArea(
      child:
          // Column(
          //   children: [
          //     Row(children: [
          //       Container(
          //         height: screenHeight-20,
          //         width: screenWidth,
          //         child:
          SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [AuthWidget.backButton(context)]),
            SizedBox(height: 10),
            Row(children: [tncHeaderLbl()]),
            SizedBox(height: 6),
            Row(
              children: [tncContent()],
            ),
            SizedBox(height: 16)
          ],
        ),
      ),
      //     )
      //   ])
      // ])
    )
        // ),
        );
  }

  Widget tncHeaderLbl() {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth - 60,
        height: 25,
        child: Text(
          Util.getTranslated(context, "signup_terms_header_title"),
          style: AppFont.bold(17,
              color: AppColor.appBlue(), decoration: TextDecoration.none),
        ));
  }

  Widget tncContent() {
    String myStr =
        '''Welcome to the Behn Meyer Group's (“us” or “we”) website (the “website"). If you, the user (“you”), continue to browse and use our website, you are agreeing to comply with and be bound by the following Terms of Use (“Terms of Use”), which together with our Privacy Policy govern the relationship with you in relation to our Website.

Copyrights

The text, images, graphics, sound files, animation files, video files, and their arrangement on our website are all subject to copyright and other intellectual property protection. All rights, title and interest not expressly granted with respect to our website and content provided on or through the website are reserved. The website’s content may not be copied for commercial use or distribution, nor may these objects be modified or reposted to other websites. 

Disclaimer of Warranties 

Use of this website is at your sole risk. All materials, information, products and services are provided "as is," with no warranties or guarantees whatsoever. We expressly disclaim to the fullest extent permitted by law all express, implied, statutory, and other warranties, guarantees, or representations, including, without limitation, the warranties of merchantability, fitness for a particular purpose, and non-infringement of proprietary and intellectual property rights. Without limitation, we make no warranty or guarantee that this website will be uninterrupted, timely, secure, or error-free. 

You understand and agree that if you download or otherwise obtain materials, information, products or services, you do so at your own discretion and risk and that you will be solely responsible for any damages that may result, including loss of data or damage to your computer system. 

Some jurisdictions do not allow the exclusion of warranties, so the above exclusions may not apply to you. 

Limitation of Liability 

In no event we will be liable to any party for any direct, indirect, incidental, special, exemplary or consequential damages of any type whatsoever related to or arising from this website or any use of this website, or of any website or resource linked to, referenced, or accessed through this website, or for the use or downloading of, or access to, any materials, information, products, or services, including, without limitation, any lost profits, business interruption, lost savings or loss of programs or other data, even if we are expressly advised of the possibility of such damages. This exclusion and waiver of liability applies to all causes of action, whether based on contract, warranty, tort, or any other legal theories. 

Indemnification 

You agree to indemnify and hold harmless us, our officers, directors, employees and agents from and against any and all claims, liabilities, damages, losses or expenses, including reasonable attorneys' fees and costs, due to your violation of these Terms of Use or any additional rules or your violation or infringement of any third party rights. 

Links to third party websites 

Links on our website to third-party websites are provided solely as a convenience to you. If you use these links, you will leave our website. We are not obligated to review such third-party websites, do not control such third-party websites, and are not responsible for any such third-party websites (or the products, services, or content available through the same). Thus, we do not endorse or make any representations about such third-party websites, any information, products, services, or materials found there or any results that may be obtained from using them. If you decide to access any of the third-party websites linked to from our website, you do this entirely at your own risk. 

Linking to our Website 

You may not create a link to our website from another website or document without our prior written consent. 

Update of Terms of Use 

We reserve the right to update the Terms of Use at any time without notice to you. The most current version of the Terms of Use can be reviewed by clicking on the "Terms of Use" hypertext link located at the bottom of our website. 

Applicable Law 

Your use of our Website and any dispute arising out of such use of the Website is subject to the laws of [countries where Behn Meyer is present]. 

Contacting Us 

If there are any questions regarding this Terms of Use you may contact us using the information below. 

Behn Meyer Deutschland Holding AG & Co. KG
Ballindamm 1
20095 Hamburg, Germany
Tel: +49-40 30299 0
Fax:+49-40 30299 319
contact [@] behnmeyer.de
http://www.behnmeyer.com''';
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth - 32,
        child: Text(
          myStr,
          style: AppFont.regular(15,
              color: Colors.black, decoration: TextDecoration.none),
          textAlign: TextAlign.justify,
        ));
  }
}
