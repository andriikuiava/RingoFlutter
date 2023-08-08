
class MainPhoto {
  int highQualityId;
  int mediumQualityId;
  int lowQualityId;
  int lazyId;

  MainPhoto({
    required this.highQualityId,
    required this.mediumQualityId,
    required this.lowQualityId,
    required this.lazyId,
  });

  factory MainPhoto.fromJson(Map<String, dynamic> json) {
    return MainPhoto(
      highQualityId: json['highQualityId'],
      mediumQualityId: json['mediumQualityId'],
      lowQualityId: json['lowQualityId'],
      lazyId: json['lazyId'],
    );
  }
}

class Photo {
  int id;
  int normalId;
  int lazyId;

  Photo({
    required this.id,
    required this.normalId,
    required this.lazyId,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      normalId: json['normalId'],
      lazyId: json['lazyId'],
    );
  }
}
