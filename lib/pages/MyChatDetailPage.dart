import 'dart:convert'as convert;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test1/dataModels/Message.dart';
import 'package:test1/utils/Constants.dart';
import 'package:test1/widgets/chart_detail_appbar.dart';
import 'package:test1/widgets/chat_message_tile.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;


class MyChatDetailPage extends StatefulWidget {
  String chatId;
  String user_id;

  MyChatDetailPage(this.chatId, this.user_id);

  @override
  _MyChatDeatilPageState createState() => _MyChatDeatilPageState();
}

class _MyChatDeatilPageState extends State<MyChatDetailPage> {
  final double minValue = 8.0;
  final double iconSize = 28.0;
  String URI = "${Constants.SOCKETURL}/api/message";
  var url = '${Constants.SERVERURL}message/fetch_all';
  FocusNode _focusNode;
  TextEditingController _txtController = TextEditingController();
  List<Message> _listMessages = [];
  bool isCurrentUserTyping = false;
  ScrollController _scrollController;
  io.Socket socket;
  String message = '';


  initState() {
    super.initState();
    initSocket();
    _scrollController = ScrollController(initialScrollOffset: 0);
     getLastMessages();
   // readLocalData();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      print('Something happened');
    });

    print('chat id is ${widget.chatId}');
  }


  void initSocket() async {
    socket = io.io('$URI', <String, dynamic>{
      'transports': ['websocket']
    });
    socket.on('connect', (_) {
      sendJoinChat();
    });

    socket.on('msgReceive', (data) {
      _onReceiveMessage(data);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _unSubscribes();
    super.dispose();
  }

  _unSubscribes() {
    if (socket != null) {
      socket.disconnect();
    }
  }

  void onTextFieldTapped() {}

  void _onMessageChanged(String value) {
    setState(() {
      message = value;
      if (value
          .trim()
          .isEmpty) {
        isCurrentUserTyping = false;
        return;
      } else {
        isCurrentUserTyping = true;
      }
    });
  }

  void _like() {}

  void _sendMessage() {
    var mainMap = Map<String, Object>();
    mainMap['sender_id'] = widget.user_id;
    mainMap['receiver_id'] = widget.user_id;
    mainMap['message'] = _txtController.text;
    mainMap['chat_id'] = widget.chatId;
    mainMap['isUser'] = true;
    String jsonString = convert.jsonEncode(mainMap);
    socket.emit('new_message', jsonString);

    setState(() {
      _listMessages.insert(0, (Message(messageBody: message, senderId: widget.user_id)));
      message = '';
      _txtController.text = '';
    });
    _scrollToLast();
  }

  void _scrollToLast() {
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildBottomSection() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 52,
            margin: EdgeInsets.all(minValue),
            padding: EdgeInsets.symmetric(horizontal: minValue),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(minValue * 4))),
            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.insert_emoticon,
                  size: iconSize,
                ),
                SizedBox(
                  width: minValue,
                ),
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    keyboardType: TextInputType.text,
                    controller: _txtController,
                    onChanged: _onMessageChanged,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type your message"),
                    autofocus: false,
                    onTap: () => onTextFieldTapped(),
                  ),
                ),
                Icon(
                  Icons.attach_file,
                  size: iconSize,
                ),
                isCurrentUserTyping
                    ? Container()
                    : Icon(
                  Icons.camera_alt,
                  size: iconSize,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: minValue),
          child: FloatingActionButton(
            onPressed: () => isCurrentUserTyping ? _sendMessage() : _like(),
            child: Icon(isCurrentUserTyping ? Icons.send : Icons.thumb_up),
          ),
        ),
      ],
    );
  }

  void readLocalData() async {
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//    String id = preferences.get('id');
//    String name = preferences.get('name');
//    String email = preferences.get('email');
//    setState(() {
//      this.id = id;
//      this.name = name;
//      this.email = email;
//    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: MyDetailAppBar(),
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                        vertical: minValue * 2, horizontal: minValue),
                    itemCount: _listMessages.length,
                    itemBuilder: (context, index) {
                      final Message message = _listMessages[index];
                      return MyMessageChatTile(
                        message: message,
                        isCurrentUser: message.senderId == widget.user_id,
                      );
                    }),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomSection(),
              )
            ],
          ),
        ),
      ),
    );
  }

  void sendJoinChat() {
   // String data = widget.chatId;
    Map map = Map();
    map['chatId'] =  widget.chatId;
    map['isUser'] = true;
    map['userId'] = widget.user_id;
   var myJson =  convert.jsonEncode(map);
    socket.emit("joinChat", myJson);
  }

  void _onReceiveMessage(msg) {
    print('data reciverd is $msg');
    var data = convert.jsonDecode(msg);

    setState(() {
      _listMessages.insert(
          0, Message(senderId: data['sender_id'], messageBody: data['message']));
    });


  }

  void getLastMessages() async {
    var url = '${Constants.SERVERURL}message/fetch_all';

    var response = await http.post(url, body: {'chat_id': widget.chatId});
    var jsonResponse = await convert.jsonDecode(response.body);
    bool err = jsonResponse['error'];
    if (!err) {
      List data = jsonResponse['data'];
      List<Message> temp = [];
      for (int i = 0; i < data.length; i++) {
        temp.add(Message(messageBody: data[i]['message'],senderId: data[i]['sender_id']));
      }
      setState(() {
        _listMessages=temp;
        temp=null;
      });
    }
  }
}
