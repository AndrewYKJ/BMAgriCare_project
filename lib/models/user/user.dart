enum UserStatus { Active, Incomplete }

enum CodeVerifyFlow { SignUp, Recovery, Settings }

extension CatExtension on UserStatus {
  String get name {
    return ["active", "incomplete"][this.index];
  }
}

class User {
  int id;
  String name;
  String photo;
  String status;
  bool agreeMarketingUpdate;
  String country;
  String language;
  String company;
  String email;
  String userType;
  String area;
  String mobileNo;
  String checkNowGuid;
  String checkNowAuthToken;
  String referralCode;
  int referrerCount;
  int referrerBalance;

  User(
      {this.id,
      this.name,
      this.photo,
      this.status,
      this.agreeMarketingUpdate,
      this.country,
      this.language,
      this.company,
      this.email,
      this.userType,
      this.area,
      this.checkNowGuid,
      this.checkNowAuthToken,
      this.referralCode,
      this.referrerCount,
      this.referrerBalance});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    photo = json['photo'];
    status = json['status'];
    agreeMarketingUpdate = json['agreeMarketingUpdate'];
    country = json['country'];
    language = json['language'];
    company = json['company'];
    email = json['email'];
    userType = json['userType'];
    area = json['area'];
    mobileNo = json['mobileNo'];
    checkNowGuid = json['checkNowGuid'];
    checkNowAuthToken = json['checkNowAuthToken'];
    referralCode = json['referralCode'];
    referrerCount = json['referrerCount'];
    referrerBalance = json['referrerBalance'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['photo'] = this.photo;
    data['status'] = this.status;
    data['agreeMarketingUpdate'] = this.agreeMarketingUpdate;
    data['country'] = this.country;
    data['language'] = this.language;
    data['company'] = this.company;
    data['email'] = this.email;
    data['userType'] = this.userType;
    data['area'] = this.area;
    data['mobileNo'] = this.mobileNo;
    data['checkNowGuid'] = this.checkNowGuid;
    data['checkNowAuthToken'] = this.checkNowAuthToken;
    data['referralCode'] = this.referralCode;
    data['referrerCount'] = this.referrerCount;
    data['referrerBalance'] = this.referrerBalance;
    return data;
  }
}
