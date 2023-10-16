import 'crop_category.dart';
import 'crop_issues_type.dart';

class CropIssuesDTO {
  CropCategoryDTO category;
  List<CropIssuesTypeDTO> deficiencies;
  List<CropIssuesTypeDTO> fertigations;
  List<CropIssuesTypeDTO> weeds;

  CropIssuesDTO(
      {this.category, this.deficiencies, this.fertigations, this.weeds});

  CropIssuesDTO.fromJson(Map<String, dynamic> json) {
    category = CropCategoryDTO.fromJson(json['category']);

    if (json['deficiencies'] != null) {
      deficiencies = [];
      json['deficiencies'].forEach((v) {
        deficiencies.add(CropIssuesTypeDTO.fromJson(v));
      });
    }

    if (json['fertigations'] != null) {
      fertigations = [];
      json['fertigations'].forEach((v) {
        fertigations.add(CropIssuesTypeDTO.fromJson(v));
      });
    }

    if (json['weeds'] != null) {
      weeds = [];
      json['weeds'].forEach((v) {
        weeds.add(CropIssuesTypeDTO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = this.category;
    data['deficiencies'] = this.deficiencies;
    data['fertigations'] = this.fertigations;
    data['weeds'] = this.weeds;
    return data;
  }
}
