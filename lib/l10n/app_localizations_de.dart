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
  String get ignoreField => '🚫 Feld ignorieren';

  @override
  String get importAssetsTo => 'Anlagen importieren nach';

  @override
  String importSuccessMessage(int count) {
    return 'Import erfolgreich! $count Anlagen erstellt.';
  }

  @override
  String get invalidAssetId => 'Invalid asset ID';

  @override
  String get invalidNavigationIds => 'Fehler: Ungültige Navigations-IDs.';

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
  String get magicAssistant => 'Magischer KI-Assistent';

  @override
  String get march => 'März';

  @override
  String get may => 'Mai';

  @override
  String get minStock => 'Min stock';

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
  String get registerNewLoan => 'Neues Darlehen registrieren';

  @override
  String get reloadContainers => 'Behälter neu laden';

  @override
  String get reloadLocations => 'Standorte neu laden';

  @override
  String get removeImage => 'Bild entfernen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get renameContainer => 'Behälter umbenennen';

  @override
  String get returned => 'Zurückgegeben';

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
  String get themeNameLabel => 'Themaname';

  @override
  String get thisFieldIsRequired => 'Dieses Feld ist erforderlich.';

  @override
  String get topLoanedItems => 'Meistgeliehene Artikel';

  @override
  String get totalAssets => 'Anlagentypen';

  @override
  String get totalItems => 'Anlagen';

  @override
  String get totals => 'Gesamtsummen';

  @override
  String get updatedAt => 'Last Update';

  @override
  String get upload => 'Hochladen';

  @override
  String get uploadImage => 'Bild hochladen';

  @override
  String get username => 'Benutzername';

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
}
