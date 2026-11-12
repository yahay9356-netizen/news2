import 'package:flutter/material.dart';

import '../news_api.dart';
import '../widgets/news_widgets.dart';

const _background = Color(0xFF090909);
const _muted = Color(0xFF9A9A9A);
const _categories = <String>[
  'General',
  'Business',
  'Sports',
  'Technology',
  'Health',
];
const _categoryIcons = <String, IconData>{
  'General': Icons.public_rounded,
  'Business': Icons.business_center_rounded,
  'Sports': Icons.sports_basketball_rounded,
  'Technology': Icons.devices_rounded,
  'Health': Icons.favorite_rounded,
};
const _categoryImages = <String, String>{
  'General':
      'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=300&h=220&fit=crop',
  'Business':
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=300&h=220&fit=crop',
  'Sports':
      'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=300&h=220&fit=crop',
  'Technology':
      'https://images.unsplash.com/photo-1518770660439-4636190af475?w=300&h=220&fit=crop',
  'Health':
      'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=300&h=220&fit=crop',
};

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  final _api = NewsApi();
  final _searchController = TextEditingController();
  final _savedArticles = <String, NewsArticle>{};

  String _category = 'General';
  int _tab = 0;
  bool _searching = false;
  bool _loading = true;
  String? _error;
  List<NewsArticle> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadHeadlines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHeadlines() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final articles = await _api.fetchHeadlines(category: _category);
      if (!mounted) return;
      setState(() {
        _articles = articles;
        _loading = false;
      });
    } on NewsApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      await _loadHeadlines();
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final articles = await _api.search(query.trim());
      if (!mounted) return;
      setState(() {
        _articles = articles;
        _loading = false;
      });
    } on NewsApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  void _selectCategory(String category) {
    setState(() {
      _category = category;
      _tab = 0;
      _searching = false;
      _searchController.clear();
    });
    _loadHeadlines();
  }

  void _toggleSaved(NewsArticle article) {
    if (_savedArticles.containsKey(article.url)) {
      _savedArticles.remove(article.url);
    } else {
      _savedArticles[article.url] = article;
    }
    setState(() {});
  }

  void _showArticle(NewsArticle article) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF171717),
      builder: (context) => NewsArticleDetails(
        article: article,
        saved: _savedArticles.containsKey(article.url),
        onSave: () => _toggleSaved(article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleArticles = _tab == 1
        ? _savedArticles.values.toList()
        : _articles;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.black,
          backgroundColor: Colors.white,
          onRefresh: _loadHeadlines,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    NewsTopBar(
                      controller: _searchController,
                      searching: _searching,
                      onSearch: _search,
                      onToggleSearch: _toggleSearch,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _tab == 1 ? 'Your reading list' : 'Good Morning',
                      style: const TextStyle(
                        fontSize: 15,
                        color: _muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _tab == 1 ? 'Saved Stories' : 'Here is Some News For You',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (_tab == 0) ...[
                      const SizedBox(height: 26),
                      NewsCategoryHeader(
                        onViewAll: () => _selectCategory('General'),
                      ),
                      const SizedBox(height: 14),
                      NewsCategories(
                        categories: _categories,
                        icons: _categoryIcons,
                        images: _categoryImages,
                        selectedCategory: _category,
                        onSelected: _selectCategory,
                      ),
                    ],
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _tab == 1 ? 'BOOKMARKS' : 'LATEST STORIES',
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: 1.8,
                              color: _muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_tab == 0)
                          Text(
                            _searchController.text.isEmpty
                                ? _category.toUpperCase()
                                : 'SEARCH RESULTS',
                            style: const TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.4,
                              color: _muted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ]),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NewsErrorPanel(
                    message: _error!,
                    onRetry: _loadHeadlines,
                  ),
                )
              else if (visibleArticles.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _tab == 1
                            ? 'Stories you save will appear here.'
                            : 'No stories found. Try another category.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _muted, fontSize: 15),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                  sliver: SliverList.separated(
                    itemCount: visibleArticles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final article = visibleArticles[index];
                      return NewsArticleCard(
                        article: article,
                        saved: _savedArticles.containsKey(article.url),
                        onSave: () => _toggleSaved(article),
                        onTap: () => _showArticle(article),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: _background,
        indicatorColor: Colors.white.withValues(alpha: 0.12),
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) _searchController.clear();
    });
    if (!_searching) _loadHeadlines();
  }
}
