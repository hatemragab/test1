import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import '../utils/Constants.dart';
import 'Login.dart';
import 'home.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  io.Socket socket;

  String URI = "${Constants.SOCKETURL}/api/chat";


  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController.text = "t2323est@gmail.com";
    nameController.text = "testtttt";
    phoneController.text = "1234567890";
    passwordController.text = "123456";
   // initSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("Register"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: "Name"),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(hintText: "Email"),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(hintText: "Phone"),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(hintText: "Password"),
              ),
              SizedBox(
                height: 15,
              ),
              RaisedButton(
                onPressed: () {
                  startRegister(nameController.text, emailController.text,
                      passwordController.text, phoneController.text);
                },
                child: Text("Register"),
              ),
              SizedBox(
                height: 15,
              ),
              InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => Login()));
                  },
                  child: Center(
                      child: Text(
                    "I have account  ",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )))
            ],
          ),
        ),
      ),
    );
  }

  void startRegister(
      String name, String email, String password, String phone) async {
    var response = await http.post("${Constants.SERVERURL}user/create", body: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone
    });
    var jsonResponse = await convert.jsonDecode(response.body);
    bool error = jsonResponse['error'];
    if (error) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('${jsonResponse['data']}'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close'))
              ],
            );
          });
    } else {
      String id = jsonResponse['data']['_id'];
      String name = jsonResponse['data']['name'];
      String email = jsonResponse['data']['email'];
      String chatId = jsonResponse['chatId'];
    //  socket.emit('getOnlineUsers',[]);

      print('chat id issssssssssssssssssssss $chatId');
      print('chat res issssssssssssssssssssss $jsonResponse');
      saveData(id, name, email, chatId);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => Home(id, name, chatId)));
    }
  }

  void saveData(String id, String name, String email, chatId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('id', id);
    sharedPreferences.setString('name', name);
    sharedPreferences.setString('email', email);
    sharedPreferences.setString('chatId', chatId);
  }



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (socket != null) {
      socket.disconnect();
    }
  }

  void initSocket() {

    socket = io.io('$URI', <String, dynamic>{
      'transports': ['websocket']
    });
    socket.on('connect', (_) {

    });
  }
}
