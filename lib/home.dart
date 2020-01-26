import 'package:flutter/material.dart';
import 'package:test1/CommentModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'Constants.dart';
import 'SubCatsModel.dart';
import 'VedioInfo.dart';

class Home extends StatefulWidget {
  String id;
  String name;

  Home(this.id, this.name);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<SubCatModel> _listSubCats = [];
  var url = '${Constants.SERVERURL}category/get_sub';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getVideoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('videos List'),
      ),
      body: Container(
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (c, i) {
              return Column(
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => VedioInfo(widget.id, widget.name,_listSubCats[i].id,_listSubCats[i].vedioname,_listSubCats[i].vedioimg)));
                    },
                    title: Text("${_listSubCats[i].vedioname}"),
                  ),
                  Divider(
                    height: 1,
                    thickness: 2,
                  ),
                  SizedBox(
                    height: 4,
                  )
                ],
              );
            },
            itemCount: _listSubCats.length,
          )),
    );
  }

  void getVideoList() async {
    //local 5e1a49b16373951040407583
    //server 5e1cd058caa4330017769d7c
    var response =
        await http.post(url, body: {'cat_id': '5e1cd058caa4330017769d7c'});
    var jsonResponse = await convert.jsonDecode(response.body);
    bool error = jsonResponse['error'];
    if (error) {
    } else {
      List data = jsonResponse['data'];
      List<SubCatModel> temp = [];
      for (int i = 0; i < data.length; i++) {
        temp.add(SubCatModel(
            id: data[i]['_id'],
            vedioname: data[i]['vedioname'],
            vedioimg: data[i]['vedioimg']));
      }
      setState(() {
        _listSubCats = temp;
      });
    }
  }
}
