class ReferralModel {
  String rewardTermUrl;
  String viewRewardUrl;

  ReferralModel({this.rewardTermUrl, this.viewRewardUrl});

  ReferralModel.fromJson(Map<String, dynamic> json) {
    rewardTermUrl = json['rewardTermUrl'];
    viewRewardUrl = json['viewRewardUrl'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map<String, dynamic>();

    json['rewardTermUrl'] = this.rewardTermUrl;
    json['viewRewardUrl'] = this.viewRewardUrl;
    return json;
  }
}
