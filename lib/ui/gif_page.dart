import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  final Map _gifData;

  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GIF escolhido: ${_gifData["title"]} "),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[900],
        actions: [
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(_gifData["images"]["fixed_height"]["url"]);
              })
        ],
      ),
      backgroundColor: Colors.deepPurple[700],
      body: Center(
        child: Image.network(_gifData["images"]["fixed_height"]["url"]),
      ),
    );
  }
}
