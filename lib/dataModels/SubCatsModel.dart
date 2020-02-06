import 'package:flutter/foundation.dart';

class SubCatModel {
  final String id;
  final String vedioname;
  final String vedioimg;

  SubCatModel(
      {@required this.id, @required this.vedioname, @required this.vedioimg});

  SubCatModel.fromJson(Map<String, dynamic> map)
      : id = map['_id'],
        vedioname = map['vedioname'],
        vedioimg = map['vedioimg'];

}
