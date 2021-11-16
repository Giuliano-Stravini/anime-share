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
          return Material(
              child: Center(
                  child: Text(result.exception.graphqlErrors.toString())));
        }
        if (result.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: (result.data["Page"]['media'] as List).map((anime) {
            var animeSummary = AnimeSummary.fromJson(anime);
            return AnimeItem(animeSummary: animeSummary);
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

class AnimeItem extends StatelessWidget {
  const AnimeItem({
    Key key,
    @required this.animeSummary,
  }) : super(key: key);

  final AnimeSummary animeSummary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnimeInfo(animeId: animeSummary.id),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  height: 70,
                  imageUrl: animeSummary.coverImage,
                  fit: BoxFit.fill,
                  errorWidget: (_, a, b) => Icon(Icons.error_outline),
                ),
              ),
              Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                    child: Text(animeSummary.title),
                  ))
            ],
          ),
        ),
        Divider(
          color: Colors.orange,
        )
      ],
    );
  }
}

// class AnimeTile extends StatelessWidget {
//   const AnimeTile({
//     Key key,
//     @required this.animeSummary,
//   }) : super(key: key);

//   final AnimeSummary animeSummary;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//         onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => AnimeInfo(animeId: animeSummary.id))),
//         leading: CachedNetworkImage(
//           imageUrl: animeSummary.coverImage,
//           fit: BoxFit.fill,
//           errorWidget: (_, a, b) => Icon(Icons.error_outline),
//         ),
//         title: Text(animeSummary.title));
//   }
// }
