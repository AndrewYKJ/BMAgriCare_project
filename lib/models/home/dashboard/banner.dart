class BannerDTO {
  int id;
  String title;
  String image;
  String url;

  BannerDTO({this.id, this.title, this.image, this.url});

  BannerDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['image'] = this.image;
    data['url'] = this.url;
    return data;
  }
}
