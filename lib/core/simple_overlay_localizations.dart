import 'package:flutter/widgets.dart';

/// Localizations for simple_logger_overlay.
///
/// Add [SimpleOverlayLocalizations.delegate] to your app's
/// [localizationsDelegates] to enable the overlay to pick up your app's
/// locale. Override individual getters in a subclass to provide translations.
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: [
///     SimpleOverlayLocalizations.delegate,
///     GlobalMaterialLocalizations.delegate,
///   ],
/// )
/// ```
///
/// To provide translated strings, extend this class:
///
/// ```dart
/// class MyLocalization extends SimpleOverlayLocalizations {
///   @override
///   String get title => AppLocalizations.of(context)!.loggerTitle;
/// }
/// ```
class SimpleOverlayLocalizations {
  const SimpleOverlayLocalizations();

  static SimpleOverlayLocalizations of(BuildContext context) {
    return Localizations.of<SimpleOverlayLocalizations>(
          context,
          SimpleOverlayLocalizations,
        ) ??
        const SimpleOverlayLocalizations();
  }

  static const LocalizationsDelegate<SimpleOverlayLocalizations> delegate =
      _SimpleOverlayLocalizationsDelegate();

  // — Overlay screen —
  String get title => 'Logger';
  String entriesCount(int count) => '$count entries';
  String get exportTooltip => 'Export logs';

  // — Tabs —
  String logsTab(int count) => 'Logs ($count)';
  String networkTab(int count) => 'Network ($count)';

  // — Search bar —
  String get searchHint => 'Search logs...';
  String get sortNewest => 'Newest first';
  String get sortOldest => 'Oldest first';

  // — Empty states —
  String get noLogsTitle => 'No logs yet';
  String get noLogsSubtitle => 'Logs will appear here as your app runs.';
  String get noNetworkTitle => 'No network logs';
  String get noNetworkSubtitle =>
      'Network requests via Dio will appear here.';
  String get noResultsTitle => 'No results';
  String noResultsSubtitle(String query) => 'No logs match "$query".';
  String noNetworkResultsSubtitle(String query) =>
      'No network logs match "$query".';

  // — Detail page —
  String get logDetailTitle => 'Log Detail';
  String get networkLogDetailTitle => 'Network Log Detail';
  String get copyTooltip => 'Copy log';
  String get copiedMessage => 'Log copied to clipboard';

  // — Detail labels —
  String get labelTag => 'Tag';
  String get labelLevel => 'Level';
  String get labelTimestamp => 'Timestamp';
  String get labelMessage => 'Message';
  String get labelUrl => 'URL';
  String get labelRequestHeaders => 'Request Headers';
  String get labelRequestBody => 'Request Body';
  String get labelResponseHeaders => 'Response Headers';
  String get labelResponseBody => 'Response Body';
}

class _SimpleOverlayLocalizationsDelegate
    extends LocalizationsDelegate<SimpleOverlayLocalizations> {
  const _SimpleOverlayLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<SimpleOverlayLocalizations> load(Locale locale) =>
      Future.value(const SimpleOverlayLocalizations());

  @override
  bool shouldReload(_SimpleOverlayLocalizationsDelegate old) => true;
}
