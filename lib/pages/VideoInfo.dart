import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:test1/dataModels/CommentModel.dart';
import 'package:test1/dataModels/UserModel.dart';
import 'package:test1/providers/AuthProvider.dart';
import 'package:test1/providers/CommentsProvider.dart';
import 'package:test1/streamModels/CommentsStream.dart';
import 'dart:convert' as convert;
import '../utils/Constants.dart';
import 'package:connectivity/connectivity.dart';
import 'package:bubble/bubble.dart';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../utils/connectionStatusSingleton.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoInfo extends StatefulWidget {

  String subId;
  String subName;
  String subImg;

  VideoInfo(
     this.subId, this.subName, this.subImg);

  @override
  _VideoInfoState createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo> {
  UserModel _userModel;
  io.Socket socket;
  bool isLoading = false;
  bool error = false;
  int page = -1;
  int limit = 20;
  double _loadingOffset = 20;
  var url = '${Constants.SERVERURL}comments/fetch_all';
  String URI = "${Constants.SOCKETURL}/api/comments";
  List<CommentModel> _listComments = [];
  CommentsStream commentsStream = CommentsStream();
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();


  @override
  void initState() {
    super.initState();

    Provider.of<CommentsProvider>(context, listen: false).subId = widget.subId;
      _userModel=  Provider.of<AuthProvider>(context, listen: false).userModel ;



    Provider.of<CommentsProvider>(context, listen: false).page = 1;



    Provider.of<CommentsProvider>(context, listen: false).getAllComments();

    ConnectionStatusSingleton connectionStatus1 =
        ConnectionStatusSingleton.getInstance();
    connectionStatus1.initialize();

    initSocket();

    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _setListener();
    print('sub is is ${widget.subId}');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: (isOffline) ? new Text("Not connected") : new Text(" Connected"),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildVideo(),
              buildListMessage(),
              Container(),
              buildInput(),
            ],
          ),
          buildLoading()
        ],
      ),
    );
  }

  void _onReceiveCommentMessage(var msg) {
    print("Message from UFO after: " + msg);
    var data = convert.jsonDecode(msg);

    var model = CommentModel(
        comment: "${data['comment']}",
        name: '${data['user_name']}',
        sender_id: '${data['sender_id']}');

    Provider.of<CommentsProvider>(context, listen: false)
        .totalCount = int.parse(data['totalCount']);

    Provider.of<CommentsProvider>(context, listen: false)
        .onReceiveCommentMessage(model);

  }

  Widget buildListMessage() {
    return Flexible(
      child: Consumer<CommentsProvider>(
        builder: (_, commentsProvider, child) {
          List<CommentModel> _commentsList = commentsProvider.listComments;
          int _commentsCount = commentsProvider.totalCount;
          bool _loading = commentsProvider.loading;
          return _commentsList.length == 0
              ? Center(
                  child: Text('No Comments Yet'),
                )
              : getListItemsToBuildListMessageMethod(_commentsList, _commentsCount,_loading);
        },
      ),
    );
  }

  Widget getListItemsToBuildListMessageMethod(
      List<CommentModel> _listComments, int totalCount, bool isLoading) {

    return Container(
      height: 1000,
      child: ListView.builder(
        reverse: true,
        controller: listScrollController,
        padding: EdgeInsets.all(10.0),
        shrinkWrap: true,
        itemCount: _listComments.length,
        itemBuilder: (context, index) {
        //  print('index is $index while length is ${_listComments.length}');
          //print('total count is  $totalCount');
          if (index == totalCount ){
            return Container(

            );
          }else if(index == _listComments.length){
            return Align(child: CircularProgressIndicator());
          }
          else{
            return buildItem(index, _listComments[index]);
          }

        },
      ),
    );
  }

  Widget buildItem(int index, CommentModel listComment) {
    if (listComment.sender_id == _userModel.id) {
      return Bubble(
        margin: BubbleEdges.only(top: 10),
        alignment: Alignment.topRight,
        nip: BubbleNip.rightTop,
        padding: BubbleEdges.all(9),
        color: Color.fromRGBO(225, 255, 199, 1.0),
        child: Text('${listComment.comment}', textAlign: TextAlign.right),
      );
    } else {
      return Bubble(
        margin: BubbleEdges.only(top: 10),
        alignment: Alignment.topLeft,
        nip: BubbleNip.leftTop,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${listComment.name}',
              style: TextStyle(fontSize: 12, color: Colors.blue),
              textAlign: TextAlign.start,
            ),
            SizedBox(
              height: 3,
            ),
            Text('${listComment.comment}')
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _unSubscribes();
    listScrollController.dispose();
    super.dispose();
  }

  void _setListener() async {

    listScrollController.addListener(() async {
      var max = listScrollController.position.maxScrollExtent;
      var offset = listScrollController.offset;
      bool _loading =
          Provider.of<CommentsProvider>(context, listen: false).loading;
      // we have reached at the top of the list, we should make _loading = true
      if (max - offset < _loadingOffset && !_loading) {
        Provider.of<CommentsProvider>(context, listen: false).setLoading();
        print('loading from listScrollController');
        Provider.of<CommentsProvider>(context, listen: false).loadMoreComments();
      }
    });
  }

  void emitNewMessageToServer(CommentModel commentModel) {
    var mainMap = Map<String, Object>();
    mainMap['user_id'] = commentModel.sender_id;
    mainMap['subId'] = commentModel.subId;
    mainMap['comment'] = commentModel.comment;
    mainMap['user_name'] = commentModel.name;
    mainMap['user_img'] = 'img.png';
    mainMap['room_name'] = commentModel.subId;
    mainMap['sender_id'] = commentModel.subId;
    String jsonString = convert.jsonEncode(mainMap);

    socket.emit('new_comment', [jsonString]);
  }

  Widget buildVideo() {
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

  void sendJoin() {
    String data = widget.subId;
    socket.emit("joinCommentsRoom", [data]);
  }

  Widget buildInput() {
    return Container(
      padding: EdgeInsets.only(left: 5),
      child: Row(
        children: <Widget>[
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: Container(),
            ),
            color: Colors.white,
          ),

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
                  if (textEditingController.text.isEmpty) {
                    Fluttertoast.showToast(
                      msg: 'Comment is empty !',
                      backgroundColor: Colors.black,
                    );
                  } else {

                    CommentModel c = CommentModel(
                        name: _userModel.name,
                        comment: textEditingController.text,
                        sender_id:_userModel.id,
                        subId: widget.subId);
                    Provider.of<CommentsProvider>(context, listen: false)
                        .addComment(c);
                   emitNewMessageToServer(c);

                    textEditingController.clear();
                    try {
                      listScrollController.animateTo(
                          listScrollController.position.minScrollExtent,
                          duration: Duration(milliseconds: 1000),
                          curve: Curves.easeIn);
                    } catch (e) {
                      print(e);
                    }
                  }
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
    socket = io.io('$URI', <String, dynamic>{
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

  Future<bool> onBackPress() {
    Navigator.pop(context);

    return Future.value(false);
  }

  _unSubscribes() {
    if (socket != null) {
      socket.disconnect();
    }
  }
}
