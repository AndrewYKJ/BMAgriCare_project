import 'package:behn_meyer_flutter/models/home/crop/crop_category.dart';
import 'package:behn_meyer_flutter/models/product/product_item.dart';

import 'crop_issue_detail_fertigation_program.dart';

class CropIssueFertigationDetailDTO {
  int id;
  String name;
  String description;
  String image;
  String type;
  List<String> images;
  List<ProductItem> products;
  List<CropIssueFertigationProgramDTO> programs;
  String supportEmail;
  CropCategoryDTO category;

  CropIssueFertigationDetailDTO(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.type,
      this.images,
      this.products,
      this.programs,
      this.supportEmail,
      this.category});

  CropIssueFertigationDetailDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    type = json['type'];
    supportEmail = json['supportEmail'];

    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images.add(v);
      });
    }

    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products.add(ProductItem.fromJson(v));
      });
    }

    if (json['programs'] != null) {
      programs = [];
      json['programs'].forEach((v) {
        programs.add(CropIssueFertigationProgramDTO.fromJson(v));
      });
    }

    if (json['category'] != null) {
      category = CropCategoryDTO.fromJson(json['category']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['type'] = this.type;
    data['images'] = this.images;
    data['products'] = this.products;
    data['programs'] = this.programs;
    data['supportEmail'] = this.supportEmail;
    data['category'] = this.category;
    return data;
  }
}
