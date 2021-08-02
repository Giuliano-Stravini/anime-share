import 'package:alreadywatched/responsive.dart';
import 'package:alreadywatched/stores/user_store.dart';
import 'package:alreadywatched/ui/anime_card_list.dart';
import 'package:alreadywatched/ui/search_anime_page.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.userStore}) : super(key: key);

  final String title;
  final UserProvider userStore;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YearsAnimeList(),
    );
  }
}

class YearsAnimeList extends StatefulWidget {
  const YearsAnimeList({
    Key key,
  }) : super(key: key);

  @override
  _YearsAnimeListState createState() => _YearsAnimeListState();
}

class _YearsAnimeListState extends State<YearsAnimeList> {
  DateTime _selectedDate = DateTime.now();
  int _seasonYear;

  @override
  void initState() {
    super.initState();
    _seasonYear = _selectedDate.year;
    // widget.userStore.fetchUserSnapshot();
  }

  var seasonQuery = r'''
query($seasonYear: Int! ,$season: MediaSeason!){
Page(){
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
      drawer: Menu(),
      appBar: AppBar(
        centerTitle: true,
        title: InkWell(
          onTap: () => _buildShowBottomSheet(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Season $_seasonYear"),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () =>
                showSearch(context: context, delegate: SearchAnimePage()),
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: ListView(
        // shrinkWrap: true,
        padding: EdgeInsets.only(bottom: Responsive().horizontal(8)),
        children: <Widget>[
          AnimeCardList(
            query: seasonQuery,
            variables: {
              "seasonYear": _seasonYear,
              "season": "WINTER",
            },
            title: "Winter",
          ),
          Text("*December ${(_seasonYear - 1)} to February of $_seasonYear"),
          AnimeCardList(
            query: seasonQuery,
            variables: {
              "seasonYear": _seasonYear,
              "season": "SPRING",
            },
            title: "Spring",
          ),
          AnimeCardList(
            query: seasonQuery,
            variables: {
              "seasonYear": _seasonYear,
              "season": "SUMMER",
            },
            title: "Summer",
          ),
          AnimeCardList(
            query: seasonQuery,
            variables: {
              "seasonYear": _seasonYear,
              "season": "FALL",
            },
            title: "Fall",
          ),
        ],
      ),
    );
  }

  PersistentBottomSheetController _buildShowBottomSheet(BuildContext context) {
    return showBottomSheet(
        context: context,
        builder: (BuildContext context) => Container(
              height: Responsive().horizontal(40),
              child: YearPicker(
                selectedDate: _selectedDate,
                firstDate: DateTime(1995),
                lastDate: DateTime.now(),
                onChanged: (val) {
                  setState(() {
                    _selectedDate = val;
                    _seasonYear = val.year;
                  });
                  Navigator.pop(context);
                },
              ),
            ));
  }
}

class Menu extends StatefulWidget {
  Menu({Key key}) : super(key: key);

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
            child: FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text("Profile"),
              onPressed: () {},
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FlatButton.icon(
              icon: Icon(Icons.favorite),
              label: Text("Favorites"),
              onPressed: () {},
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FlatButton.icon(
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
  const FavoritePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _userStore = Provider.of<UserProvider>(context);

    // var query =

    // Scaffold(body: Observer(builder: (_) => ListView()));
  }
}
