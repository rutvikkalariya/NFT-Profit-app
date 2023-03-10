// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coins_page_up.dart';
import 'localization/app_localizations.dart';
import 'models/Bitcoin.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'util/color_util.dart';

class TopLooserAndGainer extends StatefulWidget {
  TopLooserAndGainer({Key? key});
  @override
  TopLooserGainerState createState() => TopLooserGainerState();
}

class TopLooserGainerState extends State<TopLooserAndGainer> {
  String? ApiUrl = 'http://45.34.15.25:8080';
  SharedPreferences? sharedPreferences;

  @override
  void initState() {
    super.initState();
    getData();
  }

  List<Bitcoin> myDataList = [];

  void getData() async {
    var uri = Uri.parse(
        "http://45.34.15.25:8080/Bitcoin/resources/getBitcoinListLoser?size=0");
    var response = await get(uri);
    final data = json.decode(response.body) as Map;
    if (data['error'] == false) {
      setState(() {
        myDataList.addAll(data['data']
            .map<Bitcoin>((json) => Bitcoin.fromJson(json))
            .toList());
        // isLoading = false;
        // size = size + data['data'].length;
        print(myDataList.length);
        // print(myDataList);
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Container(
            padding: EdgeInsets.fromLTRB(35, 10, 35, 10),
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            decoration: BoxDecoration(
              color: getColorFromHex("#0B52E1"),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Text(
              AppLocalizations.of(context)!.translate('gainer_loser')!,
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 15)),
              textAlign: TextAlign.start,
            )),
        leading: InkWell(
          child: Container(
            child: Image.asset(
              "assets/images/back.png",
              height: 25,
              width: 25,
            ),
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        leadingWidth: 35,
        actions: <Widget>[],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: DefaultTabController(
              initialIndex: 0,
              length: 2,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      boxShadow: kElevationToShadow[0],
                      color: getPrimaryColor(),
                    ),
                    child: Container(
                      width: 300,
                      height: 30,
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      decoration: BoxDecoration(
                        color: getPrimaryColor(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: getColorFromHex("#FF7C74")),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black,
                        tabs: [
                          Tab(
                              child: Text(
                            AppLocalizations.of(context)!
                                .translate('top_gainer')!,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                    color: Colors.white)),
                            textAlign: TextAlign.left,
                          )),
                          Tab(
                              child: Text(
                            AppLocalizations.of(context)!
                                .translate('top_looser')!,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                    color: Colors.white)),
                            textAlign: TextAlign.left,
                          )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: TabBarView(children: [
                    topGainer(),
                    topLooser(),
                  ])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topGainer() {
    var list = myDataList
        .where((element) => double.parse(element.diffRate!) >= 0)
        .toList();
    return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (BuildContext context, int i) {
          return InkWell(
            child: Column(
              children: [
                Container(
                  color: getPrimaryColor(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Container(
                      height: 80,
                      padding: EdgeInsets.all(8),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  height: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: FadeInImage(
                                      placeholder:
                                          AssetImage('assets/images/cob.png'),
                                      image: NetworkImage(
                                          "$ApiUrl/Bitcoin/resources/icons/${list[i].name!.toLowerCase()}.png"),
                                    ),
                                  )),
                              SizedBox(
                                width: 15,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 7, 0, 0),
                                    child: Text(
                                      '${list[i].name}',
                                      style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 24,
                                              color: Colors.white)),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              callCurrencyDetails(list[i].name);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 4,
                              height: 40,
                              child: new charts.LineChart(
                                _createSampleData(list[i].historyRate,
                                    double.parse(list[i].diffRate!)),
                                layoutConfig: new charts.LayoutConfig(
                                    leftMarginSpec:
                                        new charts.MarginSpec.fixedPixel(5),
                                    topMarginSpec:
                                        new charts.MarginSpec.fixedPixel(10),
                                    rightMarginSpec:
                                        new charts.MarginSpec.fixedPixel(5),
                                    bottomMarginSpec:
                                        new charts.MarginSpec.fixedPixel(10)),
                                defaultRenderer: new charts.LineRendererConfig(
                                  includeArea: true,
                                  stacked: true,
                                ),
                                animate: true,
                                domainAxis: charts.NumericAxisSpec(
                                    showAxisLine: false,
                                    renderSpec: charts.NoneRenderSpec()),
                                primaryMeasureAxis: charts.NumericAxisSpec(
                                    renderSpec: charts.NoneRenderSpec()),
                              ),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        '\$${double.parse(list[i].rate!.toStringAsFixed(2))}',
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                        )),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      double.parse(list[i].diffRate!) < 0
                                          ? Container(
                                              // color: Colors.red,
                                              child: Icon(
                                                Icons.arrow_downward,
                                                color:
                                                    getColorFromHex("#FF7C74"),
                                                size: 15,
                                              ),
                                            )
                                          : Container(
                                              // color: Colors.green,
                                              child: Icon(
                                                Icons.arrow_upward_sharp,
                                                color:
                                                    getColorFromHex("#11CABE"),
                                                size: 15,
                                              ),
                                            ),
                                      SizedBox(width: 2),
                                      Text(list[i].perRate!,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: double.parse(
                                                          list[i].diffRate!) <
                                                      0
                                                  ? getColorFromHex("#FF7C74")
                                                  : getColorFromHex(
                                                      "#11CABE"))),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.white,
                  thickness: 1,
                  endIndent: 20,
                  indent: 20,
                ),
              ],
            ),
            onTap: () {
              callCurrencyDetails(myDataList[i].name);
            },
          );
        });
  }

  List<charts.Series<LinearSales, int>> _createSampleData(
      historyRate, diffRate) {
    List<LinearSales> listData = [];
    for (int i = 0; i < historyRate.length; i++) {
      double rate = historyRate[i]['rate'];
      listData.add(new LinearSales(i, rate));
    }

    return [
      new charts.Series<LinearSales, int>(
        id: 'Tablet',
        // colorFn specifies that the line will be red.
        colorFn: (_, __) => diffRate < 0
            ? charts.MaterialPalette.red.shadeDefault
            : charts.MaterialPalette.green.shadeDefault,
        // areaColorFn specifies that the area skirt will be light red.
        // areaColorFn: (_, __) => charts.MaterialPalette.red.shadeDefault.lighter,
        domainFn: (LinearSales sales, _) => sales.count,
        measureFn: (LinearSales sales, _) => sales.rate,
        data: listData,
      ),
    ];
  }

  Widget topLooser() {
    var list = myDataList
        .where((element) => double.parse(element.diffRate!) < 0)
        .toList();
    return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (BuildContext context, int i) {
          return InkWell(
            child: Column(
              children: [
                Container(
                  color: getPrimaryColor(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Container(
                      height: 80,
                      padding: EdgeInsets.all(8),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  height: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: FadeInImage(
                                      placeholder:
                                          AssetImage('assets/images/cob.png'),
                                      image: NetworkImage(
                                          "$ApiUrl/Bitcoin/resources/icons/${list[i].name!.toLowerCase()}.png"),
                                    ),
                                  )),
                              SizedBox(
                                width: 15,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 7, 0, 0),
                                    child: Text(
                                      '${list[i].name}',
                                      style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 24,
                                              color: Colors.white)),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              callCurrencyDetails(list[i].name);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 4,
                              height: 40,
                              child: new charts.LineChart(
                                _createSampleData(list[i].historyRate,
                                    double.parse(list[i].diffRate!)),
                                layoutConfig: new charts.LayoutConfig(
                                    leftMarginSpec:
                                        new charts.MarginSpec.fixedPixel(5),
                                    topMarginSpec:
                                        new charts.MarginSpec.fixedPixel(10),
                                    rightMarginSpec:
                                        new charts.MarginSpec.fixedPixel(5),
                                    bottomMarginSpec:
                                        new charts.MarginSpec.fixedPixel(10)),
                                defaultRenderer: new charts.LineRendererConfig(
                                  includeArea: true,
                                  stacked: true,
                                ),
                                animate: true,
                                domainAxis: charts.NumericAxisSpec(
                                    showAxisLine: false,
                                    renderSpec: charts.NoneRenderSpec()),
                                primaryMeasureAxis: charts.NumericAxisSpec(
                                    renderSpec: charts.NoneRenderSpec()),
                              ),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        '\$${double.parse(list[i].rate!.toStringAsFixed(2))}',
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                        )),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      double.parse(list[i].diffRate!) < 0
                                          ? Container(
                                              // color: Colors.red,
                                              child: Icon(
                                                Icons.arrow_downward,
                                                color:
                                                    getColorFromHex("#FF7C74"),
                                                size: 15,
                                              ),
                                            )
                                          : Container(
                                              // color: Colors.green,
                                              child: Icon(
                                                Icons.arrow_upward_sharp,
                                                color:
                                                    getColorFromHex("#11CABE"),
                                                size: 15,
                                              ),
                                            ),
                                      SizedBox(width: 2),
                                      Text(list[i].perRate!,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: double.parse(
                                                          list[i].diffRate!) <
                                                      0
                                                  ? getColorFromHex("#FF7C74")
                                                  : getColorFromHex(
                                                      "#11CABE"))),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.white,
                  thickness: 1,
                  endIndent: 20,
                  indent: 20,
                ),
              ],
            ),
            onTap: () {
              callCurrencyDetails(myDataList[i].name);
            },
          );
        });
  }

  Future<void> callCurrencyDetails(name) async {
    _saveProfileData(name);
  }

  _saveProfileData(String name) async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setString("currencyName", name);
      sharedPreferences!.setInt("index", 1);
      sharedPreferences!.setString(
          "title", AppLocalizations.of(context)!.translate('trends') ?? '');
      sharedPreferences!.commit();
    });

    Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
  }
}
