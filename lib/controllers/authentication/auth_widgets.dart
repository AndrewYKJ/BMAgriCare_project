import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:flutter/material.dart';

class AuthWidget {
  static Widget backButton(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.black.withOpacity(0.5), // button color
        child: InkWell(
          splashColor: Colors.grey, // inkwell color
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

  static Widget textFieldForm(BuildContext context, String fieldLbl,
      String hintTxt, TextEditingController editingController,
      {bool readOnly = false}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        height: 75,
        width: screenWidth - 35,
        child: Container(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fieldLbl,
                style: AppFont.bold(16,
                    color: AppColor.appBlue(), decoration: TextDecoration.none),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenWidth - 35,
                height: 50,
                child: TextFormField(
                  readOnly: readOnly,
                  controller: editingController,
                  maxLines: 1,
                  // textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintStyle: AppFont.regular(15,
                          color: Colors.grey[500],
                          decoration: TextDecoration.none),
                      hintText: hintTxt),
                ),
              )
            ],
          ),
          const MySeparator(color: Color.fromRGBO(18, 51, 119, 1.0)),
        ])));
  }

  static Widget phoneNoTextFieldForm(BuildContext context, String fieldLbl,
      String hintTxt, TextEditingController editingController,
      {bool readOnly = false}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 80,
      width: screenWidth - 35,
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fieldLbl,
                  style: AppFont.bold(16,
                      color: AppColor.appBlue(),
                      decoration: TextDecoration.none),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "+ 84 | ",
                  style: AppFont.regular(15,
                      color: AppColor.appBlack(),
                      decoration: TextDecoration.none),
                ),
                Container(
                  width: screenWidth - 80,
                  margin: EdgeInsets.only(top: 5.0),
                  height: 50,
                  child: TextFormField(
                    readOnly: readOnly,
                    controller: editingController,
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintStyle: AppFont.regular(15,
                            color: Colors.grey[500],
                            decoration: TextDecoration.none),
                        hintText: hintTxt),
                  ),
                )
              ],
            ),
            const MySeparator(color: Color.fromRGBO(18, 51, 119, 1.0)),
          ],
        ),
      ),
    );
  }

  static Widget passwordFieldForm(
      BuildContext context,
      String fieldLbl,
      String hintTxt,
      TextEditingController editingController,
      String currentPage) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        height: 75,
        width: screenWidth - 35,
        child: Container(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fieldLbl,
                style: AppFont.bold(16,
                    color: AppColor.appBlue(), decoration: TextDecoration.none),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenWidth - 35,
                height: 50,
                child: TextField(
                  controller: editingController,
                  maxLines: 1,
                  obscureText: true,
                  obscuringCharacter: "*",
                  // textInputAction: currentPage == 'login'
                  //     ? TextInputAction.done
                  //     : TextInputAction.next,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintStyle: AppFont.regular(17,
                          color: Colors.grey[500],
                          decoration: TextDecoration.none),
                      hintText: hintTxt),
                ),
              )
            ],
          ),
          const MySeparator(color: Color.fromRGBO(18, 51, 119, 1.0)),
        ])));
  }
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 2.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
