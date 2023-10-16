import 'crop_question_issue.dart';

class CropQuestionDTO {
  int id;
  String title;
  String content;
  // String image;
  List<String> images;
  CropQuestionIssueDTO issue;

  CropQuestionDTO({this.id, this.title, this.content, this.images, this.issue});

  CropQuestionDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    issue = CropQuestionIssueDTO.fromJson(json['issue']);

    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['images'] = this.images;
    data['issue'] = this.issue;
    return data;
  }
}
