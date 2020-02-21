import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/dataModels/CommentModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:test1/style/theme.dart' as Theme;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:test1/dataModels/UserModel.dart';
import 'package:test1/providers/AuthProvider.dart';
import 'package:test1/widgets/CategoryItem.dart';
import 'package:test1/widgets/SubCategoryItem.dart';

import '../utils/Constants.dart';
import '../dataModels/SubCatsModel.dart';
import 'MyChatDetailPage.dart';
import 'VideoInfo.dart';

class SubCategory extends StatefulWidget {
  String cat_id;

  int type;

  SubCategory(this.cat_id, this.type);

  @override
  _SubCategoryState createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  List<SubCatModel> _listSubCats = [];
  UserModel userModel;
  io.Socket socket;
  String error_data = "";
  var url = '${Constants.SERVERURL}sub_category/get_sub';
  String URI = "${Constants.SOCKETURL}";

  @override
  void initState() {
    super.initState();
    userModel = Provider.of<AuthProvider>(context, listen: false).userModel;

    print(' email isssssssss  ${userModel.email}');
    getVideoList();
    initSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.message,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          MyChatDetailPage(userModel.chatId, userModel.id)));
                })
          ],
          elevation: 2,
          centerTitle: true,
          title: Text(
            'Home Screen',
            style: TextStyle(fontSize: 17),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: <Color>[
                  Theme.Colors.loginGradientStart,
                  Theme.Colors.loginGradientEnd
                ])),
          ),
        ),
        body: getBody());
  }

  void initSocket() async {
    socket = io.io('$URI', <String, dynamic>{
      'transports': ['websocket']
    });
    socket.on('connect', (_) {
      sendOnline();
    });
  }

  void getVideoList() async {
    //local 5e1a49b16373951040407583
    //server 5e1cd058caa4330017769d7c
    var response = await http.post(url, body: {'id': widget.cat_id});
    var jsonResponse = await convert.jsonDecode(response.body);
    print(jsonResponse);
    bool error = jsonResponse['error'];
    if (error) {
      setState(() {
        error_data = "No Childs yet";
      });
    } else {
      List data = jsonResponse['data'];
      List<SubCatModel> temp = [];
      for (int i = 0; i < data.length; i++) {
        temp.add(SubCatModel(
            id: data[i]['_id'],
            name: data[i]['name'],
            img: data[i]['img'],
            type: data[i]['type']));
      }
      setState(() {
        _listSubCats = temp;
      });
    }
  }

  void sendOnline() {
    print('my id isssssssssssss${userModel.id}');
    socket.emit('goOnline', userModel.id);
  }

  getBody() {

    if(_listSubCats.length==0){}else{
      if (widget.type == 1) {
        print('categorys !!!!!!!');
        print('type is ${_listSubCats[0].type}');
        return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            return true;
          },
          child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height >= 775.0
                    ? MediaQuery.of(context).size.height
                    : 775.0,
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [
                        Theme.Colors.loginGradientStart,
                        Theme.Colors.loginGradientEnd
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    _listSubCats.length == 0
                        ? Center(
                      child: error_data == ""
                          ? Text('No Category !')
                          : CircularProgressIndicator(),
                    )
                        : Container(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(10),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: .9,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10),
                          itemBuilder: (c, i) {
                            SubCatModel categoryModel = _listSubCats[i];
                            return InkWell(onTap: (){
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => SubCategory(_listSubCats[i].id,_listSubCats[i].type)));

                            },child: SubCategoryItem(categoryModel));
                          },
                          itemCount: _listSubCats.length,
                        ))
                  ],
                ),
              )),
        );
      } else if (widget.type == 2) {
        return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            return true;
          },
          child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height >= 775.0
                    ? MediaQuery.of(context).size.height
                    : 775.0,
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [
                        Theme.Colors.loginGradientStart,
                        Theme.Colors.loginGradientEnd
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    _listSubCats.length == 0
                        ? Center(
                      child: error_data == ""
                          ? Text('No Category !')
                          : CircularProgressIndicator(),
                    )
                        : Container(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(10),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: .9,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10),
                          itemBuilder: (c, i) {
                            SubCatModel categoryModel = _listSubCats[i];
                            return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => VideoInfo(
                                          _listSubCats[i].id,
                                          _listSubCats[i].name,
                                          _listSubCats[i].img)));
                                },
                                child: SubCategoryItem(categoryModel));
                          },
                          itemCount: _listSubCats.length,
                        ))
                  ],
                ),
              )),
        );
      }
    }



  }
}
