import 'package:alreadywatched/models/anime.dart';
import 'package:alreadywatched/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
    return Scaffold(
      body: Query(
        options: QueryOptions(
          documentNode: gql(animeInfoQuery),
          variables: {"id": animeId},
        ),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.exception != null) {
            print(result.exception.graphqlErrors.toString());
            return Text(result.exception.graphqlErrors.toString());
          }
          if (result.loading) {
            print("loading");
            return Text("loading");
          }
          var anime = Anime.fromJson(result.data['Media']);

          return Container(
            width: Responsive().horizontal(100),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Center(
                      child: CachedNetworkImage(
                        height: Responsive().horizontal(30),
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        imageUrl: result.data["Media"]["bannerImage"] ??
                            "https://picsum.photos/200/400",
                        errorWidget: (context, error, object) => SizedBox(
                            height: Responsive().horizontal(30),
                            child: Icon(
                              Icons.error_outline,
                              size: Responsive().horizontal(4),
                            )),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () => Share.text("title",
                            "${anime.title}(${anime.titleEn})", 'text/plain'),
                      ),
                    ),
                  ],
                ),
                Center(
                    child: Padding(
                  padding: EdgeInsets.only(top: Responsive().horizontal(4)),
                  child: Text(
                    anime.title,
                    style: TextStyle(
                        fontSize: Responsive().horizontal(6),
                        fontWeight: FontWeight.bold),
                  ),
                )),
                Divider(
                  color: Colors.orange,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive().horizontal(4)),
                      child: CachedNetworkImage(
                        width: Responsive().horizontal(42),
                        imageUrl: result.data['Media']['coverImage']['large'] ??
                            "https://picsum.photos/200/400",
                        errorWidget: (context, error, object) => SizedBox(
                            child: Icon(
                          Icons.error_outline,
                          size: Responsive().horizontal(4),
                        )),
                      ),
                    ),
                    Container(
                      width: Responsive().horizontal(50),
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
                          _buildInfoText(text: "End", info: "${anime.endDate}"),
                          _buildInfoText(
                              text: "Genres", info: "${anime.genres}"),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(Responsive().horizontal(4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Description: "),
                      Text(anime.description),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Padding _buildInfoText({String text, String info}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive().horizontal(1)),
      child: Text(
        "$text: $info",
        softWrap: true,
      ),
    );
  }
}
