import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vimigo/services/json.services.dart';

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

  @override
  void initState() {
    super.initState();

    //retrieve json
    setting();

    // scroll listview
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
                                ],
                              ),
                              subtitle:
                              Text(_displayList[index]['phone']),
                              trailing: IconButton(
                                onPressed: () {
                                },
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
    //load up json data
    contacts = await JsonServices.loadJsonData("assets/contacts.json");

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
}
