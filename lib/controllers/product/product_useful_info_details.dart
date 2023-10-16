import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/models/page_argument/photo_view_single_argument.dart';
import 'package:behn_meyer_flutter/models/product/product_article.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class ProductUsefulInfoDetails extends StatefulWidget {

  final ProductArticle infoDetails;

  ProductUsefulInfoDetails({Key key, this.infoDetails}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductUsefulInfoDetailsState();
  }
}

class _ProductUsefulInfoDetailsState extends State<ProductUsefulInfoDetails> {

  ProductArticle article = ProductArticle();

  @override
  void initState() {
    article = widget.infoDetails;
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: Constants.analytics_product_useful_info_list_details);
  }

  @override
  Widget build(BuildContext context) {
    return 
     _detailList(context, article);
  }

  Widget _detailList(BuildContext context, ProductArticle article){
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(children: [
          _headerList(context, article.image),
          _infoArticleTitle(article.title),
          _infoArticleContent(article.content)
        ],
      )
    );
  }

   Widget _headerList(BuildContext context, String image){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _headerImages(context, image)
          ]
        ),
      ],
    );
  }

  Widget _headerImages(BuildContext context, String image) {
    String imageUrl = image;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child:
        SizedBox(
        height: screenWidth/2,
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              child: headerImagePageView(imageUrl)
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  backButton()
                ]
              ),
            ),
          ],
        )
      )
    );
  }

  Widget headerImagePageView(String imgUrl){
    return GestureDetector(
      onTap: () {
        if (imgUrl != null){
          Navigator.pushNamed(
                      context, MyRoute.photoViewSingleRoute,
                      arguments: PhotoViewSingleArgument(imgUrl));
        }
      },
      child: imgUrl != null ? DisplayImage(imgUrl, 'placeholder_3.png', boxFit: BoxFit.cover,) : Image.asset(Constants.ASSET_IMAGES+'placeholder_1.png', fit: BoxFit.cover)
    );
  }

    Widget backButton(){
    return ClipOval(
      child: Material(
        color: Colors.black.withOpacity(0.5), // button color
        child: InkWell(
          splashColor:  Colors.black.withOpacity(0.5), // inkwell color
          child: SizedBox(width: 30, height: 30, 
            child: Icon(Icons.arrow_back_ios_rounded, size: 20, color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
        ),
      ),
    );
  }


  Widget _infoArticleTitle(String title){
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(title, style: AppFont.bold(24, color: AppColor.appBlack(), decoration: TextDecoration.none)),
    );
  }

  Widget _infoArticleContent(String content){
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(content, style: AppFont.regular(14, color: AppColor.appBlack(), decoration: TextDecoration.none)),
    );
  }


}