import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Utility class for enhancing app accessibility
class AccessibilityUtils {
  
  /// Build accessible button with proper semantics
  static Widget buildAccessibleButton({
    required VoidCallback onPressed,
    required Widget child,
    String? semanticLabel,
    String? tooltip,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      excludeSemantics: excludeSemantics,
      child: Tooltip(
        message: tooltip ?? '',
        child: ElevatedButton(
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
  
  /// Build accessible icon button
  static Widget buildAccessibleIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String semanticLabel,
    String? tooltip,
    Color? color,
    double size = 24.0,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color, size: size),
          tooltip: tooltip ?? semanticLabel,
        ),
      ),
    );
  }
  
  /// Build accessible text field with proper labels
  static Widget buildAccessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? semanticLabel,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool autofocus = false,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      textField: true,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        autofocus: autofocus,
      ),
    );
  }
  
  /// Build accessible card with semantic information
  static Widget buildAccessibleCard({
    required Widget child,
    String? semanticLabel,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double elevation = 4.0,
  }) {
    final cardChild = Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: child,
    );
    
    if (onTap != null) {
      return Semantics(
        label: semanticLabel,
        button: true,
        child: Card(
          margin: margin ?? const EdgeInsets.all(8.0),
          elevation: elevation,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: cardChild,
          ),
        ),
      );
    }
    
    return Semantics(
      label: semanticLabel,
      child: Card(
        margin: margin ?? const EdgeInsets.all(8.0),
        elevation: elevation,
        child: cardChild,
      ),
    );
  }
  
  /// Build accessible list item
  static Widget buildAccessibleListItem({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
    bool selected = false,
  }) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      selected: selected,
      child: ListTile(
        onTap: onTap,
        selected: selected,
        child: child,
      ),
    );
  }
  
  /// Build accessible checkbox
  static Widget buildAccessibleCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      checked: value,
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
  
  /// Build accessible radio button
  static Widget buildAccessibleRadio<T>({
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
    required String label,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      inMutuallyExclusiveGroup: true,
      checked: value == groupValue,
      child: RadioListTile<T>(
        title: Text(label),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }
  
  /// Build accessible switch
  static Widget buildAccessibleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      toggled: value,
      child: SwitchListTile(
        title: Text(label),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
  
  /// Build accessible slider
  static Widget buildAccessibleSlider({
    required double value,
    required ValueChanged<double> onChanged,
    required String label,
    double min = 0.0,
    double max = 100.0,
    int? divisions,
    String? semanticLabel,
    String Function(double)? semanticFormatterCallback,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      value: semanticFormatterCallback?.call(value) ?? value.toString(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: divisions,
            label: semanticFormatterCallback?.call(value) ?? value.toString(),
          ),
        ],
      ),
    );
  }
  
  /// Build accessible progress indicator
  static Widget buildAccessibleProgressIndicator({
    double? value,
    String? semanticLabel,
    Color? color,
    String? progressText,
  }) {
    final progressValue = value != null ? (value * 100).round() : null;
    final accessibilityLabel = semanticLabel ?? 
        (progressValue != null ? 'Progress: $progressValue%' : 'Loading');
    
    return Semantics(
      label: accessibilityLabel,
      value: progressText ?? (progressValue != null ? '$progressValue%' : null),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: value,
            color: color,
          ),
          if (progressText != null) ...[
            const SizedBox(height: 8),
            Text(progressText, style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }
  
  /// Build accessible tab bar
  static Widget buildAccessibleTabBar({
    required TabController controller,
    required List<Tab> tabs,
    List<String>? semanticLabels,
  }) {
    return Semantics(
      container: true,
      child: TabBar(
        controller: controller,
        tabs: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final semanticLabel = semanticLabels != null && 
              index < semanticLabels.length 
              ? semanticLabels[index] 
              : null;
          
          return Semantics(
            label: semanticLabel,
            selected: controller.index == index,
            button: true,
            child: tab,
          );
        }).toList(),
      ),
    );
  }
  
  /// Announce message to screen readers
  static void announceMessage(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
  
  /// Check if reduce motion is enabled
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
  
  /// Get accessible animation duration
  static Duration getAccessibleAnimationDuration(BuildContext context) {
    return isReduceMotionEnabled(context) 
        ? Duration.zero 
        : const Duration(milliseconds: 300);
  }
  
  /// Build accessible floating action button
  static Widget buildAccessibleFAB({
    required VoidCallback onPressed,
    required Widget child,
    required String semanticLabel,
    String? tooltip,
    bool mini = false,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip ?? semanticLabel,
        mini: mini,
        child: child,
      ),
    );
  }
  
  /// Build accessible bottom navigation bar
  static Widget buildAccessibleBottomNav({
    required int currentIndex,
    required ValueChanged<int> onTap,
    required List<BottomNavigationBarItem> items,
    List<String>? semanticLabels,
  }) {
    return Semantics(
      container: true,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        items: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final semanticLabel = semanticLabels != null && 
              index < semanticLabels.length 
              ? semanticLabels[index] 
              : null;
          
          return BottomNavigationBarItem(
            icon: Semantics(
              label: semanticLabel,
              selected: currentIndex == index,
              button: true,
              child: item.icon,
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}
