import 'package:alreadywatched/models/anime_summary.dart';
import 'package:alreadywatched/ui/anime_info.dart';
import 'package:alreadywatched/ui/home_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SearchAnimePage extends StatefulWidget {
  const SearchAnimePage({required this.query});
  final String query;

  @override
  State<SearchAnimePage> createState() => _SearchAnimePageState();
}

class _SearchAnimePageState extends State<SearchAnimePage> {
  String _query = '';

  @override
  void initState() {
    _query = widget.query;
    super.initState();
  }

  final String animeQuery = r'''
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Anime Finder'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ContentSearchField(
              onPressedCallback: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          Query(
            options: QueryOptions(
              document: gql(animeQuery),
              variables: {'animeInput': _query},
            ),
            builder: (QueryResult? result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result!.exception != null) {
                print("error");
                print(result.exception!.graphqlErrors.toString());
                return Material(
                    child: Center(
                        child:
                            Text(result.exception!.graphqlErrors.toString())));
              }
              if (result.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              return Expanded(
                child: ListView(
                  children:
                      (result.data!["Page"]['media'] as List).map((anime) {
                    var animeSummary = AnimeSummary.fromJson(anime);
                    return AnimeItem(animeSummary: animeSummary);
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnimeItem extends StatelessWidget {
  const AnimeItem({
    Key? key,
    required this.animeSummary,
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
              builder: (_) => AnimeInfo(animeId: animeSummary.id!),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  height: 70,
                  imageUrl: animeSummary.coverImage!,
                  fit: BoxFit.fill,
                  errorWidget: (_, a, b) => Icon(Icons.error_outline),
                ),
              ),
              Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                    child: Text(animeSummary.title!),
                  ))
            ],
          ),
        ),
        Divider(
          color: const Color(0xFFE6B17E),
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
