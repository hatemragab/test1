import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'CommentModel.dart';
import 'Constants.dart';

import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class VedioInfo extends StatefulWidget {
  String user_id;
  String user_name;
  String subId;
  String subName;
  String subImg;

  VedioInfo(
      this.user_id, this.user_name, this.subId, this.subName, this.subImg);

  @override
  _VedioInfoState createState() => _VedioInfoState();
}

class _VedioInfoState extends State<VedioInfo> {
  var commentController = TextEditingController();

  // SocketIOManager manager;
  // SocketIO socket;
  SocketIO socketIO;
  var url = '${Constants.SERVERURL}comments/fetch_all';
  String URI = "${Constants.SOCKETURL}";
  List<CommentModel> _listComments = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // manager = SocketIOManager();
    initSocket();
    getLastComments();
  }

  @override
  void dispose() {
    _unSubscribes();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('comments'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            CachedNetworkImage(
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: 200,
              imageUrl: "${widget.subImg}",
              placeholder: (context, url) => Container(
                  padding: EdgeInsets.only(top: 100, bottom: 100),
                  child: Container()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                    itemCount: _listComments.length,
                    shrinkWrap: true,
                    itemBuilder: (c, i) {
                      return Column(
                        children: <Widget>[
                          ListTile(
                            title: Text("${_listComments[i].name}"),
                            subtitle: Text("${_listComments[i].comment}"),
                          ),
                          Divider(
                            height: 1,
                            thickness: 2,
                          )
                        ],
                      );
                    }),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(hintText: "write comment"),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      addComment(widget.user_name, widget.user_id, widget.subId,
                          commentController.text);
                      commentController.text = '';
                    },
                    icon: Icon(Icons.send),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _socketStatus(dynamic data) {
    print("Socket status: " + data);
  }

  void initSocket() async {
    socketIO = SocketIOManager().createSocketIO(
        Constants.SOCKETURL, "/api/comments",
        socketStatusCallback: _socketStatus);

    socketIO.init();
    socketIO.subscribe('connection', () {
      print('connected');
    });



    if (socketIO != null) {
      socketIO.subscribe("received", _onReceiveCommentMessage);
    }

    socketIO.connect();
//    socket = await manager.createInstance(
//        SocketOptions(URI, nameSpace: "/", query: {'forceNew': 'true'}));
//    socket.on('received', (data) {
//      print('dataaaaaaa is $data');
//    });
//    socket.onConnect((data) {
//      print("connected...");
//    });
//    socket.on('disconnect',(s){
//      print("dis connected...");
//    });
//    socket.connect();
  }

  _unSubscribes() {
    if (socketIO != null) {
      socketIO.disconnect();
    }
  }

  void getLastComments() async {
    //5e1a49b16373951040407583  local
    //5e1b30fc9db0a512c09b8ac1  server
    var response =
        await http.post(url, body: {'subcat_id': widget.subId});
    var jsonResponse = await convert.jsonDecode(response.body);
    //print('responseeeeeeeeeeeeeeeee is $jsonResponse');
    bool error = jsonResponse['error'];
    if (error) {
    } else {
      List data = jsonResponse['data'];
      List<CommentModel> temp = [];
      for (int i = 0; i < data.length; i++) {
        temp.add(CommentModel(
            name: data[i]['user_id']['name'],
            comment: data[i]['comment'],
            user_img: 'img.png'));
      }
      setState(() {
        _listComments = temp;
      });
    }
  }

  void addComment(String name, String user_id, String subId, String comment) {
    List<CommentModel> list_comments = [];
    list_comments
        .add(CommentModel(name: name, comment: comment, user_img: "img.png"));
    // Map<String, String> myData = {name: name, comment: comment};
    //"name":"$name",
    String data =
        '{"user_id":"$user_id","subId":"$subId","comment":"$comment","user_name":"$name","user_img":"img.png"}';
    socketIO.sendMessage('new_comment', data);

    setState(() {
      _listComments.add(new CommentModel(name: name, comment: comment));
    });
  }


  void _onReceiveCommentMessage(dynamic message)  {
    print("Message from UFO: " + message);
  var data=   convert.jsonDecode(message);

    var model = CommentModel(
        comment: "${data['comment']}",
        name: '${data['user_name']}',
        user_img: '${data['user_img']}');
    setState(() {

      _listComments.add(model);
    });
  }

}
