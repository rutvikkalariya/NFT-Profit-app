// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'core/utils/size_utils.dart';
import 'dashboard_helper.dart';
import 'localization/app_localizations.dart';
import 'models/Bitcoin.dart';
import 'models/PortfolioBitcoin.dart';

import 'package:collection/collection.dart';

import 'util/color_util.dart'; // You have to add this manually, for some reason it cannot be added automatically

class TrendPage extends StatefulWidget {
  const TrendPage({Key? key}) : super(key: key);

  @override
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  int buttonType = 3;

  String name = "";
  double coin = 0;
  String result = '';
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();
  String? currencyNameForImage;
  String _type = "Week";
  List<LinearSales> currencyData = [];
  List<Bitcoin> bitcoinList = [];
  double diffRate = 0;
  String? ApiUrl = 'http://45.34.15.25:8080';
  List<PortfolioBitcoin> items = [];

  final dbHelper = DatabaseHelper.instance;

  SharedPreferences? sharedPreferences;
  @override
  void initState() {
    // fetchRemoteValue();
    callBitcoinApi();
    super.initState();
    coinCountTextEditingController = TextEditingController();
    dbHelper.queryAllRows().then((notes) {
      notes.forEach((note) {
        items.add(PortfolioBitcoin.fromMap(note));
        // totalValuesOfPortfolio = totalValuesOfPortfolio + note["total_value"];
      });
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var analytics = FirebaseAnalytics.instance;
      analytics.logEvent(name: 'open_trends');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      // color: getColorFromHex("#21242D"),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                    padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        height: 40,
                                        width: 40,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: FadeInImage(
                                            placeholder: AssetImage(
                                                'assets/images/cob.png'),
                                            image: NetworkImage(
                                                "$ApiUrl/Bitcoin/resources/icons/${currencyNameForImage.toString().toLowerCase()}.png"),
                                          ),
                                        )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${coin} \$",
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                decoration: BoxDecoration(
                                  color: getColorFromHex("#282B35"),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Text(diffRate < 0 ? '-' : "+",
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 14,
                                                color: diffRate < 0
                                                    ? Colors.white
                                                    : Colors.white))),
                                    Icon(Icons.attach_money,
                                        size: 16,
                                        color: diffRate < 0
                                            ? Colors.white
                                            : Colors.white),
                                    Text('$result',
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 14,
                                                color: diffRate < 0
                                                    ? Colors.white
                                                    : Colors.white))),
                                    Icon(
                                      Icons.keyboard_arrow_up,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ButtonTheme(
                        minWidth: 50.0,
                        height: 40.0,
                        child: new ElevatedButton(
                          child: new Text(
                            "7D",
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal)),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            backgroundColor: buttonType == 3
                                ? getTopcoinContainerColor()
                                : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              buttonType = 3;
                              _type = "Week";
                              callBitcoinApi();
                            });
                          },
                        ),
                      ),
                      ButtonTheme(
                        minWidth: 50.0,
                        height: 40.0,
                        child: new ElevatedButton(
                          child: new Text(
                            '1M',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            backgroundColor: buttonType == 4
                                ? getTopcoinContainerColor()
                                : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              buttonType = 4;
                              _type = "Month";
                              callBitcoinApi();
                            });
                          },
                        ),
                      ),
                      ButtonTheme(
                        minWidth: 50.0,
                        height: 40.0,
                        child: new ElevatedButton(
                          child: new Text(
                            '1Y',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            backgroundColor: buttonType == 5
                                ? getTopcoinContainerColor()
                                : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              buttonType = 5;
                              _type = "Year";
                              callBitcoinApi();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(bottom: 10, top: 0),
                child: ListView(
                  children: <Widget>[
                    Container(
                        child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: getTopcoinContainerColor(),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    height: MediaQuery.of(context).size.height /
                                        2.7,
                                    child: SfCartesianChart(
                                      plotAreaBorderWidth: 0,
                                      enableAxisAnimation: true,
                                      enableSideBySideSeriesPlacement: true,
                                      series: <ChartSeries>[
                                        LineSeries<LinearSales, double>(
                                          dataSource: currencyData,
                                          xValueMapper: (LinearSales data, _) =>
                                              data.date,
                                          yValueMapper: (LinearSales data, _) =>
                                              data.rate,
                                          color: Colors.white,
                                          dataLabelSettings: DataLabelSettings(
                                              isVisible: true,
                                              borderColor: Colors.white,
                                              color: Colors.white),
                                          markerSettings:
                                              MarkerSettings(isVisible: true),
                                        )
                                      ],
                                      primaryXAxis: NumericAxis(
                                        isVisible: false,
                                      ),
                                      primaryYAxis: NumericAxis(
                                        isVisible: false,
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            if (bitcoinList.isNotEmpty) {
                              showPortfolioDialog(bitcoinList[0]);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(35, 8, 35, 8),
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            decoration: BoxDecoration(
                              color: getColorFromHex("#F5C249"),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                                AppLocalizations.of(context)!
                                    .translate('add_coins')!,
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 18, color: Colors.black))),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> callBitcoinApi() async {
    final SharedPreferences prefs = await _sprefs;
    var currencyName = prefs.getString("currencyName") ?? 'BTC';
    setState(() {
      currencyNameForImage = currencyName;
    });
    var uri =
        '$ApiUrl/Bitcoin/resources/getBitcoinGraph?type=$_type&name=$currencyName';
    print(uri);
    var response = await get(Uri.parse(uri));
    //  print(response.body);
    final data = json.decode(response.body) as Map;
    //print(data);
    if (data['error'] == false) {
      setState(() {
        bitcoinList = data['data']
            .map<Bitcoin>((json) => Bitcoin.fromJson(json))
            .toList();
        double count = 0;
        diffRate = double.parse(data['diffRate']);
        if (diffRate < 0)
          result = data['diffRate'].replaceAll("-", "");
        else
          result = data['diffRate'];
        currencyData = [];
        bitcoinList.forEach((element) {
          currencyData.add(new LinearSales(count, element.rate!));
          name = element.name!;
          String step2 = element.rate!.toStringAsFixed(2);
          double step3 = double.parse(step2);
          coin = step3;
          count = count + 1;
        });

        var list = bitcoinList.where(
            (element) => element.name.toString() == currencyName.toString());
      });
    } else {
      //  _ackAlert(context);
    }
  }

  TextEditingController? coinCountTextEditingController;
  final _formKey2 = GlobalKey<FormState>();

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
                  // mainAxisSize: MainAxisSize.max,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Container(
                        margin: EdgeInsets.only(top: getVerticalSize(50)),
                        height: 64,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: FadeInImage(
                            placeholder: AssetImage('assets/images/cob.png'),
                            image: NetworkImage(
                                "$ApiUrl/Bitcoin/resources/icons/${bitcoin.name!.toLowerCase()}.png"),
                          ),
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      bitcoin.name ?? '',
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
                          width: 5,
                        ),
                        Text(
                          '\$ ${bitcoin.rate!.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal,
                                  color: getColorFromHex("#F5C249"))),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
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
                    InkWell(
                      onTap: () {
                        _addSaveCoinsToLocalStorage(bitcoin);
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
        sharedPreferences!.setInt("index", 3);
        sharedPreferences!.setString("title",
            AppLocalizations.of(context)!.translate('portfolio').toString());
        sharedPreferences!.commit();
      });
      Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
    } else {}
  }
}

class LinearSales {
  final double date;
  final double rate;

  LinearSales(this.date, this.rate);
}
