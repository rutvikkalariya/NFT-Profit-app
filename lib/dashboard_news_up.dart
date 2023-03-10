// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'coins_page_up.dart';
import 'dashboard_helper.dart';
import 'localization/app_localizations.dart';
import 'models/Bitcoin.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'models/TopCoinData.dart';
import 'top_looser_gainer_screen.dart';
import 'util/color_util.dart';

class DashboardNew extends StatefulWidget {
  Function() onPortfolioSubmit;
  DashboardNew({Key? key, required this.onPortfolioSubmit}) : super(key: key);

  @override
  _DashboardNewState createState() => _DashboardNewState();
}

class _DashboardNewState extends State<DashboardNew> {
  bool isLoading = false;
  List<Bitcoin> bitcoinList = [];
  List<TopCoinData> topCoinList = [];
  List<Bitcoin> gainerLooserCoinList = [];
  List<Bitcoin> _searchResult = [];
  SharedPreferences? sharedPreferences;
  TextEditingController _searchController = new TextEditingController();
  num _size = 0;
  String? ApiUrl = 'http://45.34.15.25:8080';

  double totalValuesOfPortfolio = 0.0;
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    // callTopBitcoinApi();
    // fetchRemoteValue();
    callTopBitcoinApi();
    dbHelper.queryAllRows().then((notes) {
      notes.forEach((note) {
        totalValuesOfPortfolio = totalValuesOfPortfolio + note["total_value"];
      });
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 30),
              Stack(
                children: [
                  Center(
                    child: Image.asset(
                      "assets/images/Card surface red.png",
                      height: 180,
                      width: 400,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Image.asset(
                        "assets/images/Card surface yellow.png",
                        // height: 200,
                        // width: 500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Center(
                      child: Image.asset(
                        "assets/images/Card surface blue.png",
                        // height: 200,
                        // width: 500,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(60, 50, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!
                                  .translate('total_portfolio') ??
                              '',
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: getColorFromHex("#494D58"))),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(60, 5, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '\$ ${totalValuesOfPortfolio.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 28,
                                  color: Colors.black)),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(215, 30, 0, 0),
                    child: Image.asset(
                      "assets/images/topright.png",
                      // height: 200,
                      // width: 500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(240, 100, 0, 0),
                    child: Image.asset(
                      "assets/images/bottomRight.png",
                      // height: 200,
                      // width: 500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!
                                .translate('top_coins')!,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 18)),
                          )),
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      if (gainerLooserCoinList.isNotEmpty) {
                        _RoutePageData();
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.translate("see_all")!,
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: getColorFromHex("#F5C249"),
                              fontSize: 16)),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  // height: 225,
                  height: MediaQuery.of(context).size.height / 4,
                  child: topCoinList.length <= 0
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: topCoinList.length,
                          itemBuilder: (BuildContext context, int i) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    callCurrencyDetails(topCoinList[i].name);
                                  },
                                  child: Column(
                                      // alignment: Alignment.topLeft,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 20),
                                          decoration: BoxDecoration(
                                              color: getColorFromHex("#282B35"),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              4,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.3,

                                          // decoration: BoxDecoration(
                                          //     image: DecorationImage(
                                          //         fit: BoxFit.cover,
                                          //         image: i % 2 == 0
                                          //             ? AssetImage(
                                          //                 'assets/images/portfolio_background.png')
                                          //             : AssetImage(
                                          //                 'assets/images/Card.png')),
                                          //     borderRadius:
                                          //         BorderRadius.circular(
                                          //             25)),
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 3.0),
                                                      child: FadeInImage(
                                                        width: 40,
                                                        fit: BoxFit.contain,
                                                        height: 40,
                                                        placeholder: AssetImage(
                                                            'assets/images/cob.png'),
                                                        image: NetworkImage(
                                                            "$ApiUrl/Bitcoin/resources/icons/${topCoinList[i].name!.toLowerCase()}.png"),
                                                        // image: NetworkImage("http://45.34.15.25:8080/Bitcoin/resources/icons/${topCoinList[i].name.toLowerCase()}.png"),
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.topLeft,
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      '${topCoinList[i].name}',
                                                      style: GoogleFonts.poppins(
                                                          textStyle: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 20,
                                                              color: Colors
                                                                  .white)),
                                                      // style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold,color:Colors.white,fontFamily: GoogleFonts.poppins()),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    margin: EdgeInsets.fromLTRB(
                                                        15, 0, 15, 0),
                                                    alignment:
                                                        Alignment.topLeft,
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                child: Text(
                                                  '\$ ${topCoinList[i].rate!.toStringAsFixed(2)}',
                                                  style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 20,
                                                          color:
                                                              getColorFromHex(
                                                                  "#A7AEBF"))),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.left,
                                                ),
                                                margin: EdgeInsets.fromLTRB(
                                                    5, 10, 5, 0),
                                                alignment: Alignment.topLeft,
                                              ),
                                              Row(
                                                children: [
                                                  double.parse(topCoinList[i]
                                                              .diffRate!) <
                                                          0
                                                      ? Container(
                                                          child: Icon(
                                                            Icons
                                                                .arrow_drop_down_sharp,
                                                            color: Colors.red,
                                                            size: 25,
                                                          ),
                                                        )
                                                      : Container(
                                                          child: Icon(
                                                            Icons
                                                                .arrow_drop_up_sharp,
                                                            color: Colors.green,
                                                            size: 25,
                                                          ),
                                                        ),
                                                  Container(
                                                    child: Text(
                                                      double.parse(topCoinList[
                                                                      i]
                                                                  .diffRate!) <
                                                              0
                                                          ? "\$ " +
                                                              double.parse(topCoinList[
                                                                          i]
                                                                      .diffRate!
                                                                      .replaceAll(
                                                                          '-',
                                                                          ""))
                                                                  .toStringAsFixed(
                                                                      2)
                                                          : "\$ " +
                                                              double.parse(
                                                                      topCoinList[
                                                                              i]
                                                                          .diffRate!)
                                                                  .toStringAsFixed(
                                                                      2),
                                                      style: GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          textStyle: TextStyle(
                                                              fontSize: 15,
                                                              color: double.parse(
                                                                          topCoinList[i]
                                                                              .diffRate!) <
                                                                      0
                                                                  ? Colors
                                                                      .redAccent
                                                                  : Colors
                                                                      .greenAccent)),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    margin: EdgeInsets.fromLTRB(
                                                        5, 0, 5, 0),
                                                    alignment:
                                                        Alignment.topLeft,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              GestureDetector(
                                                onTap: () {
                                                  callCurrencyDetails(
                                                      bitcoinList[i].name);
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4,
                                                  height: 40,
                                                  child: new charts.LineChart(
                                                    _createSampleData(
                                                        gainerLooserCoinList[i]
                                                            .historyRate,
                                                        double.parse(
                                                            gainerLooserCoinList[
                                                                    i]
                                                                .diffRate!)),
                                                    layoutConfig: new charts
                                                            .LayoutConfig(
                                                        leftMarginSpec: new charts
                                                                .MarginSpec.fixedPixel(
                                                            5),
                                                        topMarginSpec: new charts
                                                                .MarginSpec.fixedPixel(
                                                            10),
                                                        rightMarginSpec: new charts
                                                                .MarginSpec.fixedPixel(
                                                            5),
                                                        bottomMarginSpec: new charts
                                                                .MarginSpec.fixedPixel(
                                                            10)),
                                                    defaultRenderer: new charts
                                                        .LineRendererConfig(
                                                      includeArea: true,
                                                      stacked: true,
                                                    ),
                                                    animate: true,
                                                    domainAxis:
                                                        charts.NumericAxisSpec(
                                                            showAxisLine: false,
                                                            renderSpec: charts
                                                                .NoneRenderSpec()),
                                                    primaryMeasureAxis:
                                                        charts.NumericAxisSpec(
                                                            renderSpec: charts
                                                                .NoneRenderSpec()),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                ),
                              ],
                            );
                          },
                        )),
              SizedBox(height: 10),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.translate('Coins')!,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 18)),
                          )),
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      if (gainerLooserCoinList.isNotEmpty) {
                        _RoutePageData();
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.translate("see_all")!,
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: getColorFromHex("#F5C249"),
                              fontSize: 16)),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                // height: 225,
                height: MediaQuery.of(context).size.height / 4,
                child: topCoinList.length <= 0
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: topCoinList.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  callCurrencyDetails(topCoinList[i].name);
                                },
                                child: Column(
                                    // alignment: Alignment.topLeft,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 20),
                                        decoration: BoxDecoration(
                                            color: getColorFromHex("#282B35"),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.3,

                                        // decoration: BoxDecoration(
                                        //     image: DecorationImage(
                                        //         fit: BoxFit.cover,
                                        //         image: i % 2 == 0
                                        //             ? AssetImage(
                                        //                 'assets/images/portfolio_background.png')
                                        //             : AssetImage(
                                        //                 'assets/images/Card.png')),
                                        //     borderRadius:
                                        //         BorderRadius.circular(
                                        //             25)),
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 3.0),
                                                    child: FadeInImage(
                                                      width: 40,
                                                      fit: BoxFit.contain,
                                                      height: 40,
                                                      placeholder: AssetImage(
                                                          'assets/images/cob.png'),
                                                      image: NetworkImage(
                                                          "$ApiUrl/Bitcoin/resources/icons/${topCoinList[i].name!.toLowerCase()}.png"),
                                                      // image: NetworkImage("http://45.34.15.25:8080/Bitcoin/resources/icons/${topCoinList[i].name.toLowerCase()}.png"),
                                                    ),
                                                  ),
                                                  alignment: Alignment.topLeft,
                                                ),
                                                Container(
                                                  child: Text(
                                                    '${topCoinList[i].name}',
                                                    style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 20,
                                                            color:
                                                                Colors.white)),
                                                    // style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold,color:Colors.white,fontFamily: GoogleFonts.poppins()),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  margin: EdgeInsets.fromLTRB(
                                                      15, 0, 15, 0),
                                                  alignment: Alignment.topLeft,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              child: Text(
                                                '\$ ${topCoinList[i].rate!.toStringAsFixed(2)}',
                                                style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 20,
                                                        color: getColorFromHex(
                                                            "#A7AEBF"))),
                                                maxLines: 1,
                                                textAlign: TextAlign.left,
                                              ),
                                              margin: EdgeInsets.fromLTRB(
                                                  5, 10, 5, 0),
                                              alignment: Alignment.topLeft,
                                            ),
                                            Row(
                                              children: [
                                                double.parse(topCoinList[i]
                                                            .diffRate!) <
                                                        0
                                                    ? Container(
                                                        child: Icon(
                                                          Icons
                                                              .arrow_drop_down_sharp,
                                                          color: Colors.red,
                                                          size: 25,
                                                        ),
                                                      )
                                                    : Container(
                                                        child: Icon(
                                                          Icons
                                                              .arrow_drop_up_sharp,
                                                          color: Colors.green,
                                                          size: 25,
                                                        ),
                                                      ),
                                                Container(
                                                  child: Text(
                                                    double.parse(topCoinList[i]
                                                                .diffRate!) <
                                                            0
                                                        ? "\$ " +
                                                            double.parse(topCoinList[
                                                                        i]
                                                                    .diffRate!
                                                                    .replaceAll(
                                                                        '-',
                                                                        ""))
                                                                .toStringAsFixed(
                                                                    2)
                                                        : "\$ " +
                                                            double.parse(
                                                                    topCoinList[
                                                                            i]
                                                                        .diffRate!)
                                                                .toStringAsFixed(
                                                                    2),
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        textStyle: TextStyle(
                                                            fontSize: 15,
                                                            color: double.parse(
                                                                        topCoinList[i]
                                                                            .diffRate!) <
                                                                    0
                                                                ? Colors
                                                                    .redAccent
                                                                : Colors
                                                                    .greenAccent)),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  margin: EdgeInsets.fromLTRB(
                                                      5, 0, 5, 0),
                                                  alignment: Alignment.topLeft,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            GestureDetector(
                                              onTap: () {
                                                callCurrencyDetails(
                                                    bitcoinList[i].name);
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4,
                                                height: 40,
                                                child: new charts.LineChart(
                                                  _createSampleData(
                                                      gainerLooserCoinList[i]
                                                          .historyRate,
                                                      double.parse(
                                                          gainerLooserCoinList[
                                                                  i]
                                                              .diffRate!)),
                                                  layoutConfig: new charts
                                                          .LayoutConfig(
                                                      leftMarginSpec: new charts
                                                              .MarginSpec.fixedPixel(
                                                          5),
                                                      topMarginSpec: new charts
                                                              .MarginSpec.fixedPixel(
                                                          10),
                                                      rightMarginSpec: new charts
                                                              .MarginSpec.fixedPixel(
                                                          5),
                                                      bottomMarginSpec: new charts
                                                              .MarginSpec.fixedPixel(
                                                          10)),
                                                  defaultRenderer: new charts
                                                      .LineRendererConfig(
                                                    includeArea: true,
                                                    stacked: true,
                                                  ),
                                                  animate: true,
                                                  domainAxis:
                                                      charts.NumericAxisSpec(
                                                          showAxisLine: false,
                                                          renderSpec: charts
                                                              .NoneRenderSpec()),
                                                  primaryMeasureAxis:
                                                      charts.NumericAxisSpec(
                                                          renderSpec: charts
                                                              .NoneRenderSpec()),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
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
        colorFn: (_, __) => diffRate < 0
            ? charts.MaterialPalette.red.shadeDefault
            : charts.MaterialPalette.green.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.count,
        measureFn: (LinearSales sales, _) => sales.rate,
        data: listData,
      ),
    ];
  }

  Future<void> callBitcoinApi() async {
    var uri = '$ApiUrl/Bitcoin/resources/getBitcoinHistoryLists?size=0';
    //  print(uri);
    var response = await get(Uri.parse(uri));
    //   print(response.body);
    final data = json.decode(response.body) as Map;
    //  print(data);
    if (data['error'] == false) {
      setState(() {
        bitcoinList.addAll(data['data']
            .map<Bitcoin>((json) => Bitcoin.fromJson(json))
            .toList());
        isLoading = false;
        _size = _size + data['data'].length;
      });
    } else {
      //  _ackAlert(context);

      setState(() {});
    }
    callTopBitcoinApi();
  }

  Future<void> callTopBitcoinApi() async {
    var uri = '$ApiUrl/Bitcoin/resources/getBitcoinHistoryLists?size=0';
    var response = await get(Uri.parse(uri));
    final data = json.decode(response.body) as Map;
    if (data['error'] == false) {
      setState(() {
        topCoinList.addAll(data['data']
            .map<TopCoinData>((json) => TopCoinData.fromJson(json))
            .toList());
        isLoading = false;
      });
    } else {
      setState(() {});
    }
    callGainerLooserBitcoinApi();
  }

  Future<void> callGainerLooserBitcoinApi() async {
    var uri = '$ApiUrl/Bitcoin/resources/getBitcoinListLoser?size=0';
    //  print(uri);
    var response = await get(Uri.parse(uri));
    //   print(response.body);
    final data = json.decode(response.body) as Map;
    //  print(data);
    if (data['error'] == false) {
      setState(() {
        gainerLooserCoinList.addAll(data['data']
            .map<Bitcoin>((json) => Bitcoin.fromJson(json))
            .toList());
        isLoading = false;
        // _size = _size + data['data'].length;
      });
    } else {
      //  _ackAlert(context);
      setState(() {});
    }
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    text = text.toLowerCase();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    gainerLooserCoinList.forEach((userDetail) {
      if (userDetail.name!.toLowerCase().contains(text))
        _searchResult.add(userDetail);
    });

    setState(() {});
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

  _RoutePageData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setInt("index", 4);
      sharedPreferences!.setString(
          "title", AppLocalizations.of(context)!.translate('coins') ?? '');
      sharedPreferences!.commit();
    });

    Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
  }
}

class LinearSales {
  final int count;
  final double rate;

  LinearSales(this.count, this.rate);
}
