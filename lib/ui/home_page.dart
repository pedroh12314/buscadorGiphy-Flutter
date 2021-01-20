import 'dart:convert';
import 'package:buscadorGiphy/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import './gif_page.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  String _search;
  int _offSet = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=i6uejzNWSD1khBDFifNh1f0EN4BFxo9N&limit=19&rating=g");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=i6uejzNWSD1khBDFifNh1f0EN4BFxo9N&q=$_search&limit=19&offset=$_offSet&rating=g&lang=en");
    return json.decode(response.body);
  }

  void _searchButton() {
    setState(() {
      _search = searchController.text;
      _offSet = 0;
    });
  }

  int _getCout(List data) {
    if (_search == null)
      return data.length;
    else
      return data.length + 1;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.deepPurple[700],
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise um Gif",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (String text) {
                setState(() {
                  _search = text;
                  _offSet = 0;
                });
              },
              controller: searchController,
            ),
          ),
          RaisedButton(
            color: Colors.blue,
            child: Text("Pesquisar"),
            textColor: Colors.white,
            onPressed: _searchButton,
          ),
          Expanded(
              child: FutureBuilder(
                  future: _getGifs(),
                  builder: (context, snapShot) {
                    switch (snapShot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 1.0,
                          ),
                        );
                      default:
                        if (snapShot.hasError) {
                          return Container(
                            alignment: Alignment.center,
                            child: Text("Erro ao obter dados"),
                          );
                        } else
                          return _createGiffTable(context, snapShot);
                    }
                  }))
        ],
      ),
    );
  }

  Widget _createGiffTable(BuildContext context, AsyncSnapshot snapShot) {
    return GridView.builder(
        padding: EdgeInsets.all(20.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCout(snapShot.data["data"]),
        itemBuilder: (contex, index) {
          if (_search == null || index < snapShot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapShot.data["data"][index]["images"]["fixed_height"]
                    ["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapShot.data["data"][index])));
              },
              onLongPress: () {
                Share.share(snapShot.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70.0,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offSet += 19;
                  });
                },
              ),
            );
        });
  }
}
