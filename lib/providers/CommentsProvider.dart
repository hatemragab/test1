import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test1/dataModels/CommentModel.dart';
import 'package:test1/httpServices/CommentsService.dart';
import 'package:test1/utils/Constants.dart';

class CommentsProvider with ChangeNotifier {
  String URI = "${Constants.SOCKETURL}/api/comments";
  List<CommentModel> listComments = [];

  int page = 1;
  int totalCount = 0;
  int limit = 20;

  String subId;
  bool loading = false;
  bool isFristTime = false;

  void getAllComments() async {

    isFristTime = false;
    Map<String, dynamic> stringJson =
        await CommentsService.getAllComments(subId, limit);

    if (stringJson['error'] == true) {
      listComments = [];
      totalCount = 0;
    } else {
      print('get all comments called !!!!!!!!!!!!!!!!!!00');
      List commentsFromJson = stringJson['data'];
      int commentsCount = stringJson['totalCount'];

      List<CommentModel> comentsListFromServer =
          commentsFromJson.map((json) => CommentModel.fromJson(json)).toList();

      totalCount = commentsCount;
      listComments =comentsListFromServer;


    }
    if(listComments.length<20){
      isFristTime = true;

    }
    print('first time isssssssssssssssssssssssssssssssssssss $isFristTime');
    notifyListeners();
  }

  void addComment(CommentModel commentModel) {

    if(!isFristTime){
      ++totalCount;
      ++totalCount;
    }else{
      ++totalCount;
    }
    listComments.insert(0, commentModel);
    notifyListeners();

  }

  void loadMoreComments() async {

    ++page;

    CommentsService.getMoreData(subId, limit, page).then((data) {
      loading = false;
     if(!data['error']){
       List list = data['data'];
       totalCount = data['totalCount'];
       List<CommentModel> _comments = list.map((json) => CommentModel.fromJson(json)).toList();

       listComments.addAll(_comments);


     }

     notifyListeners();

    });
  }

  void onReceiveCommentMessage(CommentModel model) {
//    print('onReceiveCommentMessage wase cadedddddddddddddddddddddddddddd');
//    if(!isFristTime){
//      ++totalCount;
//      ++totalCount;
//    }else{
//      ++totalCount;
//    }
    listComments.insert(0, model);
    notifyListeners();
  }

  void setLoading() {
    loading = true;
    notifyListeners();
  }
}
