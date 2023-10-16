import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:flutter/material.dart';

class DisplayImage extends StatefulWidget {
  final String url;
  final String placeholder;
  final double width;
  final double height;
  final BoxFit boxFit;

  DisplayImage(this.url, this.placeholder,
      {key: Key, this.width, this.height, this.boxFit});

  @override
  State<StatefulWidget> createState() {
    return _DisplayImage();
  }
}

class _DisplayImage extends State<DisplayImage> {
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
    return (accessToken != null && accessToken.length > 0)
        ? FadeInImage(
            fadeInDuration: const Duration(milliseconds: 100),
            fadeOutDuration: const Duration(milliseconds: 50),
            placeholder:
                AssetImage(Constants.ASSET_IMAGES + widget.placeholder),
            image: NetworkImage(
              widget.url,
              headers: {"Authorization": "Bearer $accessToken"},
            ),
            width: widget.width ?? null,
            height: widget.height ?? null,
            fit: widget.boxFit ?? BoxFit.cover,
          )
        : Image.asset(
            Constants.ASSET_IMAGES + widget.placeholder,
            width: widget.width ?? null,
            height: widget.height ?? null,
            fit: widget.boxFit ?? BoxFit.cover,
          );
  }
}
