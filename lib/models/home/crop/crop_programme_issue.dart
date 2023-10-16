import 'package:behn_meyer_flutter/models/home/crop/crop_programme.dart';

import 'crop_category.dart';

class CropProgrammeIssuesDTO {
  CropCategoryDTO category;
  List<CropProgrammeDTO> programmes;

  CropProgrammeIssuesDTO({this.category, this.programmes});

  CropProgrammeIssuesDTO.fromJson(Map<String, dynamic> json) {
    category = CropCategoryDTO.fromJson(json['category']);

    if (json['programmes'] != null) {
      programmes = [];
      json['programmes'].forEach((v) {
        programmes.add(CropProgrammeDTO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = this.category;
    data['programmes'] = this.programmes;
    return data;
  }
}
