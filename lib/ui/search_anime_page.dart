import 'package:alreadywatched/models/anime_summary.dart';
import 'package:alreadywatched/ui/anime_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SearchAnimePage extends SearchDelegate {
  String animeQuery = r'''
  query($animeInput: String!){
    Page{
      media(search: $animeInput, isAdult: false, type: ANIME){
        id,
        coverImage{
          large
        }
        title{
          english,
          romaji
        }
      }
    }
  }
  ''';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          showResults(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(animeQuery),
        variables: {'animeInput': query},
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
        return ListView(
          children: (result.data["Page"]['media'] as List).map((anime) {
            var animeSummary = AnimeSummary.fromJson(anime);
            return Column(
              children: <Widget>[
                AnimeTile(animeSummary: animeSummary),
                Divider(
                  color: Colors.orange,
                )
              ],
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}

class AnimeTile extends StatelessWidget {
  const AnimeTile({
    Key key,
    @required this.animeSummary,
  }) : super(key: key);

  final AnimeSummary animeSummary;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AnimeInfo(animeId: animeSummary.id))),
        leading: CachedNetworkImage(
          imageUrl: animeSummary.coverImage,
          fit: BoxFit.fill,
          errorWidget: (_, a, b) => Icon(Icons.error_outline),
        ),
        title: Text(animeSummary.title));
  }
}
