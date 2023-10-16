import 'dart:io';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/models/dealer/outlet.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDialogBox extends StatefulWidget {
  final Outlet outlet;

  const CustomDialogBox({Key key, this.outlet}) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0,bottom: 12.0
          ),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(color: Colors.grey,offset: Offset(0,0),
              blurRadius: 10
              ),
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // closeBtn(context),
              Text(widget.outlet.name,style: AppFont.bold(17, color: AppColor.appBlue(), decoration: TextDecoration.none),),
              SizedBox(height: 15,),
              Text(widget.outlet.address,style: AppFont.regular(15, color: AppColor.appBlack()),textAlign: TextAlign.center,),
              SizedBox(height: 22,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                widget.outlet.contactNo != null ? contactButton(context, widget.outlet.contactNo, widget.outlet.name) : SizedBox(width: 0,),
                widget.outlet.contactNo != null ? SizedBox(width: 20) : SizedBox(width: 0),
                widget.outlet.contactNo != null ? whatsappButton(context, widget.outlet.contactNo, widget.outlet.name) : SizedBox(width: 0),
                widget.outlet.contactNo != null ? SizedBox(width: 20) : SizedBox(width: 0),
                mapButton(context, widget.outlet.lat, widget.outlet.lng, widget.outlet.name, widget.outlet.name)
              ],)
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: 
              //   TextButton(
              //       onPressed: (){
              //         Navigator.of(context).pop();
              //       },
              //       child: Text(widget.text,style: TextStyle(fontSize: 18),)),
              // ),
            ],
          ),
        ),
        // Positioned(
        //   left: 12.0,
        //     right: 12.0,
        //     child: CircleAvatar(
        //       backgroundColor: Colors.transparent,
        //       radius: 45,
        //       child: ClipRRect(
        //         borderRadius: BorderRadius.all(Radius.circular(45)),
        //           child: Image.asset("assets/model.jpeg")
        //       ),
        //     ),
        // ),
      ],
    );
  }

  Widget closeBtn(BuildContext context){
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipOval(
            child: Material(
              color: Colors.black.withOpacity(0.5), // button color
              child: InkWell(
                splashColor:  Colors.black.withOpacity(0.5), // inkwell color
                child: SizedBox(width: 30, height: 30, 
                  child: Icon(Icons.close_rounded, size: 20, color: Colors.white)),
                  onTap: () {
                    Util.printInfo("on close");
                    Navigator.pop(context);
                  },
                ),
              ),
            )
        ]      
      )
    );
  }

  Widget mapButton(BuildContext context, double lat, double long, String name, String repName) {
   return InkWell(
     splashColor:  Colors.white.withOpacity(0.5), // inkwell color
      child: SizedBox(width: 35, height: 35, 
      child: Image.asset(Constants.ASSET_IMAGES+'navigate_location_icon.png')),
      onTap: () {
        Util.printInfo("on map");
        _sendNavigationAnalyticsEvent(repName);
        openMapsSheet(context, lat, long, name);
        // Navigator.pop(context);
      },
    );
  } 

  Widget whatsappButton(BuildContext context, String contact, String repName) {
   return InkWell(
     splashColor:  Colors.white.withOpacity(0.5), // inkwell color
      child: Container(width: 35, height: 35, 
      decoration: BoxDecoration(color: AppColor.whatsappGreen(), shape: BoxShape.circle),
      child: Image.asset(Constants.ASSET_IMAGES+'whatsapp_icon.png')),
      onTap: () async {
        Util.printInfo("on whatsapp");
        _sendWhatsappAnalyticsEvent(repName);
        if (Platform.isAndroid) {
          _launchBrowser('https://wa.me/'+contact);
        } else if (Platform.isIOS) {
          await launch('https://wa.me/$contact', forceSafariVC: false);
        }
      },
    );
  } 

  Widget contactButton(BuildContext context, String contact, String repName) {
   return InkWell(
     splashColor:  Colors.white.withOpacity(0.5), // inkwell color
      child: Container(width: 35, height: 35, 
        decoration: BoxDecoration(color: AppColor.appBlue(), shape: BoxShape.circle),
      child: Image.asset(Constants.ASSET_IMAGES+'white_phone_icon.png')),
      onTap: () {
        Util.printInfo('onContact');
        _sendPhoneCallAnalyticsEvent(repName);
        _launchCaller(contact);
      },
    );
  }

   _launchCaller(String contact) async {
    String url = "tel:"+contact;   
    if (await canLaunch(url)) {
       await launch(url);
    } else {
      throw 'Could not launch $url';
    }   
  }

   _launchBrowser(String website) async {
    String url = website;   
    if (await canLaunch(url)) {
       await launch(url);
    } else {
      throw 'Could not launch $url';
    }   
  }

  openMapsSheet(context, double lat, double long, String name) async {
    try {
      final coords = Coords(lat, long);
      final title = name;
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title,
                        ),
                        title: Text(map.mapName),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _sendWhatsappAnalyticsEvent(String repName) async {
    await FirebaseAnalytics().logEvent(
      name: 'whatsapp_msg',
      parameters: <String, dynamic>{
        'sales_rep': repName
      },
    );
  }

  Future<void> _sendPhoneCallAnalyticsEvent(String repName) async {
    await FirebaseAnalytics().logEvent(
      name: 'phone_call',
      parameters: <String, dynamic>{
        'sales_rep': repName
      },
    );
  }

  Future<void> _sendNavigationAnalyticsEvent(String repName) async {
    await FirebaseAnalytics().logEvent(
      name: 'map_navigation',
      parameters: <String, dynamic>{
        'sales_rep': repName
      },
    );
  }
}