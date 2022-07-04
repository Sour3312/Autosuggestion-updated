// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_literal, non_constant_identifier_names, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables, unused_field

//last wala yehi hai

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mapmyindia_gl/mapmyindia_gl.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  // ==========Declared global variables==================
  var userInput,
      AT,
      request,
      myToken,
      sorted,
      acc_tok,
      SortedData,
      ApiData,
      cnvrt2str,
      dataLength;

  Throw2Textfield() {
    print("Throw2Textfield");
  }

// =============1st Function for token generation===============================
  getToken() async {
    print("getToken called");
    request = https.Request(
        'POST',
        Uri.parse(
            'https://outpost.mapmyindia.com/api/security/oauth/token?grant_type=client_credentials&client_id=33OkryzDZsIGK9G3_WHFl8XTYLtqIgYh9kRECAhCLNPOFsP6OUvE32EyLCzy9ABln_n9_H1lybhr0DfhqKCRmQ==&client_secret=lrFxI-iSEg_qd-T6n9as4_7fk2WPyKtFb2UomHe1n3bYmHVYbOjX-LONO_lj7mnSudXW433Iq-VywW8fVlDXFc6_2xIeyyww'));
    https.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var statusOfRespnse = response.reasonPhrase;
      print("Your current status is : $statusOfRespnse");

      AT = await response.stream.bytesToString();
      myToken = json.decode(AT);
      // print("MyToken: ${myToken}");

      acc_tok = myToken["access_token"];
      print("Your access token is: ${acc_tok}");
    } else {
      print(response.reasonPhrase);
    }
    getApi(userInput);
  }

//==============2nd  Function for calling API===================================
  getApi(value) async {
    final respon = await https.get(Uri.parse(
            // 'https://atlas.mappls.com/api/places/search/json?query=dubai}'),
            'https://atlas.mappls.com/api/places/search/json?query=${userInput}}'),
        headers: {
          'Access-Control-Allow-Origin': "*",
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Methods': 'POST,GET,DELETE,PUT,OPTIONS',
          'cors': '*',
          HttpHeaders.authorizationHeader: "bearer ${acc_tok}",
        });
    try {
      ApiData = await json.decode(respon.body);
      print(ApiData);
      dataLength = ApiData["suggestedLocations"].length;
      print("This is Apidata length: ${dataLength}");
      // print(dataLength.runtimeType);
      // cnvrt2str = dataLength.toString().runtimeType;
      // print(cnvrt2str);
      return ApiData;
    } catch (e) {
      print(e);
    }
  }

//==============Map integration starts here=====================================
  final Completer<MapmyIndiaMapController> _controller = Completer();

  final CameraPosition _MmiPlex = CameraPosition(
      target: LatLng(22.805529670433828, 86.20229974835348), zoom: 6);

  @override
  void initState() {
    MapmyIndiaAccountManager.setMapSDKKey("${acc_tok}");
    MapmyIndiaAccountManager.setRestAPIKey("47e0624fbd6e55e8dd13e4453f089aa7");
    MapmyIndiaAccountManager.setAtlasClientId(
        "33OkryzDZsIGK9G3_WHFl8XTYLtqIgYh9kRECAhCLNPOFsP6OUvE32EyLCzy9ABln_n9_H1lybhr0DfhqKCRmQ==");
    MapmyIndiaAccountManager.setAtlasClientSecret(
        "lrFxI-iSEg_qd-T6n9as4_7fk2WPyKtFb2UomHe1n3bYmHVYbOjX-LONO_lj7mnSudXW433Iq-VywW8fVlDXFc6_2xIeyyww");
    super.initState();
  }

//===============Main body starts here==========================================
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Material(
      child: Scaffold(
        // =========AppBar==============
        appBar: (AppBar(
            // toolbarHeight: 100,
            backgroundColor: Colors.pinkAccent,
            titleSpacing: 40.0,
            title: Column(children: [
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: TextField(
                    // textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      userInput = value;
                      print("userInput is: $userInput");
                      setState(() {
                        getToken();
                      });
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              userInput = Null;
                              print("pressed");
                            });
                          },
                        ),
                        hintText: 'Search here...',
                        border: InputBorder.none),
                  ),
                ),
              ),
            ]))),

// =========Body============== delhi
        body: ListView.builder(
            shrinkWrap: true,
            itemCount: 12,
            itemBuilder: (BuildContext context, int index) {
              return (ListTile(
                leading: Icon(Icons.location_city_rounded),
                title: Text(
                  ApiData["suggestedLocations"][index]["placeAddress"],
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                subtitle:
                    Text(ApiData["suggestedLocations"][index]["placeName"]),
              ));
            }),
      ),
      //   body: MapmyIndiaMap(
      //       initialCameraPosition: _MmiPlex,
      //       myLocationRenderMode: MyLocationRenderMode.COMPASS,
      //       compassEnabled: true,
      //       myLocationEnabled: true,
      //       myLocationTrackingMode: MyLocationTrackingMode.NoneCompass,
      //       onMapCreated: (MapmyIndiaMapController controller) {
      //         _controller.complete(controller);
      //       }),
      // ),
    ));
  }
}
