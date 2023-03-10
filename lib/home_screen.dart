// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nftprofitapp/util/color_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'core/utils/size_utils.dart';
import 'localization/app_localizations.dart';
import 'models/Bitcoin.dart';

class HomePageReal extends StatefulWidget {
  const HomePageReal({Key? key}) : super(key: key);

  @override
  _HomePageRealState createState() => _HomePageRealState();
}

class _HomePageRealState extends State<HomePageReal> {
  final Completer<WebViewController> _controllerForm =
      Completer<WebViewController>();
  ScrollController? _controllerList;
  bool isLoading = false;
  List<Bitcoin> bitcoinList = [];
  SharedPreferences? sharedPreferences;
  String? iFrameUrl;
  bool? disableIframe;
  late WebViewController controller;
  String? ApiUrl = 'http://45.34.15.25:8080';
  int _current = 0;
  num _size = 0;
  final CarouselController _controller = CarouselController();
  @override
  void initState() {
    _controllerList = ScrollController();
    callBitcoinApi();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80),
            Align(
              child: Padding(
                padding: getPadding(all: 20),
                child: Text(
                  AppLocalizations.of(context)!.translate("newhome1")!,
                  // overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getFontSize(55),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Stack(children: [
              Image.asset("assets/images/home11.png"),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: getVerticalSize(25)),
                height: getVerticalSize(
                  470.00,
                ),
                // width: getHorizontalSize(double.infinity),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/home12.png"),
                    // fit: BoxFit.fill,
                  ),
                  // color: ColorConstant.deepPurpleA70065.withOpacity(0.2),
                ),
              ),
              Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: getVerticalSize(425)),
                  child: Image.asset("assets/images/home13.png")),
            ]),
            Padding(
              padding: EdgeInsets.only(
                  left: getHorizontalSize(20),
                  top: getVerticalSize(50),
                  right: getHorizontalSize(20),
                  bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    child: Text(
                      AppLocalizations.of(context)!.translate("newhome2")!,
                      // overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getFontSize(37),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _RoutePageData();
                    },
                    child: Align(
                      child: Text(
                        AppLocalizations.of(context)!.translate("newhome3")!,
                        // overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: getColorFromHex("#F5C249"),
                          fontSize: getFontSize(
                            20,
                          ),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
              thickness: 1,
            ),
            Container(
              height: 300,
              child: CarouselSlider.builder(
                itemCount: 3,
                options: CarouselOptions(
                  autoPlay: true,
                  initialPage: 0,
                  scrollDirection: Axis.horizontal,
                ),
                itemBuilder: (BuildContext context, int index, i) {
                  return bitcoinList.length <= 0
                      ? Center(child: CircularProgressIndicator())
                      : Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height / 2,
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.only(
                                left: 20, top: 10, right: 20),
                            decoration: BoxDecoration(
                                color: getColorFromHex("#F5C249")),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    height: 150,
                                    child: FadeInImage(
                                      placeholder:
                                          AssetImage('assets/images/cob.png'),
                                      image: NetworkImage(
                                          "$ApiUrl/Bitcoin/resources/icons/${bitcoinList[index].name!.toLowerCase()}.png"),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      bitcoinList[index].name!,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "\$",
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white),
                                        ),
                                        // const SizedBox(width: 5),
                                        Text(
                                          '${double.parse(bitcoinList[index].rate!.toStringAsFixed(2))}',
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                },
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: bitcoinList.asMap().entries.map((entry) {
            //     return GestureDetector(
            //       onTap: () => _controller.animateToPage(entry.key),
            //       child: Container(
            //         width: 12.0,
            //         height: 12.0,
            //         margin:
            //             EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            //         decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: (Theme.of(context).brightness == Brightness.dark
            //                     ? Colors.amber
            //                     : Colors.amber)
            //                 .withOpacity(_current == entry.key ? 0.9 : 0.4)),
            //       ),
            //     );
            //   }).toList(),
            // ),
            // Container(
            //   width: double.infinity,
            //   margin: EdgeInsets.only(top: getVerticalSize(23)),
            //   height: getVerticalSize(
            //     470.00,
            //   ),
            //   // width: getHorizontalSize(double.infinity),
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: AssetImage("assets/images/home14.png"),
            //       // fit: BoxFit.fill,
            //     ),
            //     // color: ColorConstant.deepPurpleA70065.withOpacity(0.2),
            //   ),
            // ),
            // SizedBox(height: 30),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Image.asset("assets/images/home15.png"),
            //     SizedBox(width: 12),
            //     Image.asset("assets/images/home15.png"),
            //     SizedBox(width: 12),
            //     Image.asset("assets/images/home15.png"),
            //   ],
            // ),
            SizedBox(height: 60),
            Stack(children: [
              Container(
                  // margin: EdgeInsets.only(top: 370),
                  child: Image.asset("assets/images/home16.png")),
              Container(
                  margin: EdgeInsets.only(
                      top: getVerticalSize(210), left: getHorizontalSize(200)),
                  child: Image.asset("assets/images/home17.png")),
            ]),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Stack(
                  // alignment: Alignment.centerLeft,
                  children: [
                    Align(
                      child: Padding(
                        padding: getPadding(left: 20, right: 20, top: 60),
                        child: Text(
                          AppLocalizations.of(context)!.translate("newhome4")!,
                          // overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: getFontSize(
                              42,
                            ),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                            top: getVerticalSize(235),
                            left: getHorizontalSize(20),
                            right: getHorizontalSize(20)),
                        child: Text(
                          AppLocalizations.of(context)!.translate("newhome5")!,
                          // overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: getFontSize(
                              20,
                            ),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: getVerticalSize(200)),
                      child: Image.asset("assets/images/home18.png"),
                    ),
                    Container(
                      // alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.only(left: getHorizontalSize(65)),
                      margin: EdgeInsets.only(top: getVerticalSize(920)),
                      child: Image.asset("assets/images/home20.png"),
                    ),
                    Container(
                      // alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.only(left: getHorizontalSize(90)),
                      margin: EdgeInsets.only(
                        top: getVerticalSize(600),
                      ),
                      child: Image.asset("assets/images/home19.png"),
                    ),
                  ],
                ),
                Center(child: Image.asset("assets/images/home21.png")),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: getVerticalSize(150),
                      ),
                      child: Center(
                        child: Image.asset("assets/images/home122.png"),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: getVerticalSize(400),
                      ),
                      child: Center(
                        child: Image.asset("assets/images/home123.png"),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: getVerticalSize(300),
                      ),
                      child: Image.asset("assets/images/home124.png"),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: getVerticalSize(700),
                        left: getHorizontalSize(20),
                      ),
                      child: Image.asset("assets/images/home125.png"),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: getVerticalSize(780),
                        left: getHorizontalSize(20),
                      ),
                      child: Align(
                        child: Text(
                          // "What is Bitcoin?",
                          AppLocalizations.of(context)!.translate("newhome6")!,
                          // overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: getFontSize(
                              50,
                            ),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: getVerticalSize(1450)),
                      child: Row(
                        children: [
                          Flexible(
                              child:
                                  Image.asset("assets/images/home125 (2).png")),
                          Flexible(
                              child:
                                  Image.asset("assets/images/home125 (2).png")),
                          Flexible(
                              child:
                                  Image.asset("assets/images/home125 (2).png")),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Divider(
                  color: Colors.white,
                  thickness: 1,
                  endIndent: 20,
                  indent: 20,
                ),
                Stack(children: [
                  Container(
                      width: double.infinity,
                      child: Image.asset("assets/images/home126.png")),
                  Align(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: getVerticalSize(100),
                        left: getHorizontalSize(20),
                        right: getHorizontalSize(20),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate("newhome7")!,
                        // overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: getFontSize(
                            25,
                          ),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 20),
              ],
            )
          ],
        ),
      ),
    );
  }
}
