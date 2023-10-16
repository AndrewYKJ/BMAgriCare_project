class CropCommonIssueDTO {
  int id;
  String title;
  String image;

  CropCommonIssueDTO({this.id, this.title, this.image});

  CropCommonIssueDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['image'] = this.image;
    return data;
  }
}
