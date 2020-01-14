import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'Constants.dart';
import 'Login.dart';
import 'home.dart';
class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {


  var url = '${Constants.SERVERURL}user/create';
  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return    Scaffold(
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
                  startRegister(nameController.text,emailController.text,passwordController.text,phoneController.text);
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
  void startRegister(String name,String email,String password,String phone) async {
    var response =
    await http.post(url, body: {'name':name,'email': email, 'password': password,'phone':phone});
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
      String id = jsonResponse['_id'];
      String name = jsonResponse['name'];
      String email = jsonResponse['email'];

      Navigator.of(context).push(MaterialPageRoute(builder: (_) => Home(id,name)));
    }

  }
}
