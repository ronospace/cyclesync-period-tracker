import 'package:flutter/material.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';

class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRegion = 'All';

  final List<String> _regions = [
    'All',
    'Americas',
    'Europe',
    'Asia Pacific',
    'Middle East & Africa',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredLanguages(
    LocalizationService localizationService,
  ) {
    List<Map<String, dynamic>> languages =
        localizationService.availableLanguages;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      languages = languages.where((language) {
        final name = language['name'].toString().toLowerCase();
        final nativeName = language['nativeName'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || nativeName.contains(query);
      }).toList();
    }

    // Filter by region
    if (_selectedRegion != 'All') {
      languages = languages.where((language) {
        final locale = language['locale'] as Locale;
        return _getLanguageRegion(locale) == _selectedRegion;
      }).toList();
    }

    // Sort alphabetically by name
    languages.sort(
      (a, b) => a['name'].toString().compareTo(b['name'].toString()),
    );

    return languages;
  }

  String _getLanguageRegion(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
      case 'es':
      case 'pt':
        return locale.countryCode == 'BR' ||
                locale.countryCode == 'US' ||
                locale.countryCode == 'MX'
            ? 'Americas'
            : 'Europe';
      case 'fr':
      case 'de':
      case 'it':
      case 'ru':
      case 'pl':
      case 'nl':
      case 'sv':
      case 'no':
      case 'da':
      case 'fi':
      case 'cs':
      case 'hu':
      case 'ro':
      case 'uk':
        return 'Europe';
      case 'zh':
      case 'ja':
      case 'ko':
      case 'hi':
      case 'th':
      case 'vi':
      case 'id':
      case 'ms':
      case 'bn':
        return 'Asia Pacific';
      case 'ar':
      case 'tr':
      case 'he':
      case 'sw':
      case 'ur':
      case 'fa':
        return 'Middle East & Africa';
      default:
        return 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.instance;
    final filteredLanguages = _getFilteredLanguages(localizationService);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Language'),
        elevation: 0,
        backgroundColor: AppTheme.primaryPink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showLanguageHelp(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryPink,
                  AppTheme.primaryPink.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${LocalizationService.supportedLocales.length} Languages Available',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Global accessibility for everyone',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search languages...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Region filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _regions.map((region) {
                      final isSelected = region == _selectedRegion;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(region),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedRegion = region;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.primaryPink.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: AppTheme.primaryPink,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results count
          if (filteredLanguages.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${filteredLanguages.length} language${filteredLanguages.length != 1 ? 's' : ''} found',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),

          // Language list
          Expanded(
            child: filteredLanguages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredLanguages.length,
                    itemBuilder: (context, index) {
                      final language = filteredLanguages[index];
                      final locale = language['locale'] as Locale;
                      final isSelected = language['isSelected'] as bool;

                      return _buildLanguageItem(
                        context,
                        localizationService,
                        language,
                        locale,
                        isSelected,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context,
    LocalizationService localizationService,
    Map<String, dynamic> language,
    Locale locale,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: isSelected
            ? AppTheme.primaryPink.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await localizationService.setLocale(locale);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language changed to ${language['name']}'),
                  backgroundColor: AppTheme.primaryPink,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Flag
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      language['flag'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Language info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language['name'],
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 16,
                          color: isSelected
                              ? AppTheme.primaryPink
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        language['nativeName'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLanguageRegion(locale),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No languages found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedRegion = 'All';
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CycleSync supports 36 languages across different regions:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              Text('📍 Americas: English, Spanish, Portuguese'),
              SizedBox(height: 8),
              Text(
                '📍 Europe: German, French, Italian, Russian, Polish, Dutch, Swedish, Norwegian, Danish, Finnish, Czech, Hungarian, Romanian, Ukrainian',
              ),
              SizedBox(height: 8),
              Text(
                '📍 Asia Pacific: Chinese, Japanese, Korean, Hindi, Thai, Vietnamese, Indonesian, Malay, Bengali',
              ),
              SizedBox(height: 8),
              Text(
                '📍 Middle East & Africa: Arabic, Turkish, Hebrew, Swahili, Urdu, Persian',
              ),
              SizedBox(height: 16),
              Text(
                '🌐 The app automatically detects your system language if supported, or defaults to English.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
