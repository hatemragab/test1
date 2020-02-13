
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test1/utils/Constants.dart';
import 'package:test1/pages/home.dart';
import 'dart:convert' as convert;
import 'Register.dart';



class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var url = '${Constants.SERVERURL}user/login';



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController.text = "hatemragap5@gmail.com";
    passwordController.text = "123456";


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("login"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(hintText: "Email"),
              ),
              SizedBox(
                height: 30,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(hintText: "Password"),
              ),
              SizedBox(
                height: 30,
              ),
              RaisedButton(
                onPressed: () {
                  startLogin(emailController.text, passwordController.text);
                },
                child: Text("login"),
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => Register()));
                  },
                  child: Center(
                      child: Text(
                    "Create Account",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  )))
            ],
          ),
        ),
      ),
    );
  }

  void startLogin(String email, String password) async {
    var response = await http.post(url,
        body: {'email': email, 'password': password},
    );
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
      String chatId = jsonResponse['data']['chatId'];
     // print('chatId isssssssssss  ${jsonResponse['data']['chatId']}');
      saveData(id,name,email);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => Home(id, name,chatId)));
    }
  }
  void saveData(String id,String name,String email)async{
    SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    sharedPreferences.setString('id',id );
    sharedPreferences.setString('name',name );
    sharedPreferences.setString('email',email );
  }


}
