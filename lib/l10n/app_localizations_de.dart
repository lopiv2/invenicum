// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get aboutInvenicum => 'Über Invenicum';

  @override
  String get active => 'Aktiv';

  @override
  String get actives => 'Actives';

  @override
  String get activeInsight => 'ACTIVE ASSETS INSIGHTS';

  @override
  String get activeLoans => 'Aktive Darlehen';

  @override
  String get activeLoansCount => 'Aktive Darlehen';

  @override
  String get addAlert => 'Benachrichtigung hinzufügen';

  @override
  String get addAsset => 'Anlage hinzufügen';

  @override
  String get addContainer => 'Behälter hinzufügen';

  @override
  String get addNewLocation => 'Neuen Standort hinzufügen';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get additionalThumbnails => 'Zusätzliche Miniaturansichten';

  @override
  String get adquisition => 'ADQUISITION';

  @override
  String aiExtractionError(String error) {
    return 'Die KI konnte keine Daten extrahieren: $error';
  }

  @override
  String get aiPasteUrlDescription =>
      'Fügen Sie den Produktlink ein und die KI extrahiert automatisch die Informationen zum Ausfüllen der Felder.';

  @override
  String get alertCritical => 'Kritisch';

  @override
  String get alertCreated => 'Benachrichtigung erstellt';

  @override
  String get alertDeleted => 'Benachrichtigung gelöscht';

  @override
  String get alertInfo => 'Information';

  @override
  String get alertMessage => 'Nachricht';

  @override
  String get alertTitle => 'Titel';

  @override
  String get alertType => 'Typ';

  @override
  String get alertWarning => 'Warnung';

  @override
  String get alerts => 'Benachrichtigungen';

  @override
  String get all => 'Alle';

  @override
  String get allUpToDateStatus => 'All up to date';

  @override
  String get appTitle => 'Invenicum Inventar';

  @override
  String get applicationTheme => 'Anwendungsthema';

  @override
  String get apply => 'Anwenden';

  @override
  String get april => 'April';

  @override
  String get assetDetail => 'Asset Details';

  @override
  String get assetImages => 'Anlagenbilder';

  @override
  String get assetImport => 'Anlagenimport';

  @override
  String get assetName => 'Anlagenname';

  @override
  String get assetNotFound => 'Asset not found';

  @override
  String assetTypeDeleted(String name) {
    return 'Anlagentyp \"$name\" erfolgreich gelöscht.';
  }

  @override
  String get assetTypes => 'Anlagentypen';

  @override
  String assetUpdated(String name) {
    return 'Anlage \"$name\" erfolgreich aktualisiert.';
  }

  @override
  String get assets => 'Anlagen';

  @override
  String get assetsIn => 'Anlagen in';

  @override
  String get august => 'August';

  @override
  String get backToAssetTypes => 'Zurück zu Anlagentypen';

  @override
  String get averageMarketValue => 'Average market price';

  @override
  String get barCode => 'Barcode (UPC)';

  @override
  String get baseCostAccumulatedWithoutInflation =>
      'Base cost accumulated without inflation';

  @override
  String get borrowerEmail => 'E-Mail des Kreditnehmers';

  @override
  String get borrowerName => 'Name des Kreditnehmers';

  @override
  String get borrowerPhone => 'Telefon des Kreditnehmers';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get centerView => 'Mittelansicht';

  @override
  String get chooseFile => 'Datei wählen';

  @override
  String get clearCounter => 'Zähler löschen';

  @override
  String get collectionContainerInfo =>
      'Sammlungsbehälter haben Sammlungs-Tracking-Balken, investierten Wert, Marktwert und Expositionsansicht';

  @override
  String get collectionFieldsConfigured => 'Sammlungsfelder konfiguriert.';

  @override
  String get condition => 'Condition';

  @override
  String get condition_mint => 'Mint (Original box)';

  @override
  String get condition_loose => 'Loose (No box)';

  @override
  String get condition_incomplete => 'Incomplete';

  @override
  String get condition_damaged => 'Damaged';

  @override
  String get condition_new => 'New';

  @override
  String get condition_digital => 'Digital';

  @override
  String get configureCollectionFields => 'Sammlungsfelder konfigurieren';

  @override
  String get configureDeliveryVoucher => 'Lieferschein konfigurieren';

  @override
  String get configureVoucherBody => 'Lieferscheinkörper konfigurieren...';

  @override
  String get confirmDeleteAlert => 'Benachrichtigung löschen';

  @override
  String get confirmDeleteAlertMessage =>
      'Sind Sie sicher, dass Sie diesen Datensatz löschen möchten?';

  @override
  String confirmDeleteAssetType(String name) {
    return 'Sind Sie sicher, dass Sie den Anlagentyp \"$name\" und alle zugehörigen Elemente löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String confirmDeleteContainer(String name) {
    return 'Sind Sie sicher, dass Sie den Behälter \"$name\" löschen möchten? Diese Aktion ist unwiderruflich und entfernt alle Anlagen und Daten.';
  }

  @override
  String confirmDeleteLocationMessage(String name) {
    return 'Sind Sie sicher, dass Sie den Standort \"$name\" löschen möchten?';
  }

  @override
  String get confirmDeletion => 'Löschung bestätigen';

  @override
  String get configurationSaved => 'Konfiguration erfolgreich gespeichert.';

  @override
  String containerCreated(String name) {
    return 'Behälter \"$name\" erfolgreich erstellt.';
  }

  @override
  String containerDeleted(String name) {
    return 'Behälter \"$name\" erfolgreich gelöscht.';
  }

  @override
  String get containerName => 'Behältername';

  @override
  String get containerOrAssetTypeNotFound =>
      'Behälter oder Anlagentyp nicht gefunden.';

  @override
  String containerRenamed(String name) {
    return 'Behälter in \"$name\" umbenannt.';
  }

  @override
  String get containers => 'Behälter';

  @override
  String get countItemsByValue => 'Elemente nach bestimmtem Wert zählen';

  @override
  String get create => 'Erstellen';

  @override
  String get createFirstContainer => 'Erstellen Sie Ihren ersten Behälter.';

  @override
  String get createdAt => 'Creation Date';

  @override
  String get currency => 'Currency';

  @override
  String get current => 'Aktuell';

  @override
  String get customColor => 'Benutzerdefinierte Farbe';

  @override
  String get customFields => 'Benutzerdefinierte Felder';

  @override
  String customFieldsOf(String name) {
    return 'Benutzerdefinierte Felder von $name';
  }

  @override
  String get customizeDeliveryVoucher =>
      'Passen Sie die PDF-Vorlage für Darlehen an';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get datalists => 'Benutzerdefinierte Listen';

  @override
  String get december => 'Dezember';

  @override
  String get definitionCustomFields => 'Benutzerdefinierte Felderdefinition';

  @override
  String get delete => 'Löschen';

  @override
  String deleteError(String error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get deleteSuccess => 'Standort erfolgreich gelöscht.';

  @override
  String get deliveryVoucher => 'LIEFERSCHEIN';

  @override
  String get deliveryVoucherEditor => 'Lieferschein-Editor';

  @override
  String get description => 'Beschreibung (optional)';

  @override
  String get desiredField => 'Gewünschtes Feld';

  @override
  String get dueDate => 'Fälligkeitsdatum';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get enterContainerName => 'Geben Sie den Behälternamen ein';

  @override
  String get enterDescription => 'Geben Sie eine Beschreibung ein';

  @override
  String get enterURL => 'URL eingeben';

  @override
  String get enterValidUrl => 'Geben Sie eine gültige URL ein';

  @override
  String errorChangingLanguage(String error) {
    return 'Fehler beim Sprachwechsel: $error';
  }

  @override
  String get errorCsvMinRows =>
      'Wählen Sie eine CSV-Datei mit Überschriften und mindestens einer Datenzeile.';

  @override
  String errorDeletingAssetType(String error) {
    return 'Fehler beim Löschen des Anlagentyps: $error';
  }

  @override
  String errorDeletingContainer(String error) {
    return 'Fehler beim Löschen des Behälters: $error';
  }

  @override
  String get errorDuringImport => 'Fehler beim Import';

  @override
  String get errorEmptyCsv => 'Die CSV-Datei ist leer.';

  @override
  String errorGeneratingPDF(String error) {
    return 'Fehler beim Generieren von PDF: $error';
  }

  @override
  String get errorInvalidPath => 'Ungültiger Dateipfad.';

  @override
  String get errorLoadingData => 'Fehler beim Laden von Daten';

  @override
  String errorLoadingListValues(String error) {
    return 'Fehler beim Laden von Listenwerten: $error';
  }

  @override
  String errorLoadingLocations(String error) {
    return 'Fehler beim Laden von Standorten: $error';
  }

  @override
  String get errorNameMappingRequired =>
      'Das Feld \"Name\" ist erforderlich und muss zugeordnet sein.';

  @override
  String get errorNoVoucherTemplate =>
      'Keine Lieferscheinvorlage konfiguriert.';

  @override
  String get errorNotBarCode =>
      'The article does not have a barcode or is invalid.';

  @override
  String get errorReadingBytes => 'Dateibytes konnten nicht gelesen werden.';

  @override
  String errorReadingFile(String error) {
    return 'Fehler beim Lesen der Datei: $error';
  }

  @override
  String errorRegisteringLoan(String error) {
    return 'Fehler beim Registrieren des Darlehens: $error';
  }

  @override
  String errorRenaming(String error) {
    return 'Fehler beim Umbenennen: $error';
  }

  @override
  String errorSaving(String error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String errorUpdatingAsset(String error) {
    return 'Fehler beim Aktualisieren der Anlage: $error';
  }

  @override
  String get exampleFilterHint => 'z.B. Beschädigt, Rot, 50';

  @override
  String get february => 'Februar';

  @override
  String get fieldChip => 'Feld';

  @override
  String fieldRequiredWithName(String field) {
    return 'Das Feld \"$field\" ist erforderlich.';
  }

  @override
  String get fieldToCount => 'Feld zum Zählen';

  @override
  String get fieldsFilledSuccess => 'Felder erfolgreich gefüllt!';

  @override
  String get formatsPNG => 'Formate: PNG, JPG';

  @override
  String get forToday => 'For today';

  @override
  String get geminiLabelModel =>
      'Recommended Gemini model: gemini-3-flash-preview';

  @override
  String get generalSettings => 'Allgemeine Einstellungen';

  @override
  String get generateVoucher => 'Lieferschein generieren';

  @override
  String get globalSearch => 'Globale Suche';

  @override
  String get greeting => 'Hallo, willkommen!';

  @override
  String get guest => 'Gast';

  @override
  String get helpDocs => 'Help & Documentation';

  @override
  String get helperGeminiKey =>
      'Enter your Gemini API key to enable integration. Get it at https://aistudio.google.com/';

  @override
  String get ignoreField => '🚫 Feld ignorieren';

  @override
  String get importAssetsTo => 'Anlagen importieren nach';

  @override
  String importSuccessMessage(int count) {
    return 'Import erfolgreich! $count Anlagen erstellt.';
  }

  @override
  String get integrations => 'Integrations';

  @override
  String get integrationGeminiDesc =>
      'Connect Invenicum with Google\'s Gemini to leverage advanced AI capabilities in managing your inventory.';

  @override
  String get integrationTelegramDesc =>
      'Connect Invenicum with Telegram to receive instant notifications about your inventory directly on your device.';

  @override
  String get invalidAssetId => 'Invalid asset ID';

  @override
  String get invalidNavigationIds => 'Fehler: Ungültige Navigations-IDs.';

  @override
  String get inventoryLabel => 'Inventory';

  @override
  String get january => 'Januar';

  @override
  String get july => 'Juli';

  @override
  String get june => 'Juni';

  @override
  String get language => 'Sprache';

  @override
  String get languageChanged => 'Sprache zu Deutsch gewechselt!';

  @override
  String get languageNotImplemented =>
      'Sprachfunktionalität muss noch implementiert werden';

  @override
  String get lightMode => 'Hellmodus';

  @override
  String get loadingAssetType => 'Anlagentyp wird geladen...';

  @override
  String loadingListField(String field) {
    return 'Lädt $field...';
  }

  @override
  String get loanDate => 'Leihdate';

  @override
  String get loanLanguageNotImplemented =>
      'Language feature not yet implemented';

  @override
  String get loanManagement => 'Darlehenverwaltung';

  @override
  String get loanObject => 'Darlehensobjekt';

  @override
  String get loans => 'Darlehen';

  @override
  String get location => 'Location';

  @override
  String get locations => 'Standorte';

  @override
  String get locationsScheme => 'Standortschema';

  @override
  String get login => 'Anmeldung';

  @override
  String get logoVoucher => 'Lieferscheinlogo';

  @override
  String get logout => 'Abmeldung';

  @override
  String get lookForContainersOrAssets => 'Look for containers or assets...';

  @override
  String get lowStockTitle => 'Low Stock';

  @override
  String get magicAssistant => 'Magischer KI-Assistent';

  @override
  String get march => 'März';

  @override
  String get marketPriceObtained => 'Market price obtained successfully';

  @override
  String get marketValueEvolution => 'Market Value Evolution';

  @override
  String get maxStock => 'Max stock';

  @override
  String get may => 'Mai';

  @override
  String get minStock => 'Min stock';

  @override
  String get myAchievements => 'My Achievements';

  @override
  String get myCustomTheme => 'Mein Thema';

  @override
  String get myProfile => 'Mein Profil';

  @override
  String get myThemesStored => 'Meine gespeicherten Themen';

  @override
  String get name => 'Name';

  @override
  String get nameCannotBeEmpty => 'Der Name darf nicht leer sein';

  @override
  String get nameSameAsCurrent => 'Der Name ist gleich dem aktuellen';

  @override
  String get newAlert => 'Neue manuelle Benachrichtigung';

  @override
  String get newContainer => 'Neuer Behälter';

  @override
  String get newName => 'Neuer Name';

  @override
  String get next => 'Next';

  @override
  String get noAssetsCreated => 'Noch keine Anlagen erstellt.';

  @override
  String get noAssetsMatch =>
      'Keine Anlagen entsprechen den Such-/Filterkriterien.';

  @override
  String get noBooleanFields => 'Keine booleschen Felder definiert.';

  @override
  String get noContainerMessage => 'Erstellen Sie Ihren ersten Behälter.';

  @override
  String get noCustomFields =>
      'Dieser Anlagentyp hat keine benutzerdefinierten Felder.';

  @override
  String get noFileSelected => 'Keine Datei ausgewählt';

  @override
  String get noImageAvailable => 'No image available';

  @override
  String get noImagesAdded =>
      'Noch keine Bilder hinzugefügt. Das erste Bild wird das Hauptbild.';

  @override
  String get noLoansFound => 'Keine Darlehen in diesem Behälter gefunden.';

  @override
  String get noLocationsMessage =>
      'Noch keine Standorte in diesem Behälter erstellt. Fügen Sie den ersten hinzu!';

  @override
  String get noNotifications => 'Keine Benachrichtigungen';

  @override
  String get noThemesSaved => 'Noch keine Themen gespeichert';

  @override
  String get none => 'Keine';

  @override
  String get november => 'November';

  @override
  String get obligatory => 'Erforderlich';

  @override
  String get october => 'Oktober';

  @override
  String get optimalStockStatus => 'Stock at optimal levels';

  @override
  String get optional => 'Optional';

  @override
  String get overdue => 'Überfällig';

  @override
  String get password => 'Passwort';

  @override
  String get pleaseEnterPassword => 'Bitte geben Sie Ihr Passwort ein';

  @override
  String get pleaseEnterUsername => 'Bitte geben Sie Ihren Benutzernamen ein';

  @override
  String get pleasePasteUrl => 'Bitte fügen Sie eine URL ein';

  @override
  String get pleaseSelectCsvWithHeaders =>
      'Bitte wählen Sie eine CSV-Datei mit Überschriften.';

  @override
  String get pleaseSelectLocation => 'Bitte wählen Sie einen Standort.';

  @override
  String get plugins => 'Plugins';

  @override
  String get possessionFieldDef => 'Besitzfeld';

  @override
  String get possessionFieldName => 'Im Besitz';

  @override
  String get preferences => 'Einstellungen';

  @override
  String get previewPDF => 'PDF-Vorschau';

  @override
  String get previous => 'Previous';

  @override
  String get primaryImage => 'Primärbild';

  @override
  String get productUrlLabel => 'Produkt-URL';

  @override
  String get quantity => 'Menge';

  @override
  String get refresh => 'Refresh data';

  @override
  String get registerNewLoan => 'Neues Darlehen registrieren';

  @override
  String get reloadContainers => 'Behälter neu laden';

  @override
  String get reloadLocations => 'Standorte neu laden';

  @override
  String get reloadLoans => 'Reload loans';

  @override
  String get removeImage => 'Bild entfernen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get renameContainer => 'Behälter umbenennen';

  @override
  String get responsibleLabel => 'Responsible';

  @override
  String get reports => 'Berichte';

  @override
  String get returned => 'Zurückgegeben';

  @override
  String get returnsLabel => 'Returns';

  @override
  String get rowsPerPageTitle => 'Anlagen pro Seite:';

  @override
  String get save => 'Speichern';

  @override
  String get saveAndApply => 'Speichern und anwenden';

  @override
  String get saveAsset => 'Anlage speichern';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get saveConfiguration => 'Konfiguration speichern';

  @override
  String get saveCustomTheme => 'Benutzerdefiniertes Thema speichern';

  @override
  String get searchInAllColumns => 'In allen Spalten suchen...';

  @override
  String get selectAndUploadImage => 'Bild auswählen und hochladen';

  @override
  String get selectApplicationCurrency => 'Select application currency';

  @override
  String get selectApplicationLanguage => 'Wählen Sie die Anwendungssprache';

  @override
  String get selectBooleanFields =>
      'Wählen Sie boolesche Felder zur Steuerung der Sammlung:';

  @override
  String get selectCsvColumn => 'CSV-Spalte auswählen';

  @override
  String get selectField => 'Feld auswählen...';

  @override
  String get selectFieldType => 'Feldtyp auswählen';

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get selectLocationRequired =>
      'Sie müssen einen Standort für die Anlage auswählen.';

  @override
  String selectedLocationLabel(String name) {
    return 'Ausgewählt: $name';
  }

  @override
  String get selectTheme => 'Thema auswählen';

  @override
  String get september => 'September';

  @override
  String get settings => 'Einstellungen';

  @override
  String get showAsGrid => 'Als Raster anzeigen';

  @override
  String get showAsList => 'Als Liste anzeigen';

  @override
  String get slotDashboardBottom => 'Bottom Dashboard Panel';

  @override
  String get slotDashboardTop => 'Top Dashboard Panel';

  @override
  String get slotFloatingActionButton => 'Floating Button';

  @override
  String get slotInventoryHeader => 'Inventory Header';

  @override
  String get slotLeftSidebar => 'Sidebar';

  @override
  String get slotUnknown => 'Unknown Slot';

  @override
  String get specificValueToCount => 'Bestimmter Wert zum Zählen';

  @override
  String get startImport => 'Import starten';

  @override
  String get startMagic => 'Magie starten';

  @override
  String get status => 'Status';

  @override
  String get step1SelectFile => 'Schritt 1: CSV-Datei auswählen';

  @override
  String get step2ColumnMapping =>
      'Schritt 2: Spaltenzuordnung (CSV -> System)';

  @override
  String get syncingSession => 'Sitzung wird synchronisiert...';

  @override
  String get systemThemes => 'Systemthemen';

  @override
  String get systemThemesModal => 'Systemthemen';

  @override
  String get templates => 'Templates';

  @override
  String get themeNameLabel => 'Themaname';

  @override
  String get thisFieldIsRequired => 'Dieses Feld ist erforderlich.';

  @override
  String get topDemanded => 'Top Demanded';

  @override
  String get topLoanedItems => 'Meistgeliehene Artikel';

  @override
  String get totalAssets => 'Anlagentypen';

  @override
  String get totalItems => 'Anlagen';

  @override
  String get totals => 'Gesamtsummen';

  @override
  String get totalSpending => 'Total Economic Investment';

  @override
  String get totalMarketValue => 'Total Market Value';

  @override
  String get updatedAt => 'Last Update';

  @override
  String get upload => 'Hochladen';

  @override
  String get uploadImage => 'Bild hochladen';

  @override
  String get username => 'Benutzername';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get connectionTestFailed => 'Connection test failed';

  @override
  String get connectionVerified => 'Connection verified successfully';

  @override
  String get errorSavingConfiguration => 'Error saving configuration';

  @override
  String get integrationsAndConnectionsTitle => 'Integrations and connections';

  @override
  String get integrationsSectionAiTitle => 'Artificial intelligence';

  @override
  String get integrationsSectionAiSubtitle =>
      'Conversational engines and assistants to enhance workflows and automations.';

  @override
  String get integrationsSectionMessagingTitle => 'Messaging and notifications';

  @override
  String get integrationsSectionMessagingSubtitle =>
      'Output channels for alerts, bots, reports, and automated deliveries.';

  @override
  String get integrationsSectionDataApisTitle => 'Data APIs';

  @override
  String get integrationsSectionDataApisSubtitle =>
      'External sources to enrich cards, games, and catalog references.';

  @override
  String get integrationsSectionValuationTitle => 'Valuation and market';

  @override
  String get integrationsSectionValuationSubtitle =>
      'Connectors for pricing, barcodes, and up-to-date value estimation.';

  @override
  String get integrationsSectionHardwareTitle => 'Hardware and labels';

  @override
  String get integrationsSectionHardwareSubtitle =>
      'Physical tools and utilities for printing, coding, and operations.';

  @override
  String integrationsActiveConnections(int count) {
    return '$count active connections';
  }

  @override
  String get integrationsModularDesign => 'Modular design by categories';

  @override
  String get integrationsCheckingStatuses => 'Checking statuses';

  @override
  String get integrationsStatusSynced => 'Status synchronized';

  @override
  String integrationConfiguredSuccess(String name) {
    return '$name configured successfully';
  }

  @override
  String integrationUnlinkedWithName(String name) {
    return '$name has been unlinked';
  }

  @override
  String get invalidUiFormat => 'Invalid UI format';

  @override
  String get loadingConfiguration => 'Loading configuration...';

  @override
  String pageNotFoundUri(String uri) {
    return 'Page not found: $uri';
  }

  @override
  String get pluginLoadError => 'Error loading plugin UI';

  @override
  String get pluginRenderError => 'Render error';

  @override
  String get testConnection => 'Test connection';

  @override
  String get testingConnection => 'Testing...';

  @override
  String get unableToUnlinkAccount => 'Could not unlink account';

  @override
  String get unlinkIntegrationUpper => 'UNLINK INTEGRATION';

  @override
  String get upcFreeModeHint =>
      'Leave this field empty to use Free mode (Limited).';

  @override
  String get alertsTabLabel => 'Alerts';

  @override
  String get alertMarkedAsRead => 'Marked as read';

  @override
  String get calendarTabLabel => 'Calendar';

  @override
  String get closeLabel => 'Close';

  @override
  String get closeLabelUpper => 'CLOSE';

  @override
  String get configureReminderLabel => 'Configure reminder:';

  @override
  String get cannotFormatInvalidJson => 'Cannot format an invalid JSON';

  @override
  String get createAlertOrEventTitle => 'Create alert/event';

  @override
  String get createdSuccessfully => 'Created successfully';

  @override
  String get createPluginTitle => 'Create plugin';

  @override
  String get editPluginTitle => 'Edit plugin';

  @override
  String get deleteFromGithubLabel => 'Delete from GitHub';

  @override
  String get deleteFromGithubSubtitle =>
      'Removes the file from the public market';

  @override
  String get deletePluginQuestion => 'Delete plugin?';

  @override
  String get deletePluginLocalWarning =>
      'It will be removed from your local database.';

  @override
  String get deleteUpper => 'DELETE';

  @override
  String get editEventTitle => 'Edit event';

  @override
  String get editLabel => 'Edit';

  @override
  String get eventDataSection => 'Event data';

  @override
  String get eventReminderAtTime => 'At event time';

  @override
  String get eventUpdated => 'Event updated';

  @override
  String get firstVersionHint => 'The first version will always be 1.0.0';

  @override
  String get fixJsonBeforeSave => 'Fix the JSON before saving';

  @override
  String get formatJson => 'Format JSON';

  @override
  String get goToProfileUpper => 'GO TO PROFILE';

  @override
  String get installPluginLabel => 'Install plugin';

  @override
  String get invalidVersionFormat => 'Invalid format (e.g., 1.0.1)';

  @override
  String get isEventQuestion => 'Is this an event?';

  @override
  String get jsonErrorGeneric => 'JSON error';

  @override
  String get makePublicLabel => 'Make public';

  @override
  String get markAsReadLabel => 'Mark as read';

  @override
  String get messageWithColon => 'Message:';

  @override
  String minutesBeforeLabel(int minutes) {
    return '$minutes minutes before';
  }

  @override
  String get newLabel => 'New';

  @override
  String get newPluginLabel => 'New plugin';

  @override
  String get noActiveAlerts => 'No active alerts';

  @override
  String get noDescriptionAvailable => 'No description available.';

  @override
  String get noEventsForDay => 'No events for this day';

  @override
  String get noPluginsAvailable => 'No plugins';

  @override
  String get notificationDeleted => 'Notification deleted successfully';

  @override
  String get oneHourBeforeLabel => '1 hour before';

  @override
  String get pluginPrivateDescription =>
      'Only you can see this plugin in your list.';

  @override
  String get pluginPublicDescription =>
      'Other users will be able to see and install this plugin.';

  @override
  String get pluginTabLibrary => 'Library';

  @override
  String get pluginTabMarket => 'Market';

  @override
  String get pluginTabMine => 'Mine';

  @override
  String get previewLabel => 'Preview';

  @override
  String get remindMeLabel => 'Remind me:';

  @override
  String get requiredField => 'Required';

  @override
  String get requiresGithubDescription =>
      'To publish plugins in the community, you need to link your GitHub account to get author credit.';

  @override
  String get requiresGithubTitle => 'GitHub required';

  @override
  String get slotLocationLabel => 'Location (slot)';

  @override
  String get stacDocumentation => 'Stac documentation';

  @override
  String get stacJsonInterfaceLabel => 'Stac JSON (interface)';

  @override
  String get uninstallLabel => 'Uninstall';

  @override
  String get unrecognizedStacStructure => 'Unrecognized Stac structure';

  @override
  String get updateLabelUpper => 'UPDATE';

  @override
  String updateToVersion(String version) {
    return 'Update to v$version';
  }

  @override
  String get versionLabel => 'Version';

  @override
  String get incrementVersionHint =>
      'Increase the version for your proposal (e.g., 1.1.0)';

  @override
  String get cancelUpper => 'CANCEL';

  @override
  String get mustLinkGithubToPublishTemplate =>
      'You must link GitHub in your profile to publish.';

  @override
  String get templateNeedsAtLeastOneField =>
      'The template must have at least one defined field.';

  @override
  String get templatePullRequestCreated =>
      'Proposal sent. A Pull Request has been created on GitHub.';

  @override
  String errorPublishingTemplate(String error) {
    return 'Error publishing: $error';
  }

  @override
  String get createGlobalTemplateTitle => 'Create global template';

  @override
  String get githubVerifiedLabel => 'GitHub verified';

  @override
  String get githubNotLinkedLabel => 'GitHub not linked';

  @override
  String get veniDesignedTemplateBanner =>
      'Veni designed this structure based on your request. Review and adjust it before publishing.';

  @override
  String get templateNameLabel => 'Template name';

  @override
  String get templateNameHint => 'E.g.: My comics collection';

  @override
  String get githubUserLabel => 'GitHub user';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryHint => 'E.g.: Books, Electronics...';

  @override
  String get templatePurposeDescription => 'Purpose description';

  @override
  String get definedFieldsTitle => 'Defined fields';

  @override
  String get addFieldButton => 'Add field';

  @override
  String get clickAddFieldToStart => 'Click \'Add field\' to start designing.';

  @override
  String get configureOptionsUpper => 'CONFIGURE OPTIONS';

  @override
  String get writeOptionAndPressEnter => 'Type an option and press Enter';

  @override
  String get publishOnGithubUpper => 'PUBLISH ON GITHUB';

  @override
  String get templateDetailFetchError => 'Could not fetch template details';

  @override
  String get templateNotAvailable =>
      'The template does not exist or is not available';

  @override
  String get backLabel => 'Back';

  @override
  String get templateDetailTitle => 'Template detail';

  @override
  String get saveToLibraryTooltip => 'Save to library';

  @override
  String templateByAuthor(String name) {
    return 'by @$name';
  }

  @override
  String get officialVerifiedTemplate => 'Official verified template';

  @override
  String dataStructureFieldsUpper(int count) {
    return 'DATA STRUCTURE ($count FIELDS)';
  }

  @override
  String get installInMyInventoryUpper => 'INSTALL IN MY INVENTORY';

  @override
  String get addedToPersonalLibrary => 'Added to your personal library';

  @override
  String get whereDoYouWantToInstall => 'Where do you want to install it?';

  @override
  String get noContainersCreateFirst =>
      'You have no containers. Create one first.';

  @override
  String get autoGeneratedListFromTemplate =>
      'Auto-generated list from template';

  @override
  String get installationSuccessAutoLists =>
      'Installation successful. Lists configured automatically.';

  @override
  String errorInstallingTemplate(String error) {
    return 'Error installing: $error';
  }

  @override
  String get publishTemplateLabel => 'Publish template';

  @override
  String get retryLabel => 'Retry';

  @override
  String get noTemplatesFoundInMarket =>
      'No templates were found in the market.';

  @override
  String get invenicumCommunity => 'Invenicum Community';

  @override
  String get refreshMarketTooltip => 'Refresh market';

  @override
  String get exploreCommunityConfigurations =>
      'Explore and download community configurations';

  @override
  String get searchByTemplateName => 'Search by template name...';

  @override
  String get filterByTagTooltip => 'Filter by tag';

  @override
  String get noMoreTags => 'No more tags';

  @override
  String confirmDeleteDataList(String name) {
    return 'Are you sure you want to delete list \"$name\"? This action is irreversible.';
  }

  @override
  String dataListDeletedSuccess(String name) {
    return 'List \"$name\" deleted successfully.';
  }

  @override
  String errorDeletingDataList(String error) {
    return 'Error deleting list: $error';
  }

  @override
  String customListsWithContainer(String name) {
    return 'Custom lists - $name';
  }

  @override
  String get newDataListLabel => 'New list';

  @override
  String get noCustomListsCreateOne =>
      'There are no custom lists. Create a new one.';

  @override
  String elementsCount(int count) {
    return '$count elements';
  }

  @override
  String get dataListNeedsAtLeastOneElement =>
      'The list must have at least one element';

  @override
  String get customDataListCreated => 'Custom list created successfully';

  @override
  String errorCreatingDataList(String error) {
    return 'Error creating list: $error';
  }

  @override
  String get newCustomDataListTitle => 'New custom list';

  @override
  String get dataListNameLabel => 'List name';

  @override
  String get pleaseEnterAName => 'Please enter a name';

  @override
  String get dataListElementsTitle => 'List elements';

  @override
  String get newElementLabel => 'New element';

  @override
  String get addLabel => 'Add';

  @override
  String get addElementsToListHint => 'Add elements to the list';

  @override
  String get saveListLabel => 'Save list';

  @override
  String get dataListUpdatedSuccessfully => 'List updated successfully';

  @override
  String errorUpdatingDataList(String error) {
    return 'Error updating list: $error';
  }

  @override
  String editListWithName(String name) {
    return 'Edit list: $name';
  }

  @override
  String get createNewLocationTitle => 'Create New Location';

  @override
  String get locationNameLabel => 'Location Name';

  @override
  String get locationNameHint => 'E.g.: Shelf B3, Server Room';

  @override
  String get locationDescriptionHint => 'Access details, content type, etc.';

  @override
  String get parentLocationLabel => 'Parent Location (Contains this one)';

  @override
  String get noParentRootLocation => 'No parent (Root Location)';

  @override
  String get noneRootScheme => 'None (Scheme Root)';

  @override
  String get savingLabel => 'Saving...';

  @override
  String get saveLocationLabel => 'Save Location';

  @override
  String locationCreatedSuccessfully(String name) {
    return 'Location \"$name\" created successfully.';
  }

  @override
  String errorCreatingLocation(String error) {
    return 'Error creating location: $error';
  }

  @override
  String get locationCannotBeItsOwnParent =>
      'A location cannot be its own parent.';

  @override
  String locationUpdatedSuccessfully(String name) {
    return 'Location \"$name\" updated.';
  }

  @override
  String errorUpdatingLocation(String error) {
    return 'Error updating location: $error';
  }

  @override
  String editLocationTitle(String name) {
    return 'Edit: $name';
  }

  @override
  String get updateLocationLabel => 'Update Location';

  @override
  String get selectObjectTitle => 'Select Object';

  @override
  String get noObjectsAvailable => 'No objects available';

  @override
  String availableQuantity(int quantity) {
    return 'Available: $quantity';
  }

  @override
  String errorSelectingObject(String error) {
    return 'Error selecting object: $error';
  }

  @override
  String get mustSelectAnObject => 'You must select an object';

  @override
  String get loanRegisteredSuccessfully => 'Loan registered successfully';

  @override
  String get selectAnObject => 'Select an object';

  @override
  String get selectLabel => 'Select';

  @override
  String get borrowerNameHint => 'E.g.: John Doe';

  @override
  String get borrowerNameRequired => 'Name is required';

  @override
  String loanQuantityAvailable(int quantity) {
    return 'Quantity to loan (Available: $quantity)';
  }

  @override
  String get enterQuantity => 'Enter a quantity';

  @override
  String get invalidQuantity => 'Invalid quantity';

  @override
  String get notEnoughStock => 'Not enough stock';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String expectedReturnDateLabel(String date) {
    return 'Expected return: $date';
  }

  @override
  String get selectReturnDate => 'Select return date';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get registerLoanLabel => 'Register Loan';

  @override
  String get totalLabel => 'Total';

  @override
  String get newLocationLabel => 'New location';

  @override
  String get newLocationHint => 'E.g.: Shelf A1, Cabinet 3...';

  @override
  String get parentLocationOptionalLabel => 'Parent location (optional)';

  @override
  String get noneRootLabel => 'None (root)';

  @override
  String locationCreatedShort(String name) {
    return 'Location \"$name\" created';
  }

  @override
  String get newLocationEllipsis => 'New location...';

  @override
  String get couldNotReloadList => 'Could not reload the list';

  @override
  String get deleteAssetTitle => 'Delete Asset';

  @override
  String confirmDeleteAssetItem(String name) {
    return 'Do you confirm deleting \"$name\"?';
  }

  @override
  String get assetDeletedShort => 'Asset deleted.';

  @override
  String viewColumnsLabel(int count) {
    return 'View: $count col.';
  }

  @override
  String get notValuedLabel => 'Not valued';

  @override
  String get manageSearchSyncAssets =>
      'Manage, search and sync your assets from a single panel.';

  @override
  String get filterLabel => 'Filter';

  @override
  String get activeFilterLabel => 'Active filter';

  @override
  String get importLabel => 'Import';

  @override
  String get syncLabel => 'Sync';

  @override
  String get syncingLabel => 'Syncing...';

  @override
  String get newAssetLabel => 'New asset';

  @override
  String get statusAndPreferences => 'Status and Preferences';

  @override
  String get itemStatusLabel => 'Item status';

  @override
  String get availableLabel => 'Available';

  @override
  String get mustBeGreaterThanZero => 'Must be greater than 0.';

  @override
  String get alertThresholdLabel => 'Alert threshold';

  @override
  String get enterMinimumStock => 'Enter a minimum stock';

  @override
  String get serializedItemFixedQuantity =>
      'This is a serialized item. Quantity is fixed at 1.';

  @override
  String get serialNumberLabel => 'Serial number';

  @override
  String get serialNumberHint => 'E.g.: SN-2024-00123';

  @override
  String get mainDataTitle => 'Main Data';

  @override
  String get currentMarketValueLabel => 'CURRENT MARKET VALUE';

  @override
  String get updatePriceLabel => 'Update Price';

  @override
  String get viewLabel => 'View';

  @override
  String get visualGalleryTitle => 'Visual Gallery';

  @override
  String get statusAndMarketTitle => 'Status and Market';

  @override
  String get valuationHistoryTitle => 'Valuation History';

  @override
  String get specificationsTitle => 'Specifications';

  @override
  String get traceabilityTitle => 'Traceability';

  @override
  String get stockLabel => 'Stock';

  @override
  String get internalReferenceLabel => 'Internal Reference';

  @override
  String get noSpecificationsAvailable => 'No specifications available';

  @override
  String get trueLabel => 'True';

  @override
  String get falseLabel => 'False';

  @override
  String get openLinkLabel => 'Open link';

  @override
  String get scannerFocusTip =>
      'Tip: If it does not focus, move the product about 30 cm away from the camera.';

  @override
  String get scanCodeTitle => 'Scan Code';

  @override
  String get scanOrEnterProductCode => 'Scan or enter the product code';

  @override
  String possessionProgressLabel(String name) {
    return 'Progress of $name';
  }

  @override
  String get externalImportTitle => 'Import from External Source';

  @override
  String get galleryTitle => 'Gallery';

  @override
  String get stockAndCodingTitle => 'Stock and Coding';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to scan';

  @override
  String get cloudDataFound => 'Data found in the cloud!';

  @override
  String get typeSomethingToSearch => 'Type something to search';

  @override
  String get importCancelled => 'Import cancelled.';

  @override
  String get couldNotCompleteImport => 'Could not complete the import';

  @override
  String get yearLabel => 'Year';

  @override
  String get authorLabel => 'Author';

  @override
  String get selectResultTitle => 'Select a result';

  @override
  String get unnamedLabel => 'Unnamed';

  @override
  String get completeRequiredFields => 'Please complete the required fields.';

  @override
  String get assetCreatedSuccess => 'Asset created!';

  @override
  String errorCreatingAsset(String error) {
    return 'Error creating asset: $error';
  }

  @override
  String get technicalDetailsTitle => 'Technical Details';

  @override
  String itemImportedSuccessfully(String name) {
    return '$name imported successfully!';
  }

  @override
  String newImagesSelected(int count) {
    return '$count new images were selected.';
  }

  @override
  String get newFileRemoved => 'New file removed.';

  @override
  String get imageMarkedForDeletion => 'Image marked for deletion when saving.';

  @override
  String get couldNotIdentifyImage => 'Could not identify the image.';

  @override
  String editAssetTitle(String name) {
    return 'Edit: $name';
  }

  @override
  String get syncPricesTitle => 'Sync prices';

  @override
  String get syncPricesDescription =>
      'The API will be queried to update the market value.';

  @override
  String get syncingMarketPrices => 'Syncing market prices...';

  @override
  String get couldNotSyncPrices => 'Could not sync prices';

  @override
  String get syncCompletedTitle => 'Synchronization completed';

  @override
  String get updatedLabel => 'Updated';

  @override
  String get noApiPriceLabel => 'No price in API';

  @override
  String get errorsLabel => 'Errors';

  @override
  String get totalProcessedLabel => 'Total processed';

  @override
  String get noAssetsToShow => 'No assets to display';

  @override
  String get noImageLabel => 'No image';

  @override
  String get aiMagicQuestion => 'Do you have a link?';

  @override
  String get aiAutocompleteAsset => 'Autocomplete this asset with AI';

  @override
  String get magicLabel => 'MAGIC';

  @override
  String get skuBarcodeLabel => 'SKU / EAN / UPC';

  @override
  String get veniChatPlaceholder => 'Fragen Sie mich alles...';

  @override
  String get veniChatPoweredBy => 'Powered by ';

  @override
  String veniChatProcessing(String query) {
    return 'Ich verarbeite Ihre Frage zu \"$query\"...';
  }

  @override
  String get veniChatStatus => 'Online';

  @override
  String get veniChatTitle => 'Veni KI';

  @override
  String get veniChatWelcome =>
      'Hallo! Ich bin Veni, Ihr Invenicum-Assistent. Wie kann ich Ihnen heute bei Ihrem Inventar helfen?';

  @override
  String get veniCmdDashboard => 'Zum Dashboard gehen';

  @override
  String get veniCmdHelpTitle => 'Veni-Fähigkeiten';

  @override
  String get veniCmdInventory => 'Überprüfen Sie den Bestand eines Artikels';

  @override
  String get veniCmdLoans => 'Aktive Darlehen anzeigen';

  @override
  String get veniCmdReport => 'Inventarbericht generieren';

  @override
  String get veniCmdScanQR => 'QR/Barcode scannen';

  @override
  String get veniCmdUnknown =>
      'Ich erkenne diesen Befehl nicht. Schreiben Sie Hilfe, um zu sehen, was ich tun kann.';

  @override
  String version(String name) {
    return 'Version $name';
  }

  @override
  String get yes => 'Ja';

  @override
  String get zoomToFit => 'Zoom anpassen';

  @override
  String get generalSettingsMenuLabel => 'General Settings';

  @override
  String get aiAssistantMenuLabel => 'AI Assistant';

  @override
  String get notificationsMenuLabel => 'Notifications';

  @override
  String get loanManagementMenuLabel => 'Loan Management';

  @override
  String get aboutMenuLabel => 'About';

  @override
  String get automaticDarkModeLabel => 'Automatic dark mode';

  @override
  String get syncWithSystemLabel => 'Sync with system';

  @override
  String get manualDarkModeLabel => 'Manual dark mode';

  @override
  String get disableAutomaticToChange => 'Disable automatic mode to change it';

  @override
  String get changeLightDark => 'Switch between light and dark';

  @override
  String get enableAiAndChatbot => 'Enable Artificial Intelligence and Chatbot';

  @override
  String get requiresGeminiLinking =>
      'Requires linking with Gemini in Integrations';

  @override
  String get aiOrganizeInventory =>
      'Use AI to organize your inventory intelligently';

  @override
  String get aiAssistantTitle => 'Artificial Intelligence Assistant';

  @override
  String get selectAiProvider =>
      'Choose which AI provider Veni will use. Make sure you have the API Key configured in Integrations.';

  @override
  String get aiProviderLabel => 'Provider';

  @override
  String get aiModelLabel => 'Model';

  @override
  String get aiProviderUpdated => 'AI Provider updated';

  @override
  String get notificationSettingsTitle => 'Notification Management';

  @override
  String get channelPriorityLabel => 'Channel Priority (Drag to reorder)';

  @override
  String get telegramBotLabel => 'Telegram Bot';

  @override
  String get resendEmailLabel => 'Resend Email';

  @override
  String get lowStockLabel => 'Low Stock';

  @override
  String get lowStockHint => 'Alert when a product falls below the minimum.';

  @override
  String get newPresalesLabel => 'New Pre-sales';

  @override
  String get newPresalesHint => 'Notify launches detected by AI.';

  @override
  String get loanReminderLabel => 'Loan Reminder';

  @override
  String get loanReminderHint => 'Alert before the return date.';

  @override
  String get overdueLoansLabel => 'Overdue Loans';

  @override
  String get overdueLoansHint =>
      'Critical alert if an object is not returned on time.';

  @override
  String get maintenanceLabel => 'Maintenance';

  @override
  String get maintenanceHint => 'Alert when an asset needs review.';

  @override
  String get priceChangeLabel => 'Price Changes';

  @override
  String get priceChangeHint => 'Notify market value variations.';

  @override
  String get unlinkGithubTitle => 'Disconnect GitHub';

  @override
  String get unlinkGithubMessage =>
      'Are you sure you want to unlink your GitHub account?';

  @override
  String get updatePasswordButton => 'UPDATE PASSWORD';

  @override
  String get newContainerDialog => 'New Container';

  @override
  String get descriptionField => 'Description';

  @override
  String get isCollectionQuestion => 'Is it a collection?';

  @override
  String get createContainerButton => 'Create Container';

  @override
  String get selectContainerHint => 'Select a container';

  @override
  String get newAssetTypeTitle => 'New Asset Type';

  @override
  String get generalConfiguration => 'General Configuration';

  @override
  String get collectionContainerWarning =>
      'This container is a collection. You can create serialized or non-serialized types, but possession and desired fields can only be configured on non-serialized types.';

  @override
  String get createAssetTypeButton => 'Create Asset Type';

  @override
  String assetTypesInContainer(String name) {
    return 'Asset Types in \"$name\"';
  }

  @override
  String get createNewTypeButton => 'Create New Type';

  @override
  String get isSerializedQuestion => 'Is it a serialized item?';

  @override
  String get addNewFieldButton => 'Add New Field';

  @override
  String get deleteFieldTooltip => 'Delete field';

  @override
  String get fieldsOptions => 'Options:';

  @override
  String get isRequiredField => 'Is Required';

  @override
  String get isSummativeFieldLabel => 'Is Summative (Added to type total)';

  @override
  String get isMonetaryValueLabel => 'Is Monetary Value';

  @override
  String get monetaryValueDescription =>
      'Will be used to calculate total investment in Dashboard';

  @override
  String get noDataListsAvailable =>
      '⚠️ No data lists available in this container.';

  @override
  String get selectDataList => 'Select Data List';

  @override
  String get chooseList => 'Choose a list';

  @override
  String get goToPageLabel => 'Go to page:';

  @override
  String get conditionLabel => 'Condition';

  @override
  String get actionsLabel => 'Actions';

  @override
  String get editButtonLabel => 'Edit';

  @override
  String get deleteButtonLabel => 'Delete';

  @override
  String get collectionFieldsTooltip => 'Collection Fields';

  @override
  String totalLocations(int count) {
    return '$count locations';
  }

  @override
  String withoutLocationLabel(int count) {
    return '$count without location · ';
  }

  @override
  String get objectIdColumn => 'Object ID';

  @override
  String containerNotFoundError(String id) {
    return 'Container with ID $id not found.';
  }

  @override
  String get invalidContainerIdError => 'Error: Invalid container ID.';

  @override
  String get startConfigurationButton => 'Start configuration';

  @override
  String get fullNameField => 'Full name';

  @override
  String get emailField => 'Email address';

  @override
  String get passwordField => 'Password';

  @override
  String get confirmPasswordField => 'Confirm password';

  @override
  String get goBackButton => 'Go back';

  @override
  String get createAccountButton => 'Create account';

  @override
  String get goToLoginButton => 'Go to login';

  @override
  String get deleteConfirmationTitle => 'Confirm Deletion';

  @override
  String deleteItemMessage(String name) {
    return 'Do you wish to delete \"$name\"?';
  }

  @override
  String get elementDeletedSuccess => 'Element deleted successfully';

  @override
  String get enterYourNameValidation => 'Enter your name.';

  @override
  String get minTwoCharactersValidation => 'Minimum 2 characters.';

  @override
  String get enterEmailValidation => 'Enter an email.';

  @override
  String get invalidEmailValidation => 'Invalid email.';

  @override
  String get enterPasswordValidation => 'Enter a password.';

  @override
  String get minEightCharactersValidation => 'Minimum 8 characters.';

  @override
  String get threeDbuttonLabel => '3D';

  @override
  String barcodeCount(String count) {
    return '$count';
  }

  @override
  String rotationSpeedLabel(String count) {
    return '${count}s';
  }

  @override
  String tagLabel(String tag) {
    return '#$tag';
  }

  @override
  String get invalidIdError => 'Invalid ID';

  @override
  String assetTypeLoadError(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get assetTypeUpdateSuccess => 'Asset type updated successfully';

  @override
  String assetTypeUpdateError(String error) {
    return 'Error updating: $error';
  }

  @override
  String editAssetTypeTitle(String name) {
    return 'Edit: $name';
  }

  @override
  String get achievementCollectionTitle => 'Achievement Collection';

  @override
  String get achievementSubtitle => 'Unlock milestones using Invenicum';

  @override
  String get legendaryAchievementLabel => 'LEGENDARY ACHIEVEMENT';

  @override
  String get achievementCompleted => 'Completed';

  @override
  String get achievementLocked => 'Locked';

  @override
  String achievementUnlockedDate(String date) {
    return 'Unlocked on $date';
  }

  @override
  String get achievementLockedMessage => 'Fulfill the objective to unlock';

  @override
  String get closeButtonLabel => 'Got it';

  @override
  String get configurationGeneralSection => 'General Configuration';

  @override
  String get assetTypeCollectionWarning =>
      'This container is a collection. You can create serialized or non-serialized types, but possession and desired fields can only be configured in non-serialized types.';

  @override
  String get updateAssetTypeButton => 'Update Asset Type';

  @override
  String get createAssetTypeButtonDefault => 'Create Asset Type';

  @override
  String get noAssetTypesMessage =>
      'No Asset Types defined yet in this container.';

  @override
  String totalCountLabel(int count) {
    return 'Total: $count';
  }

  @override
  String possessionCountLabel(int count) {
    return 'Possession: $count';
  }

  @override
  String desiredCountLabel(int count) {
    return 'Desired: $count';
  }

  @override
  String get marketValueLabel => 'Market: ';

  @override
  String get defaultSumFieldName => 'Sum';

  @override
  String get calculatingLabel => 'Calculating...';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get noNameItem => 'No name';

  @override
  String get loadingContainers => 'Loading containers...';

  @override
  String get fieldNameRequired => 'Field name is required';

  @override
  String get selectImageButton => 'Select Image';

  @override
  String assetTypeDeletedSuccess(String name) {
    return '$name deleted';
  }

  @override
  String get noLocationValueData =>
      'No assets with location and sufficient value yet to display this chart.';

  @override
  String get requiredFieldValidation => 'This field is required';

  @override
  String get oceanTheme => 'Indian Ocean';

  @override
  String get cherryBlossomTheme => 'Cherry Blossom';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get reloadListError => 'Failed to reload the list';

  @override
  String get copyItemSuffix => 'Copy';

  @override
  String itemCopiedSuccess(String name) {
    return 'Item copied: $name';
  }

  @override
  String get copyError => 'Error copying item';

  @override
  String get imageColumnLabel => 'Image';

  @override
  String get viewImageTooltip => 'View image';

  @override
  String get currentStockLabel => 'Current Stock';

  @override
  String get minimumStockLabel => 'Minimum Stock';

  @override
  String get locationColumnLabel => 'Location';

  @override
  String get serialNumberColumnLabel => 'Serial Number';

  @override
  String get marketPriceLabel => 'Market Price';

  @override
  String get conditionColumnLabel => 'Condition';

  @override
  String get actionsColumnLabel => 'Actions';

  @override
  String get imageLoadError => 'Failed to load image';

  @override
  String get imageUrlHint =>
      'Make sure the URL is correct and the server is active';

  @override
  String get assetTypeNameHint => 'E.g: Laptop, Chemical Substance';

  @override
  String get assetTypeNameLabel => 'Asset Type Name';

  @override
  String get underConstruction => 'Under Construction';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get constructionSubtitle => 'This feature is being developed';

  @override
  String get selectColor => 'Select Color';
}
