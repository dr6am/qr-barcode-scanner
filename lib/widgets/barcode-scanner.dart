import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BarcodeScannerWidget extends StatefulWidget {
  @override
  _BarcodeScannerWidgetState createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  ScanResult scanResult;
  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  var _aspectTolerance = 0.00;

  var _numberOfCameras = 0;

  var _useAutoFocus = true;

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
  }

  Widget result() => Container(
        decoration: BoxDecoration(
          color: CupertinoColors.extraLightBackgroundGray,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            if (scanResult.type != null)
              ListTile(
                title: Text("Result Type:"),
                subtitle: Text(scanResult.type?.toString() ?? ""),
              ),
            if (scanResult.type != null) Divider(),
            if (scanResult.rawContent != "")
              ListTile(
                title: Text("Raw Content:"),
                subtitle: Text(scanResult.rawContent ?? ""),
              ),
            if (scanResult.rawContent != "") Divider(),
            if (scanResult.format != null)
              ListTile(
                title: Text("Format:"),
                subtitle: Text(scanResult.format?.toString() ?? ""),
              ),
          ],
        ),
      );
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: MediaQuery.of(context).size.height * .5,
          child: Center(
            child: CupertinoButton.filled(
              child: Text("Scan"),
              onPressed: scan,
            ),
          ),
        ),
        if (scanResult != null)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: result(),
          ),
      ],
    );
  }

  Future scan() async {
    try {
      var options = ScanOptions(
        strings: {
          "cancel": "cancel",
          "flash_on": "Flash on",
          "flash_off": "Flash off",
        },
        restrictFormat: selectedFormats,
        useCamera: _numberOfCameras >= 1 ? 0 : 0,
        autoEnableFlash: false,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);

      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }
}
