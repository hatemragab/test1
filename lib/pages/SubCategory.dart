import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/dataModels/CommentModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:test1/dataModels/UserModel.dart';
import 'package:test1/providers/AuthProvider.dart';
import '../utils/Constants.dart';
import '../dataModels/SubCatsModel.dart';
import 'MyChatDetailPage.dart';
import 'VideoInfo.dart';

class SubCategory extends StatefulWidget {


  SubCategory();

  @override
  _SubCategoryState createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  List<SubCatModel> _listSubCats = [];
  UserModel userModel;
  io.Socket socket;
  var url = '${Constants.SERVERURL}category/get_sub';
  String URI = "${Constants.SOCKETURL}";
  @override
  void initState() {

    super.initState();
    userModel= Provider.of<AuthProvider>(context,listen: false).userModel;

   print(' email isssssssss  ${userModel.email}');
    getVideoList();
    initSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('videos List'),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.message,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MyChatDetailPage(userModel.chatId,userModel.id)));
              })
        ],
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
                          builder: (_) => VideoInfo(
                             userModel.id,
                             userModel.name,
                              _listSubCats[i].id,
                              _listSubCats[i].vedioname,
                              _listSubCats[i].vedioimg)));
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
    var response =
        await http.post(url, body: {'cat_id': '5e1a49b16373951040407583'});
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

  void sendOnline() {

    print('my id isssssssssssss${userModel.id}');
    socket.emit('goOnline',userModel.id);
  }
}
