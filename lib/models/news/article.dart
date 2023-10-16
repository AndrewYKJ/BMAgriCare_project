class Article {
  int id;
  String title;
  String image;
  String url;
  String date;

  Article({this.id, this.title, this.image, this.url, this.date,});

  Article.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    url = json['url'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['image'] = this.image;
    data['url'] = this.url;
    data['date'] = this.date;
    return data;
  }
}