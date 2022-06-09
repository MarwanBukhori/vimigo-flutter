import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vimigo/services/json.services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final ScrollController _scrollController = ScrollController();
  final List _displayList = [];
  List? contacts;
  int takeIndex = 10;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();

    //retrieve json
    setting();

    // scrolling listview to load more data
    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        if (_displayList.length < contacts!.length) {
          loadMoreData();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Vimigo Contact",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          body: contacts == null
              ? Center(child: CircularProgressIndicator())
              : Column(children: [
                  Expanded(
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _displayList.length + 1,
                        itemBuilder: (context, index) {
                          if (index < _displayList.length) {
                            return ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    flex: 9,
                                    child: Text(
                                      _displayList[index]['user'],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    setTime(_displayList[index]['check-in']),
                                    style: const TextStyle(
                                        color: Colors.black38, fontSize: 14),
                                  ),
                                ],
                              ),
                              subtitle: Text(_displayList[index]['phone']),
                              trailing: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.share_outlined),
                              ),
                            );
                          } else {
                            return Center(
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 50),
                                  child: index >= contacts!.length
                                      ? const Text(
                                          "You have reached end of the list")
                                      : const CircularProgressIndicator()),
                            );
                          }
                        }),
                  ),
                ])),
    );
  }

  setting() async {
    //declare sharedpreferences
    prefs = await SharedPreferences.getInstance();

    //load up json data
    contacts = await JsonServices.loadJsonData("assets/contacts.json");

    //sort contact up to recent
    contacts!.sort((a, b) {
      return (a['check-in'] as String).compareTo(b['check-in'] as String);
    });

    _displayList.addAll(contacts!.take(10));
    setState(() {});
  }

  loadMoreData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _displayList.addAll(contacts!.getRange(takeIndex, takeIndex + 5));
      takeIndex += 5;
    });
  }

  setTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    if (prefs!.getBool('normalTime') != null && prefs!.getBool('normalTime')!) {
      return DateFormat.yMd().format(dateTime);
    }
    return timeago.format(dateTime);
  }
}
