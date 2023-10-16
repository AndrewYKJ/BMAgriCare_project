import 'package:behn_meyer_flutter/models/product/product_category.dart';

class ProductData {
  int id;
  int seq;
  ProductInfo info;
  bool selected;


  ProductData({this.id, this.seq, this.info, this.selected});
  
  ProductData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    seq = json['seq'];
    info = ProductInfo.fromJson(json['info']);
    selected = false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['seq'] = this.seq;
    data['info'] = this.info;
    data['selected'] = this.selected;
    return data;
  }
}

class ProductInfo {
  int id;
  String name;
  ProductCategory language;

  ProductInfo({this.id, this.name, this.language});
  
  ProductInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    language = ProductCategory.fromJson(json['language']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['language'] = this.language;
    return data;
  }
}

