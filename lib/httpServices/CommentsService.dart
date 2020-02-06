import 'package:http/http.dart' as http;
import 'package:test1/dataModels/CommentModel.dart';
import 'dart:convert' as convert;

import 'package:test1/utils/Constants.dart';

class CommentsService {
  static Future<Map<String,dynamic>> getAllComments(
      String subId, int limit) async {
    var url = '${Constants.SERVERURL}comments/fetch_all';

    try {
      var response = await http.post(url,
          body: {'subcat_id': subId, 'page': '1', 'limit': '$limit'});
      var jsonResponse = await convert.jsonDecode(response.body);

      bool err = jsonResponse['error'];
      if (!err) {


        return jsonResponse;
//        List data = jsonResponse['data'];
//        List<CommentModel> _comments =
//            data.map((json) => CommentModel.fromJson(json)).toList();
//        return _comments;
      } else {
        return {'error':true};
      }
    } catch (err) {
      return {'error':true};
    }
  }

  static Future<List<CommentModel>> getMoreData(String subId,int limit,int page)async{
    var url = '${Constants.SERVERURL}comments/fetch_all';
    try {
      var response = await http.post(url,
          body: {'subcat_id': subId, 'page': '$page', 'limit': '$limit'});
      var jsonResponse = await convert.jsonDecode(response.body);

      bool err = jsonResponse['error'];
      if (!err) {
        List data = jsonResponse['data'];
        List<CommentModel> _comments =
        data.map((json) => CommentModel.fromJson(json)).toList();

        return _comments;
      } else {
        return [];
      }
    } catch (err) {
      throw err;
    }
  }


}
