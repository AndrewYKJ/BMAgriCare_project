class ProductNutrient {
  String nutrient;
  String percentage;

  ProductNutrient({this.nutrient, this.percentage});

  ProductNutrient.fromJson(Map<String, dynamic> json) {
    nutrient = json['nutrient'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['nutrient'] = this.nutrient;
    data['percentage'] = this.percentage;
    return data;
  }
  
}

class ProductAttributes {
  String title;
  String content;

  ProductAttributes({this.title, this.content});
  
  ProductAttributes.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['content'] = this.content;
    return data;
  }
}