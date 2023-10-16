import 'package:behn_meyer_flutter/models/product/product_category.dart';
import 'package:behn_meyer_flutter/models/product/product_data.dart';

class ProductFilter {
  int id;
  List<ProductCategory> categories;
  List<ProductSubCategory> subCategories;
  List<ProductData> activityTags;
  List<ProductData> characteristicsTags;
  List<ProductData> cropsTags;
  List<ProductData> compositionTags;
  List<ProductData> phenologicalPhaseTags;
  List<ProductData> formulationTags;
  List<ProductData> activeIngredientTags;

  ProductFilter({this.id, this.categories, this.subCategories,});
  
  ProductFilter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    var clist = json['categories'] as List;
    if (clist != null) {
      categories = clist.map((i) => ProductCategory.fromJson(i)).toList();
    }
    var slist = json['subCategories'] as List;
    if (slist != null) {
      subCategories = slist.map((i) => ProductSubCategory.fromJson(i)).toList();
    }
    var alist = json['activityTags'] as List;
    if (alist != null) {
      activityTags = alist.map((i) => ProductData.fromJson(i)).toList();
    }
    var blist = json['characteristicsTags'] as List;
    if (blist != null) {
      characteristicsTags = blist.map((i) => ProductData.fromJson(i)).toList();
    }
    var dlist = json['cropsTags'] as List;
    if (dlist != null) {
      cropsTags = dlist.map((i) => ProductData.fromJson(i)).toList();
    }
    var elist = json['compositionTags'] as List;
    if (elist != null) {
      compositionTags = elist.map((i) => ProductData.fromJson(i)).toList();
    }
    var plist = json['phenologicalPhaseTags'] as List;
    if (plist != null) {
      phenologicalPhaseTags = plist.map((i) => ProductData.fromJson(i)).toList();
    }
    var flist = json['formulationTags'] as List;
    if (flist != null) {
      formulationTags = flist.map((i) => ProductData.fromJson(i)).toList();
    }
    var glist = json['activeIngredientTags'] as List;
    if (glist != null) {
      activeIngredientTags = glist.map((i) => ProductData.fromJson(i)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['categories'] = this.categories;
    data['subCategories'] = this.subCategories;
    data['activityTags'] = this.activityTags;
    data['characteristicsTags'] = this.characteristicsTags;
    data['cropsTags'] = this.cropsTags;
    data['compositionTags'] = this.compositionTags;
    data['phenologicalPhaseTags'] = this.phenologicalPhaseTags;
    data['formulationTags'] = this.formulationTags;
    data['activeIngredientTags'] = this.activeIngredientTags;
    return data;
  }
}


class ProductFilterData {
  String name;
  String subTitle;
  String code;
  dynamic data;
  bool selected;
  bool viewMore;

  ProductFilterData({this.name, this.subTitle, this.code, this.data, this.selected, this.viewMore});
  
  ProductFilterData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    subTitle = json['subTitle'];
    code = json['code'];
    data = json['data'];
    selected = json['selected'];
    viewMore = json['viewMore'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['subTitle'] = this.subTitle;
    data['code'] = this.code;
    data['data'] = this.data;
    data['selected'] = this.selected;
    data['viewMore'] = this.viewMore;
    return data;
  }
}