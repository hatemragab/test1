import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/pages/Login.dart';
import 'package:test1/pages/NewLogonAndRgister/NewLogin.dart';
import 'package:test1/providers/CommentsProvider.dart';
import 'dart:io';
import 'utils/connectionStatusSingleton.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CommentsProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NewLogin(),
      ),
    );
  }
}
