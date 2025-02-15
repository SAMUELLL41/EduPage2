import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeworkPage extends StatefulWidget {
  final SessionManager sessionManager;

  const HomeworkPage({super.key, required this.sessionManager});

  @override
  State<HomeworkPage> createState() => HomeworkPageState();
}

class HomeworkPageState extends State<HomeworkPage> {
  bool loading = true;
  late List<dynamic> apidataMsg;

  late Widget messages;

  @override
  void initState() {
    getData(); //fetching data
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  getData() async {
    setState(() {
      loading = true; //make loading true to show progressindicator
    });

    Map<String, dynamic> msgs = await widget.sessionManager.get('homework');
    apidataMsg = msgs.values.toList();
    messages = getMessages(apidataMsg);

    loading = false;
    setState(() {}); //refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: !loading
          ? Stack(
              children: <Widget>[messages],
            )
          : Text(AppLocalizations.of(context)!.loading),
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }

  Future<void> _pullRefresh() async {
    setState(() {
      loading = true; //make loading true to show progressindicator
    });

    Map<String, dynamic> msgs = await widget.sessionManager.get('homework');
    apidataMsg = msgs.values.toList();
    messages = getMessages(apidataMsg);

    loading = false;
    setState(() {}); //refresh UI
  }

  Widget getMessages(var apidataMsg) {
    List<Widget> rows = <Widget>[];
    apidataMsg ??= [
      {
        "type": "testpridelenie",
        "title": "Načítání...",
        "text": "Nebude to trvat dlouho",
      }
    ];
    for (Map<String, dynamic> msg in apidataMsg) {
      String textAsTitle = "This isn't supposed to happen...";
      if (msg.keys.contains("name") && msg["name"] != null) {
        textAsTitle = msg["name"];
      } else if (msg.keys.contains("assignment") && msg["assignment"] != null) {
        textAsTitle = msg["assignment"]["title"];
      } else {
        continue;
      }
      rows.add(Card(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(msg["autor_meno"]),
                    const Icon(Icons.arrow_right_rounded),
                    Expanded(
                      child: Text(
                        msg["predmet_meno"],
                        overflow: TextOverflow.fade,
                        maxLines: 5,
                        softWrap: false,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        textAsTitle,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.fade,
                        maxLines: 5,
                        softWrap: false,
                      ),
                    )
                  ],
                ),
              ],
            )),
      ));
    }
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.homeworkTitle,
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 40),
                child: RefreshIndicator(
                  onRefresh: _pullRefresh,
                  child: ListView(
                    children: rows,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
