class QnaCommentDTO {
  int id;
  String content;
  String createdAt;
  UserDTO createdBy;

  QnaCommentDTO({this.id, this.content, this.createdAt, this.createdBy});

  QnaCommentDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['content'];
    createdAt = json['createdAt'];

    if (json['createdBy'] != null) {
      createdBy = UserDTO.fromJson(json['createdBy']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['content'] = this.content;
    data['createdAt'] = this.createdAt;
    data['createdBy'] = this.createdBy;
    return data;
  }
}

class UserDTO {
  int id;
  String email;
  String name;
  String role;
  String photo;

  UserDTO({this.id, this.email, this.name, this.role, this.photo});

  UserDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    role = json['role'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['name'] = this.name;
    data['role'] = this.role;
    data['photo'] = this.photo;
    return data;
  }
}
