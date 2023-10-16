import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/qna/qna_list_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/page_argument/qna_arguments.dart';
import 'package:behn_meyer_flutter/models/qna/qna.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:behn_meyer_flutter/widget/floating_button_scroll_to_top.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class QnA extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QnA();
  }
}

class _QnA extends State<QnA> {
  final scrollController = ScrollController();
  double scrollMark;
  bool isReversing = false;
  bool isViewHotTopic = true;
  bool isViewOwnQuestion = false;
  String filterBy = "hot";
  int pageNo = 1;
  int pageSize = 20;
  bool isLoading = true;
  bool noMoreData = false;
  List<dynamic> qnaList = [];

  Future<List<dynamic>> fetchQnaList(
    BuildContext ctx,
  ) {
    QnaListApi qnaListApi = QnaListApi(ctx);
    return qnaListApi.call(filterBy, pageNo, pageSize);
  }

  Future<void> _getData() async {
    callFetchQnaDataList(true);
  }

  void callFetchQnaDataList(bool isReload) {
    if (isReload) {
      pageNo = 1;
      pageSize = 20;
      noMoreData = false;
      qnaList.clear();
      isLoading = true;
    }

    fetchQnaList(context).then((value) {
      if (value != null && value.length > 0) {
        if (value.length < pageSize) {
          noMoreData = true;
        }
        qnaList.addAll(value);
        pageNo++;
      }

      setState(() {
        isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      if (error is DioError) {
        if (error.response != null) {
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

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_tab_qna);

    callFetchQnaDataList(true);

    scrollController.addListener(() {
      if (scrollController.hasClients) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (noMoreData) {
            return;
          }

          callFetchQnaDataList(false);
        }

        if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if ((scrollMark - scrollController.position.pixels) > 50.0) {
            setState(() {
              isReversing = true;
            });
          }
        } else {
          scrollMark = scrollController.position.pixels;
          setState(() {
            isReversing = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          child: logo(context),
        ),
        floatingActionButton: scrollController.hasClients
            ? floatingButtonScrollToTop(scrollController, isReversing)
            : Container(),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          margin: EdgeInsets.only(left: 16, right: 16),
          child: RefreshIndicator(
            color: AppColor.appBlue(),
            onRefresh: _getData,
            child: isLoading
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        pageTitle(context),
                        SizedBox(height: 20),
                        submitQuestion(context),
                        SizedBox(height: 20),
                        dottedLineSeperator(
                            height: 1.5, color: AppColor.appBlue()),
                        SizedBox(height: 20),
                        selectionLayout(context),
                        SizedBox(height: 20),
                        Expanded(
                            child: Center(child: CircularProgressIndicator())),
                      ],
                    ),
                  )
                : ListView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 20),
                      pageTitle(context),
                      SizedBox(height: 20),
                      submitQuestion(context),
                      SizedBox(height: 20),
                      dottedLineSeperator(
                          height: 1.5, color: AppColor.appBlue()),
                      SizedBox(height: 20),
                      selectionLayout(context),
                      SizedBox(height: 20),
                      qnaListLayout(context, qnaList),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget logo(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
      ),
      color: Colors.white,
      child: Align(
        alignment: Alignment.topLeft,
        child: Image.asset(
          Constants.ASSET_IMAGES + "s_behn_meyer_logo.png",
        ),
      ),
    );
  }

  Widget pageTitle(BuildContext context) {
    return Text(
      Util.getTranslated(context, "qna_header_title"),
      style: AppFont.bold(24,
          color: AppColor.appBlack(), decoration: TextDecoration.none),
    );
  }

  Widget submitQuestion(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, MyRoute.qnaSubmitRoute)..then(onGoBack);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text(Util.getTranslated(context, "qna_submit_btn_text"))],
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.appBlue(),
          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
          textStyle: AppFont.bold(16, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
        ),
      ),
    );
  }

  Widget selectionLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (!isViewHotTopic) {
                isViewHotTopic = true;
                isViewOwnQuestion = false;
                filterBy = "hot";
                isLoading = true;
                callFetchQnaDataList(true);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isViewHotTopic ? AppColor.appBlue() : Colors.white,
              border: Border.all(
                color: Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              Util.getTranslated(context, "qna_hot_topics_text"),
              style: AppFont.bold(16,
                  color: isViewHotTopic ? Colors.white : Colors.grey,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              if (!isViewOwnQuestion) {
                isViewHotTopic = false;
                isViewOwnQuestion = true;
                filterBy = "own";
                isLoading = true;
                callFetchQnaDataList(true);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isViewOwnQuestion ? AppColor.appBlue() : Colors.white,
              border: Border.all(
                color: Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              Util.getTranslated(context, "qna_my_submitted_question_text"),
              style: AppFont.bold(16,
                  color: isViewOwnQuestion ? Colors.white : Colors.grey,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
      ],
    );
  }

  Widget qnaListLayout(BuildContext context, List<dynamic> qnaList) {
    if (qnaList != null && qnaList.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: qnaList.length,
        itemBuilder: (BuildContext context, int index) {
          return qnaItem(context, QnaDTO.fromJson(qnaList[index]));
        },
      );
    }
    return Container();
  }

  Widget qnaItem(BuildContext context, QnaDTO qnaDTO) {
    return GestureDetector(
      onTap: () {
        if (filterBy == "hot") {
          Navigator.pushNamed(context, MyRoute.qnaDetailRoute,
              arguments: QnaArguments(qnaDTO.id, false));
        } else {
          Navigator.pushNamed(context, MyRoute.qnaDetailRoute,
              arguments: QnaArguments(qnaDTO.id, true));
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: AppColor.appBlack().withOpacity(0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qnaDTO.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.bold(
                        16,
                        color: AppColor.appBlack(),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      qnaDTO.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.regular(
                        12,
                        color: AppColor.appBlack().withOpacity(0.6),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    (qnaDTO.images != null && qnaDTO.images.length > 0)
                        ? SizedBox(height: 10)
                        : SizedBox(height: 0),
                    (qnaDTO.images != null && qnaDTO.images.length > 0)
                        ? displayRowQnaImages(qnaDTO.images)
                        : Container(),
                  ],
                ),
              ),
              qnaDTO.answer != null
                  ? Image.asset(
                      Constants.ASSET_IMAGES + "admin_icon.png",
                      width: 30.0,
                      height: 30.0,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget displayRowQnaImages(List<String> images) {
    return GridView.builder(
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
        return qnaImageItem(context, images[index]);
      },
    );
  }

  Widget qnaImageItem(BuildContext context, String imgUrl) {
    return GestureDetector(
      onTap: () {},
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

  void refreshData() {
    _getData();
  }

  void onGoBack(dynamic value) {
    refreshData();
  }
}
