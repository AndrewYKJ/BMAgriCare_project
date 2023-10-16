import 'banner.dart';
import 'crop_common_issue.dart';
import 'video.dart';

class HomeDTO {
  List<BannerDTO> banners;
  CropCommonIssueDTO cropCommonIssue;
  List<VideoDTO> videos;
  bool hasCropProgramme;

  HomeDTO(
      {this.banners, this.cropCommonIssue, this.videos, this.hasCropProgramme});

  HomeDTO.fromJson(Map<String, dynamic> json) {
    cropCommonIssue = CropCommonIssueDTO.fromJson(json['cropCommonIssue']);
    hasCropProgramme = json['hasCropProgramme'];

    if (json['banners'] != null) {
      banners = [];
      json['banners'].forEach((v) {
        banners.add(BannerDTO.fromJson(v));
      });
    }

    if (json['videos'] != null) {
      videos = [];
      json['videos'].forEach((v) {
        videos.add(VideoDTO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['banners'] = this.banners;
    data['cropCommonIssue'] = this.cropCommonIssue;
    data['videos'] = this.videos;
    data['hasCropProgramme'] = this.hasCropProgramme;
    return data;
  }
}
