import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/product/product_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/product/product_article.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class ProductUsefulInfo extends StatefulWidget {

  final int productId;

  ProductUsefulInfo({Key key, this.productId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductUsefulInfoState();
  }
}

class _ProductUsefulInfoState extends State<ProductUsefulInfo> {

  List infos = [];
  ScrollController _sc = new ScrollController();
  static int page = 1;
  final int size = 20;
  bool isLoading = false;
  bool noMore = false;

  @override
  void initState() {
    page = 1;
    noMore = false;
    if (widget.productId != null) {
      this._getMoreData(page);
    }
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: Constants.analytics_product_useful_info_list);

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        if (!noMore) {
          _getMoreData(page);
        }
      }
    });    
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  Future<List<ProductArticle>> fetchProductArticle(BuildContext context, int productId, int page, int size) async {
    ProductApi productApi = ProductApi(context);
    return productApi.getProductArticle(productId, page, size);
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (widget.productId != null ){
      return Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                backButton(context),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Text(Util.getTranslated(context, 'product_useful_info_header'), style: AppFont.bold(24, color: AppColor.appBlue(), decoration: TextDecoration.none),),
                )
              ]
            ), 
            height: 80,),
            body: Container(
              child: RefreshIndicator(
                onRefresh: refresh,
                color: AppColor.appBlue(),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: infos.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                  if (index == infos.length) {
                    return _buildProgressIndicator();
                  } else {
                    var item = infos[index];
                    return InkWell(
                      onTap: (){
                        setState(() {
                          Navigator.pushNamed(context, MyRoute.productUsefulInfoDetailsRoute, arguments: item);
                        });
                      },
                      child: Container(
                      width: screenWidth,
                      height: 130,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 8,),
                          expandedList(context, item),
                          SizedBox(height: 16),
                          SizedBox(width: screenWidth-16, child: dottedLineSeperator(color: AppColor.appBlue()),),
                        ],
                      )
                    )
                    );
                  }
                },
                controller: _sc,
                ),
              ),
            ),
            ),
          )
      );
    } else {
      return Container(color: Colors.blue, width: screenWidth, height: screenHeight,);
    }
    
  }

  void _getMoreData(int index) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      List tList = [];
      await fetchProductArticle(context, widget.productId, page, size).then((value){
        if (value.length > 0) {
          value.forEach((news) {
            tList.add(news);
          });
        } else {
          setState(() {
            noMore = true;
          });
        }
      }, onError: (error) {
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
        Util.printInfo('FETCH NEWS ERROR: $error');
      });

      setState(() {
        isLoading = false;
        infos.addAll(tList);
        page++;
      });
    }
  }

  Future<void> refresh() async{
    setState(() {
      page = 1;
      noMore = false;
      infos.clear();
    });
    _getMoreData(page);
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
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
                    Navigator.of(context).pop();
                  },
              ),
            ),
          ),
        ),
    );
  }

  Widget expandedList(BuildContext context, ProductArticle item){
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        width: screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
                          
          children: [ 
          SizedBox(width: 12),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.appLightGreyColor(), width: 1),
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: articleImage(context, item.image)        
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(item.title, maxLines: 2, style: AppFont.bold(16, color: AppColor.appBlack(), decoration: TextDecoration.none),),
          ),
          Container(
            // color: Colors.blue,
            width: 40,
            height: 25,
            child: Icon(Icons.navigate_next_rounded, size: 30, color: AppColor.appBlue()),
          )
          ],
        ),
      );
    
    // Expanded(
    //   flex: 3,
    //   child:         
    // );             
  }

  Widget articleImage(BuildContext context, String imageUrl) {
   return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)), 
        child: imageUrl != null ? DisplayImage(imageUrl, 'placeholder_1.png', boxFit: BoxFit.cover,) : Image.asset(Constants.ASSET_IMAGES+'placeholder_1.png', fit: BoxFit.cover)
      );
  } 


}