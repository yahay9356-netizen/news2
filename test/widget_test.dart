import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news/main.dart';
import 'package:news/news_api.dart';
import 'package:news/widgets/news_widgets.dart';

void main() {
  testWidgets('shows the news home and category filters', (tester) async {
    await tester.pumpWidget(const NewsApp());

    expect(find.text('NEWS'), findsOneWidget);
    expect(find.text('Good Morning'), findsOneWidget);
    expect(find.text('Explore Categories'), findsOneWidget);
    expect(find.text('Business'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.textContaining('NEWS_API_KEY'), findsOneWidget);
  });

  testWidgets('save story updates its button and invokes save callback', (
    tester,
  ) async {
    var saveCalls = 0;
    const article = NewsArticle(
      title: 'A sample news story',
      source: 'News',
      url: 'https://example.com/story',
      publishedAt: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NewsArticleDetails(
            article: article,
            saved: false,
            onSave: () => saveCalls++,
          ),
        ),
      ),
    );

    expect(find.text('Save story'), findsOneWidget);
    await tester.tap(find.text('Save story'));
    await tester.pump();

    expect(saveCalls, 1);
    expect(find.text('Saved'), findsOneWidget);
  });
}
