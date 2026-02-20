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
  String get magicAssistant => 'Assistente IA magico';

  @override
  String get march => 'Marzo';

  @override
  String get may => 'Maggio';

  @override
  String get minStock => 'Min stock';

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
  String get returned => 'Restituito';

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
  String get themeNameLabel => 'Nome tema';

  @override
  String get thisFieldIsRequired => 'Questo campo è obbligatorio.';

  @override
  String get topLoanedItems => 'Articoli più prestati';

  @override
  String get totalAssets => 'Tipi di risorse';

  @override
  String get totalItems => 'Risorse';

  @override
  String get totals => 'Totali';

  @override
  String get updatedAt => 'Last Update';

  @override
  String get upload => 'Carica';

  @override
  String get uploadImage => 'Carica immagine';

  @override
  String get username => 'Nome utente';

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
}
