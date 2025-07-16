import 'package:alreadywatched/l10n/app_localizations.dart';
import 'package:alreadywatched/stores/user_store.dart';
import 'package:alreadywatched/ui/anime_card_list.dart';
import 'package:alreadywatched/ui/search_anime_page.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class YearsAnimeList extends StatefulWidget {
  const YearsAnimeList({
    Key? key,
  }) : super(key: key);

  @override
  _YearsAnimeListState createState() => _YearsAnimeListState();
}

class _YearsAnimeListState extends State<YearsAnimeList> {
  DateTime _selectedDate = DateTime.now();
  int? _seasonYear;

  @override
  void initState() {
    super.initState();
    _seasonYear = _selectedDate.year;
    // widget.userStore.fetchUserSnapshot();
  }

  var seasonQuery = r'''
query($seasonYear: Int! ,$season: MediaSeason!, $count: Int!){
Page(perPage: $count){
  pageInfo {
      total
      perPage
      currentPage
      lastPage
      hasNextPage
    }
  media(season: $season, seasonYear: $seasonYear, sort: [SCORE_DESC], isAdult: false, type: ANIME){
     id
     averageScore
     coverImage{
       large
     },
     season,
      title {
        romaji
      }
  }
}
}
''';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: Menu(),
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
        title: Text('Anime Finder'),
        actions: <Widget>[
          IconButton(
            onPressed: () =>
                showSearch(context: context, delegate: SearchAnimePage()),
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 16),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 8),
            child: InkWell(
              onTap: () => _buildShowBottomSheet(context, _seasonYear!),
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "${AppLocalizations.of(context)!.season} $_seasonYear",
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          AnimeCardList(
            query: seasonQuery,
            variables: {
              "seasonYear": _seasonYear,
              "season": "WINTER",
              "count": 10
            },
            title: "TOP 10 ${AppLocalizations.of(context)!.winter}*",
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '*${AppLocalizations.of(context)!.winterSeasonDuration.replaceFirst('[X]', (_seasonYear! - 1).toString()).replaceFirst('[Y]', _seasonYear.toString())}',
              style: TextStyle(fontSize: 12),
            ),
          ),
          AnimeCardList(
            query: seasonQuery,
            variables: {
              "seasonYear": _seasonYear,
              "season": "SPRING",
              "count": 10
            },
            title: "TOP 10 ${AppLocalizations.of(context)!.spring}",
          ),
          AnimeCardList(
            query: seasonQuery,
            variables: {
              "seasonYear": _seasonYear,
              "season": "SUMMER",
              "count": 10
            },
            title: "TOP 10 ${AppLocalizations.of(context)!.summer}",
          ),
          AnimeCardList(
            query: seasonQuery,
            variables: {
              "seasonYear": _seasonYear,
              "season": "FALL",
              "count": 10
            },
            title: "TOP 10 ${AppLocalizations.of(context)!.fall}",
          ),
        ],
      ),
    );
  }

  PersistentBottomSheetController _buildShowBottomSheet(
      BuildContext context, int _currentYear) {
    return showBottomSheet(
        context: context,
        constraints: BoxConstraints(minHeight: 0, maxHeight: 180),
        builder: (BuildContext context) => YearPicker(
              selectedDate: _selectedDate,
              firstDate: DateTime(1990),
              lastDate: DateTime.now(),
              onChanged: (val) {
                setState(() {
                  _selectedDate = val;
                  _seasonYear = val.year;
                });
                Navigator.pop(context);
              },
            ));
  }
}

class Menu extends StatefulWidget {
  Menu({Key? key}) : super(key: key);

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    var _userStore = Provider.of<UserProvider>(context);

    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(color: ThemeData.dark().primaryColor),
              child: Container(),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: Icon(Icons.person),
              label: Text("Profile"),
              onPressed: () {},
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: Icon(Icons.favorite),
              label: Text("Favorites"),
              onPressed: () {},
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: Icon(Icons.exit_to_app, color: Colors.red),
              label: Text("Sign out"),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _userStore = Provider.of<UserProvider>(context);

    return Container();

    // var query =

    // Scaffold(body: Observer(builder: (_) => ListView()));
  }
}
