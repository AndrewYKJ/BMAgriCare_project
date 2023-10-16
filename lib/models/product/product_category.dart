class ProductCategory {
  int id;
  String code;
  String name;
  bool selected;

  ProductCategory({this.id, this.code, this.name, this.selected});

  ProductCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    selected = false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['selected'] = this.selected;
    return data;
  }
}

class ProductSubCategory {
  int id;
  String code;
  String name;
  bool selected;

  ProductSubCategory({this.id, this.code, this.name, this.selected});

  ProductSubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    selected = false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['selected'] = this.selected;
    return data;
  }
}