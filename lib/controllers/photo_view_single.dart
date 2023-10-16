import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewSingleWrapper extends StatefulWidget {
  PhotoViewSingleWrapper({this.loadingBuilder, this.imgUrl});

  final LoadingBuilder loadingBuilder;
  final String imgUrl;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewSingleWrapperState();
  }
}

class _PhotoViewSingleWrapperState extends State<PhotoViewSingleWrapper> {
  String accessToken = "";
  @override
  void initState() {
    super.initState();
    AppCache.getStringValue(AppCache.ACCESS_TOKEN_PREF).then((value) {
      setState(() {
        accessToken = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: [
            (accessToken != null && accessToken.length > 0)
                ? PhotoView(
                    imageProvider: NetworkImage(widget.imgUrl,
                        headers: {"Authorization": "Bearer $accessToken"}),
                    backgroundDecoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4.1,
                  )
                : Image.asset(
                    Constants.ASSET_IMAGES + 'placeholder_3.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 10, top: 40),
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
          ],
        ),
      ),
    );
  }
}
