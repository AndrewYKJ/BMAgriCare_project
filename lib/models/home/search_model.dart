class SearchDTO {
  int id;
  String title;
  String content;
  String image;
  String type;
  String refType;

  SearchDTO(
      {this.id, this.title, this.content, this.image, this.type, this.refType});

  SearchDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    image = json['image'];
    type = json['type'];
    refType = json['refType'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['image'] = this.image;
    data['type'] = this.type;
    data['refType'] = this.refType;
    return data;
  }
}
