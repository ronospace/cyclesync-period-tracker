import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
class BannerAdContainer extends StatefulWidget {
  final String? adUnitId; // if null, use test ID
  const BannerAdContainer({super.key, this.adUnitId});

  @override
  State<BannerAdContainer> createState() => _BannerAdContainerState();
}

class _BannerAdContainerState extends State<BannerAdContainer>
    with SingleTickerProviderStateMixin {
  BannerAd? _banner;
  bool _loaded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _hasError = false;

  static const String _testAdUnitId = "ca-app-pub-3940256099942544/6300978111"; // Google test banner

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadAd();
  }
  
  void _loadAd() {
    try {
      _banner = BannerAd(
        size: AdSize.banner,
        adUnitId: widget.adUnitId ?? _testAdUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              HapticFeedback.lightImpact();
              setState(() => _loaded = true);
              _animationController.forward();
            }
          },
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
            if (mounted) {
              setState(() {
                _hasError = true;
                _loaded = false;
              });
            }
            debugPrint('Banner failed to load: $err');
          },
          onAdClicked: (ad) {
            HapticFeedback.mediumImpact();
          },
        ),
        request: const AdRequest(),
      )..load();
    } catch (e) {
      debugPrint('Error initializing banner ad: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _loaded = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _banner?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || (!_loaded || _banner == null)) {
      return const SizedBox.shrink();
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: _banner!.size.width.toDouble(),
            height: _banner!.size.height.toDouble(),
            child: AdWidget(ad: _banner!),
          ),
        ),
      ),
    );
  }
}
