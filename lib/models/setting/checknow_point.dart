class CheckNowPointDTO {
  String points;
  String message;
  String statusCode;
  String error;
  String reportUrl;

  CheckNowPointDTO(
      {this.points, this.message, this.statusCode, this.reportUrl});

  CheckNowPointDTO.fromJson(Map<String, dynamic> json) {
    points = json['points'].toString();
    message = json['message'].toString();
    statusCode = json['statusCode'].toString();
    error = json['error'].toString();
    reportUrl = json['reportUrl'].toString();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['points'] = this.points;
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    data['error'] = this.error;
    data['reportUrl'] = this.reportUrl;
    return data;
  }
}
