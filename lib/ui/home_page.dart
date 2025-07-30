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
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
        centerTitle: true,
        title: Text('Anime Finder'),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 16, left: 16),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 18.0, bottom: 16),
            child: ContentSearchField(
              onPressedCallback: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchAnimePage(
                      query: value.trim(),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                onTap: () => _buildShowBottomSheet(context, _seasonYear!),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${AppLocalizations.of(context)!.season} $_seasonYear",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
          AnimeCardList(
            query: seasonQuery,
            variables: {
              "seasonYear": _seasonYear,
              "season": "WINTER",
              "count": 10
            },
            title: "TOP 10 ${AppLocalizations.of(context)!.winter}*",
            seasonYear: _seasonYear,
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

class ContentSearchField extends StatelessWidget {
  ContentSearchField({required this.onPressedCallback});

  void Function(String value) onPressedCallback = (value) {};
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.search,
          hintStyle: TextStyle(color: Colors.white),
          suffixIcon: IconButton(
              icon: Icon(Icons.search),
              color: Colors.white,
              onPressed: () {
                onPressedCallback(searchController.text);
              }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          contentPadding: EdgeInsets.only(left: 24.0),
          fillColor: const Color(0xFF120703),
          filled: true),
    );
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
