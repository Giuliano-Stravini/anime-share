import 'dart:convert';

import 'package:alreadywatched/models/anime.dart';
import 'package:alreadywatched/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:translator/translator.dart';

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
  genres
  }
}
''';

class AnimeInfo extends StatelessWidget {
  const AnimeInfo({Key key, @required this.animeId}) : super(key: key);

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
            print(result.exception.graphqlErrors.toString());
            return Text(result.exception.graphqlErrors.toString());
          }
          if (result.isLoading) {
            return Material(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          var anime = Anime.fromJson(result.data['Media']);

          return Scaffold(
            appBar: AppBar(
              title: Text(anime.title),
              actions: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () async {
                    try {
                      // Saved with this method.

                      await Share.share(anime.title);
                    } on PlatformException catch (error) {
                      print(error);
                    }
                  },
                  // onPressed: () => Share.text("title",
                  //     "${anime.title}(${anime.titleEn})", 'text/plain'),
                ),
              ],
            ),
            body: Container(
              width: double.infinity,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Center(
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      imageUrl: result.data["Media"]["bannerImage"] ??
                          "https://picsum.photos/200/400",
                      errorWidget: (context, error, object) => SizedBox(
                          height: 30,
                          child: Icon(
                            Icons.error_outline,
                            size: 8,
                          )),
                    ),
                  ),
                  Divider(
                    color: Colors.orange,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Hero(
                                  tag: "coverImage_$animeId",
                                  child: CachedNetworkImage(
                                    imageUrl: result.data['Media']['coverImage']
                                            ['large'] ??
                                        "https://picsum.photos/200/400",
                                    errorWidget: (context, error, object) =>
                                        SizedBox(
                                            child: Icon(
                                      Icons.error_outline,
                                      size: 8,
                                    )),
                                  ),
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
                                          "${AppLocalizations.of(context).title}",
                                      info: anime.title),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context).season}",
                                      info:
                                          "${seasonTranslate(anime.season, context)}/${anime.seasonYear}"),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context).score}",
                                      info: "${anime.averageScore}"),
                                  _buildInfoText(
                                      text: "Status",
                                      info:
                                          "${statusTranslate(anime.status, context)}"),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context).episodes}",
                                      info: "${anime.episodes}"),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context).start}",
                                      info: "${anime.startDate}"),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context).end}",
                                      info: "${anime.endDate}"),
                                  _buildInfoText(
                                      text:
                                          "${AppLocalizations.of(context).genres}",
                                      info: "${anime.genres}"),
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
                                  "${AppLocalizations.of(context).description}: "),
                              FutureBuilder<Translation>(
                                  future:
                                      translateApi(anime.description, context),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        AppLocalizations.of(context)
                                                .localeName ==
                                            'en') {
                                      return Text(anime.description);
                                    }
                                    return Text(snapshot.data.text);
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

  Padding _buildInfoText({String text, String info}) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Text(
          "$text: $info.",
          softWrap: true,
        ));
  }

  String seasonTranslate(String season, BuildContext context) {
    switch (season) {
      case "WINTER":
        return AppLocalizations.of(context).winter;
        break;
      case "FALL":
        return AppLocalizations.of(context).fall;
        break;
      case "SUMMER":
        return AppLocalizations.of(context).summer;
        break;
      case "SPRING":
        return AppLocalizations.of(context).spring;
        break;
      default:
        return "";
    }
  }

  String statusTranslate(String status, BuildContext context) {
    switch (status) {
      case "FINISHED":
        return AppLocalizations.of(context).finished;
        break;
      case "RELEASING":
        return AppLocalizations.of(context).releasing;
        break;
      case "NOT_YET_RELEASED":
        return AppLocalizations.of(context).notYetReleased;
        break;
      case "CANCELLED":
        return AppLocalizations.of(context).cancelled;
        break;
      case "HIATUS":
        return AppLocalizations.of(context).hiatus;
        break;
      default:
        return "";
    }
  }

  Future<Translation> translateApi(String text, BuildContext context) async {
    final translator = GoogleTranslator();

    return translator.translate(text,
        from: 'en', to: AppLocalizations.of(context).localeName);
    // prints Hello. Are you okay?
  }
}
