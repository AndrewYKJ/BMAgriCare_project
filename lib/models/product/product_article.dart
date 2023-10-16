class ProductArticle {
  int id;
  String title;
  String content;
  String image;

  ProductArticle({this.id, this.title, this.content, this.image});
  
  ProductArticle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    image = json['image'];
  }

   Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['image'] = this.image;
    return data;
  }
  


}