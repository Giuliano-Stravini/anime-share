import 'package:alreadywatched/models/anime_summary.dart';
import 'package:alreadywatched/responsive.dart';
import 'package:alreadywatched/stores/user_store.dart';
import 'package:alreadywatched/ui/anime_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

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
        if (result.isLoading) {
          print("loading");
          return Text("loading");
        }
        print("success");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: Responsive().horizontal(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: Responsive().horizontal(8)),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: Responsive().horizontal(6),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(
                    color: Colors.orange,
                  )
                ],
              ),
            ),
            SizedBox(
              height: Responsive().horizontal(50),
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children:
                    (result.data['Page']["media"] as List).map((animeJson) {
                  var animeSummary = AnimeSummary.fromJson(animeJson);

                  return SizedBox(
                    height: Responsive().horizontal(50),
                    width: Responsive().horizontal(37),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnimeInfo(
                            animeId: animeSummary.id,
                          ),
                        ),
                      ),
                      child: Card(
                          margin: EdgeInsets.symmetric(
                              horizontal: Responsive().horizontal(2)),
                          child: Stack(
                            children: <Widget>[
                              Hero(
                                tag: "coverImage_${animeSummary.id}",
                                child: CachedNetworkImage(
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                  imageUrl: animeSummary.coverImage,
                                  errorWidget: (context, error, object) =>
                                      Icon(Icons.error_outline),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                    color: Colors.black54,
                                    padding: EdgeInsets.all(
                                        Responsive().horizontal(1)),
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
                                  padding: EdgeInsets.all(
                                      Responsive().horizontal(1)),
                                  child: Text(
                                    animeSummary.averageScore.toString(),
                                    style: TextStyle(
                                        fontSize: Responsive().horizontal(4)),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: Responsive().horizontal(37),
                                  color: Colors.black54,
                                  child: Text(
                                    animeSummary.title,
                                    style: TextStyle(
                                        fontSize: Responsive().horizontal(4)),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
