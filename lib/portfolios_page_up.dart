import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coins_page_up.dart';
import 'core/utils/size_utils.dart';
import 'dashboard_helper.dart';
import 'localization/app_localizations.dart';
import 'models/Bitcoin.dart';
import 'models/PortfolioBitcoin.dart';
import 'util/color_util.dart';

class PortfolioPage extends StatefulWidget {
  Function() noCoinTap;
  PortfolioPage({Key? key, required this.noCoinTap}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  List<Bitcoin> bitcoinList = [];
  SharedPreferences? sharedPreferences;
  num _size = 0;
  TabController? _tabController;
  double totalValuesOfPortfolio = 0.0;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  String? ApiUrl = 'http://45.34.15.25:8080';

  TextEditingController? coinCountTextEditingController;
  TextEditingController? coinCountEditTextEditingController;
  final dbHelper = DatabaseHelper.instance;
  List<PortfolioBitcoin> items = [];

  @override
  void initState() {
    // fetchRemoteValue();
    callBitcoinApi();
    _tabController = new TabController(length: 2, vsync: this);
    coinCountTextEditingController = new TextEditingController();
    coinCountEditTextEditingController = new TextEditingController();
    dbHelper.queryAllRows().then((notes) {
      notes.forEach((note) {
        items.add(PortfolioBitcoin.fromMap(note));
        totalValuesOfPortfolio = totalValuesOfPortfolio + note["total_value"];
      });
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // fetchRemoteValue() async {
  //   final RemoteConfig remoteConfig = await RemoteConfig.instance;

  //   try {
  //     // Using default duration to force fetching from remote server.
  //     await remoteConfig.setConfigSettings(RemoteConfigSettings(
  //       fetchTimeout: const Duration(seconds: 10),
  //       minimumFetchInterval: Duration.zero,
  //     ));
  //     await remoteConfig.fetchAndActivate();
  //     ApiUrl = remoteConfig.getString('bitcoin_code_tomcat_url').trim();
  //     print(ApiUrl);
  //     setState(() {});
  //   } catch (exception) {
  //     print('Unable to fetch remote config. Cached or default values will be '
  //         'used');
  //   }
  //   callBitcoinApi();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
            // alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.translate('add_coins') ?? '',
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white)),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                AppLocalizations.of(context)!.translate('ASSETS') ?? '',
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: getColorFromHex("#787A8D"))),
                textAlign: TextAlign.left,
              ),
              Text(
                AppLocalizations.of(context)!.translate('PRICE') ?? '',
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: getColorFromHex("#787A8D"))),
                textAlign: TextAlign.center,
              ),
              Text(
                AppLocalizations.of(context)!.translate('Coins') ?? '',
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: getColorFromHex("#787A8D"))),
                textAlign: TextAlign.end,
              ),
            ],
          ),
          Divider(
            color: getColorFromHex("#21242D"),
            thickness: 1,
          ),
          SizedBox(
            height: 10,
          ),
          items != null &&
                  items.length > 0 &&
                  bitcoinList != null &&
                  bitcoinList.length > 0
              ? Expanded(
                  child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int i) {
                        var graphList = bitcoinList
                            .where((element) => element.name == items[i].name)
                            .toList();
                        return Slidable(
                          key: const ValueKey(0),
                          closeOnScroll: false,
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: ScrollMotion(),
                            children: [
                              InkWell(
                                onTap: () {
                                  _showdeleteCoinFromPortfolioDialog(items[i]);
                                },
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                  alignment: Alignment.center,
                                  height: 60,
                                  width: 60,
                                  child: Image.asset(
                                      "assets/images/delete_crypto.png"),
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
                                    height: 60,
                                    padding: EdgeInsets.all(8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                            height: 50,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: FadeInImage(
                                                placeholder: AssetImage(
                                                    'assets/images/cob.png'),
                                                image: NetworkImage(
                                                    "$ApiUrl/Bitcoin/resources/icons/${items[i].name.toLowerCase()}.png"),
                                              ),
                                            )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${items[i].name}',
                                          style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  color: Colors.white)),
                                          textAlign: TextAlign.left,
                                        ),
                                        Spacer(),
                                        Text(
                                          '\$${items[i].totalValue.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          )),
                                        ),
                                        Spacer(),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Text(
                                            '${items[i].numberOfCoins}',
                                            style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 15,
                                                    color: getColorFromHex(
                                                        "#808D90"))),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: getColorFromHex("#21242D"),
                                  thickness: 1,
                                  indent: 60,
                                  endIndent: 20,
                                ),
                              ],
                            ),
                            onTap: () {
                              showPortfolioEditDialog(items[i]);
                            },
                          ),
                        );
                      }),
                )
              : Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .translate('no_coins_added')!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )),
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
    var response = await get(Uri.parse(uri));
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
  }

  Future<void> showPortfolioEditDialog(PortfolioBitcoin bitcoin) async {
    coinCountEditTextEditingController!.text =
        bitcoin.numberOfCoins.toInt().toString();
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
                    AppLocalizations.of(context)!.translate('update_coins')!,
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
                  leadingWidth: 35,
                  actions: <Widget>[],
                ),
                body: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                        height: 64,
                        margin: EdgeInsets.only(top: getVerticalSize(50)),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: FadeInImage(
                            placeholder: AssetImage('assets/images/cob.png'),
                            image: NetworkImage(
                                "$ApiUrl/Bitcoin/resources/icons/${bitcoin.name.toLowerCase()}.png"),
                          ),
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      bitcoin.name,
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.translate("newhome8")!,
                          // overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: getFontSize(
                              16,
                            ),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '\$ ${bitcoin.totalValue.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal,
                                  color: getColorFromHex("#F5C249"))),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: getColorFromHex("#21242D"),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.fromLTRB(10, 50, 10, 10),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: TextFormField(
                        key: _formKey,
                        controller: coinCountEditTextEditingController,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
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
                          if (coinCountEditTextEditingController!.value.text ==
                                  null ||
                              coinCountEditTextEditingController!.value.text ==
                                  "" ||
                              int.parse(coinCountEditTextEditingController!
                                      .value.text) <=
                                  0) {
                            return "at least 1 coin should be added";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _updateSaveCoinsToLocalStorage(bitcoin);
                      },
                      child: Container(
                          padding: EdgeInsets.fromLTRB(100, 15, 100, 15),
                          margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                          decoration: BoxDecoration(
                            color: getColorFromHex("#F5C249"),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!
                                .translate('update_coins')!,
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

  getCurrentRateDiff(PortfolioBitcoin items, List<Bitcoin> bitcoinList) {
    Bitcoin j = bitcoinList.firstWhere((element) => element.name == items.name);

    double newRateDiff = j.rate! - items.rateDuringAdding;
    return newRateDiff;
  }

  _updateSaveCoinsToLocalStorage(PortfolioBitcoin bitcoin) async {
    if (coinCountEditTextEditingController!.text.isNotEmpty &&
        coinCountEditTextEditingController!.text != 0) {
      int adf = int.parse(coinCountEditTextEditingController!.text);
      print(adf);
      Map<String, dynamic> row = {
        DatabaseHelper.columnName: bitcoin.name,
        DatabaseHelper.columnRateDuringAdding: bitcoin.rateDuringAdding,
        DatabaseHelper.columnCoinsQuantity:
            double.parse(coinCountEditTextEditingController!.value.text),
        DatabaseHelper.columnTotalValue: (adf) * (bitcoin.rateDuringAdding),
      };
      final id = await dbHelper.update(row);
      print('inserted row id: $id');
      sharedPreferences = await SharedPreferences.getInstance();
      setState(() {
        sharedPreferences!.setString("currencyName", bitcoin.name);
        sharedPreferences!.setInt("index", 3);
        sharedPreferences!.setString("title",
            AppLocalizations.of(context)!.translate('portfolio') ?? '');
        sharedPreferences!.commit();
      });
      Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
    }
  }

  void _showdeleteCoinFromPortfolioDialog(PortfolioBitcoin item) {
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
                    AppLocalizations.of(context)!.translate('remove_coins')!,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        AppLocalizations.of(context)!.translate('do_you')!,
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: getColorFromHex("#21242D"),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                                      "$ApiUrl/Bitcoin/resources/icons/${item.name.toLowerCase()}.png"),
                                ),
                              )),
                          SizedBox(width: 10),
                          Text(
                            item.name,
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _deleteCoinsToLocalStorage(item);
                      },
                      child: Container(
                          padding: EdgeInsets.fromLTRB(100, 15, 100, 15),
                          margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                          decoration: BoxDecoration(
                            color: getColorFromHex("#F5C249"),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!
                                .translate('remove_coins')!,
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

  _deleteCoinsToLocalStorage(PortfolioBitcoin item) async {
    final id = await dbHelper.delete(item.name);
    print('inserted row id: $id');
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setInt("index", 3);
      sharedPreferences!.setString(
          "title", AppLocalizations.of(context)!.translate('coins') ?? '');
      sharedPreferences!.commit();
    });
    Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
  }
}
