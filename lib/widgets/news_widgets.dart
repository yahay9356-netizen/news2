import 'package:flutter/material.dart';

import '../news_api.dart';

const _surface = Color(0xFF171717);
const _muted = Color(0xFF9A9A9A);

class NewsTopBar extends StatelessWidget {
  const NewsTopBar({
    required this.controller,
    required this.searching,
    required this.onSearch,
    required this.onToggleSearch,
    super.key,
  });

  final TextEditingController controller;
  final bool searching;
  final ValueChanged<String> onSearch;
  final VoidCallback onToggleSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.newspaper_rounded,
            color: Colors.black,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'NEWS',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2.4),
        ),
        const Spacer(),
        if (searching)
          SizedBox(
            width: 170,
            child: TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: onSearch,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search news',
                hintStyle: const TextStyle(color: _muted, fontSize: 13),
                isDense: true,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  onPressed: () => onSearch(controller.text),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                ),
              ),
            ),
          ),
        IconButton(
          tooltip: 'Search',
          onPressed: onToggleSearch,
          icon: Icon(searching ? Icons.close_rounded : Icons.search_rounded),
        ),
      ],
    );
  }
}

class NewsCategoryHeader extends StatelessWidget {
  const NewsCategoryHeader({required this.onViewAll, super.key});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Explore Categories',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(foregroundColor: _muted),
          child: const Text('View all'),
        ),
      ],
    );
  }
}

class NewsCategories extends StatelessWidget {
  const NewsCategories({
    required this.categories,
    required this.icons,
    required this.images,
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  final List<String> categories;
  final Map<String, IconData> icons;
  final Map<String, String> images;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == selectedCategory;
          return GestureDetector(
            onTap: () => onSelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 165,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  SizedBox(
                    width: 68,
                    height: double.infinity,
                    child: Image.network(
                      images[category]!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: const Color(0xFFE6E6E6),
                        child: Icon(
                          icons[category],
                          color: Colors.black54,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 9,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(5, 4, 3, 4),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF171717)
                                  : const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'View All  ›',
                              maxLines: 1,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NewsArticleCard extends StatelessWidget {
  const NewsArticleCard({
    required this.article,
    required this.saved,
    required this.onSave,
    required this.onTap,
    super.key,
  });

  final NewsArticle article;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              Image.network(
                article.imageUrl!,
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const NewsImagePlaceholder(height: 190),
              )
            else
              const NewsImagePlaceholder(height: 190),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.source,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onSave,
                        icon: Icon(
                          saved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (article.description != null) ...[
                    const SizedBox(height: 7),
                    Text(
                      article.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    article.timeAgo,
                    style: const TextStyle(color: _muted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsImagePlaceholder extends StatelessWidget {
  const NewsImagePlaceholder({required this.height, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFF252525),
      child: const Icon(
        Icons.newspaper_rounded,
        color: Color(0xFF555555),
        size: 40,
      ),
    );
  }
}

class NewsErrorPanel extends StatelessWidget {
  const NewsErrorPanel({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 34, color: _muted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class NewsArticleDetails extends StatefulWidget {
  const NewsArticleDetails({
    required this.article,
    required this.saved,
    required this.onSave,
    super.key,
  });

  final NewsArticle article;
  final bool saved;
  final VoidCallback onSave;

  @override
  State<NewsArticleDetails> createState() => _NewsArticleDetailsState();
}

class _NewsArticleDetailsState extends State<NewsArticleDetails> {
  late bool _saved = widget.saved;

  @override
  void didUpdateWidget(covariant NewsArticleDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.saved != widget.saved) {
      _saved = widget.saved;
    }
  }

  void _toggleSaved() {
    widget.onSave();
    setState(() => _saved = !_saved);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.article.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.article.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const NewsImagePlaceholder(height: 220),
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                '${widget.article.source}  ·  ${widget.article.timeAgo}',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Text(
                widget.article.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (widget.article.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.article.description!,
                  style: const TextStyle(color: _muted, height: 1.5),
                ),
              ],
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _toggleSaved,
                icon: Icon(
                  _saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                label: Text(_saved ? 'Saved' : 'Save story'),
              ),
              if (widget.article.content != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.article.content!,
                  style: const TextStyle(height: 1.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
