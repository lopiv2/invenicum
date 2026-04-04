// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get aboutInvenicum => 'Informazioni su Invenicum';

  @override
  String get active => 'Attivo';

  @override
  String get actives => 'Actives';

  @override
  String get activeInsight => 'ACTIVE ASSETS INSIGHTS';

  @override
  String get activeLoans => 'Prestiti attivi';

  @override
  String get activeLoansCount => 'Prestiti attivi';

  @override
  String get addAlert => 'Aggiungi avviso';

  @override
  String get addAsset => 'Aggiungi risorsa';

  @override
  String get addContainer => 'Aggiungi contenitore';

  @override
  String get addNewLocation => 'Aggiungi nuova posizione';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get additionalThumbnails => 'Miniature aggiuntive';

  @override
  String get adquisition => 'ADQUISITION';

  @override
  String aiExtractionError(String error) {
    return 'L\'IA non ha potuto estrarre i dati: $error';
  }

  @override
  String get aiPasteUrlDescription =>
      'Incolla il link del prodotto e l\'IA estrarrà automaticamente le informazioni per compilare i campi.';

  @override
  String get alertCritical => 'Critico';

  @override
  String get alertCreated => 'Avviso creato';

  @override
  String get alertDeleted => 'Avviso eliminato';

  @override
  String get alertInfo => 'Informazioni';

  @override
  String get alertMessage => 'Messaggio';

  @override
  String get alertTitle => 'Titolo';

  @override
  String get alertType => 'Tipo';

  @override
  String get alertWarning => 'Avviso';

  @override
  String get alerts => 'Avvisi e notifiche';

  @override
  String get all => 'Tutto';

  @override
  String get allUpToDateStatus => 'All up to date';

  @override
  String get appTitle => 'Invenicum Inventario';

  @override
  String get applicationTheme => 'Tema dell\'applicazione';

  @override
  String get apply => 'Applica';

  @override
  String get april => 'Aprile';

  @override
  String get assetDetail => 'Asset Details';

  @override
  String get assetImages => 'Immagini risorse';

  @override
  String get assetImport => 'Importazione risorse';

  @override
  String get assetName => 'Nome risorsa';

  @override
  String get assetNotFound => 'Asset not found';

  @override
  String assetTypeDeleted(String name) {
    return 'Tipo di risorsa \"$name\" eliminato con successo.';
  }

  @override
  String get assetTypes => 'Tipi di risorse';

  @override
  String assetUpdated(String name) {
    return 'Risorsa \"$name\" aggiornata con successo.';
  }

  @override
  String get assets => 'Risorse';

  @override
  String get assetsIn => 'Risorse in';

  @override
  String get august => 'Agosto';

  @override
  String get backToAssetTypes => 'Torna ai tipi di risorse';

  @override
  String get averageMarketValue => 'Average market price';

  @override
  String get barCode => 'Barcode (UPC)';

  @override
  String get baseCostAccumulatedWithoutInflation =>
      'Base cost accumulated without inflation';

  @override
  String get borrowerEmail => 'Email mutuatario';

  @override
  String get borrowerName => 'Nome mutuatario';

  @override
  String get borrowerPhone => 'Telefono mutuatario';

  @override
  String get cancel => 'Annulla';

  @override
  String get centerView => 'Vista centrale';

  @override
  String get chooseFile => 'Scegli file';

  @override
  String get clearCounter => 'Cancella contatore';

  @override
  String get collectionContainerInfo =>
      'I contenitori di raccolta hanno barre di tracciamento della raccolta, valore investito, valore di mercato e vista Esposizione';

  @override
  String get collectionFieldsConfigured => 'Campi di raccolta configurati.';

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
  String get configureCollectionFields => 'Configura campi di raccolta';

  @override
  String get configureDeliveryVoucher => 'Configura buono di consegna';

  @override
  String get configureVoucherBody => 'Configura il corpo del buono...';

  @override
  String get confirmDeleteAlert => 'Elimina avviso';

  @override
  String get confirmDeleteAlertMessage =>
      'Sei sicuro di voler eliminare questo record?';

  @override
  String confirmDeleteAssetType(String name) {
    return 'Sei sicuro di voler eliminare il tipo di risorsa \"$name\" e tutti gli elementi associati? Questa azione non può essere annullata.';
  }

  @override
  String confirmDeleteContainer(String name) {
    return 'Sei sicuro di voler eliminare il contenitore \"$name\"? Questa azione è irreversibile e rimuoverà tutte le sue risorse e dati.';
  }

  @override
  String confirmDeleteLocationMessage(String name) {
    return 'Sei sicuro di voler eliminare la posizione \"$name\"?';
  }

  @override
  String get confirmDeletion => 'Conferma eliminazione';

  @override
  String get configurationSaved => 'Configurazione salvata con successo.';

  @override
  String containerCreated(String name) {
    return 'Contenitore \"$name\" creato con successo.';
  }

  @override
  String containerDeleted(String name) {
    return 'Contenitore \"$name\" eliminato con successo.';
  }

  @override
  String get containerName => 'Nome contenitore';

  @override
  String get containerOrAssetTypeNotFound =>
      'Contenitore o tipo di risorsa non trovato.';

  @override
  String containerRenamed(String name) {
    return 'Contenitore rinominato a \"$name\".';
  }

  @override
  String get containers => 'Contenitori';

  @override
  String get countItemsByValue => 'Conta elementi per valore specifico';

  @override
  String get create => 'Crea';

  @override
  String get createFirstContainer => 'Crea il tuo primo contenitore.';

  @override
  String get createdAt => 'Creation Date';

  @override
  String get currency => 'Currency';

  @override
  String get current => 'Corrente';

  @override
  String get customColor => 'Colore personalizzato';

  @override
  String get customFields => 'Campi personalizzati';

  @override
  String customFieldsOf(String name) {
    return 'Campi personalizzati di $name';
  }

  @override
  String get customizeDeliveryVoucher =>
      'Personalizza il modello PDF per i prestiti';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get datalists => 'Elenchi personalizzati';

  @override
  String get december => 'Dicembre';

  @override
  String get definitionCustomFields => 'Definizione campi personalizzati';

  @override
  String get delete => 'Elimina';

  @override
  String deleteError(String error) {
    return 'Errore eliminazione: $error';
  }

  @override
  String get deleteSuccess => 'Posizione eliminata con successo.';

  @override
  String get deliveryVoucher => 'BUONO DI CONSEGNA';

  @override
  String get deliveryVoucherEditor => 'Editor buono di consegna';

  @override
  String get description => 'Descrizione (facoltativa)';

  @override
  String get desiredField => 'Campo desiderato';

  @override
  String get dueDate => 'Data scadenza';

  @override
  String get edit => 'Modifica';

  @override
  String get enterContainerName => 'Inserisci il nome del contenitore';

  @override
  String get enterDescription => 'Inserisci una descrizione';

  @override
  String get enterURL => 'Inserisci URL';

  @override
  String get enterValidUrl => 'Inserisci un URL valido';

  @override
  String errorChangingLanguage(String error) {
    return 'Errore cambio lingua: $error';
  }

  @override
  String get errorCsvMinRows =>
      'Selezionare un file CSV con intestazioni e almeno una riga di dati.';

  @override
  String errorDeletingAssetType(String error) {
    return 'Errore eliminazione tipo di risorsa: $error';
  }

  @override
  String errorDeletingContainer(String error) {
    return 'Errore eliminazione contenitore: $error';
  }

  @override
  String get errorDuringImport => 'Errore durante l\'importazione';

  @override
  String get errorEmptyCsv => 'Il file CSV è vuoto.';

  @override
  String errorGeneratingPDF(String error) {
    return 'Errore generazione PDF: $error';
  }

  @override
  String get errorInvalidPath => 'Percorso file non valido.';

  @override
  String get errorLoadingData => 'Errore caricamento dati';

  @override
  String errorLoadingListValues(String error) {
    return 'Errore caricamento valori elenco: $error';
  }

  @override
  String errorLoadingLocations(String error) {
    return 'Errore caricamento posizioni: $error';
  }

  @override
  String get errorNameMappingRequired =>
      'Il campo \"Nome\" è obbligatorio e deve essere mappato.';

  @override
  String get errorNoVoucherTemplate => 'Nessun modello di buono configurato.';

  @override
  String get errorNotBarCode =>
      'The article does not have a barcode or is invalid.';

  @override
  String get errorReadingBytes => 'Impossibile leggere i byte del file.';

  @override
  String errorReadingFile(String error) {
    return 'Errore lettura file: $error';
  }

  @override
  String errorRegisteringLoan(String error) {
    return 'Errore registrazione prestito: $error';
  }

  @override
  String errorRenaming(String error) {
    return 'Errore rinomina: $error';
  }

  @override
  String errorSaving(String error) {
    return 'Errore salvataggio: $error';
  }

  @override
  String errorUpdatingAsset(String error) {
    return 'Errore aggiornamento risorsa: $error';
  }

  @override
  String get exampleFilterHint => 'Es: Danneggiato, Rosso, 50';

  @override
  String get february => 'Febbraio';

  @override
  String get fieldChip => 'Campo';

  @override
  String fieldRequiredWithName(String field) {
    return 'Il campo \"$field\" è obbligatorio.';
  }

  @override
  String get fieldToCount => 'Campo da contare';

  @override
  String get fieldsFilledSuccess => 'Campi compilati con successo!';

  @override
  String get formatsPNG => 'Formati: PNG, JPG';

  @override
  String get forToday => 'For today';

  @override
  String get geminiLabelModel =>
      'Recommended Gemini model: gemini-3-flash-preview';

  @override
  String get generalSettings => 'Impostazioni generali';

  @override
  String get generateVoucher => 'Genera buono di consegna';

  @override
  String get globalSearch => 'Ricerca globale';

  @override
  String get greeting => 'Ciao, benvenuto!';

  @override
  String get guest => 'Ospite';

  @override
  String get helpDocs => 'Help & Documentation';

  @override
  String get helperGeminiKey =>
      'Enter your Gemini API key to enable integration. Get it at https://aistudio.google.com/';

  @override
  String get ignoreField => '🚫 Ignora campo';

  @override
  String get importAssetsTo => 'Importa risorse in';

  @override
  String importSuccessMessage(int count) {
    return 'Importazione riuscita! $count risorse create.';
  }

  @override
  String get importSerializedWarning =>
      'Import successful. This asset type is serialized — all items were created with quantity 1.';

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
  String get invalidNavigationIds => 'Errore: ID di navigazione non validi.';

  @override
  String get inventoryLabel => 'Inventory';

  @override
  String get january => 'Gennaio';

  @override
  String get july => 'Luglio';

  @override
  String get june => 'Giugno';

  @override
  String get language => 'Lingua';

  @override
  String get languageChanged => 'Lingua cambiata in italiano!';

  @override
  String get languageNotImplemented =>
      'Funzionalità linguistica da implementare';

  @override
  String get lightMode => 'Modalità chiara';

  @override
  String get loadingAssetType => 'Caricamento tipo di risorsa...';

  @override
  String loadingListField(String field) {
    return 'Caricamento $field...';
  }

  @override
  String get loanDate => 'Data prestito';

  @override
  String get loanLanguageNotImplemented =>
      'Language feature not yet implemented';

  @override
  String get loanManagement => 'Gestione prestiti';

  @override
  String get loanObject => 'Oggetto prestito';

  @override
  String get loans => 'Prestiti';

  @override
  String get location => 'Location';

  @override
  String get locations => 'Posizioni';

  @override
  String get locationsScheme => 'Schema posizioni';

  @override
  String get login => 'Accedi';

  @override
  String get logoVoucher => 'Logo buono';

  @override
  String get logout => 'Esci';

  @override
  String get lookForContainersOrAssets => 'Look for containers or assets...';

  @override
  String get lowStockTitle => 'Low Stock';

  @override
  String get magicAssistant => 'Assistente IA magico';

  @override
  String get march => 'Marzo';

  @override
  String get marketPriceObtained => 'Market price obtained successfully';

  @override
  String get marketValueEvolution => 'Market Value Evolution';

  @override
  String get marketValueField => 'Market Value';

  @override
  String get maxStock => 'Max stock';

  @override
  String get may => 'Maggio';

  @override
  String get minStock => 'Min stock';

  @override
  String get myAchievements => 'My Achievements';

  @override
  String get myCustomTheme => 'Mio tema';

  @override
  String get myProfile => 'Mio profilo';

  @override
  String get myThemesStored => 'I miei temi salvati';

  @override
  String get name => 'Name';

  @override
  String get nameCannotBeEmpty => 'Il nome non può essere vuoto';

  @override
  String get nameSameAsCurrent => 'Il nome è uguale a quello corrente';

  @override
  String get newAlert => 'Nuovo avviso manuale';

  @override
  String get newContainer => 'Nuovo contenitore';

  @override
  String get newName => 'Nuovo nome';

  @override
  String get next => 'Next';

  @override
  String get noAssetsCreated => 'Nessuna risorsa creata ancora.';

  @override
  String get noAssetsMatch =>
      'Nessuna risorsa corrisponde ai criteri di ricerca/filtro.';

  @override
  String get noBooleanFields => 'Nessun campo booleano definito.';

  @override
  String get noContainerMessage => 'Crea il tuo primo contenitore.';

  @override
  String get noCustomFields =>
      'Questo tipo di risorsa non ha campi personalizzati.';

  @override
  String get noFileSelected => 'Nessun file selezionato';

  @override
  String get noImageAvailable => 'No image available';

  @override
  String get noImagesAdded =>
      'Nessuna immagine aggiunta ancora. La prima immagine sarà quella principale.';

  @override
  String get noLoansFound => 'Nessun prestito trovato in questo contenitore.';

  @override
  String get noLocationsMessage =>
      'Nessuna posizione creata in questo contenitore. Aggiungine una!';

  @override
  String get noNotifications => 'Nessuna notifica';

  @override
  String get noThemesSaved => 'Nessun tema salvato ancora';

  @override
  String get none => 'Nessuno';

  @override
  String get november => 'Novembre';

  @override
  String get obligatory => 'Obbligatorio';

  @override
  String get october => 'Ottobre';

  @override
  String get optimalStockStatus => 'Stock at optimal levels';

  @override
  String get optional => 'Facoltativo';

  @override
  String get overdue => 'Scaduto';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterPassword => 'Inserisci la password';

  @override
  String get pleaseEnterUsername => 'Inserisci il nome utente';

  @override
  String get pleasePasteUrl => 'Incolla un URL';

  @override
  String get pleaseSelectCsvWithHeaders =>
      'Seleziona un file CSV con intestazioni.';

  @override
  String get pleaseSelectLocation => 'Seleziona una posizione.';

  @override
  String get plugins => 'Plugins';

  @override
  String get possessionFieldDef => 'Campo possesso';

  @override
  String get possessionFieldName => 'In possesso';

  @override
  String get preferences => 'Preferenze';

  @override
  String get previewPDF => 'Anteprima PDF';

  @override
  String get previous => 'Previous';

  @override
  String get primaryImage => 'Immagine principale';

  @override
  String get productUrlLabel => 'URL prodotto';

  @override
  String get quantity => 'Quantità';

  @override
  String get refresh => 'Refresh data';

  @override
  String get registerNewLoan => 'Registra nuovo prestito';

  @override
  String get reloadContainers => 'Ricarica contenitori';

  @override
  String get reloadLocations => 'Ricarica posizioni';

  @override
  String get reloadLoans => 'Reload loans';

  @override
  String get removeImage => 'Rimuovi immagine';

  @override
  String get rename => 'Rinomina';

  @override
  String get renameContainer => 'Rinomina contenitore';

  @override
  String get responsibleLabel => 'Responsible';

  @override
  String get reports => 'Rapporti';

  @override
  String get returned => 'Restituito';

  @override
  String get returnsLabel => 'Returns';

  @override
  String get rowsPerPageTitle => 'Risorse per pagina:';

  @override
  String get save => 'Salva';

  @override
  String get saveAndApply => 'Salva e applica';

  @override
  String get saveAsset => 'Salva risorsa';

  @override
  String get saveChanges => 'Salva modifiche';

  @override
  String get saveConfiguration => 'Salva configurazione';

  @override
  String get saveCustomTheme => 'Salva tema personalizzato';

  @override
  String get searchInAllColumns => 'Ricerca in tutte le colonne...';

  @override
  String get selectAndUploadImage => 'Seleziona e carica immagine';

  @override
  String get selectApplicationCurrency => 'Select application currency';

  @override
  String get selectApplicationLanguage =>
      'Seleziona la lingua dell\'applicazione';

  @override
  String get selectBooleanFields =>
      'Seleziona campi booleani per controllare la raccolta:';

  @override
  String get selectCsvColumn => 'Seleziona colonna CSV';

  @override
  String get selectField => 'Seleziona campo...';

  @override
  String get selectFieldType => 'Seleziona tipo di campo';

  @override
  String get selectImage => 'Seleziona immagine';

  @override
  String get selectLocationRequired =>
      'Devi selezionare una posizione per la risorsa.';

  @override
  String selectedLocationLabel(String name) {
    return 'Selezionato: $name';
  }

  @override
  String get selectTheme => 'Seleziona tema';

  @override
  String get september => 'Settembre';

  @override
  String get settings => 'Impostazioni';

  @override
  String get showAsGrid => 'Mostra come griglia';

  @override
  String get showAsList => 'Mostra come elenco';

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
  String get specificValueToCount => 'Valore specifico da contare';

  @override
  String get startImport => 'Avvia importazione';

  @override
  String get startMagic => 'Avvia magia';

  @override
  String get status => 'Stato';

  @override
  String get step1SelectFile => 'Passaggio 1: Seleziona file CSV';

  @override
  String get step2ColumnMapping =>
      'Passaggio 2: Mappatura colonne (CSV -> Sistema)';

  @override
  String get syncingSession => 'Sincronizzazione sessione...';

  @override
  String get systemThemes => 'Temi di sistema';

  @override
  String get systemThemesModal => 'Temi di sistema';

  @override
  String get templates => 'Templates';

  @override
  String get themeNameLabel => 'Nome tema';

  @override
  String get thisFieldIsRequired => 'Questo campo è obbligatorio.';

  @override
  String get topDemanded => 'Top Demanded';

  @override
  String get topLoanedItems => 'Articoli più prestati';

  @override
  String get totalAssets => 'Tipi di risorse';

  @override
  String get totalItems => 'Risorse';

  @override
  String get totals => 'Totali';

  @override
  String get totalSpending => 'Total Economic Investment';

  @override
  String get totalMarketValue => 'Total Market Value';

  @override
  String get updatedAt => 'Last Update';

  @override
  String get upload => 'Carica';

  @override
  String get uploadImage => 'Carica immagine';

  @override
  String get username => 'Nome utente';

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
  String get integrationsHeroHeadline =>
      'Connect services, APIs, and tools from one clear view.';

  @override
  String get integrationsHeroSubheadline =>
      'We group integrations by purpose so setup is faster, more visual, and easier to maintain on mobile too.';

  @override
  String get integrationStatusConnected => 'Connected';

  @override
  String get integrationStatusNotConfigured => 'Not configured';

  @override
  String get integrationTypeDataSource => 'Data source';

  @override
  String get integrationTypeConnector => 'Connector';

  @override
  String integrationFieldsCount(int count) {
    return '$count fields';
  }

  @override
  String get integrationNoLocalCredentials => 'No local credentials';

  @override
  String get configureLabel => 'Configure';

  @override
  String get integrationModelDefaultGemini => 'Default: gemini-3-flash-preview';

  @override
  String get integrationOpenaiDesc =>
      'Use GPT-4o and other OpenAI models as an intelligent assistant.';

  @override
  String get integrationOpenaiApiKeyHint =>
      'Generated at platform.openai.com/api-keys';

  @override
  String get integrationModelDefaultOpenai => 'Default: gpt-4o';

  @override
  String get integrationClaudeDesc =>
      'Use Claude Sonnet, Opus, and Haiku as an intelligent assistant.';

  @override
  String get integrationClaudeApiKeyHint =>
      'Generated at console.anthropic.com/settings/keys';

  @override
  String get integrationModelDefaultClaude => 'Default: claude-sonnet-4-6';

  @override
  String get integrationTelegramBotTokenHint => 'From @BotFather';

  @override
  String get integrationTelegramChatIdHint => 'Use @userinfobot to get your ID';

  @override
  String get integrationEmailDesc =>
      'Ultra-reliable email delivery. Ideal for reports and critical alerts.';

  @override
  String get integrationEmailApiKeyHint => 'Generated at resend.com/api-keys';

  @override
  String get integrationEmailFromLabel => 'Sender (From)';

  @override
  String get integrationEmailFromHint =>
      'Example: Invenicum <onboarding@resend.dev>';

  @override
  String get integrationBggDesc =>
      'Connect your BGG account to sync your collection and enrich your data automatically.';

  @override
  String get integrationPokemonDesc =>
      'Connect to the Pokemon API to sync your collection and enrich your data automatically.';

  @override
  String get integrationTcgdexDesc =>
      'Query cards and sets from collectible card games to enrich your inventory automatically.';

  @override
  String get integrationQrGeneratorName => 'QR Generator';

  @override
  String get integrationQrLabelsDesc =>
      'Configure the format of your printable labels.';

  @override
  String get integrationQrPageSizeLabel => 'Page size (A4, Letter)';

  @override
  String get integrationQrMarginLabel => 'Margin (mm)';

  @override
  String get integrationPriceChartingDesc =>
      'Configure your API key to fetch updated prices.';

  @override
  String get integrationUpcitemdbDesc => 'Global price lookup by barcode.';

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
  String get exportLabel => 'Export';

  @override
  String get csvExportNoData => 'There are no items to export.';

  @override
  String csvExportSuccess(int count) {
    return 'CSV exported successfully ($count items).';
  }

  @override
  String get csvExportError => 'Could not export CSV';

  @override
  String get syncLabel => 'Sync prices';

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
  String get veniChatPlaceholder => 'Chiedimi qualsiasi cosa...';

  @override
  String get veniChatPoweredBy => 'Powered by ';

  @override
  String veniChatProcessing(String query) {
    return 'Sto elaborando la tua query su \"$query\"...';
  }

  @override
  String get veniChatStatus => 'Online';

  @override
  String get veniChatTitle => 'Veni IA';

  @override
  String get veniChatWelcome =>
      'Ciao! Sono Veni, il tuo assistente Invenicum. Come posso aiutarti con il tuo inventario oggi?';

  @override
  String get veniCmdDashboard => 'Vai al dashboard';

  @override
  String get veniCmdHelpTitle => 'Abilità Veni';

  @override
  String get veniCmdInventory => 'Controlla l\'inventario di un articolo';

  @override
  String get veniCmdLoans => 'Visualizza prestiti attivi';

  @override
  String get veniCmdReport => 'Genera rapporto inventario';

  @override
  String get veniCmdScanQR => 'Scansiona QR/Codice a barre';

  @override
  String get veniCmdUnknown =>
      'Non riconosco quel comando. Scrivi help per vedere cosa posso fare.';

  @override
  String version(String name) {
    return 'Versione $name';
  }

  @override
  String get yes => 'Sì';

  @override
  String get zoomToFit => 'Zoom per adattarsi';

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
  String get printLabel => 'Print label';

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
  String get themeBrand => 'Invenicum (Brand)';

  @override
  String get themeEmerald => 'Emerald';

  @override
  String get themeSunset => 'Sunset';

  @override
  String get themeLavender => 'Soft Lavender';

  @override
  String get themeForest => 'Deep Forest';

  @override
  String get themeCherry => 'Cherry';

  @override
  String get themeElectricNight => 'Electric Night';

  @override
  String get themeAmberGold => 'Amber Gold';

  @override
  String get themeModernSlate => 'Modern Slate';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeNordicArctic => 'Nordic Arctic';

  @override
  String get themeDeepNight => 'Deep Night';

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

  @override
  String get valueDistributionByLocation => 'Value Distribution by Location';

  @override
  String get heatmapDescription =>
      'The donut shows how the market value is distributed among the highest-weight locations.';

  @override
  String locationsCount(int count) {
    return '$count locations';
  }

  @override
  String get unitsLabel => 'units';

  @override
  String get recordsLabel => 'records';

  @override
  String get totalValueFallback => 'Total value';

  @override
  String containerFallback(String id) {
    return 'Container $id';
  }

  @override
  String locationFallback(String id) {
    return 'Location $id';
  }

  @override
  String get ofTheValueLabel => 'of the value';

  @override
  String get reportsDescription =>
      'Genera report PDF o Excel da stampare o salvare sul tuo PC';

  @override
  String get reportSectionType => 'Tipo di report';

  @override
  String get reportSectionFormat => 'Formato di output';

  @override
  String get reportSectionPreview => 'Configurazione attuale';

  @override
  String get reportSelectContainerTitle => 'Seleziona un contenitore';

  @override
  String get reportGenerate => 'Genera report';

  @override
  String get reportGenerating => 'Generazione...';

  @override
  String get reportTypeInventoryDescription =>
      'Elenco completo dell\'inventario';

  @override
  String get reportTypeLoansDescription => 'Prestiti attivi e relativo stato';

  @override
  String get reportTypeAssetsDescription =>
      'Elenco delle risorse per categoria';

  @override
  String get reportLabelContainer => 'Contenitore';

  @override
  String get reportLabelType => 'Tipo di report';

  @override
  String get reportLabelFormat => 'Formato';

  @override
  String get reportFormatPdf => 'PDF';

  @override
  String get reportFormatExcel => 'Excel';

  @override
  String get reportNotSelected => 'Non selezionato';

  @override
  String get reportUnknown => 'Sconosciuto';

  @override
  String get reportSelectContainerFirst => 'Seleziona un contenitore';

  @override
  String reportDownloadedSuccess(String format) {
    return 'Report $format scaricato correttamente';
  }

  @override
  String reportGenerateError(String error) {
    return 'Errore durante la generazione del report: $error';
  }
}
