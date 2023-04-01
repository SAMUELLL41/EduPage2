import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  final SessionManager sessionManager;

  const HomePage({super.key, required this.sessionManager});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late SharedPreferences sharedPreferences;
  String baseUrl = "https://lobster-app-z6jfk.ondigitalocean.app";
  String token = "abcd";
  late Response response;
  Dio dio = Dio();

  bool error = false; //for error status
  bool loading = true; //for data featching status
  String errmsg = ""; //to assing any error message from API/runtime
  dynamic apidata; //for decoded JSON data
  bool refresh = false;

  late Map<String, dynamic> apidataTT;
  late String username;

  @override
  void initState() {
    dio.interceptors
        .add(DioCacheManager(CacheConfig(baseUrl: baseUrl)).interceptor);
    getData(); //fetching data
    super.initState();
  }

  getData() async {
    setState(() {
      loading = true;
    });
    sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> user = await widget.sessionManager.get('user');
    username = user["firstname"] + " " + user["lastname"];
    apidataTT = await widget.sessionManager.get('timetable');
    setState(() {
      loading = false;
    }); //refresh UI
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (loading) {
      return const Center(
        child: Text("Načítání"),
      );
    }

    int lunch = -1;
    DateTime orderLunchesFor = DateTime(1998, 4, 10);
    String? l = sharedPreferences.getString("lunches");
    if (l != null) {
      var lunches = jsonDecode(l) as List<dynamic>;
      var lunchToday = lunches[0] as Map<String, dynamic>;
      lunch = 0;
      var todayLunches = lunchToday["lunches"];
      for (int i = 0; i < todayLunches.length; i++) {
        if (todayLunches[i]["ordered"]) lunch = i + 1;
      }
      for (Map<String, dynamic> li in lunches) {
        if (li["lunches"][0]["can_order"]) {
          orderLunchesFor = DateTime.parse(li["day"]);
          break;
        }
      }
    }
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              border: Border.all(
                color: theme.colorScheme.background,
              ),
              borderRadius: BorderRadiusDirectional.circular(25),
            ),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  child: IconButton(
                    icon: loading
                        ? const Icon(Icons.cloud_download)
                        : const Icon(Icons.cloud_done),
                    onPressed: () => {getData()},
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => {
                    scaffoldKey.currentState?.openDrawer(),
                  },
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 20, right: 20, top: 70),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Card(
                    elevation: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (Map<String, dynamic> lesson
                            in apidataTT["lessons"])
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text(
                                    lesson["period"]["name"] + ".",
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    lesson["subject"]["short"],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    lesson["classrooms"][0]["short"],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 20, right: 20, top: 180),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    lunch == -1
                        ? Text(
                            AppLocalizations.of(context)!.homeLunchesNotLoaded,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          )
                        : lunch == 0
                            ? Text(
                                AppLocalizations.of(context)!.homeNoLunchToday,
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                AppLocalizations.of(context)!
                                    .homeLunchToday(lunch),
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                    Text(AppLocalizations.of(context)!
                        .homeLunchDontForget(orderLunchesFor)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.background,
      drawer: Drawer(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 15),
            ),
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Odhlásit se'),
                onTap: () {},
              ),
            ),
            const AboutListTile(
              icon: Icon(Icons.info_outline),
              applicationName: 'EduPage2',
              applicationVersion: 'Beta 1.2.0 Build 1',
              applicationLegalese: '©2023 Jakub Palacký',
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
}
