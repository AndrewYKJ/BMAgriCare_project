class Outlet {
  int id;
  String name;
  String address;
  String contactNo;
  double lat;
  double lng;
  
  Outlet({this.id, this.name, this.address, this.contactNo, this.lat, this.lng});

  Outlet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    contactNo = json['contactNo'];
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['contactNo'] = this.contactNo;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}