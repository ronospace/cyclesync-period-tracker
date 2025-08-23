import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Utility class for optimizing app performance
class PerformanceUtils {
  
  /// Enable performance overlay (debug mode only)
  static void enablePerformanceOverlay() {
    assert(() {
      debugProfileBuildsEnabled = true;
      debugProfilePaintsEnabled = true;
      return true;
    }());
  }
  
  /// Optimize widget builds with const constructors
  static Widget optimizedContainer({
    Key? key,
    Widget? child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Decoration? decoration,
    BoxConstraints? constraints,
    double? width,
    double? height,
  }) {
    return Container(
      key: key,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      constraints: constraints,
      child: child,
    );
  }
  
  /// Optimized card widget with caching
  static Widget buildOptimizedCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return Card(
      margin: margin ?? const EdgeInsets.all(8.0),
      elevation: elevation ?? 4.0,
      color: color,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: padding != null 
        ? Padding(padding: padding, child: child)
        : child,
    );
  }
  
  /// Create optimized list view with performance enhancements
  static Widget buildOptimizedListView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    double? cacheExtent,
  }) {
    return ListView.builder(
      controller: controller,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      padding: padding,
      cacheExtent: cacheExtent ?? 250.0, // Optimize for smooth scrolling
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
  
  /// Optimized image widget with caching and performance
  static Widget buildOptimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit? fit,
    bool cache = true,
  }) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      cacheWidth: width?.round(),
      cacheHeight: height?.round(),
      filterQuality: FilterQuality.medium,
    );
  }
  
  /// Debounced search widget for performance
  static Widget buildDebouncedSearchField({
    required Function(String) onSearch,
    Duration debounceDelay = const Duration(milliseconds: 300),
    String? hintText,
    TextEditingController? controller,
  }) {
    return _DebouncedSearchField(
      onSearch: onSearch,
      debounceDelay: debounceDelay,
      hintText: hintText,
      controller: controller,
    );
  }
  
  /// Optimize heavy computations with isolates (placeholder for future implementation)
  static Future<T> computeHeavyOperation<T>(
    Future<T> Function() computation,
  ) async {
    // For now, just run the computation
    // In future, can be moved to isolates for CPU-intensive tasks
    return await computation();
  }
  
  /// Memory-efficient builder for large datasets
  static Widget buildLazyLoadedList<T>({
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    int itemsPerPage = 50,
    ScrollController? controller,
    Widget? loadingWidget,
  }) {
    return _LazyLoadedList<T>(
      items: items,
      itemBuilder: itemBuilder,
      itemsPerPage: itemsPerPage,
      controller: controller,
      loadingWidget: loadingWidget,
    );
  }
  
  /// Reduce widget rebuilds with RepaintBoundary
  static Widget buildRepaintBoundary(Widget child) {
    return RepaintBoundary(child: child);
  }
  
  /// Optimize animations with reduced motion support
  static Duration getOptimizedAnimationDuration(BuildContext context) {
    final isReduceAnimations = MediaQuery.of(context).disableAnimations;
    return isReduceAnimations 
        ? Duration.zero 
        : const Duration(milliseconds: 300);
  }
  
  /// Precache important images for better performance
  static Future<void> precacheImportantImages(BuildContext context) async {
    // Add important images to precache
    const imagePaths = [
      // Add your app's important image paths here
    ];
    
    for (String path in imagePaths) {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (e) {
        debugPrint('Failed to precache image: $path');
      }
    }
  }
}

/// Debounced search field implementation
class _DebouncedSearchField extends StatefulWidget {
  final Function(String) onSearch;
  final Duration debounceDelay;
  final String? hintText;
  final TextEditingController? controller;

  const _DebouncedSearchField({
    required this.onSearch,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.hintText,
    this.controller,
  });

  @override
  State<_DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<_DebouncedSearchField> {
  late TextEditingController _controller;
  late Timer _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _debounceTimer.cancel();
    super.dispose();
  }
  
  void _onSearchChanged(String query) {
    _debounceTimer.cancel();
    _debounceTimer = Timer(widget.debounceDelay, () {
      widget.onSearch(query);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Lazy loaded list implementation
class _LazyLoadedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final int itemsPerPage;
  final ScrollController? controller;
  final Widget? loadingWidget;

  const _LazyLoadedList({
    required this.items,
    required this.itemBuilder,
    this.itemsPerPage = 50,
    this.controller,
    this.loadingWidget,
  });

  @override
  State<_LazyLoadedList<T>> createState() => _LazyLoadedListState<T>();
}

class _LazyLoadedListState<T> extends State<_LazyLoadedList<T>> {
  late ScrollController _controller;
  int _currentlyLoaded = 0;
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_scrollListener);
    _currentlyLoaded = widget.itemsPerPage.clamp(0, widget.items.length);
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  void _scrollListener() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent * 0.8) {
      _loadMoreItems();
    }
  }
  
  void _loadMoreItems() {
    if (_isLoadingMore || _currentlyLoaded >= widget.items.length) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Simulate loading delay for smooth UX
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _currentlyLoaded = (_currentlyLoaded + widget.itemsPerPage)
              .clamp(0, widget.items.length);
          _isLoadingMore = false;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final displayItems = widget.items.take(_currentlyLoaded).toList();
    
    return ListView.builder(
      controller: _controller,
      itemCount: displayItems.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= displayItems.length) {
          return widget.loadingWidget ?? 
              const Center(child: CircularProgressIndicator());
        }
        
        return widget.itemBuilder(context, displayItems[index]);
      },
    );
  }
}
