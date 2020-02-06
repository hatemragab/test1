import 'dart:convert';

import 'package:flutter/foundation.dart';

class CommentModel {
  final String name;
  final String comment;
  final String sender_id;
  final String subId;
  final String createdAt;
  final int timeStamp;

  CommentModel({
    @required this.name,
    @required this.comment,
    @required this.sender_id,
      this.createdAt,
     this.timeStamp,
    this.subId
  });

  CommentModel.fromJson(Map<String, dynamic> map)
      : name = map['user_id']['name'],
        comment = map['comment'],
        sender_id = map['user_id']['_id'],
        createdAt = map['createdAt'],
        timeStamp = map['created'],
        subId = map['subId'];

  String toJson(CommentModel commentModel) {
    Map<String, dynamic> temp = {};
    temp['name'] = commentModel.name;
    temp['comment'] = commentModel.comment;
    temp['sender_id'] = commentModel.sender_id;
   // temp['createdAt'] = commentModel.createdAt;
   // temp['created'] = commentModel.timeStamp;
    return jsonEncode(temp);
  }
}
