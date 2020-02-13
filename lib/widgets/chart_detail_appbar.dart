import 'package:flutter/material.dart';



class MyDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double minValue = 8.0;
  final double iconSize = 32.0;





  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return AppBar(
      actions: <Widget>[
        IconButton(icon: Icon(Icons.more_vert), onPressed: () => null)
      ],
      title: Row(
        children: <Widget>[
          CircleAvatar(
              backgroundColor: Colors.grey,
//                radius: minValue * 2.5,
              backgroundImage: NetworkImage('https://pngimage.net/wp-content/uploads/2018/05/default-user-image-png-7.png')),
          SizedBox(
            width: minValue,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Admin"),

            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
