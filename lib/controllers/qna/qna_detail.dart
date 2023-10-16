import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/qna/create_qna_comment_api.dart';
import 'package:behn_meyer_flutter/dio/api/qna/qna_comment_api.dart';
import 'package:behn_meyer_flutter/dio/api/qna/qna_detail_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/page_argument/photo_view_single_argument.dart';
import 'package:behn_meyer_flutter/models/qna/qna.dart';
import 'package:behn_meyer_flutter/models/qna/qna_comments.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:behn_meyer_flutter/widget/floating_button_scroll_to_top.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class QnaDetail extends StatefulWidget {
  final int qnaId;
  final bool isAvailableGiveComment;

  QnaDetail({Key key, this.qnaId, this.isAvailableGiveComment})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _QnaDetail();
  }
}

class _QnaDetail extends State<QnaDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  QnaDTO qnaDTO;
  List<dynamic> qnaCommentList = [];
  int pageNo = 1;
  int pageSize = 20;
  bool noMoreData = false;
  final commentController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  double scrollMark;
  bool isReversing = false;

  Future<Response> fetchQnaDetail(BuildContext ctx) {
    QnaDetailApi qnaDetailApi = QnaDetailApi(ctx);
    return qnaDetailApi.call(widget.qnaId);
  }

  Future<List<dynamic>> fetchQnaComments(BuildContext ctx) {
    QnaCommentApi qnaCommentApi = QnaCommentApi(ctx);
    return qnaCommentApi.call(widget.qnaId, pageNo, pageSize);
  }

  Future<Response> submitComments(BuildContext ctx) {
    var bodyData = {"content": commentController.text.trim()};
    CreateQnaCommentApi createQnaCommentApi =
        CreateQnaCommentApi(ctx, bodyData: bodyData);
    return createQnaCommentApi.call(widget.qnaId);
  }

  Future<void> _getData() async {
    pageNo = 1;
    pageSize = 20;
    noMoreData = false;
    qnaCommentList.clear();
    getQnaDetail();
  }

  void getQnaDetail() {
    fetchQnaDetail(_scaffoldKey.currentContext).then((value) {
      if (value != null) {
        qnaDTO = QnaDTO.fromJson(value.data);
        getComments();
      }
    }, onError: (error) {
      if (error is DioError) {
        if (error.response != null) {
          if (error.response.data != null){
            Util.showAlertDialog(
              _scaffoldKey.currentContext,
              Util.getTranslated(context, "alert_dialog_title_error_text"),
              ErrorDTO.fromJson(error.response.data).message +
                  "(${ErrorDTO.fromJson(error.response.data).code})");
          } else {
            Util.showAlertDialog(
            _scaffoldKey.currentContext,
            Util.getTranslated(context, "alert_dialog_title_error_text"),
            Util.getTranslated(
                context, "general_alert_message_error_response"));
          }
        } else {
          Util.showAlertDialog(
            _scaffoldKey.currentContext,
            Util.getTranslated(context, "alert_dialog_title_error_text"),
            Util.getTranslated(
                context, "general_alert_message_error_response"));
        }
      } else {
        Util.showAlertDialog(
            _scaffoldKey.currentContext,
            Util.getTranslated(context, "alert_dialog_title_error_text"),
            Util.getTranslated(
                context, "general_alert_message_error_response_2"));
      }
    });
  }

  void getComments() {
    if (!noMoreData) {
      fetchQnaComments(_scaffoldKey.currentContext).then((value) {
        setState(() {
          if (value != null && value.length > 0) {
            if (value.length < pageSize) {
              noMoreData = true;
            } else {
              noMoreData = false;
            }

            qnaCommentList.addAll(value);
          }
          pageNo++;
        });
      }, onError: (error) {
        setState(() {});
      });
    }
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      print("##### Scroll reach bottom #####");
      if (noMoreData) {
        return;
      }

      getComments();
    }

    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if ((scrollMark - _scrollController.position.pixels) > 50.0) {
        setState(() {
          isReversing = true;
        });
      }
    } else {
      scrollMark = _scrollController.position.pixels;
      setState(() {
        isReversing = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_qna_detail);
    _scrollController.addListener(_scrollListener);
    getQnaDetail();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        floatingActionButton:
            floatingButtonScrollToTop(_scrollController, isReversing),
        appBar: CustomAppBar(
          child: backButton(context),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Colors.white,
            child: qnaDTO != null ? showData(context) : showLoadingBar(context),
          ),
        ),
      ),
    );
  }

  Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16.0),
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
    );
  }

  Widget showData(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColor.appBlue(),
            onRefresh: _getData,
            child: ListView(
              padding: EdgeInsets.only(bottom: 30.0),
              controller: _scrollController,
              children: [
                SizedBox(height: 20),
                widget.isAvailableGiveComment
                    ? labelText(
                        Util.getTranslated(
                            context, "qna_my_submitted_question_text"),
                        AppFont.bold(24,
                            color: AppColor.appBlue(),
                            decoration: TextDecoration.none))
                    : labelText(
                        Util.getTranslated(context, "qna_hot_topics_text"),
                        AppFont.bold(24,
                            color: AppColor.appBlue(),
                            decoration: TextDecoration.none)),
                SizedBox(height: 20),
                labelText(
                    qnaDTO.title,
                    AppFont.bold(24,
                        color: AppColor.appBlack(),
                        decoration: TextDecoration.none)),
                SizedBox(height: 20),
                labelText(
                    qnaDTO.content,
                    AppFont.regular(16,
                        color: AppColor.appBlack(),
                        decoration: TextDecoration.none)),
                SizedBox(height: 20),
                gridQnaImages(context),
                qnaDTO.answer != null
                    ? displayQnaAnswer(context)
                    : SizedBox(height: 20),
                displayComments(context),
              ],
            ),
          ),
        ),
        AppCache.me.id == qnaDTO.createdBy.id
            ? giveCommentsLayout(context)
            : Container(),
      ],
    );
  }

  Widget showLoadingBar(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }

  Widget labelText(String labelName, TextStyle labelTextStyle) {
    return Text(
      labelName,
      style: labelTextStyle,
    );
  }

  Widget gridQnaImages(BuildContext context) {
    if (qnaDTO.images != null && qnaDTO.images.length > 0) {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: qnaDTO.images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          crossAxisCount: 3,
          childAspectRatio: 1 / 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          return qnaImageItem(context, qnaDTO.images[index]);
        },
      );
    } else {
      return Container();
    }
  }

  Widget qnaImageItem(BuildContext context, String imgUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.photoViewSingleRoute,
            arguments: PhotoViewSingleArgument(imgUrl));
      },
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            child: DisplayImage(
              imgUrl,
              'placeholder_1.png',
              width: double.infinity,
              height: double.infinity,
              boxFit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget displayQnaAnswer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 20.0),
      color: Colors.grey.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: qnaDTO.answer.createdBy.role == "Admin"
                      ? (qnaDTO.answer.createdBy.photo != null &&
                              qnaDTO.answer.createdBy.photo.length > 0)
                          ? DisplayImage(
                              qnaDTO.answer.createdBy.photo,
                              'profile_placeholder.png',
                              width: 40.0,
                              height: 40.0,
                              boxFit: BoxFit.cover,
                            )
                          : Image.asset(
                              Constants.ASSET_IMAGES + 'behn-meyer-admin.png',
                              height: 40.0,
                              width: 40.0,
                              fit: BoxFit.cover,
                            )
                      : DisplayImage(
                          qnaDTO.answer.createdBy.photo,
                          'profile_placeholder.png',
                          width: 40.0,
                          height: 40.0,
                          boxFit: BoxFit.cover,
                        ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        qnaDTO.answer.createdBy.name,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.bold(
                          18,
                          color: AppColor.appBlue(),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        Util.displayTimeAgoFromTimestamp(
                            context, qnaDTO.answer.createdAt),
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.regular(
                          12,
                          color: AppColor.appBlack(),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: labelText(
              qnaDTO.answer.content,
              AppFont.regular(16,
                  color: AppColor.appBlack(), decoration: TextDecoration.none),
            ),
          ),
          displayAnswerRowImages(qnaDTO.answer.images),
        ],
      ),
    );
  }

  Widget displayAnswerRowImages(List<String> images) {
    if (images != null && images.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                crossAxisCount: 5,
                childAspectRatio: 1 / 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                return answerImageItem(context, images[index]);
              },
            ),
          ),
          SizedBox(height: 20),
          dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
      ],
    );
  }

  Widget answerImageItem(BuildContext context, String imgUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.photoViewSingleRoute,
            arguments: PhotoViewSingleArgument(imgUrl));
      },
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            child: DisplayImage(
              imgUrl,
              'placeholder_1.png',
              width: 80.0,
              height: 80.0,
              boxFit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget displayComments(BuildContext context) {
    if (qnaCommentList != null && qnaCommentList.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: qnaCommentList.length,
        itemBuilder: (BuildContext context, int index) {
          return qnaCommentItem(
              context, QnaCommentDTO.fromJson(qnaCommentList[index]));
        },
      );
    }
    return Container();
  }

  Widget qnaCommentItem(BuildContext context, QnaCommentDTO qnaCommentDTO) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.grey.withOpacity(0.1),
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: qnaCommentDTO.createdBy.role == "Admin"
                      ? (qnaDTO.answer.createdBy.photo != null &&
                              qnaDTO.answer.createdBy.photo.length > 0)
                          ? DisplayImage(
                              qnaDTO.answer.createdBy.photo,
                              'profile_placeholder.png',
                              width: 40.0,
                              height: 40.0,
                              boxFit: BoxFit.cover,
                            )
                          : Image.asset(
                              Constants.ASSET_IMAGES + 'behn-meyer-admin.png',
                              height: 40.0,
                              width: 40.0,
                              fit: BoxFit.cover,
                            )
                      : DisplayImage(
                          qnaCommentDTO.createdBy.photo,
                          'profile_placeholder.png',
                          width: 40.0,
                          height: 40.0,
                          boxFit: BoxFit.cover,
                        ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (AppCache.me != null &&
                                AppCache.me.id == qnaCommentDTO.createdBy.id)
                            ? qnaCommentDTO.createdBy.name + " (me)"
                            : qnaCommentDTO.createdBy.name,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.bold(
                          18,
                          color: AppColor.appBlue(),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        Util.displayTimeAgoFromTimestamp(
                            context, qnaCommentDTO.createdAt),
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.regular(
                          12,
                          color: AppColor.appBlack(),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: labelText(
              qnaCommentDTO.content,
              AppFont.regular(16,
                  color: AppColor.appBlack(), decoration: TextDecoration.none),
            ),
          ),
          SizedBox(height: 20),
          dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
        ],
      ),
    );
  }

  Widget giveCommentsLayout(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 20.0),
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: Util.getTranslated(
                    context, "qna_question_add_comment_hint_text"),
                hintStyle: AppFont.regular(16,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none),
              ),
              style: AppFont.regular(
                16,
                color: AppColor.appBlack(),
                decoration: TextDecoration.none,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              if (commentController.text.isNotEmpty) {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }

                await EasyLoading.show(maskType: EasyLoadingMaskType.black);
                submitComments(context).then((value) {
                  EasyLoading.dismiss();
                  commentController.clear();
                  pageNo = 1;
                  pageSize = 20;
                  noMoreData = false;
                  qnaCommentList.clear();
                  getComments();
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
                });
              }
            },
            child: Container(
              padding: EdgeInsets.only(left: 10.0),
              child: Image.asset(
                Constants.ASSET_IMAGES + "ic_send.png",
                width: 20.0,
                height: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
