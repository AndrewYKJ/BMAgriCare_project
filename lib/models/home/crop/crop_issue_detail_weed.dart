import 'package:behn_meyer_flutter/models/home/crop/crop_category.dart';

class CropIssueWeedsDetailDTO {
  int id;
  String name;
  String description;
  String image;
  String type;
  List<String> images;
  String solution;
  String usefulInfo;
  List<String> usefulInfoLinks;
  String supportEmail;
  CropCategoryDTO category;

  CropIssueWeedsDetailDTO(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.type,
      this.images,
      this.solution,
      this.usefulInfo,
      this.usefulInfoLinks,
      this.supportEmail,
      this.category});

  CropIssueWeedsDetailDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    type = json['type'];
    solution = json['solution'];
    usefulInfo = json['usefulInfo'];
    supportEmail = json['supportEmail'];

    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images.add(v);
      });
    }

    if (json['usefulInfoLinks'] != null) {
      usefulInfoLinks = [];
      json['usefulInfoLinks'].forEach((v) {
        usefulInfoLinks.add(v);
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
    data['solution'] = this.solution;
    data['usefulInfo'] = this.usefulInfo;
    data['usefulInfoLinks'] = this.usefulInfoLinks;
    data['supportEmail'] = this.supportEmail;
    data['category'] = this.category;
    return data;
  }
}
