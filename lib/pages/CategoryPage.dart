import 'package:flutter/material.dart';
import 'package:test1/dataModels/CategoryModel.dart';
import 'package:test1/style/theme.dart' as Theme;
import 'package:test1/utils/Constants.dart';
import 'package:test1/widgets/CategoryItem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<CategoryModel> _listCategory = [];
  String _url = '${Constants.SERVERURL}category/fetch_all';
  String error_data = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategorys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: Text(
          'Home Screen',
          style: TextStyle(fontSize: 17),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: <Color>[
                Theme.Colors.loginGradientStart,
                Theme.Colors.loginGradientEnd
              ])),
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          return true;
        },
        child: SingleChildScrollView(
            child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height >= 775.0
              ? MediaQuery.of(context).size.height
              : 775.0,
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Theme.Colors.loginGradientStart,
                  Theme.Colors.loginGradientEnd
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Text(
                'Welome to yourTech App ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              _listCategory.length == 0
                  ? Center(
                      child: error_data == ""
                          ? Text('No Category !')
                          : CircularProgressIndicator(),
                    )
                  : Container(
                      child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: .9,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                      itemBuilder: (c, i) {
                        CategoryModel categoryModel = _listCategory[i];
                        return CategoryItem(categoryModel);
                      },
                      itemCount: _listCategory.length,
                    ))
            ],
          ),
        )),
      ),
    );
  }

  void getCategorys() async {
    var response = await http.get(
      _url,
    );

    var jsonResponse = await convert.jsonDecode(response.body);
    print(jsonResponse);
    bool error = jsonResponse['error'];
    if (!error) {
      List data = jsonResponse['data'];
      List<CategoryModel> temp = [];
      for (int i = 0; i < data.length; i++) {
        temp.add(CategoryModel(
            id: data[i]['_id'],
            name: data[i]['name'],
            img: data[i]['img'],
            type: data[i]['type'],
            isLive: false));
      }
      setState(() {
        _listCategory = temp;
      });
      temp = null;
    } else {
      setState(() {
        error_data = jsonResponse['data'];
      });
    }
  }
}
