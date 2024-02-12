class AnimeSummary {
  int? id;
  String? title;
  String? coverImage;
  String? season;
  String? averageScore;

  AnimeSummary({
    this.id,
    this.title,
    this.coverImage,
    this.season,
    this.averageScore,
  });

  factory AnimeSummary.fromJson(Map<String, dynamic> json) => AnimeSummary(
      id: json["id"],
      title: json["title"]["romaji"],
      coverImage: json['coverImage']['large'],
      season: json['season'],
      averageScore: json['averageScore'] != null
          ? (json['averageScore'] / 10).toString()
          : "0.0");
}
