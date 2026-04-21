import 'package:flutter/widgets.dart';
import 'package:simple_logger_overlay/simple_logger_overlay.dart';

/// Locale-aware delegate for [SimpleOverlayLocalizations].
///
/// Register this in your app instead of [SimpleOverlayLocalizations.delegate]
/// to get translated overlay strings.
class ExampleOverlayLocalizationsDelegate
    extends LocalizationsDelegate<SimpleOverlayLocalizations> {
  const ExampleOverlayLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<SimpleOverlayLocalizations> load(Locale locale) {
    return Future.value(_forLocale(locale));
  }

  @override
  bool shouldReload(ExampleOverlayLocalizationsDelegate old) => true;

  static SimpleOverlayLocalizations _forLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return const _EsOverlayL10n();
      case 'fr':
        return const _FrOverlayL10n();
      case 'ar':
        return const _ArOverlayL10n();
      case 'de':
        return const _DeOverlayL10n();
      case 'ja':
        return const _JaOverlayL10n();
      default:
        return const SimpleOverlayLocalizations();
    }
  }
}

// ---------------------------------------------------------------------------
// Spanish
// ---------------------------------------------------------------------------

class _EsOverlayL10n extends SimpleOverlayLocalizations {
  const _EsOverlayL10n();

  @override
  String get title => 'Registros';
  @override
  String entriesCount(int n) => '$n entradas';
  @override
  String get exportTooltip => 'Exportar registros';
  @override
  String logsTab(int n) => 'Registros ($n)';
  @override
  String networkTab(int n) => 'Red ($n)';
  @override
  String get searchHint => 'Buscar registros...';
  @override
  String get sortNewest => 'Más reciente primero';
  @override
  String get sortOldest => 'Más antiguo primero';
  @override
  String get noLogsTitle => 'Sin registros';
  @override
  String get noLogsSubtitle => 'Los registros aparecerán aquí.';
  @override
  String get noNetworkTitle => 'Sin registros de red';
  @override
  String get noNetworkSubtitle => 'Las solicitudes Dio aparecerán aquí.';
  @override
  String get noResultsTitle => 'Sin resultados';
  @override
  String noResultsSubtitle(String q) => 'Ningún registro coincide con "$q".';
  @override
  String noNetworkResultsSubtitle(String q) =>
      'Ninguna solicitud coincide con "$q".';
  @override
  String get logDetailTitle => 'Detalle del registro';
  @override
  String get networkLogDetailTitle => 'Detalle de red';
  @override
  String get copyTooltip => 'Copiar registro';
  @override
  String get copiedMessage => 'Registro copiado';
  @override
  String get labelTag => 'Etiqueta';
  @override
  String get labelLevel => 'Nivel';
  @override
  String get labelTimestamp => 'Marca de tiempo';
  @override
  String get labelMessage => 'Mensaje';
  @override
  String get labelUrl => 'URL';
  @override
  String get labelRequestHeaders => 'Cabeceras de solicitud';
  @override
  String get labelRequestBody => 'Cuerpo de solicitud';
  @override
  String get labelResponseHeaders => 'Cabeceras de respuesta';
  @override
  String get labelResponseBody => 'Cuerpo de respuesta';
}

// ---------------------------------------------------------------------------
// French
// ---------------------------------------------------------------------------

class _FrOverlayL10n extends SimpleOverlayLocalizations {
  const _FrOverlayL10n();

  @override
  String get title => 'Journal';
  @override
  String entriesCount(int n) => '$n entrées';
  @override
  String get exportTooltip => 'Exporter les journaux';
  @override
  String logsTab(int n) => 'Journaux ($n)';
  @override
  String networkTab(int n) => 'Réseau ($n)';
  @override
  String get searchHint => 'Rechercher...';
  @override
  String get sortNewest => 'Plus récent en premier';
  @override
  String get sortOldest => 'Plus ancien en premier';
  @override
  String get noLogsTitle => 'Aucun journal';
  @override
  String get noLogsSubtitle => 'Les journaux apparaîtront ici.';
  @override
  String get noNetworkTitle => 'Aucune requête réseau';
  @override
  String get noNetworkSubtitle => 'Les requêtes Dio apparaîtront ici.';
  @override
  String get noResultsTitle => 'Aucun résultat';
  @override
  String noResultsSubtitle(String q) => 'Aucun journal ne correspond à "$q".';
  @override
  String noNetworkResultsSubtitle(String q) =>
      'Aucune requête ne correspond à "$q".';
  @override
  String get logDetailTitle => 'Détail du journal';
  @override
  String get networkLogDetailTitle => 'Détail réseau';
  @override
  String get copyTooltip => 'Copier le journal';
  @override
  String get copiedMessage => 'Journal copié';
  @override
  String get labelTag => 'Étiquette';
  @override
  String get labelLevel => 'Niveau';
  @override
  String get labelTimestamp => 'Horodatage';
  @override
  String get labelMessage => 'Message';
  @override
  String get labelUrl => 'URL';
  @override
  String get labelRequestHeaders => 'En-têtes de requête';
  @override
  String get labelRequestBody => 'Corps de requête';
  @override
  String get labelResponseHeaders => 'En-têtes de réponse';
  @override
  String get labelResponseBody => 'Corps de réponse';
}

// ---------------------------------------------------------------------------
// Arabic
// ---------------------------------------------------------------------------

class _ArOverlayL10n extends SimpleOverlayLocalizations {
  const _ArOverlayL10n();

  @override
  String get title => 'السجلات';
  @override
  String entriesCount(int n) => '$n إدخالات';
  @override
  String get exportTooltip => 'تصدير السجلات';
  @override
  String logsTab(int n) => 'السجلات ($n)';
  @override
  String networkTab(int n) => 'الشبكة ($n)';
  @override
  String get searchHint => 'بحث في السجلات...';
  @override
  String get sortNewest => 'الأحدث أولاً';
  @override
  String get sortOldest => 'الأقدم أولاً';
  @override
  String get noLogsTitle => 'لا توجد سجلات';
  @override
  String get noLogsSubtitle => 'ستظهر السجلات هنا.';
  @override
  String get noNetworkTitle => 'لا توجد سجلات شبكة';
  @override
  String get noNetworkSubtitle => 'طلبات Dio ستظهر هنا.';
  @override
  String get noResultsTitle => 'لا توجد نتائج';
  @override
  String noResultsSubtitle(String q) => 'لا توجد سجلات تطابق "$q".';
  @override
  String noNetworkResultsSubtitle(String q) => 'لا توجد سجلات شبكة تطابق "$q".';
  @override
  String get logDetailTitle => 'تفاصيل السجل';
  @override
  String get networkLogDetailTitle => 'تفاصيل الشبكة';
  @override
  String get copyTooltip => 'نسخ السجل';
  @override
  String get copiedMessage => 'تم النسخ';
  @override
  String get labelTag => 'وسم';
  @override
  String get labelLevel => 'المستوى';
  @override
  String get labelTimestamp => 'الطابع الزمني';
  @override
  String get labelMessage => 'الرسالة';
  @override
  String get labelUrl => 'الرابط';
  @override
  String get labelRequestHeaders => 'رؤوس الطلب';
  @override
  String get labelRequestBody => 'نص الطلب';
  @override
  String get labelResponseHeaders => 'رؤوس الاستجابة';
  @override
  String get labelResponseBody => 'نص الاستجابة';
}

// ---------------------------------------------------------------------------
// German
// ---------------------------------------------------------------------------

class _DeOverlayL10n extends SimpleOverlayLocalizations {
  const _DeOverlayL10n();

  @override
  String get title => 'Protokoll';
  @override
  String entriesCount(int n) => '$n Einträge';
  @override
  String get exportTooltip => 'Protokolle exportieren';
  @override
  String logsTab(int n) => 'Protokolle ($n)';
  @override
  String networkTab(int n) => 'Netzwerk ($n)';
  @override
  String get searchHint => 'Protokolle suchen...';
  @override
  String get sortNewest => 'Neueste zuerst';
  @override
  String get sortOldest => 'Älteste zuerst';
  @override
  String get noLogsTitle => 'Keine Protokolle';
  @override
  String get noLogsSubtitle => 'Protokolle werden hier angezeigt.';
  @override
  String get noNetworkTitle => 'Keine Netzwerkprotokolle';
  @override
  String get noNetworkSubtitle => 'Dio-Anfragen werden hier angezeigt.';
  @override
  String get noResultsTitle => 'Keine Ergebnisse';
  @override
  String noResultsSubtitle(String q) => 'Keine Protokolle für "$q".';
  @override
  String noNetworkResultsSubtitle(String q) =>
      'Keine Netzwerkprotokolle für "$q".';
  @override
  String get logDetailTitle => 'Protokolldetails';
  @override
  String get networkLogDetailTitle => 'Netzwerkdetails';
  @override
  String get copyTooltip => 'Protokoll kopieren';
  @override
  String get copiedMessage => 'Kopiert';
  @override
  String get labelTag => 'Tag';
  @override
  String get labelLevel => 'Ebene';
  @override
  String get labelTimestamp => 'Zeitstempel';
  @override
  String get labelMessage => 'Nachricht';
  @override
  String get labelUrl => 'URL';
  @override
  String get labelRequestHeaders => 'Anfrage-Header';
  @override
  String get labelRequestBody => 'Anfrage-Body';
  @override
  String get labelResponseHeaders => 'Antwort-Header';
  @override
  String get labelResponseBody => 'Antwort-Body';
}

// ---------------------------------------------------------------------------
// Japanese
// ---------------------------------------------------------------------------

class _JaOverlayL10n extends SimpleOverlayLocalizations {
  const _JaOverlayL10n();

  @override
  String get title => 'ログ';
  @override
  String entriesCount(int n) => '$n 件';
  @override
  String get exportTooltip => 'ログをエクスポート';
  @override
  String logsTab(int n) => 'ログ ($n)';
  @override
  String networkTab(int n) => 'ネットワーク ($n)';
  @override
  String get searchHint => 'ログを検索...';
  @override
  String get sortNewest => '新しい順';
  @override
  String get sortOldest => '古い順';
  @override
  String get noLogsTitle => 'ログなし';
  @override
  String get noLogsSubtitle => 'ログはここに表示されます。';
  @override
  String get noNetworkTitle => 'ネットワークログなし';
  @override
  String get noNetworkSubtitle => 'Dioのリクエストはここに表示されます。';
  @override
  String get noResultsTitle => '結果なし';
  @override
  String noResultsSubtitle(String q) => '"$q" に一致するログはありません。';
  @override
  String noNetworkResultsSubtitle(String q) => '"$q" に一致するネットワークログはありません。';
  @override
  String get logDetailTitle => 'ログ詳細';
  @override
  String get networkLogDetailTitle => 'ネットワーク詳細';
  @override
  String get copyTooltip => 'ログをコピー';
  @override
  String get copiedMessage => 'コピーしました';
  @override
  String get labelTag => 'タグ';
  @override
  String get labelLevel => 'レベル';
  @override
  String get labelTimestamp => 'タイムスタンプ';
  @override
  String get labelMessage => 'メッセージ';
  @override
  String get labelUrl => 'URL';
  @override
  String get labelRequestHeaders => 'リクエストヘッダー';
  @override
  String get labelRequestBody => 'リクエストボディ';
  @override
  String get labelResponseHeaders => 'レスポンスヘッダー';
  @override
  String get labelResponseBody => 'レスポンスボディ';
}
