import 'dart:async';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'CommentModel.dart';
import 'Constants.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as io;

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
  io.Socket socket;
  bool isLoading;
  bool error = false;
  var url = '${Constants.SERVERURL}comments/fetch_all';
  String URI = "${Constants.SOCKETURL}/api/comments";

  List<CommentModel> _listComments = [];

  StreamSubscription _connectionChangeStream;

  bool isOffline = false;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {

    super.initState();
    isLoading = false;
    ConnectionStatusSingleton connectionStatus1 =
        ConnectionStatusSingleton.getInstance();
    connectionStatus1.initialize();

    initSocket();
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    getLastComments();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
    if (hasConnection) {
      //initSocket();

    } else {
      _unSubscribes();
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
        title: (isOffline) ? new Text("Not connected") : new Text(" Connected"),
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                buildViedio(),
                buildListMessage(),
                Container(),
                buildInput(),
              ],
            ),
            buildLoading()
          ],
        ),
      ),
    );
  }

  Widget buildInput() {
    return Container(
      padding: EdgeInsets.only(left: 5),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.blue, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'write your comment',
                  hintStyle: TextStyle(color: Colors.blue),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () {
                  addComment(widget.user_name, widget.user_id, widget.subId,
                      textEditingController.text);
                  textEditingController.clear();
                },
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: Colors.blue, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  void initSocket() async {
    socket = io.io('${Constants.SOCKETURL}/api/comments', <String, dynamic>{
      'transports': ['websocket']
    });
    socket.on('connect', (_) {
      print('connect');
      sendJoin();
    });
    socket.on('disconnect', (_) => print('disconnect'));

    socket.on('received', (data) {
      _onReceiveCommentMessage(data);
    });
  }

  _unSubscribes() {
    if (socket != null) {
      socket.disconnect();
    }
  }

  void getLastComments() async {
    //5e1a49b16373951040407583  local
    //5e1b30fc9db0a512c09b8ac1  server
    var response = await http.post(url, body: {'subcat_id': widget.subId,'page':'1','limit':'20'});
    var jsonResponse = await convert.jsonDecode(response.body);

    bool err = jsonResponse['error'];
    if (err) {
      setState(() {
        error = true;
      });
    } else {
      List data = jsonResponse['data'];
      List<CommentModel> temp = [];
      for (int i = 0; i < data.length; i++) {
        temp.add(CommentModel(
            name: data[i]['user_id']['name'],
            comment: data[i]['comment'],
            user_img: 'img.png',
            sender_id: data[i]['user_id']['_id']));
      }
      setState(() {
        _listComments = temp;
      });
      listScrollController.animateTo(
          listScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeIn);
    }
  }

  void addComment(String name, String user_id, String subId, String comment) {
    //Fluttertoast.showToast(msg: 'Nothing to send');
//    List<CommentModel> list_comments = [];
//    list_comments
//        .add(CommentModel(name: name, comment: comment, user_img: "img.png"));
//
//    String data =
//        '{"user_id":"$user_id","subId":"$subId","comment":"$comment","user_name":"$name","user_img":"img.png","room_name":"room 1"}';

    var mainMap = Map<String, Object>();
    mainMap['user_id'] = user_id;
    mainMap['subId'] = subId;
    mainMap['comment'] = comment;
    mainMap['user_name'] = name;
    mainMap['user_img'] = 'img.png';
    mainMap['room_name'] = widget.subId;
    mainMap['sender_id'] = widget.user_id;
    String jsonString = convert.jsonEncode(mainMap);
    socket.emit('new_comment', [jsonString]);



   // var l = _listComments.reversed.toList();
//    l.add(new CommentModel(
//        name: name,
//        comment: comment,
//        user_img: 'img.png',
//        sender_id: widget.user_id));
    setState(() {
      _listComments.add(new CommentModel(
          name: name,
          comment: comment,
          user_img: 'img.png',
          sender_id: widget.user_id));

    });

    listScrollController.animateTo(
        listScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeIn);
  }

  void _onReceiveCommentMessage(var msg) {
    //  String msg=  message.replaceFirst("#","");
    print("Message from UFO after: " + msg);
    var data = convert.jsonDecode(msg);

    var model = CommentModel(
        comment: "${data['comment']}",
        name: '${data['user_name']}',
        user_img: '${data['user_img']}',
        sender_id: '${data['sender_id']}');

    setState(() {
      _listComments.add(model);
      print('_list model add! ${model.sender_id}');
    });
    listScrollController.animateTo(
        listScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeIn);
  }

  void sendJoin() {
    String data = widget.subId;
    socket.emit("join", [data]);
  }

  Widget buildListMessage() {
    return Flexible(
      child: _listComments.length == 0 && error == false
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
          : error == true
              ? Center(
                  child: Text('No comments yet'),
                )
              : ListView.builder(
                  reverse: false,
                  controller: listScrollController,
                  padding: EdgeInsets.all(10.0),
                  shrinkWrap: true,
                  itemCount: _listComments.length,
                  itemBuilder: (context, index) =>
                      buildItem(index, _listComments[index]),
                ),
    );
  }

  Widget buildViedio() {
    return Container(
      padding: EdgeInsets.all(8),
      child: CachedNetworkImage(
        fit: BoxFit.fill,
        width: MediaQuery.of(context).size.width,
        height: 180,
        imageUrl: "${widget.subImg}",
        placeholder: (context, url) => Container(
            padding: EdgeInsets.only(top: 100, bottom: 100),
            child: Container()),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

  buildItem(int index, CommentModel listComment) {
    if (listComment.sender_id == widget.user_id) {
      return Container(
        child: Text(
          listComment.comment,
          style: TextStyle(color: Colors.black),
        ),
        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        width: 200.0,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(8.0)),
        margin: EdgeInsets.only(
            bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: listComment.user_img != 'img.png'
                            ? CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  ),
                                  width: 35.0,
                                  height: 35.0,
                                  padding: EdgeInsets.all(10.0),
                                ),
                                imageUrl: listComment.user_img == 'img.png'
                                    ? ""
                                    : listComment.user_img,
                                width: 35.0,
                                height: 35.0,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.account_circle,
                                size: 35.0,
                                color: Colors.grey,
                              ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                Container(
                  child: Text(
                    listComment.comment,
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0),
                )
              ],
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            _listComments != null &&
            _listComments[index - 1].sender_id != widget.user_id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            _listComments != null &&
            _listComments[index - 1].sender_id == widget.user_id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }
}
