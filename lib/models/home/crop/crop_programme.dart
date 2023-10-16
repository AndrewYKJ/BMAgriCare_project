class CropProgrammeDTO {
  int id;
  String name;
  String image;
  String type;
  String shareUrl;
  String viewUrl;

  CropProgrammeDTO(
      {this.id, this.name, this.image, this.type, this.shareUrl, this.viewUrl});

  CropProgrammeDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    type = json['type'];
    shareUrl = json['shareUrl'];
    viewUrl = json['viewUrl'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['type'] = this.type;
    data['shareUrl'] = this.shareUrl;
    data['viewUrl'] = this.viewUrl;
    return data;
  }
}
