class CropCategoryDTO {
  int id;
  String code;
  String name;
  String image;

  CropCategoryDTO({this.id, this.code, this.name, this.image});

  CropCategoryDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}
