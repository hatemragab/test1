import 'dart:async';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'CommentModel.dart';
import 'Constants.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:io';

import 'connectionStatusSingleton.dart';

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
  SocketIOManager manager;
  SocketIO socket;
  var url = '${Constants.SERVERURL}comments/fetch_all';
  String URI = "${Constants.SOCKETURL}";
  List<CommentModel> _listComments = [];

  StreamSubscription _connectionChangeStream;

  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus1 =
        ConnectionStatusSingleton.getInstance();
    connectionStatus1.initialize();
    manager = SocketIOManager();
    initSocket();
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    getLastComments();
  }

  void connectionChanged(dynamic hasConnection) {
    if (hasConnection) {
      // initSocket();
    } else {
      //_unSubscribes();
    }
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
        title: (isOffline) ? new Text("Not connected") : new Text("Connected"),
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

  void initSocket() async {

    socket = await manager.createInstance(SocketOptions(
        //Socket IO server URI
        URI,
        nameSpace: "/api/comments",
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [
          Transports.WEB_SOCKET /*, Transports.POLLING*/
        ] //Enable required transport
        ));
    socket.onConnect((data) {
      print("connected...");

      sendMessage();
    });
    socket.on('received', (data) {
      _onReceiveCommentMessage(data);

    });
    socket.connect();
  }

  _unSubscribes() {
    if (socket != null) {
      manager.clearInstance(socket);
    }
  }

  void getLastComments() async {
    //5e1a49b16373951040407583  local
    //5e1b30fc9db0a512c09b8ac1  server
    var response = await http.post(url, body: {'subcat_id': widget.subId});
    var jsonResponse = await convert.jsonDecode(response.body);

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

    String data =
        '{"user_id":"$user_id","subId":"$subId","comment":"$comment","user_name":"$name","user_img":"img.png","room_name":"room 1"}';

    var mainMap = Map<String, Object>();
    mainMap['user_id']=user_id;
    mainMap['subId']=subId;
    mainMap['comment']=comment;
    mainMap['user_name']=name;
    mainMap['user_img']='img.png';
    mainMap['room_name']=widget.subId;
    String jsonString = convert.jsonEncode(mainMap);


    // add [] for adhara lib.
    // send data as string for flutter_socket_io
    socket.emit('new_comment', [jsonString]);
    setState(() {
      _listComments.add(new CommentModel(name: name, comment: comment));
    });
  }

  void _onReceiveCommentMessage(String message) {


     String msg=  message.replaceFirst("#","");
     print("Message from UFO after: " + msg);
     var data= convert.jsonDecode(msg);

    var model = CommentModel(
        comment: "${data['comment']}",
        name: '${data['user_name']}',
        user_img: '${data['user_img']}');


    setState(() {
      _listComments.add(model);
    });
  }

  void sendMessage() {
    String data =widget.subId;
    socket.emit("join", [data]);
  }
}
