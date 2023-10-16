class DetectCountryModel {
  String country;

  DetectCountryModel({this.country});

  DetectCountryModel.fromJson(Map<String, dynamic> json) {
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map<String, dynamic>();

    json['country'] = this.country;

    return json;
  }
}
