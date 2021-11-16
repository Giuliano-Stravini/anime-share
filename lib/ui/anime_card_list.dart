import 'dart:ui';

import 'package:alreadywatched/models/anime_summary.dart';
import 'package:alreadywatched/responsive.dart';
import 'package:alreadywatched/stores/user_store.dart';
import 'package:alreadywatched/ui/anime_info.dart';
import 'package:alreadywatched/ui/search_anime_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AnimeCardList extends StatefulWidget {
  const AnimeCardList({
    Key key,
    @required this.query,
    @required this.variables,
    @required this.title,
  }) : super(key: key);

  final String query;
  final String title;
  final Map<String, dynamic> variables;

  @override
  _AnimeCardListState createState() => _AnimeCardListState();
}

class _AnimeCardListState extends State<AnimeCardList> {
  @override
  Widget build(BuildContext context) {
    // var userStore = Provider.of<UserProvider>(context);
    return Query(
      options: QueryOptions(
        document: gql(widget.query),
        variables: widget.variables,
      ),
      builder: (QueryResult result,
          {VoidCallback refetch, FetchMore fetchMore}) {
        if (result.exception != null) {
          print("error");
          print(result.exception.graphqlErrors.toString());
          return Text(result.exception.graphqlErrors.toString());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      widget.title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(
                    color: Colors.orange,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 170,
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 4 / 3,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: result.isLoading
                    ? List.generate(
                        9,
                        (index) => Shimmer.fromColors(
                            child: Container(),
                            baseColor: Colors.grey,
                            highlightColor: Colors.orange))
                    : [
                        ...(result.data['Page']["media"] as List)
                            .map((animeJson) {
                          var animeSummary = AnimeSummary.fromJson(animeJson);

                          return InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AnimeInfo(
                                  animeId: animeSummary.id,
                                ),
                              ),
                            ),
                            child: _buildCard(animeSummary),
                          );
                        }).toList(),
                        TextButton(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 80,
                              ),
                              Text('Ver mais...'),
                            ],
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return Query(
                                  options: QueryOptions(
                                    document: gql(widget.query
                                        .replaceAll("\$count: Int!", "")
                                        .replaceAll("perPage: \$count", "")),
                                    variables: widget.variables,
                                  ),
                                  builder: (QueryResult result,
                                      {VoidCallback refetch,
                                      FetchMore fetchMore}) {
                                    return Scaffold(
                                      appBar: AppBar(
                                        title: Text("Todos"),
                                      ),
                                      body: result.isLoading
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : ListView(
                                              children: (result.data['Page']
                                                      ["media"] as List)
                                                  .map((animeJson) {
                                              var animeSummary =
                                                  AnimeSummary.fromJson(
                                                      animeJson);
                                              return AnimeItem(
                                                animeSummary: animeSummary,
                                              );
                                            }).toList()),
                                    );
                                  });
                            }));
                          },
                        ),
                      ],
              ),
            ),
          ],
        );
      },
    );
  }

  Card _buildCard(AnimeSummary animeSummary) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          children: <Widget>[
            Hero(
              tag: "coverImage_${animeSummary.id ?? 0}",
              child: CachedNetworkImage(
                imageUrl: animeSummary.coverImage,
                placeholder: (context, url) {
                  return Container();
                },
                errorWidget: (context, error, object) =>
                    Icon(Icons.error_outline),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                  color: Colors.black54,
                  padding: EdgeInsets.all(4),
                  child: Container()
                  // InkWell(
                  //   onTap: () {
                  //     print(userStore.user.uid);
                  //     Provider.of<UserProvider>(context,
                  //             listen: false)
                  //         .updateFavoriteList(animeSummary.id,
                  //             userStore.user.uid);
                  //     setState(() {});
                  //   },
                  //   child: userStore
                  //           .checkFavorite(animeSummary.id)
                  //       ? Icon(
                  //           Icons.favorite,
                  //           size: Responsive().horizontal(5),
                  //           color: Colors.red,
                  //         )
                  //       : Icon(
                  //           Icons.favorite_border,
                  //           size: Responsive().horizontal(5),
                  //           color: Colors.white,
                  //         ),
                  // ),
                  ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                color: Colors.black54,
                padding: EdgeInsets.all(4),
                child: Text(
                  animeSummary?.averageScore?.toString() ?? "",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 120,
                color: Colors.black54,
                child: Text(
                  animeSummary?.title ?? "",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ));
  }
}
