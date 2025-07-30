import 'dart:convert';

import 'package:alreadywatched/l10n/app_localizations.dart';
import 'package:alreadywatched/models/anime.dart';
import 'package:alreadywatched/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher_string.dart';

var animeInfoQuery = r'''
query($id: Int!){
  Media(id: $id){
    coverImage{
       large
     },
    bannerImage,
    title {
        romaji,
        english
     },
    averageScore,
    season,
    seasonYear,
    status,
    format,
    description(asHtml: false)
      startDate {
    year
    month
    day
  },
  endDate {
    year
    month
    day
  },
  episodes,
  genres,
  externalLinks {
    id,
    icon,
    site,
    url,
    color
    }
  }
}
''';

class AnimeInfo extends StatelessWidget {
  const AnimeInfo({Key? key, required this.animeId}) : super(key: key);

  final int animeId;

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(animeInfoQuery),
          variables: {"id": animeId},
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.exception != null) {
            print(result.exception?.graphqlErrors.toString());
            return Material(
                color: Colors.white54,
                child:
                    Text(result.exception?.graphqlErrors.toString() ?? "null"));
          }
          if (result.isLoading) {
            return Material(
              child: Center(
                child: Column(
                  children: [
                    Spacer(),
                    CircularProgressIndicator(),
                    Text("${AppLocalizations.of(context)?.loading}..."),
                    Spacer(),
                  ],
                ),
              ),
            );
          }
          var anime = Anime.fromJson(result.data?['Media']);

          return Scaffold(
            appBar: AppBar(
              title: Text(anime.title ?? "Title null"),
              actions: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () async {
                    try {
                      SharePlus.instance.share(
                          ShareParams(text: anime.title ?? "Title null"));
                    } on PlatformException catch (error) {
                      print(error);
                    }
                  },
                ),
              ],
            ),
            body: Container(
              width: double.infinity,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  anime.bannerImage?.isNotEmpty ?? false
                      ? Center(
                          child: CachedNetworkImage(
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            imageUrl: anime.bannerImage ?? "null",
                            errorWidget: (context, error, object) => SizedBox(
                                height: 30,
                                child: Icon(
                                  Icons.error_outline,
                                  size: 8,
                                )),
                          ),
                        )
                      : Container(),
                  Divider(
                    color: const Color(0xFFE6B17E),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            anime.title ?? "-",
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Hero(
                                  tag: "coverImage_$animeId",
                                  child: (result.data?['Media']['coverImage']
                                              ['large'] as String)
                                          .isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: result.data?['Media']
                                              ['coverImage']['large'],
                                          errorWidget:
                                              (context, error, object) =>
                                                  SizedBox(
                                                      child: Icon(
                                            Icons.error_outline,
                                            size: 8,
                                          )),
                                        )
                                      : Container(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context)?.season}",
                                      info:
                                          "${seasonTranslate(anime.season ?? 'null', context)}/${anime.seasonYear}"),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context)?.score}",
                                      info: "${anime.averageScore}"),
                                  _buildInfoText(
                                      text: "Status",
                                      info:
                                          "${statusTranslate(anime.status ?? 'null', context)}"),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context)?.episodes}",
                                      info: "${anime.episodes}"),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context)?.start}",
                                      info: "${anime.startDate}"),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context)?.end}",
                                      info: "${anime.endDate}"),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context)?.genres}",
                                      info: "${anime.genres}"),
                                  ..._buildExternalLinkText(
                                      externalLinks: anime.externalLinks),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  "${AppLocalizations.of(context)?.description}: "),
                              FutureBuilder<Translation>(
                                  future: translateApi(
                                      anime.description ?? 'null', context),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        AppLocalizations.of(context)
                                                ?.localeName ==
                                            'en') {
                                      return Text(anime.description ?? 'null');
                                    }
                                    return Text(snapshot.data?.text ?? 'null');
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Padding _buildInfoText({String? text, String? info}) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Text(
          "$text: $info.",
          softWrap: true,
        ));
  }

  List<Widget> _buildExternalLinkText({List<ExternalLinks>? externalLinks}) {
    return externalLinks!.map((e) {
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Image.network(e.icon ?? "", height: 20, width: 20),
              TextButton(
                child: Text("${e.site}"),
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all(Color(Colors.white.value))),
                onPressed: () => launchUrlString(e.url!),
              ),
            ],
          ));
    }).toList();
  }

  String seasonTranslate(String season, BuildContext context) {
    switch (season) {
      case "WINTER":
        return AppLocalizations.of(context)?.winter ?? 'null';
      case "FALL":
        return AppLocalizations.of(context)?.fall ?? 'null';
      case "SUMMER":
        return AppLocalizations.of(context)?.summer ?? 'null';
      case "SPRING":
        return AppLocalizations.of(context)?.spring ?? 'null';
      default:
        return "";
    }
  }

  String statusTranslate(String status, BuildContext context) {
    switch (status) {
      case "FINISHED":
        return AppLocalizations.of(context)!.finished;
      case "RELEASING":
        return AppLocalizations.of(context)!.releasing;
      case "NOT_YET_RELEASED":
        return AppLocalizations.of(context)!.notYetReleased;
      case "CANCELLED":
        return AppLocalizations.of(context)!.cancelled;
      case "HIATUS":
        return AppLocalizations.of(context)!.hiatus;
      default:
        return "";
    }
  }

  Future<Translation> translateApi(String text, BuildContext context) async {
    final translator = GoogleTranslator();

    return translator.translate(text,
        from: 'en', to: AppLocalizations.of(context)!.localeName);
  }
}
