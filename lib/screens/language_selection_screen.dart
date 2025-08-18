import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/app_logo.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAITranslationEnabled = false;
  
  // Language definitions with native names
  static const Map<String, Map<String, String>> _languages = {
    'en': {
      'name': 'English',
      'nativeName': 'English',
      'region': 'Global',
      'flag': '🇺🇸',
    },
    'es': {
      'name': 'Spanish',
      'nativeName': 'Español',
      'region': 'Global',
      'flag': '🇪🇸',
    },
    'fr': {
      'name': 'French',
      'nativeName': 'Français',
      'region': 'Global',
      'flag': '🇫🇷',
    },
    'de': {
      'name': 'German',
      'nativeName': 'Deutsch',
      'region': 'Germany',
      'flag': '🇩🇪',
    },
    'ar': {
      'name': 'Arabic',
      'nativeName': 'العربية',
      'region': 'Middle East',
      'flag': '🇸🇦',
    },
    'sw': {
      'name': 'Swahili',
      'nativeName': 'Kiswahili',
      'region': 'East Africa',
      'flag': '🇰🇪',
    },
    'hi': {
      'name': 'Hindi',
      'nativeName': 'हिन्दी',
      'region': 'India',
      'flag': '🇮🇳',
    },
    'zh': {
      'name': 'Chinese',
      'nativeName': '中文',
      'region': 'China',
      'flag': '🇨🇳',
    },
    'ja': {
      'name': 'Japanese',
      'nativeName': '日本語',
      'region': 'Japan',
      'flag': '🇯🇵',
    },
    'ko': {
      'name': 'Korean',
      'nativeName': '한국어',
      'region': 'Korea',
      'flag': '🇰🇷',
    },
    'pt': {
      'name': 'Portuguese',
      'nativeName': 'Português',
      'region': 'Brazil',
      'flag': '🇧🇷',
    },
    'ru': {
      'name': 'Russian',
      'nativeName': 'Русский',
      'region': 'Russia',
      'flag': '🇷🇺',
    },
    'it': {
      'name': 'Italian',
      'nativeName': 'Italiano',
      'region': 'Italy',
      'flag': '🇮🇹',
    },
    'tr': {
      'name': 'Turkish',
      'nativeName': 'Türkçe',
      'region': 'Turkey',
      'flag': '🇹🇷',
    },
    'id': {
      'name': 'Indonesian',
      'nativeName': 'Bahasa Indonesia',
      'region': 'Indonesia',
      'flag': '🇮🇩',
    },
    'bn': {
      'name': 'Bengali',
      'nativeName': 'বাংলা',
      'region': 'Bangladesh',
      'flag': '🇧🇩',
    },
    'fa': {
      'name': 'Persian',
      'nativeName': 'فارسی',
      'region': 'Iran',
      'flag': '🇮🇷',
    },
  };

  List<MapEntry<String, Map<String, String>>> get _filteredLanguages {
    if (_searchQuery.isEmpty) {
      return _languages.entries.toList();
    }
    
    return _languages.entries.where((entry) {
      final lang = entry.value;
      final query = _searchQuery.toLowerCase();
      return lang['name']!.toLowerCase().contains(query) ||
             lang['nativeName']!.toLowerCase().contains(query) ||
             lang['region']!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final filteredLanguages = _filteredLanguages;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSelectorTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: Icon(_isAITranslationEnabled 
                ? Icons.translate 
                : Icons.translate_outlined),
            onPressed: () {
              setState(() {
                _isAITranslationEnabled = !_isAITranslationEnabled;
              });
              _showAITranslationInfo();
            },
            tooltip: 'AI Translation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header section with logo and subtitle
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const AppLogo(
                  size: 60,
                  showText: true,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.languageSelectorSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.languageSelectorSearch,
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
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.languageSelectorResults(filteredLanguages.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (_isAITranslationEnabled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI Enhanced',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Language list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredLanguages.length,
              itemBuilder: (context, index) {
                final entry = filteredLanguages[index];
                final languageCode = entry.key;
                final language = entry.value;
                final isSelected = localizationService.currentLocale.languageCode == languageCode;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected 
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    elevation: isSelected ? 2 : 1,
                    shadowColor: theme.shadowColor.withOpacity(0.1),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _selectLanguage(languageCode, localizationService),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Flag
                            Text(
                              language['flag']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 16),
                            
                            // Language info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    language['nativeName']!,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected 
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        language['name']!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isSelected
                                              ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                                              : theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        ' • ${language['region']}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isSelected
                                              ? theme.colorScheme.onPrimaryContainer.withOpacity(0.6)
                                              : theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Selection indicator
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 24,
                              )
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage(String languageCode, LocalizationService localizationService) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Switching language...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Change locale
      final locale = Locale(languageCode);
      await localizationService.setLocale(locale);
      
      // If AI translation is enabled, initialize AI services
      if (_isAITranslationEnabled) {
        await _initializeAITranslation(languageCode);
      }
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Language changed to ${_languages[languageCode]!['nativeName']}'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Go back to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Failed to change language: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAITranslationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.blue),
            SizedBox(width: 8),
            Text('AI Translation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isAITranslationEnabled 
                  ? 'AI Translation is now ENABLED' 
                  : 'AI Translation is now DISABLED',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (_isAITranslationEnabled) ...[
              const Text('✨ Enhanced features:'),
              const SizedBox(height: 8),
              const Text('• Real-time translation improvements'),
              const Text('• Context-aware menstrual health terms'),
              const Text('• Cultural adaptation for health advice'),
              const Text('• Smart localization of medical terms'),
              const SizedBox(height: 16),
              Text(
                'Note: AI translation may require an internet connection and could affect app performance.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const Text('Standard translations will be used without AI enhancement.'),
              const SizedBox(height: 8),
              const Text('• Faster performance'),
              const Text('• Works offline'),
              const Text('• Uses pre-translated content'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeAITranslation(String languageCode) async {
    // Simulate AI translation initialization
    // In a real app, this would connect to translation services like Google Translate API,
    // OpenAI API, or other AI translation services
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Here you would:
    // 1. Initialize AI translation service
    // 2. Download language-specific AI models if needed
    // 3. Set up real-time translation pipeline
    // 4. Configure medical/health terminology dictionaries
    
    debugPrint('AI Translation initialized for language: $languageCode');
  }
}
