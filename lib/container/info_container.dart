import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:package_info/package_info.dart';

class InfoContainer extends StatefulWidget {
  @override
  State createState() {
    return _InfoContainerState();
  }
}

class _InfoContainerState extends State<InfoContainer> {
  var _version = "";
  var _buildNumber = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getInfo();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20);
    var versionStyle = TextStyle(color: Colors.white, fontSize: 15);

    return Container(
      decoration: BoxDecoration(
        image: new DecorationImage(
          image: AssetImage("assets/image_blue_blur.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 90,
          ),
          Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 100,
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            "Lịch Vạn Niên 2019",
            style: textStyle,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              'Version: ${_version}',
              style: versionStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              'Build: ${_buildNumber}',
              style: versionStyle,
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: EdgeInsets.only(bottom: 70, right: 10),
                    child: Text("Developed by ThienMD"))),
          )
        ],
      ),
    );
  }

  Future<void> getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _buildNumber = packageInfo.buildNumber;
      _version = packageInfo.version;
    });
  }
}
