import 'package:behn_meyer_flutter/models/qna/qna_answer.dart';

class QnaDTO {
  int id;
  String title;
  String content;
  List<String> images;
  QnaAnswerDTO answer;
  UserDTO createdBy;
  String createdAt;

  QnaDTO(
      {this.id,
      this.title,
      this.content,
      this.images,
      this.answer,
      this.createdBy,
      this.createdAt});

  QnaDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    createdAt = json['createdAt'];

    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images.add(v);
      });
    }

    if (json['answer'] != null) {
      answer = QnaAnswerDTO.fromJson(json['answer']);
    }

    if (json['createdBy'] != null) {
      createdBy = UserDTO.fromJson(json['createdBy']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['images'] = this.images;
    return data;
  }
}
