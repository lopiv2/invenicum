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
  String get deliveryVoucherTitle => 'ABGABEBESCHEINIGUNG';

  @override
  String get aboutDialogTitle => 'Über Invenicum';

  @override
  String get aboutDialogCoolText =>
      'Dein Inventar auf Steroiden. Wir prüfen gerade, ob eine neuere Version verfügbar ist.';

  @override
  String get aboutCurrentVersionLabel => 'Aktuelle Version';

  @override
  String get aboutLatestVersionLabel => 'Neueste Version';

  @override
  String get aboutCheckingVersion => 'Online-Version wird geprüft...';

  @override
  String get aboutVersionUnknown => 'Unbekannt';

  @override
  String get aboutVersionUpToDate => 'Deine App ist aktuell.';

  @override
  String get aboutUpdateAvailable => 'Eine neue Version ist verfügbar.';

  @override
  String get aboutVersionCheckFailed =>
      'Online-Version konnte nicht geprüft werden.';

  @override
  String get aboutOpenReleases => 'Releases ansehen';

  @override
  String get active => 'Aktiv';

  @override
  String get actives => 'Aktiva';

  @override
  String get activeInsight => 'INFORMATIONEN ZU LAUFENDEN AKTIVA';

  @override
  String get activeLoans => 'Laufende Ausleihen';

  @override
  String get activeLoansCount => 'Laufende Ausleihen';

  @override
  String get addAlert => 'Benachrichtigung hinzufügen';

  @override
  String get addAsset => 'Aktiv hinzufügen';

  @override
  String get addContainer => 'Container hinzufügen';

  @override
  String get addNewLocation => 'Neuen Standort hinzufügen';

  @override
  String get additionalInformation => 'Zusätzliche Informationen';

  @override
  String get additionalThumbnails => 'Weitere Vorschaubilder';

  @override
  String get adquisition => 'ERWERB';

  @override
  String aiExtractionError(String error) {
    return 'KI konnte Daten nicht extrahieren: $error';
  }

  @override
  String get aiPasteUrlDescription =>
      'Füge den Produkt-Link ein und die KI extrahiert automatisch die Informationen zum Ausfüllen der Felder.';

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
  String get alerts => 'Benachrichtigungen & Warnungen';

  @override
  String get all => 'Alle';

  @override
  String get allUpToDateStatus => 'Alles aktuell';

  @override
  String get appTitle => 'Invenicum Inventar';

  @override
  String get applicationTheme => 'App-Design';

  @override
  String get apply => 'Anwenden';

  @override
  String get april => 'April';

  @override
  String get assetDetail => 'Aktiv-Details';

  @override
  String get assetImages => 'Aktiv-Bilder';

  @override
  String get assetImport => 'Aktiv-Import';

  @override
  String get assetName => 'Name';

  @override
  String get assetNotFound => 'Aktiv nicht gefunden';

  @override
  String assetTypeDeleted(String name) {
    return 'Aktivtyp \"$name\" erfolgreich gelöscht.';
  }

  @override
  String get assetTypes => 'Aktivtypen';

  @override
  String assetUpdated(String name) {
    return 'Aktiv \"$name\" erfolgreich aktualisiert.';
  }

  @override
  String get assets => 'Aktiva';

  @override
  String get assetsIn => 'Aktiva in';

  @override
  String get august => 'August';

  @override
  String get backToAssetTypes => 'Zurück zu Aktivtypen';

  @override
  String get averageMarketValue => 'Durchschnittlicher Marktwert';

  @override
  String get barCode => 'Barcode (EAN)';

  @override
  String get baseCostAccumulatedWithoutInflation =>
      'Kumulierte Basiskosten ohne Inflation';

  @override
  String get borrowerEmail => 'E-Mail des Entleihers';

  @override
  String get borrowerName => 'Name des Entleihers';

  @override
  String get borrowerPhone => 'Telefon des Entleihers';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get centerView => 'Ansicht zentrieren';

  @override
  String get chooseFile => 'Datei auswählen';

  @override
  String get clearCounter => 'Zähler zurücksetzen';

  @override
  String get collectionContainerInfo =>
      'Sammlungs-Container haben Sammlungs-Fortschrittsbalken, Investitionswert, Marktwert und Ausstellungsansicht';

  @override
  String get collectionFieldsConfigured => 'Sammlungsfelder konfiguriert.';

  @override
  String get condition => 'Zustand';

  @override
  String get condition_mint => 'Originalverpackung';

  @override
  String get condition_loose => 'Lose (Ohne Verpackung)';

  @override
  String get condition_incomplete => 'Unvollständig';

  @override
  String get condition_damaged => 'Beschädigt / Gebrauchsspuren';

  @override
  String get condition_new => 'Neu';

  @override
  String get condition_digital => 'Digital / Immateriell';

  @override
  String get configureCollectionFields => 'Sammlungsfelder konfigurieren';

  @override
  String get configureDeliveryVoucher => 'Lieferschein konfigurieren';

  @override
  String get configureVoucherBody => 'Inhalt des Scheins konfigurieren...';

  @override
  String get confirmDeleteAlert => 'Benachrichtigung löschen';

  @override
  String get confirmDeleteAlertMessage =>
      'Bist du sicher, dass du diesen Eintrag löschen möchtest?';

  @override
  String confirmDeleteAssetType(String name) {
    return 'Bist du sicher, dass du den Aktivtyp \"$name\" und alle zugehörigen Elemente löschen möchtest? Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String confirmDeleteContainer(String name) {
    return 'Bist du sicher, dass du den Container \"$name\" löschen möchtest? Diese Aktion ist unwiderruflich und löscht alle enthaltenen Aktiva und Daten.';
  }

  @override
  String confirmDeleteLocationMessage(String name) {
    return 'Bist du sicher, dass du den Standort \"$name\" löschen möchtest?';
  }

  @override
  String get confirmDeletion => 'Löschen bestätigen';

  @override
  String get configurationSaved => 'Konfiguration erfolgreich gespeichert.';

  @override
  String containerCreated(String name) {
    return 'Container \"$name\" erfolgreich erstellt.';
  }

  @override
  String containerDeleted(String name) {
    return 'Container \"$name\" erfolgreich gelöscht.';
  }

  @override
  String get containerName => 'Container-Name';

  @override
  String get containerOrAssetTypeNotFound =>
      'Container oder Aktivtyp nicht gefunden.';

  @override
  String containerRenamed(String name) {
    return 'Container umbenannt in \"$name\".';
  }

  @override
  String get containers => 'Container';

  @override
  String get countItemsByValue => 'Elemente nach bestimmtem Wert zählen';

  @override
  String get create => 'Erstellen';

  @override
  String get createFirstContainer => 'Erstelle deinen ersten Container.';

  @override
  String get createdAt => 'Erstellt am';

  @override
  String get currency => 'Währung';

  @override
  String get current => 'Aktuell';

  @override
  String get customColor => 'Farbe anpassen';

  @override
  String get customFields => 'Benutzerdefinierte Felder';

  @override
  String customFieldsOf(String name) {
    return 'Benutzerdefinierte Felder von $name';
  }

  @override
  String get customizeDeliveryVoucher => 'PDF-Vorlage für Ausleihen anpassen';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get datalists => 'Benutzerdefinierte Listen';

  @override
  String get december => 'Dezember';

  @override
  String get definitionCustomFields => 'Definition benutzerdefinierter Felder';

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
  String get desiredField => 'Wunschfeld';

  @override
  String get dueDate => 'Fälligkeitsdatum';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get enterContainerName => 'Container-Namen eingeben';

  @override
  String get enterDescription => 'Beschreibung eingeben';

  @override
  String get enterURL => 'URL eingeben';

  @override
  String get enterValidUrl => 'Gültige URL eingeben';

  @override
  String errorChangingLanguage(String error) {
    return 'Fehler beim Ändern der Sprache: $error';
  }

  @override
  String get errorCsvMinRows =>
      'Bitte wähle eine CSV-Datei mit Kopfzeilen und mindestens einer Datenzeile aus.';

  @override
  String errorDeletingAssetType(String error) {
    return 'Fehler beim Löschen des Aktivtyps: $error';
  }

  @override
  String errorDeletingContainer(String error) {
    return 'Fehler beim Löschen des Containers: $error';
  }

  @override
  String get errorDuringImport => 'Fehler beim Import';

  @override
  String get errorEmptyCsv => 'Die CSV-Datei ist leer.';

  @override
  String errorGeneratingPDF(String error) {
    return 'Fehler beim Erstellen des PDFs: $error';
  }

  @override
  String get errorInvalidPath => 'Ungültiger Dateipfad.';

  @override
  String get errorLoadingData => 'Fehler beim Laden der Daten';

  @override
  String errorLoadingListValues(String error) {
    return 'Fehler beim Laden der Listenwerte: $error';
  }

  @override
  String errorLoadingLocations(String error) {
    return 'Fehler beim Laden der Standorte: $error';
  }

  @override
  String get errorNameMappingRequired =>
      'Das Feld \'Name\' ist erforderlich und muss zugeordnet werden.';

  @override
  String get errorNoVoucherTemplate =>
      'Es ist keine Schein-Vorlage konfiguriert.';

  @override
  String get errorNotBarCode =>
      'Der Artikel hat keinen oder keinen gültigen Barcode.';

  @override
  String get errorReadingBytes => 'Datei-Bytes konnten nicht gelesen werden.';

  @override
  String errorReadingFile(String error) {
    return 'Fehler beim Lesen der Datei: $error';
  }

  @override
  String errorRegisteringLoan(String error) {
    return 'Fehler beim Registrieren der Ausleihe: $error';
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
    return 'Fehler beim Aktualisieren des Aktivs: $error';
  }

  @override
  String get exampleFilterHint => 'Bsp.: Beschädigt, Rot, 50';

  @override
  String get february => 'Februar';

  @override
  String get fieldChip => 'Feld';

  @override
  String fieldRequiredWithName(String field) {
    return 'Das Feld \"$field\" ist erforderlich.';
  }

  @override
  String get fieldToCount => 'Zu zählendes Feld';

  @override
  String get fieldsFilledSuccess => 'Felder erfolgreich ausgefüllt!';

  @override
  String get formatsPNG => 'Formate: PNG, JPG';

  @override
  String get forToday => 'Für heute';

  @override
  String get geminiLabelModel =>
      'Empfohlenes Gemini-Modell: gemini-3-flash-preview';

  @override
  String get generalSettings => 'Allgemeine Einstellungen';

  @override
  String get generateVoucher => 'Lieferschein erstellen';

  @override
  String get globalSearch => 'Globale Suche';

  @override
  String get greeting => 'Hallo, willkommen!';

  @override
  String get guest => 'Gast';

  @override
  String get helpDocs => 'Hilfe & Dokumentation';

  @override
  String get helperGeminiKey =>
      'Gib deinen Gemini API-Schlüssel ein, um die Integration zu aktivieren. Erhältlich unter https://aistudio.google.com/';

  @override
  String get ignoreField => '🚫 Feld ignorieren';

  @override
  String get importAssetsTo => 'Aktiva importieren nach';

  @override
  String importSuccessMessage(int count) {
    return 'Import erfolgreich! $count Aktiva erstellt.';
  }

  @override
  String get importSerializedWarning =>
      'Import erfolgreich. Dieser Aktivtyp ist serialisiert — alle Elemente wurden mit Menge 1 erstellt.';

  @override
  String get integrations => 'Integrationen';

  @override
  String get integrationGeminiDesc =>
      'Verbinde Invenicum mit Google Gemini, um erweiterte KI-Funktionen in deiner Inventarverwaltung zu nutzen.';

  @override
  String get integrationTelegramDesc =>
      'Verbinde Invenicum mit Telegram, um sofortige Benachrichtigungen über dein Inventar direkt auf deinem Gerät zu erhalten.';

  @override
  String get invalidAssetId => 'Ungültige Aktiv-ID';

  @override
  String get invalidNavigationIds => 'Fehler: Ungültige Navigations-IDs.';

  @override
  String get inventoryLabel => 'Inventar';

  @override
  String get january => 'Januar';

  @override
  String get july => 'Juli';

  @override
  String get june => 'Juni';

  @override
  String get language => 'Sprache';

  @override
  String get languageChanged => 'Sprache auf Deutsch geändert!';

  @override
  String get languageNotImplemented =>
      'Sprachfunktion noch nicht implementiert';

  @override
  String get lightMode => 'Heller Modus';

  @override
  String get loadingAssetType => 'Aktivtyp wird geladen...';

  @override
  String loadingListField(String field) {
    return '$field wird geladen...';
  }

  @override
  String get loanDate => 'Ausleihdatum';

  @override
  String get loanLanguageNotImplemented =>
      'Sprachfunktion noch nicht implementiert';

  @override
  String get loanManagement => 'Ausleihverwaltung';

  @override
  String get loanObject => 'Auszuleihendes Objekt';

  @override
  String get loans => 'Ausleihen';

  @override
  String get location => 'Standort';

  @override
  String get locations => 'Standorte';

  @override
  String get locationsScheme => 'Standortschema';

  @override
  String get login => 'Anmelden';

  @override
  String get logoVoucher => 'Schein-Logo';

  @override
  String get logout => 'Abmelden';

  @override
  String get lookForContainersOrAssets => 'Container oder Aktiva suchen...';

  @override
  String get lowStockTitle => 'Niedriger Bestand';

  @override
  String get magicAssistant => 'KI-Magie-Assistent';

  @override
  String get march => 'März';

  @override
  String get marketPriceObtained => 'Marktpreis erfolgreich abgerufen';

  @override
  String get marketValueEvolution => 'Entwicklung des Marktwerts';

  @override
  String get marketValueField => 'Marktwert';

  @override
  String get marketRealRate => 'Realer Marktpreis';

  @override
  String get maxStock => 'Maximaler Bestand';

  @override
  String get may => 'Mai';

  @override
  String get minStock => 'Mindestbestand';

  @override
  String get myAchievements => 'Meine Erfolge';

  @override
  String get myCustomTheme => 'Mein Design';

  @override
  String get myProfile => 'Mein Profil';

  @override
  String get myThemesStored => 'Meine gespeicherten Designs';

  @override
  String get name => 'Name';

  @override
  String get nameCannotBeEmpty => 'Name darf nicht leer sein';

  @override
  String get nameSameAsCurrent => 'Name ist identisch mit dem aktuellen';

  @override
  String get newAlert => 'Neue manuelle Benachrichtigung';

  @override
  String get newContainer => 'Neuer Container';

  @override
  String get newName => 'Neuer Name';

  @override
  String get next => 'Weiter';

  @override
  String get noAssetsCreated => 'Noch keine Aktiva erstellt.';

  @override
  String get noAssetsMatch =>
      'Kein Aktiv entspricht den Such-/Filterkriterien.';

  @override
  String get noBooleanFields => 'Keine booleschen Felder definiert.';

  @override
  String get noContainerMessage => 'Erstelle deinen ersten Container.';

  @override
  String get noCustomFields =>
      'Dieser Aktivtyp hat keine benutzerdefinierten Felder.';

  @override
  String get noFileSelected => 'Keine Datei ausgewählt';

  @override
  String get noImageAvailable => 'Kein Bild verfügbar';

  @override
  String get noImagesAdded =>
      'Noch keine Bilder hinzugefügt. Das erste Bild wird das Hauptbild.';

  @override
  String get noLoansFound => 'Keine Ausleihen in diesem Container gefunden.';

  @override
  String get noLocationsMessage =>
      'Keine Standorte in diesem Container erstellt. Füge den ersten hinzu!';

  @override
  String get noNotifications => 'Keine Benachrichtigungen';

  @override
  String get noThemesSaved => 'Noch keine Designs gespeichert';

  @override
  String get none => 'Keine';

  @override
  String get november => 'November';

  @override
  String get obligatory => 'Pflichtfeld';

  @override
  String get october => 'Oktober';

  @override
  String get optimalStockStatus => 'Bestand auf optimalem Niveau';

  @override
  String get optional => 'Optional';

  @override
  String get overdue => 'Überfällig';

  @override
  String get password => 'Passwort';

  @override
  String get pleaseEnterPassword => 'Bitte Passwort eingeben';

  @override
  String get pleaseEnterUsername => 'Bitte Benutzernamen eingeben';

  @override
  String get pleasePasteUrl => 'Bitte URL einfügen';

  @override
  String get pleaseSelectCsvWithHeaders =>
      'Bitte wähle eine CSV-Datei mit Kopfzeilen aus.';

  @override
  String get pleaseSelectLocation => 'Bitte einen Standort auswählen.';

  @override
  String get plugins => 'Plugins';

  @override
  String get possessionFieldDef => 'Besitzfeld';

  @override
  String get possessionFieldName => 'Im Besitz';

  @override
  String get preferences => 'Einstellungen';

  @override
  String get previewPDF => 'Vorschau';

  @override
  String get previous => 'Zurück';

  @override
  String get primaryImage => 'Hauptbild';

  @override
  String get processing => 'Wird bearbeitet...';

  @override
  String get productUrlLabel => 'Produkt-URL';

  @override
  String get quantity => 'Menge';

  @override
  String get refresh => 'Daten neu laden';

  @override
  String get registerNewLoan => 'Neue Ausleihe registrieren';

  @override
  String get reloadContainers => 'Container neu laden';

  @override
  String get reloadLocations => 'Standorte neu laden';

  @override
  String get reloadLoans => 'Ausleihen neu laden';

  @override
  String get removeImage => 'Bild entfernen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get renameContainer => 'Container umbenennen';

  @override
  String get responsibleLabel => 'Verantwortlich';

  @override
  String get reports => 'Berichte';

  @override
  String get returned => 'Zurückgegeben';

  @override
  String get returnsLabel => 'Rückgaben';

  @override
  String get rowsPerPageTitle => 'Aktiva pro Seite:';

  @override
  String get save => 'Speichern';

  @override
  String get saveAndApply => 'Speichern und anwenden';

  @override
  String get saveAsset => 'Aktiv speichern';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get saveConfiguration => 'Konfiguration speichern';

  @override
  String get saveCustomTheme => 'Benutzerdefiniertes Design speichern';

  @override
  String get searchInAllColumns => 'In allen Spalten suchen...';

  @override
  String get selectAndUploadImage => 'Bild auswählen und hochladen';

  @override
  String get selectApplicationCurrency => 'App-Währung auswählen';

  @override
  String get selectApplicationLanguage => 'App-Sprache auswählen';

  @override
  String get selectBooleanFields =>
      'Boolesche Felder zur Sammlungskontrolle auswählen:';

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
      'Es muss ein Standort für das Aktiv ausgewählt werden.';

  @override
  String selectedLocationLabel(String name) {
    return 'Ausgewählt: $name';
  }

  @override
  String get selectTheme => 'Design auswählen';

  @override
  String get september => 'September';

  @override
  String get settings => 'Einstellungen';

  @override
  String get showAsGrid => 'Als Raster anzeigen';

  @override
  String get showAsList => 'Als Liste anzeigen';

  @override
  String get sortAsc => 'Aufsteigend';

  @override
  String get sortDesc => 'Absteigend';

  @override
  String get slotDashboardBottom => 'Dashboard unten';

  @override
  String get slotDashboardTop => 'Dashboard oben';

  @override
  String get slotFloatingActionButton => 'Schwebende Aktionsschaltfläche';

  @override
  String get slotInventoryHeader => 'Inventar-Kopfzeile';

  @override
  String get slotLeftSidebar => 'Linke Seitenleiste';

  @override
  String get slotUnknown => 'Unbekannter Slot';

  @override
  String get specificValueToCount => 'Spezifischer zu zählender Wert';

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
      'Schritt 2: Spalten-Zuordnung (CSV -> System)';

  @override
  String get syncingSession => 'Sitzung wird synchronisiert...';

  @override
  String get systemThemes => 'System-Designs';

  @override
  String get systemThemesModal => 'System-Designs';

  @override
  String get templates => 'Vorlagen';

  @override
  String get themeNameLabel => 'Design-Name';

  @override
  String get thisFieldIsRequired => 'Dieses Feld ist erforderlich.';

  @override
  String get topDemanded => 'Am meisten nachgefragt';

  @override
  String get topLoanedItems => 'Meistgeliehene Artikel nach Monaten';

  @override
  String get totalAssets => 'Aktivtypen';

  @override
  String get totalItems => 'Aktiva';

  @override
  String get totals => 'Gesamt';

  @override
  String get totalSpending => 'Gesamtinvestition';

  @override
  String get totalMarketValue => 'Gesamtmarktwert';

  @override
  String get updatedAt => 'Zuletzt aktualisiert';

  @override
  String get upload => 'Hochladen';

  @override
  String get uploadImage => 'Bild hochladen';

  @override
  String get username => 'Benutzername';

  @override
  String get copiedToClipboard => 'In Zwischenablage kopiert';

  @override
  String get connectionTestFailed => 'Verbindungstest fehlgeschlagen';

  @override
  String get connectionVerified => 'Verbindung erfolgreich verifiziert';

  @override
  String get errorSavingConfiguration =>
      'Fehler beim Speichern der Konfiguration';

  @override
  String get integrationsAndConnectionsTitle =>
      'Integrationen und Verbindungen';

  @override
  String get integrationsSectionAiTitle => 'Künstliche Intelligenz';

  @override
  String get integrationsSectionAiSubtitle =>
      'Konversationsengines und Assistenten zur Bereicherung von Abläufen und Automatisierungen.';

  @override
  String get integrationsSectionMessagingTitle =>
      'Messaging und Benachrichtigungen';

  @override
  String get integrationsSectionMessagingSubtitle =>
      'Ausgabekanäle für Hinweise, Bots, Berichte und automatische Lieferungen.';

  @override
  String get integrationsSectionDataApisTitle => 'Daten-APIs';

  @override
  String get integrationsSectionDataApisSubtitle =>
      'Externe Quellen zur Anreicherung von Karten, Spielen und Katalogreferenzen.';

  @override
  String get integrationsSectionValuationTitle => 'Bewertung und Markt';

  @override
  String get integrationsSectionValuationSubtitle =>
      'Konnektoren für Preise, Barcodes und aktuelle Wertschätzung.';

  @override
  String get integrationsSectionHardwareTitle => 'Hardware und Etiketten';

  @override
  String get integrationsSectionHardwareSubtitle =>
      'Physische Werkzeuge und Hilfsprogramme für Druck, Kodierung und Betrieb.';

  @override
  String integrationsActiveConnections(int count) {
    return '$count aktive Verbindungen';
  }

  @override
  String get integrationsModularDesign => 'Modulares Design nach Kategorien';

  @override
  String get integrationsCheckingStatuses => 'Status wird geprüft';

  @override
  String get integrationsStatusSynced => 'Status synchronisiert';

  @override
  String get integrationsHeroHeadline =>
      'Verbinde Dienste, APIs und Tools in einer klaren Ansicht.';

  @override
  String get integrationsHeroSubheadline =>
      'Wir gruppieren Integrationen nach Zweck, damit die Konfiguration schneller, visueller und auch auf dem Handy einfacher zu pflegen ist.';

  @override
  String get integrationStatusConnected => 'Verbunden';

  @override
  String get integrationStatusNotConfigured => 'Nicht konfiguriert';

  @override
  String get integrationTypeDataSource => 'Datenquelle';

  @override
  String get integrationTypeConnector => 'Konnektor';

  @override
  String integrationFieldsCount(int count) {
    return '$count Felder';
  }

  @override
  String get integrationNoLocalCredentials => 'Keine lokalen Anmeldedaten';

  @override
  String get configureLabel => 'Konfigurieren';

  @override
  String get integrationModelDefaultGemini =>
      'Standard: gemini-3-flash-preview';

  @override
  String get integrationOpenaiDesc =>
      'Nutze GPT-4o und andere OpenAI-Modelle als intelligenten Assistenten.';

  @override
  String get integrationOpenaiApiKeyHint =>
      'Erhältlich unter platform.openai.com/api-keys';

  @override
  String get integrationModelDefaultOpenai => 'Standard: gpt-4o';

  @override
  String get integrationClaudeDesc =>
      'Nutze Claude Sonnet, Opus und Haiku als intelligenten Assistenten.';

  @override
  String get integrationClaudeApiKeyHint =>
      'Erhältlich unter console.anthropic.com/settings/keys';

  @override
  String get integrationModelDefaultClaude => 'Standard: claude-sonnet-4-6';

  @override
  String get integrationTelegramBotTokenHint => 'Von @BotFather';

  @override
  String get integrationTelegramChatIdHint =>
      'Verwende @userinfobot, um deine ID zu erhalten';

  @override
  String get integrationEmailDesc =>
      'Höchst zuverlässiger E-Mail-Versand. Ideal für Berichte und kritische Warnungen.';

  @override
  String get integrationEmailApiKeyHint =>
      'Erhältlich unter resend.com/api-keys';

  @override
  String get integrationEmailFromLabel => 'Absender (Von)';

  @override
  String get integrationEmailFromHint =>
      'Bsp.: Invenicum <onboarding@resend.dev>';

  @override
  String get integrationBggDesc =>
      'Verbinde dein BGG-Konto, um deine Sammlung zu synchronisieren und Daten automatisch anzureichern.';

  @override
  String get integrationPokemonDesc =>
      'Verbinde dich mit der Pokemon-API, um deine Sammlung zu synchronisieren und Daten automatisch anzureichern.';

  @override
  String get integrationTcgdexDesc =>
      'Karten und Erweiterungen von Sammelkartenspielen abfragen, um dein Inventar automatisch anzureichern.';

  @override
  String get integrationQrGeneratorName => 'QR-Generator';

  @override
  String get integrationQrLabelsDesc =>
      'Format deiner druckbaren Etiketten konfigurieren.';

  @override
  String get integrationQrPageSizeLabel => 'Seitengröße (A4, Letter)';

  @override
  String get integrationQrMarginLabel => 'Rand (mm)';

  @override
  String get integrationPriceChartingDesc =>
      'API-Schlüssel konfigurieren, um aktuelle Preise zu erhalten.';

  @override
  String get integrationUpcitemdbDesc => 'Globale Preissuche per Barcode.';

  @override
  String integrationConfiguredSuccess(String name) {
    return '$name erfolgreich konfiguriert';
  }

  @override
  String integrationUnlinkedWithName(String name) {
    return '$name wurde getrennt';
  }

  @override
  String get invalidUiFormat => 'Ungültiges UI-Format';

  @override
  String get loadingConfiguration => 'Konfiguration wird geladen...';

  @override
  String pageNotFoundUri(String uri) {
    return 'Seite nicht gefunden: $uri';
  }

  @override
  String get pluginLoadError => 'Fehler beim Laden der Plugin-Oberfläche';

  @override
  String get pluginRenderError => 'Rendering-Fehler';

  @override
  String get testConnection => 'Verbindung testen';

  @override
  String get testingConnection => 'Wird getestet...';

  @override
  String get unableToUnlinkAccount => 'Konto konnte nicht getrennt werden';

  @override
  String get unlinkIntegrationUpper => 'INTEGRATION TRENNEN';

  @override
  String get upcFreeModeHint =>
      'Dieses Feld leer lassen, um den kostenlosen Modus (eingeschränkt) zu nutzen.';

  @override
  String get alertsTabLabel => 'Benachrichtigungen';

  @override
  String get alertMarkedAsRead => 'Als gelesen markiert';

  @override
  String get calendarTabLabel => 'Kalender';

  @override
  String get closeLabel => 'Schließen';

  @override
  String get closeLabelUpper => 'SCHLIESSEN';

  @override
  String get configureReminderLabel => 'Erinnerung konfigurieren:';

  @override
  String get cannotFormatInvalidJson =>
      'Ungültiges JSON kann nicht formatiert werden';

  @override
  String get createAlertOrEventTitle => 'Benachrichtigung/Ereignis erstellen';

  @override
  String get createdSuccessfully => 'Erfolgreich erstellt';

  @override
  String get createPluginTitle => 'Plugin erstellen';

  @override
  String get editPluginTitle => 'Plugin bearbeiten';

  @override
  String get deleteFromGithubLabel => 'Von GitHub löschen';

  @override
  String get deleteFromGithubSubtitle =>
      'Datei aus dem öffentlichen Markt entfernen';

  @override
  String get deletePluginQuestion => 'Plugin löschen?';

  @override
  String get deletePluginLocalWarning =>
      'Es wird aus deiner lokalen Datenbank gelöscht.';

  @override
  String get deleteUpper => 'LÖSCHEN';

  @override
  String get editEventTitle => 'Ereignis bearbeiten';

  @override
  String get editLabel => 'Bearbeiten';

  @override
  String get eventDataSection => 'Ereignisdaten';

  @override
  String get eventReminderAtTime => 'Zum Zeitpunkt des Ereignisses';

  @override
  String get eventUpdated => 'Ereignis aktualisiert';

  @override
  String get firstVersionHint => 'Die erste Version ist immer 1.0.0';

  @override
  String get fixJsonBeforeSave => 'JSON vor dem Speichern korrigieren';

  @override
  String get formatJson => 'JSON formatieren';

  @override
  String get goToProfileUpper => 'ZUM PROFIL';

  @override
  String get installPluginLabel => 'Plugin installieren';

  @override
  String get invalidVersionFormat => 'Ungültiges Format (Bsp.: 1.0.1)';

  @override
  String get isEventQuestion => 'Ist es ein Ereignis?';

  @override
  String get jsonErrorGeneric => 'Fehler im JSON';

  @override
  String get makePublicLabel => 'Öffentlich machen';

  @override
  String get markAsReadLabel => 'Als gelesen markieren';

  @override
  String get messageWithColon => 'Nachricht:';

  @override
  String minutesBeforeLabel(int minutes) {
    return '$minutes Minuten vorher';
  }

  @override
  String get newLabel => 'Neu';

  @override
  String get newPluginLabel => 'Neues Plugin';

  @override
  String get noActiveAlerts => 'Keine aktiven Benachrichtigungen';

  @override
  String get noDescriptionAvailable => 'Keine Beschreibung verfügbar.';

  @override
  String get noEventsForDay => 'Keine Ereignisse für diesen Tag';

  @override
  String get noPluginsAvailable => 'Keine Plugins vorhanden';

  @override
  String get notificationDeleted => 'Benachrichtigung erfolgreich gelöscht';

  @override
  String get oneHourBeforeLabel => '1 Stunde vorher';

  @override
  String get pluginPrivateDescription =>
      'Nur du kannst dieses Plugin in deiner Liste sehen.';

  @override
  String get pluginPublicDescription =>
      'Andere Benutzer können dieses Plugin sehen und installieren.';

  @override
  String get pluginTabLibrary => 'Bibliothek';

  @override
  String get pluginTabMarket => 'Marktplatz';

  @override
  String get pluginTabMine => 'Meine';

  @override
  String get previewLabel => 'Vorschau';

  @override
  String get remindMeLabel => 'Erinnere mich:';

  @override
  String get requiredField => 'Erforderlich';

  @override
  String get requiresGithubDescription =>
      'Um Plugins in der Community zu veröffentlichen, musst du dein GitHub-Konto verknüpfen, damit du als Autor anerkannt wirst.';

  @override
  String get requiresGithubTitle => 'GitHub erforderlich';

  @override
  String get slotLocationLabel => 'Standort (Slot)';

  @override
  String get stacDocumentation => 'Stac-Dokumentation';

  @override
  String get stacJsonInterfaceLabel => 'Stac JSON (Oberfläche)';

  @override
  String get uninstallLabel => 'Deinstallieren';

  @override
  String get unrecognizedStacStructure => 'Unbekannte Stac-Struktur';

  @override
  String get updateLabelUpper => 'AKTUALISIEREN';

  @override
  String updateToVersion(String version) {
    return 'Auf v$version aktualisieren';
  }

  @override
  String get versionLabel => 'Version';

  @override
  String get incrementVersionHint =>
      'Version für deinen Vorschlag erhöhen (Bsp.: 1.1.0)';

  @override
  String get cancelUpper => 'ABBRECHEN';

  @override
  String get mustLinkGithubToPublishTemplate =>
      'Du musst GitHub in deinem Profil verknüpfen, um zu veröffentlichen.';

  @override
  String get templateNeedsAtLeastOneField =>
      'Die Vorlage muss mindestens ein definiertes Feld haben.';

  @override
  String get templatePullRequestCreated =>
      'Vorschlag eingereicht. Ein Pull Request wurde auf GitHub erstellt.';

  @override
  String errorPublishingTemplate(String error) {
    return 'Fehler beim Veröffentlichen: $error';
  }

  @override
  String get createGlobalTemplateTitle => 'Globale Vorlage erstellen';

  @override
  String get githubVerifiedLabel => 'GitHub verifiziert';

  @override
  String get githubNotLinkedLabel => 'GitHub nicht verknüpft';

  @override
  String get veniDesignedTemplateBanner =>
      'Veni hat diese Struktur basierend auf deiner Anfrage entworfen. Überprüfe und passe sie vor der Veröffentlichung an.';

  @override
  String get templateNameLabel => 'Vorlagenname';

  @override
  String get templateNameHint => 'Bsp.: Meine Comic-Sammlung';

  @override
  String get githubUserLabel => 'GitHub-Benutzer';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get categoryHint => 'Bsp.: Bücher, Elektronik...';

  @override
  String get templatePurposeDescription => 'Zweckbeschreibung';

  @override
  String get definedFieldsTitle => 'Definierte Felder';

  @override
  String get addFieldButton => 'Feld hinzufügen';

  @override
  String get clickAddFieldToStart =>
      'Klicke auf \'Feld hinzufügen\', um mit dem Entwurf zu beginnen.';

  @override
  String get configureOptionsUpper => 'OPTIONEN KONFIGURIEREN';

  @override
  String get writeOptionAndPressEnter => 'Option eingeben und Enter drücken';

  @override
  String get publishOnGithubUpper => 'AUF GITHUB VERÖFFENTLICHEN';

  @override
  String get templateDetailFetchError =>
      'Vorlagendetail konnte nicht abgerufen werden';

  @override
  String get templateNotAvailable =>
      'Die Vorlage existiert nicht oder ist nicht verfügbar';

  @override
  String get backLabel => 'Zurück';

  @override
  String get templateDetailTitle => 'Vorlagen-Detail';

  @override
  String get saveToLibraryTooltip => 'In Bibliothek speichern';

  @override
  String templateByAuthor(String name) {
    return 'von @$name';
  }

  @override
  String get officialVerifiedTemplate => 'Offizielle verifizierte Vorlage';

  @override
  String dataStructureFieldsUpper(int count) {
    return 'DATENSTRUKTUR ($count FELDER)';
  }

  @override
  String get installInMyInventoryUpper => 'IN MEIN INVENTAR INSTALLIEREN';

  @override
  String get addedToPersonalLibrary =>
      'Zu deiner persönlichen Bibliothek hinzugefügt';

  @override
  String get whereDoYouWantToInstall => 'Wo möchtest du es installieren?';

  @override
  String get noContainersCreateFirst =>
      'Du hast keine Container. Erstelle zuerst einen.';

  @override
  String get autoGeneratedListFromTemplate =>
      'Automatisch aus Vorlage generierte Liste';

  @override
  String get installationSuccessAutoLists =>
      'Installation erfolgreich. Listen automatisch konfiguriert.';

  @override
  String errorInstallingTemplate(String error) {
    return 'Fehler bei der Installation: $error';
  }

  @override
  String get publishTemplateLabel => 'Vorlage veröffentlichen';

  @override
  String get retryLabel => 'Erneut versuchen';

  @override
  String get noTemplatesFoundInMarket =>
      'Keine Vorlagen im Marktplatz gefunden.';

  @override
  String get invenicumCommunity => 'Invenicum Community';

  @override
  String get refreshMarketTooltip => 'Marktplatz aktualisieren';

  @override
  String get exploreCommunityConfigurations =>
      'Community-Konfigurationen erkunden und herunterladen';

  @override
  String get searchByTemplateName => 'Nach Vorlagenname suchen...';

  @override
  String get filterByTagTooltip => 'Nach Tag filtern';

  @override
  String get noMoreTags => 'Keine weiteren Tags';

  @override
  String confirmDeleteDataList(String name) {
    return 'Bist du sicher, dass du die Liste \"$name\" löschen möchtest? Diese Aktion ist unwiderruflich.';
  }

  @override
  String dataListDeletedSuccess(String name) {
    return 'Liste \"$name\" erfolgreich gelöscht.';
  }

  @override
  String errorDeletingDataList(String error) {
    return 'Fehler beim Löschen der Liste: $error';
  }

  @override
  String customListsWithContainer(String name) {
    return 'Benutzerdefinierte Listen - $name';
  }

  @override
  String get newDataListLabel => 'Neue Liste';

  @override
  String get noCustomListsCreateOne =>
      'Keine benutzerdefinierten Listen. Erstelle eine neue.';

  @override
  String elementsCount(int count) {
    return '$count Elemente';
  }

  @override
  String get dataListNeedsAtLeastOneElement =>
      'Die Liste muss mindestens ein Element haben';

  @override
  String get customDataListCreated =>
      'Benutzerdefinierte Liste erfolgreich erstellt';

  @override
  String errorCreatingDataList(String error) {
    return 'Fehler beim Erstellen der Liste: $error';
  }

  @override
  String get newCustomDataListTitle => 'Neue benutzerdefinierte Liste';

  @override
  String get dataListNameLabel => 'Listenname';

  @override
  String get pleaseEnterAName => 'Bitte einen Namen eingeben';

  @override
  String get dataListElementsTitle => 'Listenelemente';

  @override
  String get newElementLabel => 'Neues Element';

  @override
  String get addLabel => 'Hinzufügen';

  @override
  String get addElementsToListHint => 'Elemente zur Liste hinzufügen';

  @override
  String get saveListLabel => 'Liste speichern';

  @override
  String get dataListUpdatedSuccessfully => 'Liste erfolgreich aktualisiert';

  @override
  String errorUpdatingDataList(String error) {
    return 'Fehler beim Aktualisieren der Liste: $error';
  }

  @override
  String editListWithName(String name) {
    return 'Liste bearbeiten: $name';
  }

  @override
  String get createNewLocationTitle => 'Neuen Standort erstellen';

  @override
  String get locationNameLabel => 'Standortname';

  @override
  String get locationNameHint => 'Bsp.: Regal B3, Serverraum';

  @override
  String get locationDescriptionHint => 'Zugangsinformationen, Inhaltstyp usw.';

  @override
  String get parentLocationLabel => 'Übergeordneter Standort (Enthält diesen)';

  @override
  String get noParentRootLocation =>
      'Kein übergeordneter Standort (Wurzel-Standort)';

  @override
  String get noneRootScheme => 'Kein übergeordneter (Schemawurzel)';

  @override
  String get savingLabel => 'Wird gespeichert...';

  @override
  String get saveLocationLabel => 'Standort speichern';

  @override
  String locationCreatedSuccessfully(String name) {
    return 'Standort \"$name\" erfolgreich erstellt.';
  }

  @override
  String errorCreatingLocation(String error) {
    return 'Fehler beim Erstellen des Standorts: $error';
  }

  @override
  String get locationCannotBeItsOwnParent =>
      'Ein Standort kann nicht sein eigener übergeordneter Standort sein.';

  @override
  String locationUpdatedSuccessfully(String name) {
    return 'Standort \"$name\" aktualisiert.';
  }

  @override
  String errorUpdatingLocation(String error) {
    return 'Fehler beim Aktualisieren des Standorts: $error';
  }

  @override
  String editLocationTitle(String name) {
    return 'Bearbeiten: $name';
  }

  @override
  String get updateLocationLabel => 'Standort aktualisieren';

  @override
  String get selectObjectTitle => 'Objekt auswählen';

  @override
  String get noObjectsAvailable => 'Keine Objekte verfügbar';

  @override
  String availableQuantity(int quantity) {
    return 'Verfügbar: $quantity';
  }

  @override
  String errorSelectingObject(String error) {
    return 'Fehler beim Auswählen des Objekts: $error';
  }

  @override
  String get mustSelectAnObject => 'Du musst ein Objekt auswählen';

  @override
  String get loanRegisteredSuccessfully => 'Ausleihe erfolgreich registriert';

  @override
  String get selectAnObject => 'Objekt auswählen';

  @override
  String get selectLabel => 'Auswählen';

  @override
  String get borrowerNameHint => 'Bsp.: Max Mustermann';

  @override
  String get borrowerNameRequired => 'Name ist erforderlich';

  @override
  String loanQuantityAvailable(int quantity) {
    return 'Auszuleihende Menge (Verfügbar: $quantity)';
  }

  @override
  String get enterQuantity => 'Menge eingeben';

  @override
  String get invalidQuantity => 'Ungültige Menge';

  @override
  String get notEnoughStock => 'Nicht genug Bestand';

  @override
  String get invalidEmail => 'Ungültige E-Mail';

  @override
  String expectedReturnDateLabel(String date) {
    return 'Erwartete Rückgabe: $date';
  }

  @override
  String get selectReturnDate => 'Rückgabedatum auswählen';

  @override
  String get additionalNotes => 'Zusätzliche Anmerkungen';

  @override
  String get registerLoanLabel => 'Ausleihe registrieren';

  @override
  String get totalLabel => 'Gesamt';

  @override
  String get newLocationLabel => 'Neuer Standort';

  @override
  String get newLocationHint => 'Bsp.: Regal A1, Schrank 3...';

  @override
  String get parentLocationOptionalLabel =>
      'Übergeordneter Standort (optional)';

  @override
  String get noneRootLabel => 'Keiner (Wurzel)';

  @override
  String locationCreatedShort(String name) {
    return 'Standort \"$name\" erstellt';
  }

  @override
  String get newLocationEllipsis => 'Neuer Standort...';

  @override
  String get couldNotReloadList => 'Liste konnte nicht neu geladen werden';

  @override
  String get deleteAssetTitle => 'Aktiv löschen';

  @override
  String confirmDeleteAssetItem(String name) {
    return 'Möchtest du \"$name\" wirklich löschen?';
  }

  @override
  String get assetDeletedShort => 'Aktiv gelöscht.';

  @override
  String viewColumnsLabel(int count) {
    return 'Ansicht: $count Sp.';
  }

  @override
  String get notValuedLabel => 'Nicht bewertet';

  @override
  String get manageSearchSyncAssets =>
      'Verwalte, suche und synchronisiere deine Aktiva in einem einzigen Dashboard.';

  @override
  String get filterLabel => 'Filter';

  @override
  String get activeFilterLabel => 'Aktiver Filter';

  @override
  String get importLabel => 'Importieren';

  @override
  String get exportLabel => 'Exportieren';

  @override
  String get csvExportNoData => 'Keine Elemente zum Exportieren.';

  @override
  String csvExportSuccess(int count) {
    return 'CSV erfolgreich exportiert ($count Elemente).';
  }

  @override
  String get csvExportError => 'CSV konnte nicht exportiert werden';

  @override
  String get syncLabel => 'Preise synchronisieren';

  @override
  String get syncingLabel => 'Wird synchronisiert...';

  @override
  String get newAssetLabel => 'Neues Aktiv';

  @override
  String get statusAndPreferences => 'Status und Einstellungen';

  @override
  String get itemStatusLabel => 'Element-Status';

  @override
  String get availableLabel => 'Verfügbar';

  @override
  String get mustBeGreaterThanZero => 'Muss größer als 0 sein.';

  @override
  String get alertThresholdLabel => 'Warnschwelle';

  @override
  String get enterMinimumStock => 'Mindestbestand eingeben.';

  @override
  String get serializedItemFixedQuantity =>
      'Dies ist ein serialisierter Artikel. Die Menge ist fest auf 1 gesetzt.';

  @override
  String get serialNumberLabel => 'Seriennummer';

  @override
  String get serialNumberHint => 'Bsp.: SN-2024-00123';

  @override
  String get mainDataTitle => 'Hauptdaten';

  @override
  String get currentMarketValueLabel => 'AKTUELLER MARKTWERT';

  @override
  String get updatePriceLabel => 'Preis aktualisieren';

  @override
  String get viewLabel => 'Ansicht';

  @override
  String get visualGalleryTitle => 'Visuelle Galerie';

  @override
  String get statusAndMarketTitle => 'Status und Markt';

  @override
  String get valuationHistoryTitle => 'Bewertungsverlauf';

  @override
  String get specificationsTitle => 'Spezifikationen';

  @override
  String get traceabilityTitle => 'Rückverfolgbarkeit';

  @override
  String get stockLabel => 'Bestand';

  @override
  String get internalReferenceLabel => 'Interne Referenz';

  @override
  String get noSpecificationsAvailable => 'Keine Spezifikationen verfügbar';

  @override
  String get trueLabel => 'Wahr';

  @override
  String get falseLabel => 'Falsch';

  @override
  String get openLinkLabel => 'Link öffnen';

  @override
  String get scannerFocusTip =>
      'Tipp: Wenn der Fokus nicht funktioniert, halte das Produkt ca. 30 cm von der Kamera entfernt.';

  @override
  String get scanCodeTitle => 'Code scannen';

  @override
  String get scanOrEnterProductCode => 'Produktcode scannen oder eingeben';

  @override
  String possessionProgressLabel(String name) {
    return 'Fortschritt von $name';
  }

  @override
  String get externalImportTitle => 'Aus externer Quelle importieren';

  @override
  String get galleryTitle => 'Galerie';

  @override
  String get stockAndCodingTitle => 'Bestand und Codierung';

  @override
  String get cameraPermissionRequired =>
      'Kameraerlaubnis zum Scannen erforderlich';

  @override
  String get cloudDataFound => 'Daten in der Cloud gefunden!';

  @override
  String get typeSomethingToSearch => 'Etwas eingeben, um zu suchen';

  @override
  String get importCancelled => 'Import abgebrochen.';

  @override
  String get couldNotCompleteImport =>
      'Import konnte nicht abgeschlossen werden';

  @override
  String get yearLabel => 'Jahr';

  @override
  String get authorLabel => 'Autor';

  @override
  String get selectResultTitle => 'Ergebnis auswählen';

  @override
  String get unnamedLabel => 'Ohne Namen';

  @override
  String get completeRequiredFields => 'Bitte die Pflichtfelder ausfüllen.';

  @override
  String get assetCreatedSuccess => 'Aktiv erstellt!';

  @override
  String errorCreatingAsset(String error) {
    return 'Fehler beim Erstellen des Aktivs: $error';
  }

  @override
  String get technicalDetailsTitle => 'Technische Details';

  @override
  String itemImportedSuccessfully(String name) {
    return '$name erfolgreich importiert!';
  }

  @override
  String newImagesSelected(int count) {
    return '$count neue Bilder ausgewählt.';
  }

  @override
  String get newFileRemoved => 'Neue Datei entfernt.';

  @override
  String get imageMarkedForDeletion =>
      'Bild beim Speichern zum Löschen markiert.';

  @override
  String get couldNotIdentifyImage => 'Bild konnte nicht identifiziert werden.';

  @override
  String editAssetTitle(String name) {
    return 'Bearbeiten: $name';
  }

  @override
  String get syncPricesTitle => 'Preise synchronisieren';

  @override
  String get syncPricesDescription =>
      'Die API wird abgefragt, um den Marktwert zu aktualisieren.';

  @override
  String get syncingMarketPrices => 'Marktpreise werden synchronisiert...';

  @override
  String get couldNotSyncPrices => 'Preise konnten nicht synchronisiert werden';

  @override
  String get syncCompletedTitle => 'Synchronisierung abgeschlossen';

  @override
  String get updatedLabel => 'Aktualisiert';

  @override
  String get noApiPriceLabel => 'Kein Preis in API';

  @override
  String get errorsLabel => 'Fehler';

  @override
  String get totalProcessedLabel => 'Gesamt verarbeitet';

  @override
  String get noAssetsToShow => 'Keine Aktiva zum Anzeigen';

  @override
  String get noImageLabel => 'Kein Bild';

  @override
  String get aiMagicQuestion => 'Hast du einen Link?';

  @override
  String get aiAutocompleteAsset => 'Dieses Aktiv mit KI automatisch ausfüllen';

  @override
  String get magicLabel => 'MAGIE';

  @override
  String get skuBarcodeLabel => 'SKU / EAN / UPC';

  @override
  String get veniChatPlaceholder => 'Frag mich etwas...';

  @override
  String get veniChatPoweredBy => 'Powered by ';

  @override
  String veniChatProcessing(String query) {
    return 'Ich verarbeite deine Anfrage zu \"$query\"...';
  }

  @override
  String get veniChatStatus => 'Online';

  @override
  String get veniChatTitle => 'Venibot KI';

  @override
  String get veniChatWelcome =>
      'Hallo! Ich bin Venibot, dein Invenicum-Assistent. Wie kann ich dir heute bei deinem Inventar helfen?';

  @override
  String get veniCmdDashboard => 'Zum Dashboard gehen';

  @override
  String get veniCmdHelpTitle => 'Venis Fähigkeiten';

  @override
  String get veniCmdInventory => 'Bestand eines Artikels abfragen';

  @override
  String get veniCmdLoans => 'Aktive Ausleihen anzeigen';

  @override
  String get veniCmdReport => 'Inventarbericht erstellen';

  @override
  String get veniCmdScanQR => 'QR-/Barcode scannen';

  @override
  String get veniCmdUnknown =>
      'Diesen Befehl kenne ich nicht. Tippe Hilfe, um zu sehen, was ich kann.';

  @override
  String version(String name) {
    return 'Version $name';
  }

  @override
  String get yes => 'Ja';

  @override
  String get zoomToFit => 'Ansicht anpassen';

  @override
  String get generalSettingsMenuLabel => 'Allgemeine Einstellungen';

  @override
  String get aiAssistantMenuLabel => 'KI-Assistent';

  @override
  String get notificationsMenuLabel => 'Benachrichtigungen';

  @override
  String get loanManagementMenuLabel => 'Ausleihverwaltung';

  @override
  String get aboutMenuLabel => 'Info';

  @override
  String get automaticDarkModeLabel => 'Automatischer Dunkelmodus';

  @override
  String get syncWithSystemLabel => 'Mit System synchronisieren';

  @override
  String get manualDarkModeLabel => 'Manueller Dunkelmodus';

  @override
  String get disableAutomaticToChange =>
      'Automatischen Modus deaktivieren, um ihn zu ändern';

  @override
  String get changeLightDark => 'Zwischen Hell und Dunkel wechseln';

  @override
  String get enableAiAndChatbot =>
      'Künstliche Intelligenz und Chatbot aktivieren';

  @override
  String get requiresGeminiLinking =>
      'Erfordert Verknüpfung mit Gemini unter Integrationen';

  @override
  String get aiOrganizeInventory =>
      'KI nutzen, um dein Inventar intelligent zu organisieren';

  @override
  String get aiAssistantTitle => 'KI-Assistent';

  @override
  String get selectAiProvider =>
      'Wähle, welchen KI-Anbieter Veni verwenden soll. Stelle sicher, dass der API-Schlüssel unter Integrationen konfiguriert ist.';

  @override
  String get aiProviderLabel => 'Anbieter';

  @override
  String get aiModelLabel => 'Modell';

  @override
  String get aiProviderUpdated => 'KI-Anbieter aktualisiert';

  @override
  String get purgeChatHistoryTitle => 'Chatverlauf';

  @override
  String get purgeChatHistoryDescription =>
      'Löscht dauerhaft den gesamten gespeicherten Gesprächsverlauf von Veni.';

  @override
  String get purgeChatHistoryButton => 'Verlauf löschen';

  @override
  String get purgeChatHistoryConfirmTitle => 'Chatverlauf löschen?';

  @override
  String get purgeChatHistoryConfirmMessage =>
      'Diese Aktion löscht alle gespeicherten Nachrichten und kann nicht rückgängig gemacht werden.';

  @override
  String get purgeChatHistoryConfirmAction => 'Ja, löschen';

  @override
  String get purgeChatHistorySuccess => 'Chatverlauf erfolgreich gelöscht.';

  @override
  String get purgeChatHistoryError =>
      'Chatverlauf konnte nicht gelöscht werden.';

  @override
  String get notificationSettingsTitle => 'Benachrichtigungsverwaltung';

  @override
  String get channelPriorityLabel => 'Kanalpriorität (Zum Sortieren ziehen)';

  @override
  String get telegramBotLabel => 'Telegram Bot';

  @override
  String get resendEmailLabel => 'Resend E-Mail';

  @override
  String get lowStockLabel => 'Niedriger Bestand';

  @override
  String get lowStockHint =>
      'Benachrichtigen, wenn ein Produkt unter das Minimum fällt.';

  @override
  String get newPresalesLabel => 'Neue Vorbestellungen';

  @override
  String get newPresalesHint =>
      'Über von der KI erkannte Markteinführungen benachrichtigen.';

  @override
  String get loanReminderLabel => 'Ausleih-Erinnerung';

  @override
  String get loanReminderHint => 'Vor dem Rückgabedatum benachrichtigen.';

  @override
  String get overdueLoansLabel => 'Überfällige Ausleihen';

  @override
  String get overdueLoansHint =>
      'Kritische Warnung, wenn ein Objekt nicht rechtzeitig zurückgegeben wird.';

  @override
  String get maintenanceLabel => 'Wartung';

  @override
  String get maintenanceHint =>
      'Benachrichtigen, wenn ein Aktiv überprüft werden muss.';

  @override
  String get priceChangeLabel => 'Preisänderungen';

  @override
  String get priceChangeHint =>
      'Über Wertschwankungen auf dem Markt benachrichtigen.';

  @override
  String get unlinkGithubTitle => 'GitHub trennen';

  @override
  String get unlinkGithubMessage =>
      'Bist du sicher, dass du dein GitHub-Konto trennen möchtest?';

  @override
  String get updatePasswordButton => 'PASSWORT AKTUALISIEREN';

  @override
  String get profileFillAllFieldsError => 'Bitte fülle alle Felder aus';

  @override
  String get profilePasswordUpdatedSuccess =>
      'Passwort erfolgreich aktualisiert!';

  @override
  String get profileDisconnectActionUpper => 'TRENNEN';

  @override
  String get profileGithubUnlinkedSuccess => 'GitHub erfolgreich getrennt';

  @override
  String get profileGithubLinkedSuccess => 'GitHub erfolgreich verknüpft!';

  @override
  String profileGithubProcessError(String error) {
    return 'Fehler beim Verarbeiten der GitHub-Verknüpfung: $error';
  }

  @override
  String get profileGithubConfigUnavailableError =>
      'Fehler: GitHub-Konfiguration nicht verfügbar';

  @override
  String profileServerConnectionError(String error) {
    return 'Verbindung zum Server fehlgeschlagen: $error';
  }

  @override
  String get profileUpdatedSuccess => 'Profil erfolgreich aktualisiert';

  @override
  String profileUpdateError(String error) {
    return 'Fehler beim Aktualisieren des Profils: $error';
  }

  @override
  String get profileUsernameCommunityLabel => 'Benutzername (Community)';

  @override
  String get profileUsernameCommunityHelper =>
      'Erforderlich, um Plugins zu veröffentlichen.';

  @override
  String get profileUpdateButtonUpper => 'PROFIL AKTUALISIEREN';

  @override
  String get profileGithubIdentityTitle => 'GitHub-Identität';

  @override
  String profileGithubLinkedAs(String username) {
    return 'Verknüpft als @$username';
  }

  @override
  String get profileGithubLinkPrompt =>
      'Verknüpfe dein Konto, um Plugins zu veröffentlichen';

  @override
  String get profileGithubUsernameHint => 'Dein GitHub-Benutzername';

  @override
  String get profileGithubFieldHint =>
      'Dieses Feld wird automatisch nach der GitHub-Authentifizierung ausgefüllt.';

  @override
  String get profileGithubDefaultMissingKeys =>
      'GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET';

  @override
  String profileGithubOAuthNotConfigured(String missing) {
    return 'GitHub OAuth nicht konfiguriert. Fehlend: $missing. Konfiguriere GITHUB_CLIENT_ID und GITHUB_CLIENT_SECRET im Backend und starte den Server neu.';
  }

  @override
  String get profileDisconnectGithubButton => 'GitHub trennen';

  @override
  String get profileLinkGithubButton => 'Mit GitHub verknüpfen';

  @override
  String get profileSecurityTitle => 'Sicherheit';

  @override
  String get profileChangeUpper => 'ÄNDERN';

  @override
  String get profileCurrentPasswordLabel => 'Aktuelles Passwort';

  @override
  String get profileNewPasswordLabel => 'Neues Passwort';

  @override
  String get profileConfirmNewPasswordLabel => 'Neues Passwort bestätigen';

  @override
  String get profileChangePasswordHint =>
      'Ändere dein Passwort regelmäßig, um dein Konto sicher zu halten.';

  @override
  String get newContainerDialog => 'Neuer Container';

  @override
  String get descriptionField => 'Beschreibung';

  @override
  String get isCollectionQuestion => 'Ist es eine Sammlung?';

  @override
  String get createContainerButton => 'Container erstellen';

  @override
  String get selectContainerHint => 'Container auswählen';

  @override
  String get newAssetTypeTitle => 'Neuer Aktivtyp';

  @override
  String get generalConfiguration => 'Allgemeine Konfiguration';

  @override
  String get collectionContainerWarning =>
      'Dieser Container ist eine Sammlung. Du kannst serialisierte oder nicht serialisierte Typen erstellen, aber Besitz- und Wunschfelder können nur bei nicht serialisierten Typen konfiguriert werden.';

  @override
  String get createAssetTypeButton => 'Aktivtyp erstellen';

  @override
  String assetTypesInContainer(String name) {
    return 'Aktivtypen in \"$name\"';
  }

  @override
  String get createNewTypeButton => 'Neuen Typ erstellen';

  @override
  String get isSerializedQuestion => 'Ist es ein serialisierter Artikel?';

  @override
  String get addNewFieldButton => 'Neues Feld hinzufügen';

  @override
  String get deleteFieldTooltip => 'Feld löschen';

  @override
  String get fieldsOptions => 'Optionen:';

  @override
  String get isRequiredField => 'Ist Pflichtfeld';

  @override
  String get isSummativeFieldLabel =>
      'Ist summativ (Wird zum Typ-Gesamtwert addiert)';

  @override
  String get isMonetaryValueLabel => 'Ist Geldwert';

  @override
  String get monetaryValueDescription =>
      'Wird zur Berechnung der Gesamtinvestition im Dashboard verwendet';

  @override
  String get noDataListsAvailable =>
      '⚠️ Keine Datenlisten in diesem Container verfügbar.';

  @override
  String get selectDataList => 'Datenliste auswählen';

  @override
  String get chooseList => 'Liste auswählen';

  @override
  String get goToPageLabel => 'Zur Seite:';

  @override
  String get conditionLabel => 'Zustand';

  @override
  String get actionsLabel => 'Aktionen';

  @override
  String get editButtonLabel => 'Bearbeiten';

  @override
  String get deleteButtonLabel => 'Löschen';

  @override
  String get printLabel => 'Etikett drucken';

  @override
  String get collectionFieldsTooltip => 'Sammlungsfelder';

  @override
  String totalLocations(int count) {
    return '$count Standorte';
  }

  @override
  String withoutLocationLabel(int count) {
    return '$count ohne Standort · ';
  }

  @override
  String get objectIdColumn => 'Obj.-ID';

  @override
  String containerNotFoundError(String id) {
    return 'Container mit ID $id nicht gefunden.';
  }

  @override
  String get invalidContainerIdError => 'Fehler: Ungültige Container-ID.';

  @override
  String get startConfigurationButton => 'Konfiguration starten';

  @override
  String get fullNameField => 'Vollständiger Name';

  @override
  String get emailField => 'E-Mail-Adresse';

  @override
  String get passwordField => 'Passwort';

  @override
  String get confirmPasswordField => 'Passwort bestätigen';

  @override
  String get goBackButton => 'Zurück';

  @override
  String get createAccountButton => 'Konto erstellen';

  @override
  String get goToLoginButton => 'Zur Anmeldung';

  @override
  String get deleteConfirmationTitle => 'Löschen bestätigen';

  @override
  String deleteItemMessage(String name) {
    return 'Möchtest du \"$name\" löschen?';
  }

  @override
  String get elementDeletedSuccess => 'Element erfolgreich gelöscht';

  @override
  String get enterYourNameValidation => 'Gib deinen Namen ein.';

  @override
  String get minTwoCharactersValidation => 'Mindestens 2 Zeichen.';

  @override
  String get enterEmailValidation => 'Gib eine E-Mail ein.';

  @override
  String get invalidEmailValidation => 'Ungültige E-Mail.';

  @override
  String get enterPasswordValidation => 'Gib ein Passwort ein.';

  @override
  String get minEightCharactersValidation => 'Mindestens 8 Zeichen.';

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
  String get invalidIdError => 'Ungültige ID';

  @override
  String assetTypeLoadError(String error) {
    return 'Fehler beim Laden der Daten: $error';
  }

  @override
  String get assetTypeUpdateSuccess => 'Aktivtyp erfolgreich aktualisiert';

  @override
  String assetTypeUpdateError(String error) {
    return 'Fehler beim Aktualisieren: $error';
  }

  @override
  String editAssetTypeTitle(String name) {
    return 'Bearbeiten: $name';
  }

  @override
  String get achievementCollectionTitle => 'Sammlungserfolge';

  @override
  String get achievementSubtitle =>
      'Schalte Meilensteine durch die Nutzung von Invenicum frei';

  @override
  String get legendaryAchievementLabel => 'LEGENDÄRER ERFOLG';

  @override
  String get achievementCompleted => 'Abgeschlossen';

  @override
  String get achievementLocked => 'Gesperrt';

  @override
  String achievementUnlockedDate(String date) {
    return 'Erreicht am $date';
  }

  @override
  String get achievementLockedMessage => 'Ziel erfüllen, um freizuschalten';

  @override
  String get closeButtonLabel => 'Verstanden';

  @override
  String get configurationGeneralSection => 'Allgemeine Konfiguration';

  @override
  String get assetTypeCollectionWarning =>
      'Dieser Container ist eine Sammlung. Du kannst serialisierte oder nicht serialisierte Typen erstellen, aber Besitz- und Wunschfelder können nur bei nicht serialisierten Typen konfiguriert werden.';

  @override
  String get updateAssetTypeButton => 'Aktivtyp aktualisieren';

  @override
  String get createAssetTypeButtonDefault => 'Aktivtyp erstellen';

  @override
  String get noAssetTypesMessage =>
      'In diesem Container sind noch keine Aktivtypen definiert.';

  @override
  String totalCountLabel(int count) {
    return 'Gesamt: $count';
  }

  @override
  String possessionCountLabel(int count) {
    return 'Besitz: $count';
  }

  @override
  String desiredCountLabel(int count) {
    return 'Gewünscht: $count';
  }

  @override
  String get marketValueLabel => 'Markt: ';

  @override
  String get defaultSumFieldName => 'Summe';

  @override
  String get calculatingLabel => 'Wird berechnet...';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get noNameItem => 'Ohne Namen';

  @override
  String get loadingContainers => 'Container werden geladen...';

  @override
  String get fieldNameRequired => 'Feldname ist erforderlich';

  @override
  String get selectImageButton => 'Bild auswählen';

  @override
  String assetTypeDeletedSuccess(String name) {
    return '$name gelöscht';
  }

  @override
  String get noLocationValueData =>
      'Noch keine Aktiva mit Standort und ausreichendem Wert, um dieses Diagramm zu erstellen.';

  @override
  String get requiredFieldValidation => 'Dieses Feld ist erforderlich';

  @override
  String get oceanTheme => 'Indischer Ozean';

  @override
  String get cherryBlossomTheme => 'Kirschblüte';

  @override
  String get themeBrand => 'Invenicum (Marke)';

  @override
  String get themeEmerald => 'Smaragd';

  @override
  String get themeSunset => 'Sonnenuntergang';

  @override
  String get themeLavender => 'Sanfter Lavendel';

  @override
  String get themeForest => 'Tiefer Wald';

  @override
  String get themeCherry => 'Kirsche';

  @override
  String get themeElectricNight => 'Elektrische Nacht';

  @override
  String get themeAmberGold => 'Bernsteingold';

  @override
  String get themeModernSlate => 'Modernes Schiefer';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeNordicArctic => 'Nordisches Arktis';

  @override
  String get themeDeepNight => 'Tiefe Nacht';

  @override
  String get loginSuccess => 'Anmeldung erfolgreich';

  @override
  String get reloadListError => 'Liste konnte nicht neu geladen werden';

  @override
  String get copyItemSuffix => 'Kopie';

  @override
  String itemCopiedSuccess(String name) {
    return 'Element kopiert: $name';
  }

  @override
  String get copyError => 'Fehler beim Kopieren';

  @override
  String get imageColumnLabel => 'Bild';

  @override
  String get viewImageTooltip => 'Bild anzeigen';

  @override
  String get currentStockLabel => 'Aktueller Bestand';

  @override
  String get minimumStockLabel => 'Mindestbestand';

  @override
  String get locationColumnLabel => 'Standort';

  @override
  String get serialNumberColumnLabel => 'Seriennummer';

  @override
  String get marketPriceLabel => 'Marktpreis';

  @override
  String get conditionColumnLabel => 'Zustand';

  @override
  String get actionsColumnLabel => 'Aktionen';

  @override
  String get imageLoadError => 'Bild konnte nicht geladen werden';

  @override
  String get imageUrlHint =>
      'Stelle sicher, dass die URL korrekt ist und der Server aktiv ist';

  @override
  String get assetTypeNameHint => 'Bsp.: Laptop, Chemikalie';

  @override
  String get assetTypeNameLabel => 'Name des Aktivtyps';

  @override
  String get underConstruction => 'Im Aufbau';

  @override
  String get comingSoon => 'Demnächst';

  @override
  String get constructionSubtitle => 'Diese Funktion wird gerade entwickelt';

  @override
  String get selectColor => 'Farbe auswählen';

  @override
  String get valueDistributionByLocation => 'Wertverteilung nach Standort';

  @override
  String get heatmapDescription =>
      'Der Donut zeigt, wie sich der Marktwert auf die wichtigsten Standorte verteilt.';

  @override
  String locationsCount(int count) {
    return '$count Standorte';
  }

  @override
  String get unitsLabel => 'Stk.';

  @override
  String get recordsLabel => 'Einträge';

  @override
  String get totalValueFallback => 'Gesamtwert';

  @override
  String containerFallback(String id) {
    return 'Container $id';
  }

  @override
  String locationFallback(String id) {
    return 'Standort $id';
  }

  @override
  String get ofTheValueLabel => 'des Werts';

  @override
  String get reportsDescription =>
      'Berichte als PDF oder Excel erstellen, um sie zu drucken oder auf dem PC zu speichern';

  @override
  String get reportSectionType => 'Berichtstyp';

  @override
  String get reportSectionFormat => 'Ausgabeformat';

  @override
  String get reportSectionPreview => 'Aktuelle Konfiguration';

  @override
  String get reportSelectContainerTitle => 'Container auswählen';

  @override
  String get reportGenerate => 'Bericht erstellen';

  @override
  String get reportGenerating => 'Wird erstellt...';

  @override
  String get reportTypeInventoryDescription => 'Vollständige Inventarliste';

  @override
  String get reportTypeLoansDescription => 'Aktive Ausleihen und ihr Status';

  @override
  String get reportTypeAssetsDescription => 'Aktivliste nach Kategorie';

  @override
  String get reportLabelContainer => 'Container';

  @override
  String get reportLabelType => 'Berichtstyp';

  @override
  String get reportLabelFormat => 'Format';

  @override
  String get reportFormatPdf => 'PDF';

  @override
  String get reportFormatExcel => 'Excel';

  @override
  String get reportNotSelected => 'Nicht ausgewählt';

  @override
  String get reportUnknown => 'Unbekannt';

  @override
  String get reportSelectContainerFirst =>
      'Bitte zuerst einen Container auswählen';

  @override
  String reportDownloadedSuccess(String format) {
    return 'Bericht $format erfolgreich heruntergeladen';
  }

  @override
  String reportGenerateError(String error) {
    return 'Fehler beim Erstellen des Berichts: $error';
  }

  @override
  String get firstRunWelcomeTitle => 'Willkommen bei Invenicum';

  @override
  String get firstRunConfigTitle => 'Erstmalige Einrichtung';

  @override
  String get firstRunWelcomeDescription =>
      'Es sieht so aus, als würde die App zum ersten Mal gestartet. Lassen Sie uns Ihr Admin-Konto erstellen, um zu beginnen.';

  @override
  String get firstRunStep1Label => 'Schritt 1 von 2 · Willkommen';

  @override
  String get firstRunStep2Label => 'Schritt 2 von 2 · Admin erstellen';

  @override
  String get firstRunSuccessMessage => 'Ihr Konto wurde erstellt';

  @override
  String get firstRunAdminTitle => 'Admin erstellen';

  @override
  String get firstRunAdminDescription =>
      'Dieser Benutzer hat vollständigen Zugriff auf die Plattform.';

  @override
  String get firstRunFeature1 => 'Erstellen Sie Ihren Admin-Benutzer';

  @override
  String get firstRunFeature2 => 'Sicherer Zugriff mit Passwort';

  @override
  String get firstRunFeature3 => 'Einsatzbereit in Sekunden';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein.';

  @override
  String get firstRunSuccessTitle => 'Konto erstellt!';

  @override
  String get firstRunSuccessSubtitle =>
      'Ihr Admin-Konto ist bereit.\\nSie können sich jetzt anmelden.';

  @override
  String get firstRunAccountCreatedLabel => 'KONTO ERSTELLT';

  @override
  String get firstRunCopyright => 'Invenicum ©';

  @override
  String get addImageFromUrl => 'Bild von URL hinzufügen';

  @override
  String get imageDownloadedSuccessfully => 'Bild erfolgreich heruntergeladen';

  @override
  String errorDownloadingImage(String error) {
    return 'Fehler beim Herunterladen des Bildes: $error';
  }
}
