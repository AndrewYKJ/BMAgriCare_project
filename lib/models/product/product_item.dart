import 'package:behn_meyer_flutter/models/product/product_category.dart';

class ProductItem {
  int id;
  ProductCategory category;
  ProductSubCategory subCategory;
  String name;
  String imageUrl;

  ProductItem({this.id, this.category, this.subCategory, this.name, this.imageUrl});
  
  ProductItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = ProductCategory.fromJson(json['category']);
    subCategory = ProductSubCategory.fromJson(json['subCategory']);
    name = json['name'];
    imageUrl = json['image'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category'] = this.category;
    data['subCategory'] = this.subCategory;
    data['name'] = this.name;
    data['image'] = this.imageUrl;
    return data;
  }
}

class ProductItemWrapper {
  int total;
  List<ProductItem> result;

  ProductItemWrapper({this.total, this.result});
  
  ProductItemWrapper.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    var ilist = json['result'] as List;
    if (ilist != null) {
      result = ilist.map((i) => ProductItem.fromJson(i)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['result'] = this.result;
    return data;
  }
}