import 'dart:convert';

class UserModel{
  String name;
  String id;
  String password;
  String email;
  String phone;
  String chatId;

  UserModel({this.id,this.name, this.password, this.email, this.phone,this.chatId});


  UserModel.fromJson(Map<String, dynamic> map)
      : name = map['name'],
        password = map['password'],
        id = map['id'],
        email = map['email'],
        chatId = map['chatId'],
        phone = map['phone'];

  String toJson(UserModel userModel) {
    Map<String, dynamic> temp = {};
    temp['name'] = userModel.name;
    temp['password'] = userModel.password;
    temp['id'] = userModel.id;
    temp['email'] = userModel.email;
    temp['phone'] = userModel.phone;
    temp['chatId'] = userModel.chatId;

    return jsonEncode(temp);
  }

}