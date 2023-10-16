import 'dart:async';
import 'dart:io';

import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/product/product_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/page_argument/page_arguments.dart';
import 'package:behn_meyer_flutter/models/page_argument/photo_view_multiple_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/photo_view_single_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/product_dealer_argument.dart';
import 'package:behn_meyer_flutter/models/product/product_desc.dart';
import 'package:behn_meyer_flutter/models/product/product_nutrient.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'dart:ui' as ui;

import 'package:url_launcher/url_launcher.dart';

class ProductDetails extends StatefulWidget {
  final int productId;

  ProductDetails({Key key, this.productId}) : super(key: key);

  @override
  ProductDetailsState createState() => ProductDetailsState();
}

class ProductDetailsState extends State<ProductDetails> {
  final photoController = PageController();
  // final _key = GlobalKey();
  ProductDesc product = ProductDesc();
  String country = "";
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'deviceVersion': data.systemVersion,
      'model': data.model,
      'isPhysicalDevice': data.isPhysicalDevice,
      'uuid': data.identifierForVendor
    };
  }

  @override
  void initState() {
    getProductDetails();
    super.initState();
    initPlatformState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_product_details);

    AppCache.getCountry().then((value) {
      setState(() {
        if (value != null && value.length > 0) {
          country = value;
        } else {
          country = Constants.COUNTRY_CODE_MALAYSIA;
        }
      });
    });
  }

  Future<ProductDesc> fetchProductDetails(
      BuildContext context, int productId) async {
    ProductApi productApi = ProductApi(context);
    return productApi.getProductDetail(productId);
  }

  void getProductDetails() async {
    await EasyLoading.show(maskType: EasyLoadingMaskType.black);
    ProductDesc tProduct;
    await this.fetchProductDetails(context, widget.productId).then((value) {
      EasyLoading.dismiss();
      if (value != null) {
        tProduct = value;
      }
    }, onError: (error) {
      EasyLoading.dismiss();
      if (error is DioError) {
          if (error.response != null){
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
      Util.printInfo('FETCH PRODUCT DETAILS ERROR: $error');
    });

    setState(() {
      product = tProduct;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: _detailList(context, product)),
              _footerBtns(context, product.name)
            ],
          ),
        ));
  }

  Widget _detailList(BuildContext context, ProductDesc productDesc) {
    if (productDesc.category != null) {
      // if (productDesc.category.code == 'P_F') {
      //   return  ListView(children: [
      //     _headerList(context, productDesc),
      //     nutrientView(productDesc.nutrients, Util.getTranslated(context, 'product_details_header_nutrients')),
      //     textDescView(productDesc.features, Util.getTranslated(context, 'product_details_header_features')),
      //     (product.application != null) ? textDescView(product.application, Util.getTranslated(context, 'product_details_header_application')) : SizedBox(height: 0),
      //     (product.testimonyImages != null ) ? textImgDescView(product.testimonyImages, Util.getTranslated(context, 'product_details_header_testimonial')) : ((product.testimony != null) ? textImgDescView(product.testimony, Util.getTranslated(context, 'product_details_header_testimonial')) : SizedBox(height: 0)),
      //   ],);
      // } else
      if (productDesc.category.code == 'P_CP') {
        return ListView(
          children: [
            _headerList(context, productDesc),
            (product.attributes != null)
                ? cropProductAttributeView(
                    Util.getTranslated(
                        context, 'product_details_header_attributes'),
                    productDesc.attributes)
                : SizedBox(height: 0),
            (product.labelRecImage != null)
                ? cropLabelRecomenView(
                    context,
                    Util.getTranslated(
                        context, 'product_details_header_lbl_recommendation'),
                    productDesc.labelRecImage)
                : SizedBox(height: 0),
            (product.usefulInfo != null)
                ? cropUsefulInfoView(
                    context,
                    Util.getTranslated(
                        context, 'product_details_header_useful_info'),
                    productDesc.usefulInfo)
                : SizedBox(height: 0),
          ],
        );
      } else {
        return ListView(
          children: [
            _headerList(context, productDesc),
            (product.nutrients != null)
                ? nutrientView(
                    productDesc.nutrients,
                    Util.getTranslated(
                        context, 'product_details_header_nutrients'))
                : SizedBox(height: 0),
            (product.features != null)
                ? textDescView(
                    productDesc.features,
                    Util.getTranslated(
                        context, 'product_details_header_features'))
                : SizedBox(height: 0),
            (product.application != null)
                ? textDescView(
                    product.application,
                    Util.getTranslated(
                        context, 'product_details_header_application'))
                : SizedBox(height: 0),
            (product.testimonyImages != null)
                ? textImgDescView(
                    product.testimonyImages,
                    Util.getTranslated(
                        context, 'product_details_header_testimonial'))
                : ((product.testimony != null)
                    ? textImgDescView(
                        product.testimony,
                        Util.getTranslated(
                            context, 'product_details_header_testimonial'))
                    : SizedBox(height: 0)),
          ],
        );
      }
    } else {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      return Container(
          color: Colors.white, height: screenHeight, width: screenWidth);
    }
  }

  Widget _headerList(BuildContext context, ProductDesc product) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          _headerImages(context, product.images, product.shareUrl)
        ]),
        SizedBox(
          height: 8,
        ),
        (product.subCategory != null)
            ? _headerProductCategory(product.category.name,
                productSubCat: product.subCategory.name)
            : _headerProductCategory(product.category.name),
        SizedBox(
          height: 8,
        ),
        _headerProductTitle(product.name),
        SizedBox(
          height: 8,
        ),
        _headerProductDesc(product.desc),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget _headerImages(
      BuildContext context, List<String> images, String shareUrl) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        width: screenWidth,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: SizedBox(
            height: screenWidth / 2,
            child: Stack(
              children: [
                Container(
                    width: screenWidth, child: headerImagePageView(images)),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20, bottom: 20),
                    child: SmoothPageIndicator(
                      controller: photoController,
                      count: images.length,
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
                Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [backButton(), shareButton(shareUrl)]),
                ),
              ],
            )));
  }

  Widget headerImagePageView(List<String> images) {
    return PageView.builder(
      controller: photoController,
      itemCount: images.length,
      itemBuilder: (contex, index) =>
          imageViewPagerItem(context, images[index], images, index),
    );
  }

  Widget imageViewPagerItem(
      BuildContext context, String imgUrl, List<String> images, int index) {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, MyRoute.photoViewMultipleRoute,
              arguments: PhotoViewMultipleArgument(images, index));
        },
        child: DisplayImage(
          imgUrl,
          'placeholder_3.png',
          boxFit: BoxFit.cover,
        ));
  }

  Widget _headerProductCategory(String productCat, {String productSubCat}) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      // height: 20,
      child: Text(
          productSubCat != null
              ? '$productCat ($productSubCat)'
              : '$productCat',
          style: AppFont.bold(16,
              color: AppColor.appBlue(), decoration: TextDecoration.none)),
    );
  }

  Widget _headerProductTitle(String productName) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Text(productName,
          style: AppFont.bold(24,
              color: AppColor.appBlack(), decoration: TextDecoration.none)),
    );
  }

  Widget _headerProductDesc(String productDesc) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Text(productDesc,
          style: AppFont.regular(14,
              color: AppColor.appBlack(), decoration: TextDecoration.none)),
    );
  }

  Widget backButton() {
    return ClipOval(
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
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget shareButton(String shareUrl) {
    return ClipOval(
      child: Material(
        color: Colors.black.withOpacity(0.5), // button color
        child: InkWell(
          splashColor: Colors.black.withOpacity(0.5), // inkwell color
          child: SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.share, size: 20, color: Colors.white)),
          onTap: () {
            Util.printInfo("on Share");
            Share.share(shareUrl);
          },
        ),
      ),
    );
  }

  Widget nutrientView(List<ProductNutrient> nutrients, String headerTitle) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          listHeader(headerTitle),
          SizedBox(height: 8),
          getNutrientsContent(nutrients)
        ]);
  }

  Widget getNutrientsContent(List<ProductNutrient> nutrients) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
      alignment: FractionalOffset.center,
      color: Colors.white,
      width: screenWidth,
      child: GridView.count(
          childAspectRatio: 3 / 2,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 3,
          children: nutrients
              .map((e) => Row(
                    children: [
                      Flexible(
                        child: nutrientContent(e.nutrient, e.percentage),
                      )
                    ],
                  ))
              .toList()),
    );
  }

  Widget nutrientContent(String title, String percentage) {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Text(
                      title,
                      style: AppFont.chemicalRegular(24,
                          color: AppColor.appBlue(),
                          decoration: TextDecoration.none),
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.nutrientBgBlue(),
                      border: Border.all(
                          color: AppColor.nutrientBorderBlue(), width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ))
              ]),
          SizedBox(height: 5),
          Text(
            "$percentage",
            style: AppFont.bold(10, color: AppColor.appBlue()),
          )
        ]);
  }

  Widget textDescView(String textDesc, String headerTitle) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          listHeader(headerTitle),
          SizedBox(height: 8),
          getTextContent(textDesc),
          SizedBox(height: 8),
        ]);
  }

  Widget getTextContent(String textDesc) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Text(textDesc,
          style: AppFont.regular(14,
              color: AppColor.appBlack(), decoration: TextDecoration.none)),
    );
  }

  Widget textImgDescView(String textImgDesc, String headerTitle) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          listHeader(headerTitle),
          SizedBox(height: 8),
          textImgDesc.startsWith("http")
              ? getImageContent(textImgDesc)
              : getTextContent(textImgDesc),
          SizedBox(height: 8),
        ]);
  }

  Widget getImageContent(String imageDesc) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: FutureBuilder<ui.Image>(
          future: _getImage(imageDesc),
          builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
            if (snapshot.hasData) {
              double ratio = snapshot.data.height / snapshot.data.width;
              Util.printInfo(
                  '${snapshot.data.width} X ${snapshot.data.height}');
              return displaySinglePhoto(context, imageDesc, ratio);
            } else {
              return Text(
                  Util.getTranslated(context, 'product_details_loading'));
            }
          }),
    );
  }

  Widget displaySinglePhoto(BuildContext context, String imgUrl, double ratio) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        child: GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.photoViewSingleRoute,
            arguments: PhotoViewSingleArgument(imgUrl));
      },
      child: DisplayImage(imgUrl, 'placeholder_3.png',
          width: screenWidth - 40,
          height: (screenWidth - 40) * ratio,
          boxFit: BoxFit.cover),
    ));
  }

  Widget cropProductAttributeView(
      String headerTitle, List<ProductAttributes> attrs) {
    return Column(mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          listHeader(headerTitle),
          SizedBox(height: 8),
          cropProductAttributeContent(attrs)
        ]);
  }

  Widget cropProductAttributeContent(List<ProductAttributes> attrs) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      width: screenWidth,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: attrs.length,
          itemBuilder: (context, index) {
            final item = attrs[index];
            return ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              title: Text(
                item.title,
                style: AppFont.bold(16,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none),
              ),
              subtitle: Text(
                item.content,
                style: AppFont.regular(14,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none),
              ),
            );
          }),
    );
  }

  Widget cropLabelRecomenView(
      BuildContext context, String headerTitle, String imageUrl) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          listHeader(headerTitle),
          SizedBox(height: 8),
          getImageContent(imageUrl),
          SizedBox(height: 8),
        ]);
  }

  Widget cropUsefulInfoView(
      BuildContext context, String headerTitle, String usefulInfo) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          listHeader(headerTitle),
          SizedBox(height: 8),
          getTextContent(usefulInfo),
          SizedBox(height: 8),
          cropUsefulInfoButton(context),
          SizedBox(height: 8),
        ]);
  }

  Widget cropUsefulInfoButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      width: 200,
      height: 40,
      child: TextButton(
        onPressed: () {
          onUsefulInfo(context);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              Util.getTranslated(context, 'product_details_read_more'),
              style: AppFont.bold(16,
                  color: Colors.white, decoration: TextDecoration.none),
            ),
            Icon(Icons.navigate_next_rounded, size: 25, color: Colors.white),
          ],
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.appBlue(),
          textStyle: AppFont.bold(15, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  Widget listHeader(String title) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        height: 30,
        alignment: Alignment.centerLeft,
        width: screenWidth,
        color: AppColor.productListHeaderBgBlue(),
        child: Text(title,
            style: AppFont.bold(
              12,
              color: AppColor.appBlue(),
              decoration: TextDecoration.none,
            )));
  }

  Widget _footerBtns(BuildContext context, String productName) {
    return SizedBox(
        height: 80,
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              inquiryButton(context, productName),
              country == Constants.COUNTRY_CODE_MALAYSIA
                  ? dealerButton(context)
                  : Container(),
            ],
          ),
        ));
  }

  Widget inquiryButton(BuildContext context, String productName) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: country == Constants.COUNTRY_CODE_MALAYSIA
          ? (screenWidth / 2) - 20
          : screenWidth - 20,
      height: 50,
      child: TextButton(
        onPressed: () {
          onInquiry(context, productName);
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Constants.ASSET_IMAGES + 'product_inquiry_icon.png',
                width: 25,
                height: 25,
              ),
              SizedBox(
                width: 5,
              ),
              Text(Util.getTranslated(context, 'product_details_inquiry_btn')),
            ]),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.appBlue(),
          textStyle: screenWidth <= 375
              ? AppFont.bold(12, color: Colors.white)
              : AppFont.bold(14, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  Widget dealerButton(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: (screenWidth / 2) - 20,
      height: 50,
      child: TextButton(
        onPressed: () {
          onDealer(context);
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Constants.ASSET_IMAGES + 'locate_dealer_icon.png',
                width: 25,
                height: 25,
              ),
              SizedBox(
                width: 5,
              ),
              Text(Util.getTranslated(context, 'product_details_dealer_btn')),
            ]),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.appBlue(),
          textStyle: screenWidth <= 375
              ? AppFont.bold(12, color: Colors.white)
              : AppFont.bold(14, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  void onInquiry(BuildContext context, String productName) async {
    print('onInquiry');
    if (country == Constants.COUNTRY_CODE_MALAYSIA) {
      String emailSubject = "";
      String emailBody = "";
      String emailUrl = "";
      List<String> specialVersionList = [
        '14.4',
        '14.4.1',
        '14.4.2',
        '14.5',
        '14.5.1',
        '14.6',
        '14.7',
        '14.7.1',
        '14.8',
        '14.8.1'
      ];

      if (Platform.isIOS) {
        if (_deviceData != null) {
          if (specialVersionList
              .contains(_deviceData['deviceVersion'].toString())) {
            emailSubject =
                Util.getTranslated(context, "product_inquiry_email_subject") +
                    productName;
            emailBody = Util.getTranslated(
                    context, "product_inquiry_email_body_sp_1") +
                " " +
                productName +
                ". " +
                Util.getTranslated(context, "product_inquiry_email_body_sp_2");

            final Uri params = Uri(
                scheme: 'mailto',
                path: country == Constants.COUNTRY_CODE_MALAYSIA
                    ? Constants.BEHN_MEYER_EMAIL
                    : Constants.BEHN_MEYER_EMAIL_VIETNAM,
                query: encodeQueryParameters(<String, String>{
                  'subject': '$emailSubject',
                  'body': '$emailBody'
                }));
            emailUrl = params.toString();
          } else {
            emailSubject =
                Util.getTranslated(context, "product_inquiry_email_subject") +
                    productName;
            emailBody =
                '''${Util.getTranslated(context, "product_inquiry_email_body_1")} $productName.\r\n${Util.getTranslated(context, "product_inquiry_email_body_2")}\r\n${Util.getTranslated(context, "product_inquiry_email_body_3")}\r\n${Util.getTranslated(context, "product_inquiry_email_body_4")}\r\n${Util.getTranslated(context, "product_inquiry_email_body_5")}\r\n${Util.getTranslated(context, "product_inquiry_email_body_6")}<br>
${Util.getTranslated(context, "product_inquiry_email_body_7")}''';

            final Uri params = Uri(
                scheme: 'mailto',
                path: country == Constants.COUNTRY_CODE_MALAYSIA
                    ? Constants.BEHN_MEYER_EMAIL
                    : Constants.BEHN_MEYER_EMAIL_VIETNAM,
                query: encodeQueryParameters(<String, String>{
                  'subject': '$emailSubject',
                  'body': '$emailBody'
                }));

            emailUrl =
                params.toString().replaceAll("%3Cbr%3E%0A", "%0D%0A%0D%0A");
          }
        }
      } else {
        emailSubject =
            Util.getTranslated(context, "product_inquiry_email_subject") +
                productName;
        emailBody =
            '''${Util.getTranslated(context, "product_inquiry_email_body_1")} $productName.\r\n${Util.getTranslated(context, "product_inquiry_email_body_2")}\r\n${Util.getTranslated(context, "product_inquiry_email_body_3")}\r\n${Util.getTranslated(context, "product_inquiry_email_body_4")}\r\n${Util.getTranslated(context, "product_inquiry_email_body_5")}\r\n${Util.getTranslated(context, "product_inquiry_email_body_6")}<br>
${Util.getTranslated(context, "product_inquiry_email_body_7")}''';

        final Uri params = Uri(
            scheme: 'mailto',
            path: country == Constants.COUNTRY_CODE_MALAYSIA
                ? Constants.BEHN_MEYER_EMAIL
                : Constants.BEHN_MEYER_EMAIL_VIETNAM,
            query: encodeQueryParameters(<String, String>{
              'subject': '$emailSubject',
              'body': '$emailBody'
            }));

        emailUrl = params.toString().replaceAll("%3Cbr%3E%0A", "%0D%0A%0D%0A");
      }

      Util.printInfo(emailUrl);
      if (await canLaunch(emailUrl)) {
        await launch(emailUrl);
      } else {
        throw 'Could not launch $emailUrl';
      }
    } else {
      _launchEmail(
          country == Constants.COUNTRY_CODE_MALAYSIA
              ? Constants.BEHN_MEYER_EMAIL
              : Constants.BEHN_MEYER_EMAIL_VIETNAM,
          Uri.encodeFull(
              Util.getTranslated(context, "product_inquiry_email_subject") +
                  productName),
          Uri.encodeFull(
              Util.getTranslated(context, "product_inquiry_email_body") +
                  productName));
    }
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void onDealer(BuildContext context) {
    print('onDealer');
    Navigator.pushNamed(context, MyRoute.productDealerRoute,
        arguments: ProductDealerArguments(product.category.id, true));
  }

  void onUsefulInfo(BuildContext context) {
    print('onUsefulInfo');
    if (product != null) {
      Util.printInfo("PRODUCT NOT NIL");
      Navigator.pushNamed(context, MyRoute.productUsefulInfoRoute,
          arguments: PageArguments(product.id));
    }
  }

  Future<ui.Image> _getImage(String imgUrl) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    final String url = imgUrl;
    Image image = Image.network(url);

    image.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool isSync) {
      print('Image SIZE: ${info.image.width}');
      if (!completer.isCompleted) {
        completer.complete(info.image);
      }
    }));

    return completer.future;
  }

  _launchEmail(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
