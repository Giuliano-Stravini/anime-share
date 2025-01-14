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
  List<ExternalLinks>? externalLinks;

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
    this.externalLinks,
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
            .replaceAll("<i>", ""),
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
        externalLinks: ExternalLinks.filterExternalLinks(
                (json['externalLinks'] as List)
                    .map((e) => ExternalLinks.fromJson(e))
                    .toList())
            .toList(),
      );
}

class ExternalLinks {
  String? site;
  String? icon;
  String? url;
  String? color;

  ExternalLinks({this.site, this.icon, this.url, this.color}) {
    if (site == null || url == null) {
      throw ArgumentError('Site and URL cannot be null');
    }
  }

  static const List<String> allowedSites = <String>["Crunchyroll", "Netflix"];

  /// Creates an instance of ExternalLinks from a JSON map.
  factory ExternalLinks.fromJson(Map<String, dynamic> json) => ExternalLinks(
      site: json['site'],
      icon: json['icon'],
      url: json['url'],
      color: json['color']);

  /// Filters a list of ExternalLinks to only include allowed sites.
  static List<ExternalLinks> filterExternalLinks(
      List<ExternalLinks> externalLinks) {
    return externalLinks
        .where((link) => allowedSites.contains(link.site))
        .toList();
  }
}
