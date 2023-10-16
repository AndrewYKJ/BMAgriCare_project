class CropIssuesTypeDTO {
  int id;
  String name;
  String description;
  String image;
  String type;

  CropIssuesTypeDTO(
      {this.id, this.name, this.description, this.image, this.type});

  CropIssuesTypeDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['type'] = this.type;
    return data;
  }
}
