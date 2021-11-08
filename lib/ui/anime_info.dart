import 'dart:convert';

import 'package:alreadywatched/models/anime.dart';
import 'package:alreadywatched/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

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
            print("loading");
            return Text("loading");
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
                      // height: Responsive().horizontal(30),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Hero(
                          tag: "coverImage_$animeId",
                          child: CachedNetworkImage(
                            width: 50,
                            imageUrl: result.data['Media']['coverImage']
                                    ['large'] ??
                                "https://picsum.photos/200/400",
                            errorWidget: (context, error, object) => SizedBox(
                                child: Icon(
                              Icons.error_outline,
                              size: 8,
                            )),
                          ),
                        ),
                      ),
                      Container(
                        width: 500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _buildInfoText(
                                text: "Title(en)", info: anime.titleEn),
                            _buildInfoText(
                                text: "Season",
                                info: "${anime.season} - ${anime.seasonYear}"),
                            _buildInfoText(
                                text: "Score", info: "${anime.averageScore}"),
                            _buildInfoText(
                                text: "Status", info: "${anime.status}"),
                            _buildInfoText(
                                text: "Episodes", info: "${anime.episodes}"),
                            _buildInfoText(
                                text: "Start", info: "${anime.startDate}"),
                            _buildInfoText(
                                text: "End", info: "${anime.endDate}"),
                            _buildInfoText(
                                text: "Genres", info: "${anime.genres}"),
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
                        Text("Description: "),
                        FutureBuilder<String>(
                            future: translateApi(anime.description),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Text(anime.description);
                              }
                              return Text(snapshot.data);
                            }),
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
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(
          "$text: $info",
          softWrap: true,
        ));
  }

  Future<String> translateApi(String text) async {
    try {
      var response = await http.post(
          Uri.parse("https://translator.contrateumdev.com.br/api/translate"),
          body: {'from': 'en', 'to': 'pt', 'text': text});

      if (response.statusCode != 200) {
        throw "Error ${response.statusCode}";
      }

      var result = jsonDecode(response.body)['translate']['translations'][0]
          ['translation'];

      return result;
    } catch (e) {
      print(e);
      return text;
    }
  }
}
