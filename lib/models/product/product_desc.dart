import 'package:behn_meyer_flutter/models/product/product_category.dart';
import 'package:behn_meyer_flutter/models/product/product_item.dart';
import 'package:behn_meyer_flutter/models/product/product_nutrient.dart';

class ProductDesc {
  int id;
  ProductCategory category;
  ProductSubCategory subCategory;
  String name;
  String image;
  String desc;
  List<String> images;
  List<ProductNutrient> nutrients;
  String application;
  String features;
  String testimonyImages;
  String testimony;
  List<ProductItem> relatedProducts;
  String usefulInfo;
  String labelRecImage;
  List<ProductAttributes> attributes;
  String shareUrl;

  ProductDesc(
      {this.id,
      this.category,
      this.subCategory,
      this.name,
      this.image,
      this.desc,
      this.images,
      this.nutrients,
      this.application,
      this.features,
      this.testimonyImages,
      this.testimony,
      this.relatedProducts,
      this.usefulInfo,
      this.labelRecImage,
      this.attributes,
      this.shareUrl});

  ProductDesc.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = ProductCategory.fromJson(json['category']);
    subCategory = ProductSubCategory.fromJson(json['subCategory']);
    name = json['name'];
    image = json['image'];
    desc = json['description'];
    var ilist = json['images'] as List;
    if (ilist != null) {
      images = ilist.map((i) => i.toString()).toList();
    }
    var nlist = json['nutrients'] as List;
    if (nlist != null) {
      nutrients = nlist.map((i) => ProductNutrient.fromJson(i)).toList();
    }
    application = json['application'];
    features = json['features'];
    testimonyImages = json['testimonyImage'];
    testimony = json['testimony'];
    var plist = json['relatedProducts'] as List;
    if (plist != null) {
      relatedProducts = plist.map((i) => ProductItem.fromJson(i)).toList();
    }
    usefulInfo = json['usefulInfo'];
    labelRecImage = json['labelRecImage'];
    var alist = json['attributes'] as List;
    if (alist != null) {
      attributes = alist.map((i) => ProductAttributes.fromJson(i)).toList();
    }
    shareUrl = json['shareUrl'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category'] = this.category;
    data['subCategory'] = this.subCategory;
    data['name'] = this.name;
    data['image'] = this.image;
    data['description'] = this.desc;
    data['images'] = this.images;
    data['nutrients'] = this.nutrients;
    data['application'] = this.application;
    data['features'] = this.features;
    data['testimonyImage'] = this.testimonyImages;
    data['testimony'] = this.testimony;
    data['relatedProducts'] = this.relatedProducts;
    data['usefulInfo'] = this.usefulInfo;
    data['labelRecImage'] = this.labelRecImage;
    data['attributes'] = this.attributes;
    data['shareUrl'] = this.shareUrl;
    return data;
  }
}
