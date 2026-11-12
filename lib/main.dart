import 'package:flutter/material.dart';

import 'screens/news_home_page.dart';

const _background = Color(0xFF090909);

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: _background,
        ),
        useMaterial3: true,
        fontFamily: 'Avenir',
      ),
      home: const NewsHomePage(),
    );
  }
}
