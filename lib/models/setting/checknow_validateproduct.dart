class CheckNowValidateProductDTO {
  String serialNumber;
  String productName;
  String scanCount;
  String authenticationStatus;
  String statusCode;
  String error;
  String viewMoreUrl;
  String reportUrl;

  CheckNowValidateProductDTO(
      {this.serialNumber,
      this.productName,
      this.scanCount,
      this.authenticationStatus,
      this.statusCode,
      this.error,
      this.viewMoreUrl,
      this.reportUrl});

  CheckNowValidateProductDTO.fromJson(Map<String, dynamic> json) {
    serialNumber = json['serialNumber'].toString();
    productName = json['productName'].toString();
    scanCount = json['scanCount'].toString();
    authenticationStatus = json['authenticationStatus'].toString();
    statusCode = json['statusCode'].toString();
    error = json['error'].toString();
    viewMoreUrl = json['viewMoreUrl'].toString();
    reportUrl = json['reportUrl'].toString();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['serialNumber'] = this.serialNumber;
    data['productName'] = this.productName;
    data['scanCount'] = this.scanCount;
    data['authenticationStatus'] = this.authenticationStatus;
    data['statusCode'] = this.statusCode;
    data['error'] = this.error;
    data['viewMoreUrl'] = this.viewMoreUrl;
    data['reportUrl'] = this.reportUrl;
    return data;
  }
}
