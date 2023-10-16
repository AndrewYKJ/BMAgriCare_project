import 'package:app_settings/app_settings.dart';
import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/controllers/authentication/auth_widgets.dart';
import 'package:behn_meyer_flutter/controllers/dealer/dealer_dialog.dart';
import 'package:behn_meyer_flutter/dio/api/dealer/dealer_api.dart';
import 'package:behn_meyer_flutter/models/dealer/outlet.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/widget/floating_button_scroll_to_top.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class Dealer extends StatefulWidget {
  final int productCatId;
  final bool isFromProducts;
  // Dealer({Key key, this.isFromProducts}) : super(key: key);
  Dealer({Key key, this.productCatId, this.isFromProducts}) : super(key: key);

  @override
  DealerState createState() => DealerState();
}

class DealerState extends State<Dealer> with WidgetsBindingObserver {
  GoogleMapController mapController;
  static final LatLng _kMapCenter =
      LatLng(3.0451071114439308, 101.56535625089315);
  static final CameraPosition _kInitialPosition =
      CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);
  Location _location = Location();
  List outlets = [];
  ScrollController _sc = new ScrollController();
  static int page = 1;
  final int size = 2000;
  bool isLoading = true;
  bool _serviceEnabled;
  bool noMore = false;
  bool wasNotGranted = false;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  bool isFirstTime = false;
  double scrollMark;
  bool isReversing = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _location.onLocationChanged.listen((l) {
      if (isFirstTime) {
        if (_permissionGranted != null){
          if (_permissionGranted == PermissionStatus.granted){
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 13),
              ),
            );
            _locationData = l;
          }
        }
        isFirstTime = false;
      }
    });
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

  void checkLocationPermission() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        EasyLoading.dismiss();
        return;
      }
    }
    setState(() {
      isFirstTime = true;
    });

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      EasyLoading.dismiss();
      Util.printInfo("permission denied : $_permissionGranted");
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        Util.printInfo("permission granted from denied : $_permissionGranted");
        _locationData = await _location.getLocation();
      } else {
        if (_permissionGranted == PermissionStatus.deniedForever || _permissionGranted == PermissionStatus.grantedLimited) {
          Util.printInfo(
              "permission deniedForever from denied : $_permissionGranted");
          if (Platform.isIOS) {
            Util.printInfo("IS IOS");
            showDialog(
              context: context,
              builder: (_) => new CupertinoAlertDialog(
                title: new Text(Util.getTranslated(
                    context, 'alert_dialog_title_info_text')),
                content: new Text(
                    Util.getTranslated(context, 'dealer_enable_location')),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(Util.getTranslated(
                        context, 'alert_dialog_cancel_text')),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoDialogAction(
                    child:
                        Text(Util.getTranslated(context, 'dealer_go_settings')),
                    onPressed: () {
                      setState(() {
                        wasNotGranted = true;
                      });
                      Navigator.pop(context);
                      AppSettings.openLocationSettings();
                    },
                  ),
                ],
              ),
            );
            if (_permissionGranted == PermissionStatus.granted) {
              Util.printInfo(
                  "permission granted from denied forever : $_permissionGranted");
              _locationData = await _location.getLocation();
            }
          }
        } else {
          Util.printInfo("permission others from denied : $_permissionGranted");
        }
      }
    } else if (_permissionGranted == PermissionStatus.granted) {
      Util.printInfo("permission granted : $_permissionGranted");
      _locationData = await _location.getLocation();
    } else if (_permissionGranted == PermissionStatus.deniedForever || _permissionGranted == PermissionStatus.grantedLimited) {
      Util.printInfo("permission denied forever : $_permissionGranted");
      if (Platform.isIOS) {
        Util.printInfo("IS IOS");
        setState(() {
          wasNotGranted = true;
        });
        showDialog(
          context: context,
          builder: (_) => new CupertinoAlertDialog(
            title: new Text(
                Util.getTranslated(context, 'alert_dialog_title_info_text')),
            content:
                new Text(Util.getTranslated(context, 'dealer_enable_location')),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                    Util.getTranslated(context, 'alert_dialog_cancel_text')),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text(Util.getTranslated(context, 'dealer_go_settings')),
                onPressed: () {
                  Navigator.pop(context);
                  AppSettings.openLocationSettings();
                },
              ),
            ],
          ),
        );
        if (_permissionGranted == PermissionStatus.granted) {
          Util.printInfo(
              "permission granted from denied forever : $_permissionGranted");
          _locationData = await _location.getLocation();
        }
      }
    } else {
      Util.printInfo("permission other : $_permissionGranted");
    }

    this.refresh();
  }

  @override
  void initState() {
    page = 1;
    noMore = false;
    isFirstTime = false;
    checkLocationPermission();
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_tab_dealer);

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        if (!noMore) {
          // _getMoreData(page);
          if (widget.isFromProducts) {
            _getOutlets(widget.productCatId);
          } else {
            _getOutlets(null);
          }
        }
      }

      if (_sc.position.userScrollDirection == ScrollDirection.forward) {
        if ((scrollMark - _sc.position.pixels) > 50.0) {
          setState(() {
            isReversing = true;
          });
        }
      } else {
        scrollMark = _sc.position.pixels;
        setState(() {
          isReversing = false;
        });
      }
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _sc.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<List<Outlet>> fetchOutlets(BuildContext context, double currentLat,
      double currentLng, int productCatId, int page, int size) async {
    DealerApi dealerApi = DealerApi(context);
    return dealerApi.fetchOutletList(
        currentLat, currentLng, productCatId, page, size);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        Util.printInfo('App is resumed');
        // widget is resumed
        if (wasNotGranted) {
          setState(() {
            wasNotGranted = false;
          });
          EasyLoading.show(maskType: EasyLoadingMaskType.black);
          checkLocationPermission();
        }
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        break;
      case AppLifecycleState.paused:
        // widget is paused
        break;
      case AppLifecycleState.detached:
        // widget is detached
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingButtonScrollToTop(_sc, isReversing),
      body: SafeArea(
        child: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Stack(children: [
              mapHeader(),
              widget.isFromProducts
                  ? closeBtn(context)
                  : SizedBox(
                      height: 0,
                    ),
            ])),
      ),
    );
  }

  Widget mapHeader() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: refresh,
        color: AppColor.appBlue(),
        child: ListView.builder(
          itemCount: (outlets.length > 0)
              ? outlets.length + 2
              : (widget.productCatId == null)
                  ? ((AppCache.cOutlet != null && AppCache.cOutlet.length > 0)
                      ? AppCache.cOutlet.length + 2
                      : 2)
                  : 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              // return the header
              return SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    zoomGesturesEnabled: true,
                    initialCameraPosition: _kInitialPosition,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: _createMarker(outlets),
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                      new Factory<OneSequenceGestureRecognizer>(
                        () => new EagerGestureRecognizer(),
                      ),
                    ].toSet()),
              );
            } else {
              index -= 1;
              var dealerCount;
              if (outlets.length > 0) {
                dealerCount = outlets.length;
              } else {
                if (widget.isFromProducts) {
                  dealerCount = 0;
                } else {
                  dealerCount =
                      (AppCache.cOutlet != null && AppCache.cOutlet.length > 0)
                          ? AppCache.cOutlet.length
                          : 0;
                }
              }
              if (index == dealerCount) {
                return _buildProgressIndicator();
              } else {
                // return row
                var item = (outlets.length > 0)
                    ? outlets[index]
                    : (widget.productCatId == null)
                        ? ((AppCache.cOutlet != null &&
                                AppCache.cOutlet.length > 0)
                            ? AppCache.cOutlet[index]
                            : outlets[index])
                        : null;
                // outlets[index];
                if (item == null) {
                  return Text("Hello World");
                } else {
                  return new Container(
                    width: screenWidth,
                    height: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              width: screenWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: AppFont.bold(16,
                                              color: AppColor.appBlue(),
                                              decoration: TextDecoration.none),
                                        ),
                                        Text(
                                          item.address,
                                          style: AppFont.regular(14,
                                              color: AppColor.appBlack(),
                                              decoration: TextDecoration.none),
                                        ),
                                        // Text(item.contact)
                                      ],
                                    ),
                                  ),
                                  Container(
                                      width: 70,
                                      child: mapButton(context, item.lat,
                                          item.lng, item.name, item.name))
                                ],
                              ),
                            )),
                        (item.contactNo != null && item.contactNo.length > 0)
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  (item.contactNo != null &&
                                          item.contactNo.length > 0)
                                      ? contactButton(
                                          context, item.contactNo, item.name)
                                      : SizedBox(
                                          height: 0,
                                        ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  (item.contactNo != null &&
                                          item.contactNo.length > 0)
                                      ? whatsappButton(
                                          context, item.contactNo, item.name)
                                      : SizedBox(
                                          height: 0,
                                        ),
                                ],
                              )
                            : SizedBox(
                                height: 0,
                              ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: screenWidth - 16,
                          child: const MySeparator(
                              color: Color.fromRGBO(18, 51, 119, 1.0)),
                        ),
                      ],
                    ),
                  );
                }
              }
            }
          },
          controller: _sc,
        ),
      ),
    );
  }

  Widget closeBtn(BuildContext context) {
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
                    splashColor: Colors.black.withOpacity(0.5), // inkwell color
                    child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(Icons.close_rounded,
                            size: 20, color: Colors.white)),
                    onTap: () {
                      Util.printInfo("on close");
                      Navigator.pop(context);
                    },
                  ),
                ),
              )
            ]));
  }

  Widget mapButton(BuildContext context, double lat, double long, String name,
      String repName) {
    return InkWell(
      splashColor: Colors.white.withOpacity(0.5), // inkwell color
      child: SizedBox(
          width: 35,
          height: 35,
          child: Image.asset(
              Constants.ASSET_IMAGES + 'navigate_location_icon.png')),
      onTap: () {
        Util.printInfo("on map");
        _sendNavigationAnalyticsEvent(repName);
        openMapsSheet(context, lat, long, name);
        // Navigator.pop(context);
      },
    );
  }

  Widget contactButton(BuildContext context, String contact, String repName) {
    return SizedBox(
      width: 150,
      height: 35,
      child: TextButton(
        onPressed: () {
          Util.printInfo('onContact');
          _sendPhoneCallAnalyticsEvent(repName);
          _launchCaller(contact);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(Constants.ASSET_IMAGES + 'white_phone_icon.png',
                width: 15, fit: BoxFit.contain),
            Text(
              contact,
              style: AppFont.bold(14,
                  color: Colors.white, decoration: TextDecoration.none),
            )
          ],
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.appBlue(),
          textStyle: AppFont.bold(16, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  Widget whatsappButton(BuildContext context, String contact, String repName) {
    return SizedBox(
      width: 150,
      height: 35,
      child: TextButton(
        onPressed: () async {
          Util.printInfo('onWhatsapp');
          _sendWhatsappAnalyticsEvent(repName);
          if (Platform.isAndroid) {
            _launchBrowser('https://wa.me/' + contact);
          } else if (Platform.isIOS) {
            await launch('https://wa.me/$contact', forceSafariVC: false);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(Constants.ASSET_IMAGES + 'whatsapp_icon.png',
                width: 15, fit: BoxFit.contain),
            Text(
              'WhatsApp',
              style: AppFont.bold(14,
                  color: Colors.white, decoration: TextDecoration.none),
            )
          ],
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.whatsappGreen(),
          textStyle: AppFont.bold(16, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  // void _getMoreData(int index) async {
  //   if (!isLoading && !widget.isFromProducts) {
  //     setState(() {
  //       // EasyLoading.show();
  //       isLoading = true;
  //     });
  //   }

  //   List tList = [];
  //   double lat;
  //   double lng;
  //   if (_locationData != null) {
  //     lat = _locationData.latitude;
  //     lng = _locationData.longitude;
  //   } else {
  //     lat = 3.0451071114439308;
  //     lng = 101.56535625089315;
  //   }

  //   Util.printInfo("SIZE: $size");
  //   await fetchOutlets(context, lat, lng, widget.productCatId, page, size).then(
  //       (value) {
  //     if (value.length > 0) {
  //       value.forEach((outlet) {
  //         tList.add(outlet);
  //       });
  //     } else {
  //       setState(() {
  //         noMore = true;
  //       });
  //     }
  //   }, onError: (error) {
  //     EasyLoading.dismiss();
  //     if (error is DioError) {
  //       if (error.response.data != null) {
  //         ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
  //         Util.showAlertDialog(
  //             context,
  //             Util.getTranslated(context, 'alert_dialog_title_error_text'),
  //             errorDTO.message);
  //       } else {
  //         Util.showAlertDialog(
  //             context,
  //             Util.getTranslated(context, 'alert_dialog_title_error_text'),
  //             Util.getTranslated(
  //                 context, 'general_alert_message_error_response'));
  //       }
  //     } else {
  //       Util.showAlertDialog(
  //           context,
  //           Util.getTranslated(context, 'alert_dialog_title_error_text'),
  //           Util.getTranslated(
  //               context, 'general_alert_message_error_response_2'));
  //     }
  //     Util.printInfo('FETCH OUTLETS ERROR: $error');
  //   });

  //   setState(() {
  //     EasyLoading.dismiss();
  //     isLoading = false;
  //     outlets.addAll(tList);
  //     if (widget.productCatId == null) {
  //       AppCache.cOutlet = outlets;
  //     }
  //     page++;
  //   });
  // }

  void _getOutlets(int productCatId) async {
    if (!isLoading && !widget.isFromProducts) {
      setState(() {
        // EasyLoading.show();
        isLoading = true;
      });
    }

    List tList = [];
    double lat;
    double lng;
    if (_locationData != null) {
      lat = _locationData.latitude;
      lng = _locationData.longitude;
    } else {
      lat = 3.0451071114439308;
      lng = 101.56535625089315;
    }

    Util.printInfo("SIZE: $size");
    await fetchOutlets(context, lat, lng, productCatId, page, size).then(
        (value) {
      if (value.length > 0) {
        value.forEach((outlet) {
          tList.add(outlet);
        });
      } else {
        if (productCatId != null) {
          _getOutlets(null);
        } else {
          setState(() {
            noMore = true;
          });
        }
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
      Util.printInfo('FETCH OUTLETS ERROR: $error');
    });

    setState(() {
      EasyLoading.dismiss();
      isLoading = false;
      outlets.addAll(tList);
      if (widget.productCatId == null) {
        AppCache.cOutlet = outlets;
      }
      page++;
    });
  }

  Future<void> refresh() async {
    setState(() {
      page = 1;
      noMore = false;
      outlets.clear();
    });
    if (_locationData != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(_locationData.latitude, _locationData.longitude),
              zoom: 11),
        ),
      );
    } else {
      if (mapController != null){
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(3.0451071114439308, 101.56535625089315), zoom: 11),
          ),
        );
      }
    }
    // _getMoreData(page);
    if (widget.isFromProducts) {
      _getOutlets(widget.productCatId);
    } else {
      _getOutlets(null);
    }
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

  _launchCaller(String contact) async {
    String url = "tel:" + contact;
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

  Set<Marker> _createMarker(List outlets) {
    List<Marker> markers = [];
    if (outlets.length > 0) {
      outlets.forEach((outlet) {
        if (outlet is Outlet) {
          var tMarker = Marker(
              position: LatLng(outlet.lat, outlet.lng),
              markerId: MarkerId(outlet.name),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialogBox(
                        outlet: outlet,
                      );
                    });
              });
          markers.add(tMarker);
        }
      });
    }

    return Set<Marker>.of(markers);
  }

  Future<void> _sendWhatsappAnalyticsEvent(String repName) async {
    await FirebaseAnalytics().logEvent(
      name: 'whatsapp_msg',
      parameters: <String, dynamic>{'sales_rep': repName},
    );
  }

  Future<void> _sendPhoneCallAnalyticsEvent(String repName) async {
    await FirebaseAnalytics().logEvent(
      name: 'phone_call',
      parameters: <String, dynamic>{'sales_rep': repName},
    );
  }

  Future<void> _sendNavigationAnalyticsEvent(String repName) async {
    await FirebaseAnalytics().logEvent(
      name: 'map_navigation',
      parameters: <String, dynamic>{'sales_rep': repName},
    );
  }
}
