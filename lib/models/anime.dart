import 'package:intl/intl.dart';

class Anime {
  String? title;
  String? titleEn;
  String? coverImage;
  String? bannerImage;
  String? averageScore;
  String? season;
  int? seasonYear;
  String? status;
  String? format;
  String? description;
  String? startDate;
  String? endDate;
  int? episodes;
  List<String>? genres;

  Anime({
    this.title,
    this.titleEn,
    this.coverImage,
    this.bannerImage,
    this.averageScore,
    this.season,
    this.seasonYear,
    this.status,
    this.format,
    this.description,
    this.startDate,
    this.endDate,
    this.episodes,
    this.genres,
  });

  factory Anime.fromJson(Map<String, dynamic> json) => Anime(
        title: json["title"]["romaji"] ?? null,
        titleEn: json["title"]["english"] ?? null,
        coverImage: json['coverImage']['large'] ?? null,
        bannerImage: json['bannerImage'] ?? null,
        averageScore: json['averageScore'] != null
            ? (json['averageScore'] / 10).toString()
            : "-",
        season: json['season'] ?? null,
        seasonYear: json['seasonYear'] ?? null,
        status: json['status'] ?? null,
        format: json['format'] ?? null,
        description: (json['description'] as String)
                .replaceAll("<br>", "")
                .replaceAll("</i>", "")
                .replaceAll("<i>", "") ??
            null,
        startDate: json['startDate']['day'] != null
            ? DateFormat.yMMMd().format(DateTime(json['startDate']['year'],
                json['startDate']['month'], json['startDate']['day']))
            : "-",
        endDate: json['endDate']['day'] != null
            ? DateFormat.yMMMd().format(DateTime(json['endDate']['year'],
                json['endDate']['month'], json['endDate']['day']))
            : "-",
        episodes: json['episodes'],
        genres: (json['genres'] as List).map((e) => e.toString()).toList(),
      );
}
