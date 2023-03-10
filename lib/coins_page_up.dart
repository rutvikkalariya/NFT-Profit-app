// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:collection/collection.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_helper.dart';
import 'localization/app_localizations.dart';
import 'models/Bitcoin.dart';
import 'models/PortfolioBitcoin.dart';
import 'util/color_util.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({Key? key}) : super(key: key);

  @override
  _CoinsPageState createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  List<Bitcoin> bitcoinList = [];
  List<Bitcoin> myDataList = [];
  List<Bitcoin> _searchResult = [];
  SharedPreferences? sharedPreferences;
  num _size = 0;
  double totalValuesOfPortfolio = 0.0;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  String? ApiUrl = 'http://45.34.15.25:8080';

  TextEditingController? coinCountTextEditingController;
  TextEditingController? coinCountEditTextEditingController;
  final dbHelper = DatabaseHelper.instance;
  List<PortfolioBitcoin> items = [];
  TextEditingController _searchController = new TextEditingController();

  List<String> categoryList = [];
  late TabController _tabController;
  @override
  void initState() {
    // callBitcoinApi();
    // fetchRemoteValue();
    callBitcoinApi();
    getData();
    coinCountTextEditingController = new TextEditingController();
    coinCountEditTextEditingController = new TextEditingController();
    dbHelper.queryAllRows().then((notes) {
      notes.forEach((note) {
        items.add(PortfolioBitcoin.fromMap(note));
        totalValuesOfPortfolio = totalValuesOfPortfolio + note["total_value"];
      });
      setState(() {});
    });
    _tabController = TabController(length: 3, vsync: this);
    categoryList.add("All Coins");
    categoryList.add("Top Gainers");
    categoryList.add("Top Losers");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

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

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Container(
            height: 40,
            margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(
                8.0,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              // give the indicator a decoration (color and border radius)
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  8.0,
                ),
                color: selectedIndex == 0
                    ? getColorFromHex("#282B35")
                    : Colors.transparent,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              tabs: [
                // first tab [you can add an icon using the icon property]
                Tab(
                  child: Text(
                    "All Coins",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: getColorFromHex("#F5C249"),
                        fontSize: 16),
                  ),
                ),
                // second tab [you can add an icon using the icon property]
                Tab(
                  child: Text(
                    "Top Gainers",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: getColorFromHex("#F5C249"),
                        fontSize: 16),
                  ),
                ),
                Tab(
                  child: Text(
                    "Top Losers",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: getColorFromHex("#F5C249"),
                        fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // first tab bar view widget
                Container(
                  padding: EdgeInsets.all(10),
                  child: LazyLoadScrollView(
                    scrollDirection: Axis.horizontal,
                    isLoading: isLoading,
                    onEndOfPage: () => callBitcoinApi(),
                    child: bitcoinList.length <= 0
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: bitcoinList.length,
                            itemBuilder: (BuildContext context, int i) {
                              return Slidable(
                                key: const ValueKey(0),
                                closeOnScroll: false,
                                endActionPane: ActionPane(
                                  extentRatio: 0.2,
                                  motion: ScrollMotion(),
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showPortfolioDialog(bitcoinList[i]);
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.fromLTRB(0, 0, 0, 10),
                                        alignment: Alignment.center,
                                        height: 40,
                                        width: 40,
                                        child: Image.asset(
                                            "assets/images/add_crypto.png"),
                                      ),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, right: 5.0),
                                        child: Container(
                                          // color: getPrimaryColor(),
                                          height: 60,
                                          padding: EdgeInsets.all(5),
                                          child: new Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                      height: 50,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: FadeInImage(
                                                          placeholder: AssetImage(
                                                              'assets/images/cob.png'),
                                                          image: NetworkImage(
                                                              "$ApiUrl/Bitcoin/resources/icons/${bitcoinList[i].name!.toLowerCase()}.png"),
                                                          // image: NetworkImage("http://45.34.15.25:8080/Bitcoin/resources/icons/${gainerLooserCoinList[i].name.toLowerCase()}.png"),
                                                        ),
                                                      )),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                0, 7, 0, 0),
                                                        child: Text(
                                                          '${bitcoinList[i].name}',
                                                          style: GoogleFonts.poppins(
                                                              textStyle: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white)),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
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
                                                  height: 30,
                                                  child: new charts.LineChart(
                                                    _createSampleData(
                                                        bitcoinList[i]
                                                            .historyRate,
                                                        double.parse(
                                                            bitcoinList[i]
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
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  Text(
                                                    '\$${double.parse(bitcoinList[i].rate!.toStringAsFixed(2))}',
                                                    style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    )),
                                                  ),
                                                  Row(
                                                    children: [
                                                      double.parse(bitcoinList[
                                                                      i]
                                                                  .diffRate!) <
                                                              0
                                                          ? Container(
                                                              // color: Colors.red,
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_downward,
                                                                color: getColorFromHex(
                                                                    "#FF7C74"),
                                                                size: 15,
                                                              ),
                                                            )
                                                          : Container(
                                                              // color: Colors.green,
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_upward_sharp,
                                                                color: getColorFromHex(
                                                                    "#11CABE"),
                                                                size: 15,
                                                              ),
                                                            ),
                                                      SizedBox(width: 2),
                                                      Text(
                                                          double.parse(bitcoinList[i].diffRate!) < 0
                                                              ? double.parse(bitcoinList[i]
                                                                      .diffRate!
                                                                      .replaceAll(
                                                                          '-', ""))
                                                                  .toStringAsFixed(
                                                                      2)
                                                              : double.parse(bitcoinList[i].diffRate!)
                                                                  .toStringAsFixed(
                                                                      2),
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: double.parse(bitcoinList[i].diffRate!) < 0
                                                                  ? getColorFromHex(
                                                                      "#FF7C74")
                                                                  : getColorFromHex("#11CABE"))),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                        // thickness: 1,
                                        endIndent: 10,
                                        indent: 70,
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // showPortfolioDialog(bitcoinList[i]);

                                    callCurrencyDetails(bitcoinList[i].name);
                                  },
                                ),
                              );
                            }),
                  ),
                ),

                topGainer(),
                topLooser(),
              ],
            ),
          ),
        ],
      ),
    );
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

  Future<void> callBitcoinApi() async {
    var uri = '$ApiUrl/Bitcoin/resources/getBitcoinList?size=${_size}';
    // var uri = 'http://45.34.15.25:8080/Bitcoin/resources/getBitcoinList?size=${_size}';
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
      setState(() {});
    }
  }

  Future<void> showPortfolioDialog(Bitcoin bitcoin) async {
    coinCountTextEditingController!.text = "";
    showCupertinoModalPopup(
        context: context,
        builder: (ctxt) => Container(
              height: MediaQuery.of(context).size.height,
              child: Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.black,
                  centerTitle: true,
                  title: Text(
                    AppLocalizations.of(context)!.translate('add_coins')!,
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18)),
                    textAlign: TextAlign.start,
                  ),
                  leading: InkWell(
                    child: Container(
                      child: Image.asset(
                        "assets/images/back.png",
                        height: 25,
                        width: 25,
                      ),
                      margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  leadingWidth: 40,
                  actions: <Widget>[],
                ),
                body: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: getColorFromHex("#21242D"),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
                      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                      child: Row(
                        children: [
                          Container(
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: FadeInImage(
                                  placeholder:
                                      AssetImage('assets/images/cob.png'),
                                  image: NetworkImage(
                                      "$ApiUrl/Bitcoin/resources/icons/${bitcoin.name!.toLowerCase()}.png"),
                                  // "http://45.34.15.25:8080/Bitcoin/resources/icons/${bitcoin.name.toLowerCase()}.png"),
                                ),
                              )),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            bitcoin.name ?? '',
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white)),
                          ),
                          Container(
                            child: Icon(
                              Icons.arrow_drop_down_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          Spacer(),
                          Text(
                            bitcoin.rate!.toStringAsFixed(2),
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white)),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: getColorFromHex("#21242D"),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.fromLTRB(20, 50, 20, 10),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Form(
                        key: _formKey2,
                        child: TextFormField(
                          controller: coinCountTextEditingController,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.start,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            hintStyle: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: getColorFromHex("#C3C3C3"),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14)),
                            hintText: 'Enter Number of Coins',
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ], // O
                          //only numbers can be entered
                          validator: (val) {
                            if (coinCountTextEditingController!.text == "" ||
                                int.parse(coinCountTextEditingController!
                                        .value.text) <=
                                    0) {
                              return "At least 1 coin should be added";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        _addSaveCoinsToLocalStorage(bitcoin);
                        // _updateSaveCoinsToLocalStorage(bitcoin);
                      },
                      child: Container(
                          padding: EdgeInsets.fromLTRB(100, 15, 100, 15),
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          decoration: BoxDecoration(
                            color: getColorFromHex("#F5C249"),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!
                                .translate('add_coins')!,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18)),
                            textAlign: TextAlign.start,
                          )),
                    ),
                  ],
                ),
              ),
            ));
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

  Future<void> callCurrencyDetails(name) async {
    _saveProfileData(name);
  }

  _addSaveCoinsToLocalStorage(Bitcoin bitcoin) async {
    if (_formKey2.currentState!.validate()) {
      if (items != null && items.length > 0) {
        PortfolioBitcoin? bitcoinLocal =
            items.firstWhereOrNull((element) => element.name == bitcoin.name);

        if (bitcoinLocal != null) {
          Map<String, dynamic> row = {
            DatabaseHelper.columnName: bitcoin.name,
            DatabaseHelper.columnRateDuringAdding: bitcoin.rate,
            DatabaseHelper.columnCoinsQuantity:
                double.parse(coinCountTextEditingController!.value.text) +
                    bitcoinLocal.numberOfCoins,
            DatabaseHelper.columnTotalValue:
                double.parse(coinCountTextEditingController!.value.text) *
                        (bitcoin.rate!) +
                    bitcoinLocal.totalValue,
          };
          final id = await dbHelper.update(row);
          print('inserted row id: $id');
        } else {
          Map<String, dynamic> row = {
            DatabaseHelper.columnName: bitcoin.name,
            DatabaseHelper.columnRateDuringAdding: bitcoin.rate,
            DatabaseHelper.columnCoinsQuantity:
                double.parse(coinCountTextEditingController!.value.text),
            DatabaseHelper.columnTotalValue:
                double.parse(coinCountTextEditingController!.value.text) *
                    (bitcoin.rate!),
          };
          final id = await dbHelper.insert(row);
          print('inserted row id: $id');
        }
      } else {
        Map<String, dynamic> row = {
          DatabaseHelper.columnName: bitcoin.name,
          DatabaseHelper.columnRateDuringAdding: bitcoin.rate,
          DatabaseHelper.columnCoinsQuantity:
              double.parse(coinCountTextEditingController!.text),
          DatabaseHelper.columnTotalValue:
              double.parse(coinCountTextEditingController!.value.text) *
                  (bitcoin.rate!),
        };
        final id = await dbHelper.insert(row);
        print('inserted row id: $id');
      }

      sharedPreferences = await SharedPreferences.getInstance();
      setState(() {
        sharedPreferences!.setString("currencyName", bitcoin.name ?? '');
        sharedPreferences!.setInt("index", 1);
        sharedPreferences!.setString("title",
            AppLocalizations.of(context)!.translate('trends').toString());
        sharedPreferences!.commit();
      });
      Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
    } else {}
  }

  getCurrentRateDiff(PortfolioBitcoin items, List<Bitcoin> bitcoinList) {
    Bitcoin j = bitcoinList.firstWhere((element) => element.name == items.name);

    double newRateDiff = j.rate! - items.rateDuringAdding;
    return newRateDiff;
  }

  Widget topGainer() {
    var list = myDataList
        .where((element) => double.parse(element.diffRate!) >= 0)
        .toList();
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int i) {
            return InkWell(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Container(
                      // color: getPrimaryColor(),
                      height: 60,
                      padding: EdgeInsets.all(5),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: FadeInImage(
                                      placeholder:
                                          AssetImage('assets/images/cob.png'),
                                      image: NetworkImage(
                                          "$ApiUrl/Bitcoin/resources/icons/${myDataList[i].name!.toLowerCase()}.png"),
                                      // image: NetworkImage("http://45.34.15.25:8080/Bitcoin/resources/icons/${gainerLooserCoinList[i].name.toLowerCase()}.png"),
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
                                      '${myDataList[i].name}',
                                      style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
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
                              callCurrencyDetails(myDataList[i].name);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 4,
                              height: 40,
                              child: new charts.LineChart(
                                _createSampleData(myDataList[i].historyRate,
                                    double.parse(myDataList[i].diffRate!)),
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
                                        '\$${double.parse(myDataList[i].rate!.toStringAsFixed(2))}',
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        )),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      double.parse(myDataList[i].diffRate!) < 0
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
                                      Text(
                                          double.parse(myDataList[i].diffRate!) <
                                                  0
                                              ? double.parse(myDataList[i]
                                                      .diffRate!
                                                      .replaceAll('-', ""))
                                                  .toStringAsFixed(2)
                                              : double.parse(
                                                      myDataList[i].diffRate!)
                                                  .toStringAsFixed(2),
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: double.parse(myDataList[i]
                                                          .diffRate!) <
                                                      0
                                                  ? getColorFromHex("#FF7C74")
                                                  : getColorFromHex("#11CABE"))),
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
                  
                  Divider(
                    color: Colors.grey,
                    // thickness: 1,
                    endIndent: 10,
                    indent: 70,
                  ),
                ],
              ),
              onTap: () {
                callCurrencyDetails(myDataList[i].name);
              },
            );
          }),
    );
  }

  Widget topLooser() {
    var list = myDataList
        .where((element) => double.parse(element.diffRate!) < 0)
        .toList();
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int i) {
            return InkWell(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Container(
                      // color: getPrimaryColor(),
                      height: 60,
                      padding: EdgeInsets.all(5),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: FadeInImage(
                                      placeholder:
                                          AssetImage('assets/images/cob.png'),
                                      image: NetworkImage(
                                          "$ApiUrl/Bitcoin/resources/icons/${myDataList[i].name!.toLowerCase()}.png"),
                                      // image: NetworkImage("http://45.34.15.25:8080/Bitcoin/resources/icons/${gainerLooserCoinList[i].name.toLowerCase()}.png"),
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
                                      '${myDataList[i].name}',
                                      style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
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
                              callCurrencyDetails(myDataList[i].name);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 4,
                              height: 40,
                              child: new charts.LineChart(
                                _createSampleData(myDataList[i].historyRate,
                                    double.parse(myDataList[i].diffRate!)),
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
                                        '\$${double.parse(myDataList[i].rate!.toStringAsFixed(2))}',
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        )),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      double.parse(myDataList[i].diffRate!) < 0
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
                                      Text(
                                          double.parse(myDataList[i].diffRate!) <
                                                  0
                                              ? double.parse(myDataList[i]
                                                      .diffRate!
                                                      .replaceAll('-', ""))
                                                  .toStringAsFixed(2)
                                              : double.parse(
                                                      myDataList[i].diffRate!)
                                                  .toStringAsFixed(2),
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: double.parse(myDataList[i]
                                                          .diffRate!) <
                                                      0
                                                  ? getColorFromHex("#FF7C74")
                                                  : getColorFromHex("#11CABE"))),
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
                  Divider(
                    color: Colors.grey,
                    // thickness: 1,
                    endIndent: 10,
                    indent: 70,
                  ),
                ],
              ),
              onTap: () {
                callCurrencyDetails(myDataList[i].name);
              },
            );
          }),
    );
  }
}

class LinearSales {
  final int count;
  final double rate;

  LinearSales(this.count, this.rate);
}
