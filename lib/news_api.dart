import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class NewsApiException implements Exception {
  const NewsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NewsArticle {
  const NewsArticle({
    required this.title,
    required this.source,
    required this.url,
    required this.publishedAt,
    this.description,
    this.imageUrl,
    this.content,
  });

  final String title;
  final String source;
  final String url;
  final DateTime? publishedAt;
  final String? description;
  final String? imageUrl;
  final String? content;

  String get timeAgo {
    final date = publishedAt;
    if (date == null) return 'Recently';
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    final published = json['publishedAt'];
    final image = json['urlToImage'];
    final description = json['description'];
    final content = json['content'];
    final url = json['url'];

    return NewsArticle(
      title: _text(json['title']) ?? 'Untitled story',
      source: source is Map<String, dynamic>
          ? _text(source['name']) ?? 'News'
          : 'News',
      url: _text(url) ?? '',
      publishedAt: published is String ? DateTime.tryParse(published) : null,
      description: _text(description),
      imageUrl: _text(image),
      content: _text(content),
    );
  }
}

String? _text(Object? value) {
  if (value is! String || value.trim().isEmpty || value == '[Removed]') {
    return null;
  }
  return value.trim();
}

class NewsApi {
  const NewsApi();

  static const _apiKey = String.fromEnvironment('NEWS_API_KEY');
  static const _baseUrl = 'newsapi.org';

  Future<List<NewsArticle>> fetchHeadlines({required String category}) {
    return _get('/v2/top-headlines', {
      'country': 'us',
      if (category.toLowerCase() != 'general')
        'category': category.toLowerCase(),
    });
  }

  Future<List<NewsArticle>> search(String query) {
    return _get('/v2/everything', {
      'q': query,
      'language': 'en',
      'sortBy': 'publishedAt',
      'pageSize': '30',
    });
  }

  Future<List<NewsArticle>> _get(
    String path,
    Map<String, String> parameters,
  ) async {
    if (_apiKey.isEmpty) {
      throw const NewsApiException(
        'Add a NewsAPI key to run the app: '
        '--dart-define=NEWS_API_KEY=your_key',
      );
    }

    final uri = Uri.https(_baseUrl, path, {...parameters, 'apiKey': _apiKey});
    late final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const NewsApiException(
        'Could not connect to NewsAPI. Check your connection.',
      );
    } on TimeoutException {
      throw const NewsApiException(
        'NewsAPI took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const NewsApiException(
        'Could not connect to NewsAPI. Check your connection.',
      );
    }

    final Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object');
      }
      payload = decoded;
    } on FormatException {
      throw const NewsApiException('NewsAPI returned an unreadable response.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = payload['message'];
      throw NewsApiException(
        message is String
            ? 'NewsAPI error: $message'
            : 'NewsAPI error (${response.statusCode}).',
      );
    }
    if (payload['status'] != 'ok') {
      final message = payload['message'];
      throw NewsApiException(
        message is String
            ? 'NewsAPI error: $message'
            : 'NewsAPI could not load stories.',
      );
    }

    final results = payload['articles'];
    if (results is! List) {
      throw const NewsApiException(
        'NewsAPI returned an invalid articles list.',
      );
    }
    return results
        .whereType<Map<String, dynamic>>()
        .map(NewsArticle.fromJson)
        .where((article) => article.url.isNotEmpty)
        .toList();
  }
}
