import 'package:flutter/material.dart';
import 'package:test1/dataModels/CategoryModel.dart';
import 'package:test1/dataModels/SubCatsModel.dart';
import 'package:test1/pages/Category.dart';
import 'package:test1/pages/SubCategory.dart';

class SubCategoryItem extends StatelessWidget {
  SubCatModel _subCategory;

  SubCategoryItem(this._subCategory);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridTile(
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: Image.network(
                  '${_subCategory.img}',
                  fit: BoxFit.cover,
                  height: 150,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Text(
                '${_subCategory.name}',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
