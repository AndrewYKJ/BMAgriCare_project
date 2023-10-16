import 'dart:io';

class OtpVerifyArguments {
  String phoneNo;
  String name;
  String password;
  String area;
  String referralCode;
  bool agreeMarketUpdate;
  File photo;
  bool isRegister;
  String otp;

  OtpVerifyArguments(this.phoneNo, this.name, this.password, this.area,
      this.referralCode, this.agreeMarketUpdate, this.photo, this.isRegister);
}
