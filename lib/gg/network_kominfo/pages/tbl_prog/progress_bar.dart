import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ta_uniska_bjm/gg/network_kominfo/model/users.dart';
import 'package:ta_uniska_bjm/gg/network_kominfo/widgetsutils/pagecontrol.dart';
import 'package:ta_uniska_bjm/gg/network_kominfo/widgetsutils/robot.dart';
import 'package:ta_uniska_bjm/utils/widgets/scroll_parent.dart';

import 'data_generator.dart';

class ProgressPageBar extends StatefulWidget {
  final String ipIs;
  final Users user;
  final bool exp;
  const ProgressPageBar(
      {Key? key, required this.ipIs, required this.user, required this.exp})
      : super(key: key);

  @override
  State<ProgressPageBar> createState() => _ProgressPageBarState();
}

class _ProgressPageBarState extends State<ProgressPageBar> {
  final _rollCon = ScrollController();
  int _lit = 0, _maxPage = 1;

  Future<void>? _setMaxPage() async {
    try {
      Uri docari =
          Uri.parse("https://${widget.ipIs}/jaringan/conn/doProsess.php");
      final responecari = await http.post(docari, body: {
        'action': 'getJumlahData',
        'key': 'RumputJatuh',
        'sql': 'ProBaru'
      });
      double totalData = double.parse(responecari.body);
      _maxPage = totalData ~/ 6;
      if (totalData % 6 != 0) _maxPage++;
    } catch (e) {
      debugPrint(e.toString());
      _maxPage = 1;
    }
  }

  Future<List> _dataSet() async {
    try {
      Uri dophp =
          Uri.parse("https://${widget.ipIs}/jaringan/conn/doProsess.php");
      final respone = await http.post(dophp, body: {
        'action': 'getAllData',
        'key': 'RumputJatuh',
        'jenis': 'baru',
        'lit': _lit.toString()
      });
      await Future.delayed(const Duration(milliseconds: 500));
      return jsonDecode(respone.body);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      return <String>[];
    }
  }

  late Color color1;

  @override
  void initState() {
    color1 = getBlueColor();
    super.initState();
    _setMaxPage();
  }

  @override
  void dispose() {
    _rollCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tinggi = MediaQuery.of(context).size.height;
    final lebar = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.only(top: 5, right: 5),
      margin: EdgeInsets.only(left: widget.exp ? 50 : 0),
      child: FutureBuilder<void>(
          future: _setMaxPage(),
          builder: (context, x) {
            return ListView(
              controller: _rollCon,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: 90, left: lebar - 340, bottom: 30),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey.shade200),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.home,
                              color: Colors.blue,
                            ),
                            Text("/ "),
                            Text(
                              "Progress ",
                              style: TextStyle(color: Colors.blue),
                            ),
                            Text(
                              "/ Progress Pemasangan Baru",
                              style: TextStyle(color: Colors.blue),
                            ),
                            Text("/ Tabels")
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Stack(
                    children: [
                      Container(
                        height: (tinggi >= 255) ? tinggi - 255 : tinggi,
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26, offset: Offset(5, 4))
                            ],
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        margin: const EdgeInsets.only(
                            top: 40, left: 20, right: 10, bottom: 5),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: FutureBuilder<List>(
                                  future: _dataSet(),
                                  builder: (context, snapped) {
                                    if (snapped.hasError) {
                                      return Center(
                                        child: Text(snapped.toString()),
                                      );
                                    } else {
                                      try {
                                        if (snapped.data!.isEmpty) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                bottom: (tinggi >= 415)
                                                    ? tinggi - 415
                                                    : tinggi,
                                                top: 40),
                                            child: noDataSizedBox(),
                                          );
                                        }
                                        return SizedBox(
                                            height: (tinggi > 350)
                                                ? tinggi - 350
                                                : tinggi,
                                            width: 500,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: ScrollParent(
                                                controller: _rollCon,
                                                child: ProgGanList(
                                                  color1,
                                                  [
                                                    (widget.user.status ==
                                                            "petugas" ||
                                                        widget.user.status ==
                                                            "twomni"),
                                                    (widget.user.status ==
                                                        "admin"),
                                                    (widget.user.status ==
                                                        "twomni"),
                                                  ],
                                                  controller: _rollCon,
                                                  refresh: () {
                                                    setState(() {});
                                                  },
                                                  user: widget.user,
                                                  list: snapped.data,
                                                  ipIs: widget.ipIs,
                                                ),
                                              ),
                                            ));
                                      } catch (e) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              top: 40,
                                              bottom: (tinggi >= 415)
                                                  ? tinggi - 415
                                                  : tinggi),
                                          child: noDataSizedBox(),
                                        );
                                      }
                                    }
                                  }),
                            ),
                            PageControl(_maxPage, newPage: (i) {
                              _lit = (6 * i) - 6;
                              setState(() {});
                            })
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 208, 225, 249),
                        ),
                        margin: EdgeInsets.only(
                            left: (widget.exp) ? 60 : 30, top: 0),
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            gradient: const LinearGradient(colors: [
                              Color.fromARGB(255, 110, 181, 192),
                              Color.fromARGB(255, 146, 170, 199)
                            ]),
                          ),
                          child: const Text(
                            "Data Progress Pemasangan Baru",
                            style: TextStyle(color: Colors.white, fontSize: 28),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
