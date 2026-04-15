// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get aboutInvenicum => 'A proposito di Invenicum';

  @override
  String get deliveryVoucherTitle => 'VOUCHER DI CONSEGNA';

  @override
  String get aboutDialogTitle => 'A proposito di Invenicum';

  @override
  String get aboutDialogCoolText =>
      'Il tuo inventario, ma con gli steroidi. Stiamo controllando per vedere se c\'è una versione più recente per farti andare avanti.';

  @override
  String get aboutCurrentVersionLabel => 'Versione attuale';

  @override
  String get aboutLatestVersionLabel => 'Ultima versione';

  @override
  String get aboutCheckingVersion => 'Controllo della versione online...';

  @override
  String get aboutVersionUnknown => 'Sconosciuto';

  @override
  String get aboutVersionUpToDate => 'La tua app è aggiornata.';

  @override
  String get aboutUpdateAvailable => 'È disponibile una nuova versione.';

  @override
  String get aboutVersionCheckFailed =>
      'Non è stato possibile verificare la versione online.';

  @override
  String get aboutOpenReleases => 'Vedi release';

  @override
  String get active => 'Risorsa';

  @override
  String get actives => 'Attività';

  @override
  String get activeInsight => 'INFORMAZIONI SULL\'ATTIVO CORRENTE';

  @override
  String get activeLoans => 'Prestiti in corso';

  @override
  String get activeLoansCount => 'Prestiti in corso';

  @override
  String get addAlert => 'Aggiungi avviso';

  @override
  String get addAsset => 'Aggiungi risorsa';

  @override
  String get addContainer => 'Aggiungi contenitore';

  @override
  String get addNewLocation => 'Aggiungi nuova posizione';

  @override
  String get additionalInformation => 'Ulteriori informazioni';

  @override
  String get additionalThumbnails => 'Miniature aggiuntive';

  @override
  String get adquisition => 'ACQUISIZIONE';

  @override
  String aiExtractionError(String error) {
    return 'L\'IA non è riuscita a estrarre i dati: $error';
  }

  @override
  String get aiPasteUrlDescription =>
      'Incolla il collegamento del prodotto e l\'IA estrarrà automaticamente le informazioni per compilare i campi.';

  @override
  String get alertCritical => 'Critico';

  @override
  String get alertCreated => 'Avviso creato';

  @override
  String get alertDeleted => 'Avviso rimosso';

  @override
  String get alertInfo => 'Informazioni';

  @override
  String get alertMessage => 'Messaggio';

  @override
  String get alertTitle => 'Qualificazione';

  @override
  String get alertType => 'Tipo';

  @override
  String get alertWarning => 'Avvertimento';

  @override
  String get alerts => 'Avvisi e notifiche';

  @override
  String get all => 'Tutto';

  @override
  String get allUpToDateStatus => 'Tutto aggiornato';

  @override
  String get appTitle => 'Inventario dell\'Invenicum';

  @override
  String get applicationTheme => 'Tema dell\'app';

  @override
  String get apply => 'Fare domanda a';

  @override
  String get april => 'aprile';

  @override
  String get assetDetail => 'Dettagli risorsa';

  @override
  String get assetImages => 'Immagini delle risorse';

  @override
  String get assetImport => 'Importazione di risorse';

  @override
  String get assetName => 'Nome';

  @override
  String get assetNotFound => 'Risorsa non trovata';

  @override
  String assetTypeDeleted(String name) {
    return 'Tipo di risorsa \"$name\" eliminato correttamente.';
  }

  @override
  String get assetTypes => 'Tipi di risorse';

  @override
  String assetUpdated(String name) {
    return 'L\'attivo \"$name\" è stato aggiornato correttamente.';
  }

  @override
  String get assets => 'Attività';

  @override
  String get assetsIn => 'Beni in';

  @override
  String get august => 'agosto';

  @override
  String get backToAssetTypes => 'Torna a Tipi di asset';

  @override
  String get averageMarketValue => 'Prezzo medio di mercato';

  @override
  String get barCode => 'Codice a barre (EAN)';

  @override
  String get baseCostAccumulatedWithoutInflation =>
      'Costo base cumulativo senza inflazione';

  @override
  String get borrowerEmail => 'E-mail del mutuatario';

  @override
  String get borrowerName => 'Nome del mutuatario';

  @override
  String get borrowerPhone => 'Telefono del mutuatario';

  @override
  String get cancel => 'Cancellare';

  @override
  String get centerView => 'Vista centrale';

  @override
  String get chooseFile => 'Scegli File';

  @override
  String get clearCounter => 'Cancella contatore';

  @override
  String get collectionContainerInfo =>
      'I contenitori di raccolta dispongono di barre di rilevamento della raccolta, valore investito, valore di mercato e visualizzazione della mostra';

  @override
  String get collectionFieldsConfigured => 'Campi di raccolta configurati.';

  @override
  String get condition => 'Condizione';

  @override
  String get condition_mint => 'scatola originale';

  @override
  String get condition_loose => 'Sfuso (senza scatola)';

  @override
  String get condition_incomplete => 'Incompleto';

  @override
  String get condition_damaged => 'Danneggiato/Segni';

  @override
  String get condition_new => 'Nuovo';

  @override
  String get condition_digital => 'Digitale/Immateriale';

  @override
  String get configureCollectionFields => 'Configura i campi della raccolta';

  @override
  String get configureDeliveryVoucher => 'Configura il buono di consegna';

  @override
  String get configureVoucherBody => 'Configura il corpo del voucher...';

  @override
  String get confirmDeleteAlert => 'Elimina avviso';

  @override
  String get confirmDeleteAlertMessage =>
      'Sei sicuro di voler eliminare questo record?';

  @override
  String confirmDeleteAssetType(String name) {
    return 'Vuoi eliminare il tipo di risorsa \"$name\" e tutti gli elementi associati? Questa azione non può essere annullata.';
  }

  @override
  String confirmDeleteContainer(String name) {
    return 'Vuoi eliminare il contenitore \"$name\"? Questa azione è irreversibile e cancellerà tutte le tue risorse e i tuoi dati.';
  }

  @override
  String confirmDeleteLocationMessage(String name) {
    return 'Vuoi eliminare la posizione \"$name\"?';
  }

  @override
  String get confirmDeletion => 'Conferma l\'eliminazione';

  @override
  String get configurationSaved => 'Configurazione salvata con successo.';

  @override
  String containerCreated(String name) {
    return 'Contenitore \"$name\" creato correttamente.';
  }

  @override
  String containerDeleted(String name) {
    return 'Contenitore \"$name\" rimosso correttamente.';
  }

  @override
  String get containerName => 'Nome del contenitore';

  @override
  String get containerOrAssetTypeNotFound =>
      'Contenitore o tipo di risorsa non trovato.';

  @override
  String containerRenamed(String name) {
    return 'Contenitore rinominato in \"$name\".';
  }

  @override
  String get containers => 'Contenitori';

  @override
  String get countItemsByValue =>
      'Contare gli elementi in base a un valore specifico';

  @override
  String get create => 'Creare';

  @override
  String get createFirstContainer => 'Crea il tuo primo contenitore.';

  @override
  String get createdAt => 'Data di creazione';

  @override
  String get currency => 'Valuta';

  @override
  String get current => 'Attuale';

  @override
  String get customColor => 'Personalizza il colore';

  @override
  String get customFields => 'Campi personalizzati';

  @override
  String customFieldsOf(String name) {
    return '$name Campi personalizzati';
  }

  @override
  String get customizeDeliveryVoucher =>
      'Personalizza il modello PDF per i prestiti';

  @override
  String get darkMode => 'Modalità oscura';

  @override
  String get dashboard => 'Pannello di controllo';

  @override
  String get datalists => 'Elenchi personalizzati';

  @override
  String get december => 'Dicembre';

  @override
  String get definitionCustomFields => 'Definizione di campi personalizzati';

  @override
  String get delete => 'Eliminare';

  @override
  String deleteError(String error) {
    return 'Elimina errore: $error';
  }

  @override
  String get deleteSuccess => 'Posizione eliminata con successo.';

  @override
  String get deliveryVoucher => 'BUONO DI CONSEGNA';

  @override
  String get deliveryVoucherEditor => 'Redattore dei buoni di consegna';

  @override
  String get description => 'Descrizione (facoltativa)';

  @override
  String get desiredField => 'Campo desiderato';

  @override
  String get dueDate => 'Data di scadenza';

  @override
  String get edit => 'Modificare';

  @override
  String get enterContainerName => 'Inserisci il nome del contenitore';

  @override
  String get enterDescription => 'Inserisci una descrizione';

  @override
  String get enterURL => 'Inserisci l\'URL';

  @override
  String get enterValidUrl => 'Inserisci un URL valido';

  @override
  String errorChangingLanguage(String error) {
    return 'Errore durante la modifica della lingua: $error';
  }

  @override
  String get errorCsvMinRows =>
      'Seleziona un file CSV con intestazioni e almeno una riga di dati.';

  @override
  String errorDeletingAssetType(String error) {
    return 'Errore durante l\'eliminazione del tipo di risorsa: $error';
  }

  @override
  String errorDeletingContainer(String error) {
    return 'Errore durante l\'eliminazione del contenitore: $error';
  }

  @override
  String get errorDuringImport => 'Errore durante l\'importazione';

  @override
  String get errorEmptyCsv => 'Il file CSV è vuoto.';

  @override
  String errorGeneratingPDF(String error) {
    return 'Errore durante la generazione del PDF: $error';
  }

  @override
  String get errorInvalidPath => 'Percorso file non valido.';

  @override
  String get errorLoadingData => 'Errore durante il caricamento dei dati';

  @override
  String errorLoadingListValues(String error) {
    return 'Errore durante il caricamento dei valori dell\'elenco: $error';
  }

  @override
  String errorLoadingLocations(String error) {
    return 'Errore durante il caricamento delle posizioni: $error';
  }

  @override
  String get errorNameMappingRequired =>
      'Il campo \'Nome\' è obbligatorio e deve essere mappato.';

  @override
  String get errorNoVoucherTemplate =>
      'Non è configurato alcun modello di voucher.';

  @override
  String get errorNotBarCode =>
      'L\'articolo non ha un codice a barre o non è valido.';

  @override
  String get errorReadingBytes => 'Impossibile leggere i byte del file.';

  @override
  String errorReadingFile(String error) {
    return 'Errore durante la lettura del file: $error';
  }

  @override
  String errorRegisteringLoan(String error) {
    return 'Errore durante la registrazione del prestito: $error';
  }

  @override
  String errorRenaming(String error) {
    return 'Errore di ridenominazione: $error';
  }

  @override
  String errorSaving(String error) {
    return 'Salva errore: $error';
  }

  @override
  String errorUpdatingAsset(String error) {
    return 'Errore durante l\'aggiornamento della risorsa: $error';
  }

  @override
  String get exampleFilterHint => 'Esempio: Danneggiato, Rosso, 50';

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
  String get fieldsFilledSuccess => 'Campi completati con successo!';

  @override
  String get formatsPNG => 'Formati: PNG, JPG';

  @override
  String get forToday => 'per oggi';

  @override
  String get geminiLabelModel =>
      'Modello Gemini consigliato: gemini-3-flash-preview';

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
  String get helpDocs => 'Aiuto e documentazione';

  @override
  String get helperGeminiKey =>
      'Inserisci la tua chiave API Gemini per abilitare l\'integrazione. Ottienilo su https://aistudio.google.com/';

  @override
  String get ignoreField => '🚫 Ignora Campo';

  @override
  String get importAssetsTo => 'Importa risorse in';

  @override
  String importSuccessMessage(int count) {
    return 'Importazione riuscita! $count risorse create.';
  }

  @override
  String get importSerializedWarning =>
      'Importazione riuscita. Questo tipo di asset è serializzato: tutti gli articoli sono stati creati con la quantità 1.';

  @override
  String get integrations => 'Integrazioni';

  @override
  String get integrationGeminiDesc =>
      'Connetti Invenicum con Google Gemini per sfruttare le funzionalità avanzate dell\'intelligenza artificiale nella gestione del tuo inventario.';

  @override
  String get integrationTelegramDesc =>
      'Collega Invenicum a Telegram per ricevere notifiche istantanee sul tuo inventario direttamente sul tuo dispositivo.';

  @override
  String get invalidAssetId => 'ID risorsa non valido';

  @override
  String get invalidNavigationIds => 'Errore: ID di navigazione non validi.';

  @override
  String get inventoryLabel => 'Inventario';

  @override
  String get january => 'Gennaio';

  @override
  String get july => 'Luglio';

  @override
  String get june => 'Giugno';

  @override
  String get language => 'Lingua';

  @override
  String get languageChanged => 'La lingua è cambiata in spagnolo!';

  @override
  String get languageNotImplemented =>
      'Funzionalità linguistiche da implementare';

  @override
  String get lightMode => 'Modalità Cancella';

  @override
  String get loadingAssetType => 'Caricamento del tipo di risorsa...';

  @override
  String loadingListField(String field) {
    return 'Caricamento $field...';
  }

  @override
  String get loanDate => 'Data del prestito';

  @override
  String get loanLanguageNotImplemented =>
      'Funzionalità linguistiche da implementare';

  @override
  String get loanManagement => 'Gestione dei prestiti';

  @override
  String get loanObject => 'Oggetto da prestare';

  @override
  String get loans => 'Prestiti';

  @override
  String get location => 'Posizione';

  @override
  String get locations => 'Posizioni';

  @override
  String get locationsScheme => 'Schema di posizione';

  @override
  String get login => 'Login';

  @override
  String get logoVoucher => 'Il logo della Vale';

  @override
  String get logout => 'disconnessione';

  @override
  String get lookForContainersOrAssets => 'Cerca contenitori o risorse...';

  @override
  String get lowStockTitle => 'Scorte basse';

  @override
  String get magicAssistant => 'Assistente magico dell\'IA';

  @override
  String get march => 'Marzo';

  @override
  String get marketPriceObtained => 'Prezzo di mercato ottenuto correttamente';

  @override
  String get marketValueEvolution => 'Evoluzione del valore di mercato';

  @override
  String get marketValueField => 'Valore di mercato';

  @override
  String get marketRealRate => 'Tasso reale di mercato';

  @override
  String get maxStock => 'Scorta massima';

  @override
  String get may => 'Maggio';

  @override
  String get minStock => 'Scorta minima';

  @override
  String get myAchievements => 'I miei successi';

  @override
  String get myCustomTheme => 'Il mio tema';

  @override
  String get myProfile => 'Il mio profilo';

  @override
  String get myThemesStored => 'I miei argomenti salvati';

  @override
  String get name => 'Nome';

  @override
  String get nameCannotBeEmpty => 'Il nome non può essere vuoto';

  @override
  String get nameSameAsCurrent => 'Il nome è lo stesso di quello attuale';

  @override
  String get newAlert => 'Nuovo avviso manuale';

  @override
  String get newContainer => 'Nuovo contenitore';

  @override
  String get newName => 'Nuovo nome';

  @override
  String get next => 'Seguente';

  @override
  String get noAssetsCreated => 'Non sono ancora state create risorse.';

  @override
  String get noAssetsMatch =>
      'Nessuna risorsa corrisponde ai criteri di ricerca/filtro.';

  @override
  String get noBooleanFields => 'Non ci sono campi booleani definiti.';

  @override
  String get noContainerMessage => 'Crea il tuo primo contenitore.';

  @override
  String get noCustomFields =>
      'Questo tipo di risorsa non dispone di campi personalizzati.';

  @override
  String get noFileSelected => 'Nessun file selezionato';

  @override
  String get noImageAvailable => 'Nessuna immagine disponibile';

  @override
  String get noImagesAdded =>
      'Non ci sono ancora immagini aggiunte. La prima immagine sarà quella principale.';

  @override
  String get noLoansFound =>
      'Nessun prestito è stato trovato in questo contenitore.';

  @override
  String get noLocationsMessage =>
      'Non sono state create posizioni in questo contenitore. Aggiungi il primo!';

  @override
  String get noNotifications => 'Nessuna notifica';

  @override
  String get noThemesSaved => 'Non ci sono ancora brani salvati';

  @override
  String get none => 'Nessuno';

  @override
  String get november => 'novembre';

  @override
  String get obligatory => 'Obbligatorio';

  @override
  String get october => 'ottobre';

  @override
  String get optimalStockStatus => 'Scorte a livelli ottimali';

  @override
  String get optional => 'Opzionale';

  @override
  String get overdue => 'Tardi';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterPassword => 'Inserisci la tua password';

  @override
  String get pleaseEnterUsername => 'Inserisci il tuo nome utente';

  @override
  String get pleasePasteUrl => 'Per favore incolla un URL';

  @override
  String get pleaseSelectCsvWithHeaders =>
      'Seleziona un file CSV con intestazioni.';

  @override
  String get pleaseSelectLocation => 'Seleziona una località.';

  @override
  String get plugins => 'Plugin';

  @override
  String get possessionFieldDef => 'Campo di possessione';

  @override
  String get possessionFieldName => 'In possesso';

  @override
  String get preferences => 'Preferenze';

  @override
  String get previewPDF => 'Anteprima';

  @override
  String get previous => 'Ex';

  @override
  String get primaryImage => 'Immagine principale';

  @override
  String get processing => 'Elaborazione...';

  @override
  String get productUrlLabel => 'URL del prodotto';

  @override
  String get quantity => 'Quantità';

  @override
  String get refresh => 'Ricarica i dati';

  @override
  String get registerNewLoan => 'Registra nuovo prestito';

  @override
  String get reloadContainers => 'Ricaricare i contenitori';

  @override
  String get reloadLocations => 'Ricarica posizioni';

  @override
  String get reloadLoans => 'Ricaricare i prestiti';

  @override
  String get removeImage => 'Elimina immagine';

  @override
  String get rename => 'Rinominare';

  @override
  String get renameContainer => 'Rinomina contenitore';

  @override
  String get responsibleLabel => 'Responsabile';

  @override
  String get reports => 'Informazioni';

  @override
  String get returned => 'restituito';

  @override
  String get returnsLabel => 'Ritorni';

  @override
  String get rowsPerPageTitle => 'Risorse per pagina:';

  @override
  String get save => 'Mantenere';

  @override
  String get saveAndApply => 'Salva e applica';

  @override
  String get saveAsset => 'Salva attivo';

  @override
  String get saveChanges => 'Salva modifiche';

  @override
  String get saveConfiguration => 'Salva impostazioni';

  @override
  String get saveCustomTheme => 'Salva tema personalizzato';

  @override
  String get searchInAllColumns => 'Cerca in tutte le colonne...';

  @override
  String get selectAndUploadImage => 'Seleziona e carica l\'immagine';

  @override
  String get selectApplicationCurrency => 'Seleziona la valuta dell\'app';

  @override
  String get selectApplicationLanguage =>
      'Seleziona la lingua dell\'applicazione';

  @override
  String get selectBooleanFields =>
      'Seleziona i campi booleani per controllare la raccolta:';

  @override
  String get selectCsvColumn => 'Seleziona Colonna CSV';

  @override
  String get selectField => 'Seleziona campo...';

  @override
  String get selectFieldType => 'Seleziona il tipo di campo';

  @override
  String get selectImage => 'Seleziona Immagine';

  @override
  String get selectLocationRequired =>
      'È necessario selezionare una posizione per la risorsa.';

  @override
  String selectedLocationLabel(String name) {
    return 'Selezionato: $name';
  }

  @override
  String get selectTheme => 'Seleziona Tema';

  @override
  String get september => 'settembre';

  @override
  String get settings => 'Impostazioni';

  @override
  String get showAsGrid => 'Mostra come griglia';

  @override
  String get showAsList => 'Mostra come elenco';

  @override
  String get sortAsc => 'Crescente';

  @override
  String get sortDesc => 'Decrescente';

  @override
  String get slotDashboardBottom => 'Pannello di controllo inferiore';

  @override
  String get slotDashboardTop => 'Pannello di controllo superiore';

  @override
  String get slotFloatingActionButton => 'Pulsante mobile';

  @override
  String get slotInventoryHeader => 'Intestazione inventario';

  @override
  String get slotLeftSidebar => 'Barra laterale';

  @override
  String get slotUnknown => 'Slot sconosciuto';

  @override
  String get specificValueToCount => 'Valore specifico da contare';

  @override
  String get startImport => 'Avvia l\'importazione';

  @override
  String get startMagic => 'Inizia la magia';

  @override
  String get status => 'Stato';

  @override
  String get step1SelectFile => 'Passaggio 1: seleziona il file CSV';

  @override
  String get step2ColumnMapping =>
      'Passaggio 2: mappatura delle colonne (CSV -> Sistema)';

  @override
  String get syncingSession => 'Sincronizzazione sessione...';

  @override
  String get systemThemes => 'Problemi di sistema';

  @override
  String get systemThemesModal => 'Problemi di sistema';

  @override
  String get templates => 'Modelli';

  @override
  String get themeNameLabel => 'Nome del tema';

  @override
  String get thisFieldIsRequired => 'Questo campo è obbligatorio.';

  @override
  String get topDemanded => 'Principali imputati';

  @override
  String get topLoanedItems =>
      'La maggior parte dei prodotti presi in prestito al mese';

  @override
  String get totalAssets => 'Tipi di risorse';

  @override
  String get totalItems => 'Attività';

  @override
  String get totals => 'Totali';

  @override
  String get totalSpending => 'Investimento economico totale';

  @override
  String get totalMarketValue => 'Valore di mercato totale';

  @override
  String get updatedAt => 'Ultimo aggiornamento';

  @override
  String get upload => 'Aumento';

  @override
  String get uploadImage => 'Carica immagine';

  @override
  String get username => 'Utente';

  @override
  String get copiedToClipboard => 'Copiato negli appunti';

  @override
  String get connectionTestFailed => 'Il test di connessione è fallito';

  @override
  String get connectionVerified => 'Connessione verificata con successo';

  @override
  String get errorSavingConfiguration =>
      'Errore durante il salvataggio delle impostazioni';

  @override
  String get integrationsAndConnectionsTitle => 'Integrazioni e connessioni';

  @override
  String get integrationsSectionAiTitle => 'Intelligenza artificiale';

  @override
  String get integrationsSectionAiSubtitle =>
      'Motori e assistenti conversazionali per arricchire flussi e automazioni.';

  @override
  String get integrationsSectionMessagingTitle => 'Messaggi e notifiche';

  @override
  String get integrationsSectionMessagingSubtitle =>
      'Canali di output per avvisi, bot, report e consegne automatiche.';

  @override
  String get integrationsSectionDataApisTitle => 'API di dati';

  @override
  String get integrationsSectionDataApisSubtitle =>
      'Fonti esterne per arricchire carte, carte, giochi e riferimenti al catalogo.';

  @override
  String get integrationsSectionValuationTitle => 'Valutazione e mercato';

  @override
  String get integrationsSectionValuationSubtitle =>
      'Connettori per prezzi, codici a barre e stima del valore aggiornata.';

  @override
  String get integrationsSectionHardwareTitle => 'Hardware ed etichette';

  @override
  String get integrationsSectionHardwareSubtitle =>
      'Strumenti fisici e utilità per la stampa, la codifica e il funzionamento.';

  @override
  String integrationsActiveConnections(int count) {
    return '$count connessioni attive';
  }

  @override
  String get integrationsModularDesign => 'Design modulare per categorie';

  @override
  String get integrationsCheckingStatuses => 'Controllo degli stati';

  @override
  String get integrationsStatusSynced => 'Stato sincronizzato';

  @override
  String get integrationsHeroHeadline =>
      'Connetti servizi, API e strumenti da un\'unica visione chiara.';

  @override
  String get integrationsHeroSubheadline =>
      'Raggruppiamo le integrazioni per scopo per rendere la configurazione più rapida, più visiva e più facile da mantenere anche sui dispositivi mobili.';

  @override
  String get integrationStatusConnected => 'Collegato';

  @override
  String get integrationStatusNotConfigured => 'Non configurato';

  @override
  String get integrationTypeDataSource => 'Origine dati';

  @override
  String get integrationTypeConnector => 'Connettore';

  @override
  String integrationFieldsCount(int count) {
    return '$count campi';
  }

  @override
  String get integrationNoLocalCredentials => 'Nessuna credenziale locale';

  @override
  String get configureLabel => 'Impostare';

  @override
  String get integrationModelDefaultGemini =>
      'Impostazione predefinita: gemini-3-flash-preview';

  @override
  String get integrationOpenaiDesc =>
      'Utilizza GPT-4o e altri modelli OpenAI come assistente intelligente.';

  @override
  String get integrationOpenaiApiKeyHint =>
      'Ottenuta su platform.openai.com/api-keys';

  @override
  String get integrationModelDefaultOpenai => 'Predefinito: gpt-4o';

  @override
  String get integrationClaudeDesc =>
      'Usa Claude Sonnet, Opus e Haiku come assistente intelligente.';

  @override
  String get integrationClaudeApiKeyHint =>
      'Ottenuta su console.anthropic.com/settings/keys';

  @override
  String get integrationModelDefaultClaude => 'Predefinito: claude-sonetto-4-6';

  @override
  String get integrationTelegramBotTokenHint => 'Da @BotFather';

  @override
  String get integrationTelegramChatIdHint =>
      'Usa @userinfobot per ottenere il tuo ID';

  @override
  String get integrationEmailDesc =>
      'Invio di e-mail ultra affidabile. Ideale per report e avvisi critici.';

  @override
  String get integrationEmailApiKeyHint => 'Ottenuta su resend.com/api-keys';

  @override
  String get integrationEmailFromLabel => 'Mittente (Da)';

  @override
  String get integrationEmailFromHint =>
      'Esempio: Invenicum <onboarding@resend.dev>';

  @override
  String get integrationBggDesc =>
      'Collega il tuo account BGG per sincronizzare la tua raccolta e arricchire i tuoi dati automaticamente.';

  @override
  String get integrationPokemonDesc =>
      'Connettiti all\'API Pokemon per sincronizzare la tua raccolta e arricchire i tuoi dati automaticamente.';

  @override
  String get integrationTcgdexDesc =>
      'Scopri le carte e le espansioni dei giochi di carte collezionabili per arricchire automaticamente il tuo inventario.';

  @override
  String get integrationQrGeneratorName => 'Generatore QR';

  @override
  String get integrationQrLabelsDesc =>
      'Imposta il formato delle tue etichette stampabili.';

  @override
  String get integrationQrPageSizeLabel => 'Formato pagina (A4, Lettera)';

  @override
  String get integrationQrMarginLabel => 'Margine (mm)';

  @override
  String get integrationPriceChartingDesc =>
      'Configura la tua chiave API per ottenere i prezzi aggiornati.';

  @override
  String get integrationUpcitemdbDesc =>
      'Ricerca globale dei prezzi tramite codice a barre.';

  @override
  String integrationConfiguredSuccess(String name) {
    return '$name configurato correttamente';
  }

  @override
  String integrationUnlinkedWithName(String name) {
    return '$name è stato scollegato';
  }

  @override
  String get invalidUiFormat => 'Formato dell\'interfaccia utente non valido';

  @override
  String get loadingConfiguration => 'Caricamento configurazione...';

  @override
  String pageNotFoundUri(String uri) {
    return 'Pagina non trovata: $uri';
  }

  @override
  String get pluginLoadError =>
      'Errore durante il caricamento dell\'interfaccia del plugin';

  @override
  String get pluginRenderError => 'errore di rendering';

  @override
  String get testConnection => 'Testare la connessione';

  @override
  String get testingConnection => 'Prova...';

  @override
  String get unableToUnlinkAccount => 'Impossibile scollegare l\'account';

  @override
  String get unlinkIntegrationUpper => 'SCOLLEGA INTEGRAZIONE';

  @override
  String get upcFreeModeHint =>
      'Lascia vuoto questo campo per utilizzare la modalità gratuita (limitata).';

  @override
  String get alertsTabLabel => 'Avvisi';

  @override
  String get alertMarkedAsRead => 'Contrassegnato come letto';

  @override
  String get calendarTabLabel => 'Calendario';

  @override
  String get closeLabel => 'Vicino';

  @override
  String get closeLabelUpper => 'Vicino';

  @override
  String get configureReminderLabel => 'Imposta avviso:';

  @override
  String get cannotFormatInvalidJson =>
      'Impossibile formattare JSON non valido';

  @override
  String get createAlertOrEventTitle => 'Crea avviso/evento';

  @override
  String get createdSuccessfully => 'Creato con successo';

  @override
  String get createPluginTitle => 'Crea plugin';

  @override
  String get editPluginTitle => 'Modifica plug-in';

  @override
  String get deleteFromGithubLabel => 'Elimina da GitHub';

  @override
  String get deleteFromGithubSubtitle =>
      'Eliminare il file dal mercato pubblico';

  @override
  String get deletePluginQuestion => 'Eliminare il plug-in?';

  @override
  String get deletePluginLocalWarning => 'Verrà rimosso dal database locale.';

  @override
  String get deleteUpper => 'ELIMINA';

  @override
  String get editEventTitle => 'Modifica evento';

  @override
  String get editLabel => 'Modificare';

  @override
  String get eventDataSection => 'Dettagli dell\'evento';

  @override
  String get eventReminderAtTime => 'Al momento dell\'evento';

  @override
  String get eventUpdated => 'Evento aggiornato';

  @override
  String get firstVersionHint => 'La prima versione sarà sempre la 1.0.0';

  @override
  String get fixJsonBeforeSave => 'Correggere il JSON prima di salvare';

  @override
  String get formatJson => 'Formato JSON';

  @override
  String get goToProfileUpper => 'VAI AL PROFILO';

  @override
  String get installPluginLabel => 'Installa il plug-in';

  @override
  String get invalidVersionFormat => 'Formato non valido (es: 1.0.1)';

  @override
  String get isEventQuestion => 'È un evento?';

  @override
  String get jsonErrorGeneric => 'Errore JSON';

  @override
  String get makePublicLabel => 'Pubblicizzare';

  @override
  String get markAsReadLabel => 'Segna come letto';

  @override
  String get messageWithColon => 'Messaggio:';

  @override
  String minutesBeforeLabel(int minutes) {
    return '$minutes minuti prima';
  }

  @override
  String get newLabel => 'Nuovo';

  @override
  String get newPluginLabel => 'Nuovo plug-in';

  @override
  String get noActiveAlerts => 'Non ci sono avvisi attivi';

  @override
  String get noDescriptionAvailable => 'Nessuna descrizione disponibile.';

  @override
  String get noEventsForDay => 'Nessun evento per questo giorno';

  @override
  String get noPluginsAvailable => 'Non ci sono plugin';

  @override
  String get notificationDeleted => 'Notifica rimossa con successo';

  @override
  String get oneHourBeforeLabel => '1 ora prima';

  @override
  String get pluginPrivateDescription =>
      'Solo tu potrai vedere questo plugin nella tua lista.';

  @override
  String get pluginPublicDescription =>
      'Altri utenti potranno vedere e installare questo plugin.';

  @override
  String get pluginTabLibrary => 'Libreria';

  @override
  String get pluginTabMarket => 'mercato';

  @override
  String get pluginTabMine => 'I miei';

  @override
  String get previewLabel => 'Anteprima';

  @override
  String get remindMeLabel => 'Avvisami:';

  @override
  String get requiredField => 'Richiesto';

  @override
  String get requiresGithubDescription =>
      'Per pubblicare plugin nella community, devi collegare il tuo account GitHub per accreditarti il ​​merito dell\'autore.';

  @override
  String get requiresGithubTitle => 'Richiede GitHub';

  @override
  String get slotLocationLabel => 'Posizione (spazio)';

  @override
  String get stacDocumentation => 'Documentazione Stac';

  @override
  String get stacJsonInterfaceLabel => 'JSON Stac (interfaccia)';

  @override
  String get uninstallLabel => 'Disinstallare';

  @override
  String get unrecognizedStacStructure => 'Struttura Stac non riconosciuta';

  @override
  String get updateLabelUpper => 'AGGIORNA';

  @override
  String updateToVersion(String version) {
    return 'Aggiorna a v$version';
  }

  @override
  String get versionLabel => 'Versione';

  @override
  String get incrementVersionHint =>
      'Aumenta la versione della tua proposta (es: 1.1.0)';

  @override
  String get cancelUpper => 'ANNULLA';

  @override
  String get mustLinkGithubToPublishTemplate =>
      'Devi collegare GitHub nel tuo profilo per pubblicare.';

  @override
  String get templateNeedsAtLeastOneField =>
      'Il modello deve avere almeno un campo definito.';

  @override
  String get templatePullRequestCreated =>
      'Proposta inviata. È stata creata una richiesta pull su GitHub.';

  @override
  String errorPublishingTemplate(String error) {
    return 'Errore durante la pubblicazione: $error';
  }

  @override
  String get createGlobalTemplateTitle => 'Crea modello globale';

  @override
  String get githubVerifiedLabel => 'GitHub verificato';

  @override
  String get githubNotLinkedLabel => 'GitHub scollegato';

  @override
  String get veniDesignedTemplateBanner =>
      'Veni ha progettato questa struttura in base alla vostra richiesta. Rivedi e modifica prima di pubblicare.';

  @override
  String get templateNameLabel => 'Nome del modello';

  @override
  String get templateNameHint => 'Esempio: la mia collezione di fumetti';

  @override
  String get githubUserLabel => 'Utente GitHub';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get categoryHint => 'Es: libri, elettronica...';

  @override
  String get templatePurposeDescription => 'Descrizione dello scopo';

  @override
  String get definedFieldsTitle => 'Campi definiti';

  @override
  String get addFieldButton => 'Aggiungi campo';

  @override
  String get clickAddFieldToStart =>
      'Fai clic su \"Aggiungi campo\" per iniziare a progettare.';

  @override
  String get configureOptionsUpper => 'CONFIGURA OPZIONI';

  @override
  String get writeOptionAndPressEnter => 'Digitare un\'opzione e premere Invio';

  @override
  String get publishOnGithubUpper => 'PUBBLICA SU GITHUB';

  @override
  String get templateDetailFetchError =>
      'Impossibile ottenere i dettagli del modello';

  @override
  String get templateNotAvailable =>
      'Il modello non esiste o non è disponibile';

  @override
  String get backLabel => 'Ritorno';

  @override
  String get templateDetailTitle => 'Dettaglio del modello';

  @override
  String get saveToLibraryTooltip => 'Salva nella libreria';

  @override
  String templateByAuthor(String name) {
    return 'di @$name';
  }

  @override
  String get officialVerifiedTemplate => 'Modello verificato ufficiale';

  @override
  String dataStructureFieldsUpper(int count) {
    return 'STRUTTURA DATI ($count CAMPI)';
  }

  @override
  String get installInMyInventoryUpper => 'INSTALLA NEL MIO INVENTARIO';

  @override
  String get addedToPersonalLibrary => 'Aggiunto alla tua libreria personale';

  @override
  String get whereDoYouWantToInstall => 'Dove vuoi installarlo?';

  @override
  String get noContainersCreateFirst =>
      'Non hai contenitori. Creane uno prima.';

  @override
  String get autoGeneratedListFromTemplate =>
      'Elenco generato automaticamente dal modello';

  @override
  String get installationSuccessAutoLists =>
      'Installazione riuscita. Elenchi configurati automaticamente.';

  @override
  String errorInstallingTemplate(String error) {
    return 'Errore durante l\'installazione: $error';
  }

  @override
  String get publishTemplateLabel => 'Pubblica modello';

  @override
  String get retryLabel => 'Riprova';

  @override
  String get noTemplatesFoundInMarket => 'Nessun modello trovato sul mercato.';

  @override
  String get invenicumCommunity => 'Comunità Invenicum';

  @override
  String get refreshMarketTooltip => 'Aggiornare il mercato';

  @override
  String get exploreCommunityConfigurations =>
      'Esplora e scarica le impostazioni della community';

  @override
  String get searchByTemplateName => 'Cerca per nome modello...';

  @override
  String get filterByTagTooltip => 'Filtra per tag';

  @override
  String get noMoreTags => 'Non ci sono più etichette';

  @override
  String confirmDeleteDataList(String name) {
    return 'Vuoi eliminare l\'elenco \"$name\"? Questa azione è irreversibile.';
  }

  @override
  String dataListDeletedSuccess(String name) {
    return 'Elenco \"$name\" eliminato correttamente.';
  }

  @override
  String errorDeletingDataList(String error) {
    return 'Errore durante l\'eliminazione dell\'elenco: $error';
  }

  @override
  String customListsWithContainer(String name) {
    return 'Elenchi personalizzati - $name';
  }

  @override
  String get newDataListLabel => 'Nuovo elenco';

  @override
  String get noCustomListsCreateOne =>
      'Non sono presenti elenchi personalizzati. Creane uno nuovo.';

  @override
  String elementsCount(int count) {
    return '$count elementi';
  }

  @override
  String get dataListNeedsAtLeastOneElement =>
      'L\'elenco deve contenere almeno un elemento';

  @override
  String get customDataListCreated =>
      'Elenco personalizzato creato correttamente';

  @override
  String errorCreatingDataList(String error) {
    return 'Errore durante la creazione dell\'elenco: $error';
  }

  @override
  String get newCustomDataListTitle => 'Nuovo elenco personalizzato';

  @override
  String get dataListNameLabel => 'Nome dell\'elenco';

  @override
  String get pleaseEnterAName => 'Inserisci un nome';

  @override
  String get dataListElementsTitle => 'Elenca elementi';

  @override
  String get newElementLabel => 'Nuovo oggetto';

  @override
  String get addLabel => 'Aggiungere';

  @override
  String get addElementsToListHint => 'Aggiungi elementi all\'elenco';

  @override
  String get saveListLabel => 'Salva elenco';

  @override
  String get dataListUpdatedSuccessfully => 'Elenco aggiornato con successo';

  @override
  String errorUpdatingDataList(String error) {
    return 'Errore durante l\'aggiornamento dell\'elenco: $error';
  }

  @override
  String editListWithName(String name) {
    return 'Modifica elenco: $name';
  }

  @override
  String get createNewLocationTitle => 'Crea nuova posizione';

  @override
  String get locationNameLabel => 'Nome della posizione';

  @override
  String get locationNameHint => 'Es: Scaffalatura B3, Sala Server';

  @override
  String get locationDescriptionHint =>
      'Dettagli di accesso, tipo di contenuto, ecc.';

  @override
  String get parentLocationLabel => 'Posizione genitore (contiene questo)';

  @override
  String get noParentRootLocation => 'Nessun genitore (posizione radice)';

  @override
  String get noneRootScheme => 'Nessuno (radice dello schema)';

  @override
  String get savingLabel => 'Risparmio...';

  @override
  String get saveLocationLabel => 'Salva posizione';

  @override
  String locationCreatedSuccessfully(String name) {
    return 'Posizione \"$name\" creata correttamente.';
  }

  @override
  String errorCreatingLocation(String error) {
    return 'Errore durante la creazione della posizione: $error';
  }

  @override
  String get locationCannotBeItsOwnParent =>
      'Una posizione non può essere il proprio genitore.';

  @override
  String locationUpdatedSuccessfully(String name) {
    return 'Posizione \"$name\" aggiornata.';
  }

  @override
  String errorUpdatingLocation(String error) {
    return 'Errore durante l\'aggiornamento della posizione: $error';
  }

  @override
  String editLocationTitle(String name) {
    return 'Modifica: $name';
  }

  @override
  String get updateLocationLabel => 'Aggiorna posizione';

  @override
  String get selectObjectTitle => 'Seleziona oggetto';

  @override
  String get noObjectsAvailable => 'Nessun articolo disponibile';

  @override
  String availableQuantity(int quantity) {
    return 'Disponibile: $quantity';
  }

  @override
  String errorSelectingObject(String error) {
    return 'Errore nella selezione dell\'oggetto: $error';
  }

  @override
  String get mustSelectAnObject => 'È necessario selezionare un oggetto';

  @override
  String get loanRegisteredSuccessfully => 'Prestito registrato con successo';

  @override
  String get selectAnObject => 'Seleziona un oggetto';

  @override
  String get selectLabel => 'Selezionare';

  @override
  String get borrowerNameHint => 'Esempio: Juan Perez';

  @override
  String get borrowerNameRequired => 'Il nome è obbligatorio';

  @override
  String loanQuantityAvailable(int quantity) {
    return 'Importo da prestare (Disponibile: $quantity)';
  }

  @override
  String get enterQuantity => 'Inserisci un importo';

  @override
  String get invalidQuantity => 'Quantità non valida';

  @override
  String get notEnoughStock => 'Le scorte non sono sufficienti';

  @override
  String get invalidEmail => 'e-mail non valida';

  @override
  String expectedReturnDateLabel(String date) {
    return 'Rendimento previsto: $date';
  }

  @override
  String get selectReturnDate => 'Seleziona la data di ritorno';

  @override
  String get additionalNotes => 'Note aggiuntive';

  @override
  String get registerLoanLabel => 'Registrati Prestito';

  @override
  String get totalLabel => 'Totale';

  @override
  String get newLocationLabel => 'Nuova posizione';

  @override
  String get newLocationHint => 'Es: Scaffale A1, Armadietto 3...';

  @override
  String get parentLocationOptionalLabel => 'Località principale (facoltativo)';

  @override
  String get noneRootLabel => 'Nessuno (radice)';

  @override
  String locationCreatedShort(String name) {
    return 'Posizione \"$name\" creata';
  }

  @override
  String get newLocationEllipsis => 'Nuova sede...';

  @override
  String get couldNotReloadList => 'Impossibile ricaricare l\'elenco';

  @override
  String get deleteAssetTitle => 'Elimina risorsa';

  @override
  String confirmDeleteAssetItem(String name) {
    return 'Confermi di voler rimuovere \"$name\"?';
  }

  @override
  String get assetDeletedShort => 'Risorsa rimossa.';

  @override
  String viewColumnsLabel(int count) {
    return 'Visualizza: $count col.';
  }

  @override
  String get notValuedLabel => 'Non valutato';

  @override
  String get manageSearchSyncAssets =>
      'Gestisci, cerca e sincronizza le tue risorse da un\'unica dashboard.';

  @override
  String get filterLabel => 'Filtro';

  @override
  String get activeFilterLabel => 'Filtro attivo';

  @override
  String get importLabel => 'Questione';

  @override
  String get exportLabel => 'Esportare';

  @override
  String get csvExportNoData => 'Non ci sono elementi da esportare.';

  @override
  String csvExportSuccess(int count) {
    return 'CSV esportato correttamente ($count elementi).';
  }

  @override
  String get csvExportError => 'Impossibile esportare CSV';

  @override
  String get syncLabel => 'Sincronizza i prezzi';

  @override
  String get syncingLabel => 'Sincronizzazione...';

  @override
  String get newAssetLabel => 'Nuova risorsa';

  @override
  String get statusAndPreferences => 'Stato e preferenze';

  @override
  String get itemStatusLabel => 'Stato dell\'articolo';

  @override
  String get availableLabel => 'Disponibile';

  @override
  String get mustBeGreaterThanZero => 'Deve essere maggiore di 0.';

  @override
  String get alertThresholdLabel => 'Soglia di avviso';

  @override
  String get enterMinimumStock => 'Inserisci una scorta minima.';

  @override
  String get serializedItemFixedQuantity =>
      'Questo è un articolo seriale. La quantità è fissata a 1.';

  @override
  String get serialNumberLabel => 'Numero di serie';

  @override
  String get serialNumberHint => 'Esempio: SN-2024-00123';

  @override
  String get mainDataTitle => 'Dati principali';

  @override
  String get currentMarketValueLabel => 'VALORE ATTUALE DI MERCATO';

  @override
  String get updatePriceLabel => 'Aggiorna prezzo';

  @override
  String get viewLabel => 'Visualizzazione';

  @override
  String get visualGalleryTitle => 'Galleria visiva';

  @override
  String get statusAndMarketTitle => 'Stato e mercato';

  @override
  String get valuationHistoryTitle => 'Cronologia delle valutazioni';

  @override
  String get specificationsTitle => 'Specifiche';

  @override
  String get traceabilityTitle => 'Tracciabilità';

  @override
  String get stockLabel => 'azione';

  @override
  String get internalReferenceLabel => 'Riferimento interno';

  @override
  String get noSpecificationsAvailable => 'Nessuna specifica disponibile';

  @override
  String get trueLabel => 'VERO';

  @override
  String get falseLabel => 'Impostore';

  @override
  String get openLinkLabel => 'Apri collegamento';

  @override
  String get scannerFocusTip =>
      'Suggerimento: se non mette a fuoco, spostare il prodotto a circa 30 cm dalla fotocamera.';

  @override
  String get scanCodeTitle => 'Scansione codice';

  @override
  String get scanOrEnterProductCode =>
      'Scansiona o inserisci il codice prodotto';

  @override
  String possessionProgressLabel(String name) {
    return '$name progressi';
  }

  @override
  String get externalImportTitle => 'Importa da fonte esterna';

  @override
  String get galleryTitle => 'Galleria';

  @override
  String get stockAndCodingTitle => 'Magazzino e codifica';

  @override
  String get cameraPermissionRequired =>
      'Per eseguire la scansione è necessaria l\'autorizzazione della fotocamera';

  @override
  String get cloudDataFound => 'Dati trovati nel cloud!';

  @override
  String get typeSomethingToSearch => 'Scrivi qualcosa da cercare';

  @override
  String get importCancelled => 'Importazione annullata.';

  @override
  String get couldNotCompleteImport => 'Impossibile completare l\'importazione';

  @override
  String get yearLabel => 'Anno';

  @override
  String get authorLabel => 'Autore';

  @override
  String get selectResultTitle => 'Seleziona un risultato';

  @override
  String get unnamedLabel => 'Senza nome';

  @override
  String get completeRequiredFields =>
      'Si prega di completare i campi richiesti.';

  @override
  String get assetCreatedSuccess => 'Risorsa creata!';

  @override
  String errorCreatingAsset(String error) {
    return 'Errore durante la creazione della risorsa: $error';
  }

  @override
  String get technicalDetailsTitle => 'Dettagli tecnici';

  @override
  String itemImportedSuccessfully(String name) {
    return '$name importato con successo!';
  }

  @override
  String newImagesSelected(int count) {
    return 'Sono state selezionate $count nuove immagini.';
  }

  @override
  String get newFileRemoved => 'Nuovo file rimosso.';

  @override
  String get imageMarkedForDeletion =>
      'Immagine contrassegnata per l\'eliminazione al momento del salvataggio.';

  @override
  String get couldNotIdentifyImage => 'Impossibile identificare l\'immagine.';

  @override
  String editAssetTitle(String name) {
    return 'Modifica: $name';
  }

  @override
  String get syncPricesTitle => 'Sincronizza i prezzi';

  @override
  String get syncPricesDescription =>
      'Verrà eseguita una query sull\'API per aggiornare il valore di mercato.';

  @override
  String get syncingMarketPrices => 'Sincronizzazione dei prezzi di mercato...';

  @override
  String get couldNotSyncPrices => 'Impossibile sincronizzare i prezzi';

  @override
  String get syncCompletedTitle => 'Sincronizzazione completata';

  @override
  String get updatedLabel => 'Aggiornato';

  @override
  String get noApiPriceLabel => 'Nessun prezzo nell\'API';

  @override
  String get errorsLabel => 'Errori';

  @override
  String get totalProcessedLabel => 'Totale elaborato';

  @override
  String get noAssetsToShow => 'Non ci sono risorse da visualizzare';

  @override
  String get noImageLabel => 'Nessuna immagine';

  @override
  String get aiMagicQuestion => 'Hai un collegamento?';

  @override
  String get aiAutocompleteAsset =>
      'Compila automaticamente questa risorsa con l\'intelligenza artificiale';

  @override
  String get magicLabel => 'MAGIA';

  @override
  String get skuBarcodeLabel => 'SKU/EAN/UPC';

  @override
  String get veniChatPlaceholder => 'Chiedimi qualcosa...';

  @override
  String get veniChatPoweredBy => 'Powered by ';

  @override
  String veniChatProcessing(String query) {
    return 'Sto elaborando la tua domanda su \"$query\"...';
  }

  @override
  String get veniChatStatus => 'In linea';

  @override
  String get veniChatTitle => 'Venibot AI';

  @override
  String get veniChatWelcome =>
      'Ciao! Sono Venibot, il tuo assistente Invenicum. Come posso aiutarti con il tuo inventario oggi?';

  @override
  String get veniCmdDashboard => 'Vai al pannello di controllo';

  @override
  String get veniCmdHelpTitle => 'Le abilità di Veni';

  @override
  String get veniCmdInventory => 'Controlla lo stock di un articolo';

  @override
  String get veniCmdLoans => 'Visualizza i prestiti attivi';

  @override
  String get veniCmdReport => 'Genera un rapporto sull\'inventario';

  @override
  String get veniCmdScanQR => 'Scansiona il codice QR/a barre';

  @override
  String get veniCmdUnknown =>
      'Non riconosco quel comando. Scrivi aiuto per vedere cosa posso fare.';

  @override
  String version(String name) {
    return 'Versione $name';
  }

  @override
  String get yes => 'Sì';

  @override
  String get zoomToFit => 'Regola vista';

  @override
  String get generalSettingsMenuLabel => 'Impostazioni generali';

  @override
  String get aiAssistantMenuLabel => 'Assistente AI';

  @override
  String get notificationsMenuLabel => 'Notifiche';

  @override
  String get loanManagementMenuLabel => 'Gestione dei prestiti';

  @override
  String get aboutMenuLabel => 'Informazioni';

  @override
  String get automaticDarkModeLabel => 'Modalità oscura automatica';

  @override
  String get syncWithSystemLabel => 'Sincronizzarsi con il sistema';

  @override
  String get manualDarkModeLabel => 'Modalità oscura manuale';

  @override
  String get disableAutomaticToChange =>
      'Disattiva la modalità automatica per modificarla';

  @override
  String get changeLightDark => 'Passa da chiaro a scuro';

  @override
  String get enableAiAndChatbot =>
      'Abilita l\'intelligenza artificiale e il chatbot';

  @override
  String get requiresGeminiLinking =>
      'Richiede la connessione con Gemini in Integrazioni';

  @override
  String get aiOrganizeInventory =>
      'Usa l\'intelligenza artificiale per organizzare il tuo inventario in modo intelligente';

  @override
  String get aiAssistantTitle => 'Assistente all\'intelligenza artificiale';

  @override
  String get selectAiProvider =>
      'Scegli quale fornitore di intelligenza artificiale Veni utilizzerà. Assicurati di avere la chiave API configurata in Integrazioni.';

  @override
  String get aiProviderLabel => 'Fornitore';

  @override
  String get aiModelLabel => 'Modello';

  @override
  String get aiProviderUpdated => 'Fornitore AI aggiornato';

  @override
  String get purgeChatHistoryTitle => 'Cronologia chat';

  @override
  String get purgeChatHistoryDescription =>
      'Elimina definitivamente tutta la cronologia delle conversazioni salvate di Veni.';

  @override
  String get purgeChatHistoryButton => 'Elimina la cronologia';

  @override
  String get purgeChatHistoryConfirmTitle => 'Eliminare la cronologia chat?';

  @override
  String get purgeChatHistoryConfirmMessage =>
      'Questa azione eliminerà tutti i messaggi salvati e non potrà essere annullata.';

  @override
  String get purgeChatHistoryConfirmAction => 'Sì, spurgo';

  @override
  String get purgeChatHistorySuccess =>
      'Cronologia chat eliminata correttamente.';

  @override
  String get purgeChatHistoryError =>
      'Impossibile eliminare la cronologia chat.';

  @override
  String get notificationSettingsTitle => 'Gestione delle notifiche';

  @override
  String get channelPriorityLabel => 'Priorità canale (trascina per ordinare)';

  @override
  String get telegramBotLabel => 'Bot di Telegramma';

  @override
  String get resendEmailLabel => 'Invia nuovamente l\'e-mail';

  @override
  String get lowStockLabel => 'Scorte basse';

  @override
  String get lowStockHint =>
      'Avvisa quando un prodotto scende al di sotto del minimo.';

  @override
  String get newPresalesLabel => 'Nuove prevendite';

  @override
  String get newPresalesHint =>
      'Notifica i lanci rilevati dall\'intelligenza artificiale.';

  @override
  String get loanReminderLabel => 'Promemoria prestito';

  @override
  String get loanReminderHint => 'Avvisare prima della data di ritorno.';

  @override
  String get overdueLoansLabel => 'Prestiti scaduti';

  @override
  String get overdueLoansHint =>
      'Avviso critico se un oggetto non viene restituito in tempo.';

  @override
  String get maintenanceLabel => 'Manutenzione';

  @override
  String get maintenanceHint =>
      'Avvisa quando è il momento di rivedere una risorsa.';

  @override
  String get priceChangeLabel => 'Variazioni di prezzo';

  @override
  String get priceChangeHint =>
      'Notificare le variazioni di valore nel mercato.';

  @override
  String get unlinkGithubTitle => 'Disconnetti GitHub';

  @override
  String get unlinkGithubMessage =>
      'Sei sicuro di voler scollegare il tuo account GitHub?';

  @override
  String get updatePasswordButton => 'AGGIORNA LA PASSWORD';

  @override
  String get profileFillAllFieldsError => 'Per favore, compila tutti i campi';

  @override
  String get profilePasswordUpdatedSuccess =>
      'Password aggiornata con successo!';

  @override
  String get profileDisconnectActionUpper => 'DISCONNETTI';

  @override
  String get profileGithubUnlinkedSuccess =>
      'Account GitHub scollegato correttamente';

  @override
  String get profileGithubLinkedSuccess =>
      'Account GitHub collegato correttamente!';

  @override
  String profileGithubProcessError(String error) {
    return 'Errore durante l\'elaborazione del collegamento GitHub: $error';
  }

  @override
  String get profileGithubConfigUnavailableError =>
      'Errore: configurazione GitHub non disponibile';

  @override
  String profileServerConnectionError(String error) {
    return 'Impossibile connettersi al server: $error';
  }

  @override
  String get profileUpdatedSuccess => 'Profilo aggiornato correttamente';

  @override
  String profileUpdateError(String error) {
    return 'Errore durante l\'aggiornamento del profilo: $error';
  }

  @override
  String get profileUsernameCommunityLabel => 'Username (Community)';

  @override
  String get profileUsernameCommunityHelper =>
      'Richiesto per pubblicare plugin.';

  @override
  String get profileUpdateButtonUpper => 'AGGIORNA PROFILO';

  @override
  String get profileGithubIdentityTitle => 'Identità GitHub';

  @override
  String profileGithubLinkedAs(String username) {
    return 'Collegato come @$username';
  }

  @override
  String get profileGithubLinkPrompt =>
      'Collega il tuo account per pubblicare plugin';

  @override
  String get profileGithubUsernameHint => 'Il tuo username GitHub';

  @override
  String get profileGithubFieldHint =>
      'Questo campo viene compilato automaticamente dopo l\'autenticazione con GitHub.';

  @override
  String get profileGithubDefaultMissingKeys =>
      'GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET';

  @override
  String profileGithubOAuthNotConfigured(String missing) {
    return 'GitHub OAuth non configurato. Mancanti: $missing. Configura GITHUB_CLIENT_ID e GITHUB_CLIENT_SECRET nel backend e riavvia il server.';
  }

  @override
  String get profileDisconnectGithubButton => 'Disconnetti GitHub';

  @override
  String get profileLinkGithubButton => 'Collega con GitHub';

  @override
  String get profileSecurityTitle => 'Sicurezza';

  @override
  String get profileChangeUpper => 'CAMBIA';

  @override
  String get profileCurrentPasswordLabel => 'Password attuale';

  @override
  String get profileNewPasswordLabel => 'Nuova password';

  @override
  String get profileConfirmNewPasswordLabel => 'Conferma nuova password';

  @override
  String get profileChangePasswordHint =>
      'Cambia periodicamente la tua password per mantenere sicuro il tuo account.';

  @override
  String get newContainerDialog => 'Nuovo contenitore';

  @override
  String get descriptionField => 'Descrizione';

  @override
  String get isCollectionQuestion => 'È una collezione?';

  @override
  String get createContainerButton => 'Crea contenitore';

  @override
  String get selectContainerHint => 'Seleziona un contenitore';

  @override
  String get newAssetTypeTitle => 'Nuovo tipo di risorsa';

  @override
  String get generalConfiguration => 'Impostazioni generali';

  @override
  String get collectionContainerWarning =>
      'Questo contenitore è una raccolta. È possibile creare tipi seriali o non seriali, ma il possesso e i campi desiderati possono essere configurati solo su tipi non seriali.';

  @override
  String get createAssetTypeButton => 'Crea tipo di risorsa';

  @override
  String assetTypesInContainer(String name) {
    return 'Tipi di risorse in \"$name\"';
  }

  @override
  String get createNewTypeButton => 'Crea nuovo tipo';

  @override
  String get isSerializedQuestion => 'È un articolo seriale?';

  @override
  String get addNewFieldButton => 'Aggiungi nuovo campo';

  @override
  String get deleteFieldTooltip => 'Elimina campo';

  @override
  String get fieldsOptions => 'Opzioni:';

  @override
  String get isRequiredField => 'È necessario';

  @override
  String get isSummativeFieldLabel =>
      'È la sommatoria (viene aggiunto al totale del tipo)';

  @override
  String get isMonetaryValueLabel => 'È valore monetario';

  @override
  String get monetaryValueDescription =>
      'Verrà utilizzato per calcolare l\'investimento totale nella Dashboard';

  @override
  String get noDataListsAvailable =>
      '⚠️ Non ci sono elenchi di dati disponibili in questo contenitore.';

  @override
  String get selectDataList => 'Seleziona Elenco dati';

  @override
  String get chooseList => 'Scegli un elenco';

  @override
  String get goToPageLabel => 'Vai alla pagina:';

  @override
  String get conditionLabel => 'Condizione';

  @override
  String get actionsLabel => 'Azioni';

  @override
  String get editButtonLabel => 'Modificare';

  @override
  String get deleteButtonLabel => 'Eliminare';

  @override
  String get printLabel => 'Stampa etichetta';

  @override
  String get collectionFieldsTooltip => 'Campi di raccolta';

  @override
  String totalLocations(int count) {
    return '$count posizioni';
  }

  @override
  String withoutLocationLabel(int count) {
    return '$count nessuna posizione ·';
  }

  @override
  String get objectIdColumn => 'Identificativo dell\'oggetto';

  @override
  String containerNotFoundError(String id) {
    return 'Contenitore con ID $id non trovato.';
  }

  @override
  String get invalidContainerIdError => 'Errore: ID contenitore non valido.';

  @override
  String get startConfigurationButton => 'Avvia la configurazione';

  @override
  String get fullNameField => 'Nome e cognome';

  @override
  String get emailField => 'E-mail';

  @override
  String get passwordField => 'Password';

  @override
  String get confirmPasswordField => 'Conferma password';

  @override
  String get goBackButton => 'Ritorno';

  @override
  String get createAccountButton => 'Creare un account';

  @override
  String get goToLoginButton => 'Vai al login';

  @override
  String get deleteConfirmationTitle => 'Conferma l\'eliminazione';

  @override
  String deleteItemMessage(String name) {
    return 'Vuoi rimuovere \"$name\"?';
  }

  @override
  String get elementDeletedSuccess => 'Elemento eliminato con successo';

  @override
  String get enterYourNameValidation => 'Inserisci il tuo nome.';

  @override
  String get minTwoCharactersValidation => 'Minimo 2 caratteri.';

  @override
  String get enterEmailValidation => 'Inserisci un\'e-mail.';

  @override
  String get invalidEmailValidation => 'E-mail non valida.';

  @override
  String get enterPasswordValidation => 'Inserisci una password.';

  @override
  String get minEightCharactersValidation => 'Minimo 8 caratteri.';

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
  String get invalidIdError => 'documento d\'identità non valido';

  @override
  String assetTypeLoadError(String error) {
    return 'Errore durante il caricamento dei dati: $error';
  }

  @override
  String get assetTypeUpdateSuccess =>
      'Tipo di risorsa aggiornato correttamente';

  @override
  String assetTypeUpdateError(String error) {
    return 'Errore durante l\'aggiornamento: $error';
  }

  @override
  String editAssetTypeTitle(String name) {
    return 'Modifica: $name';
  }

  @override
  String get achievementCollectionTitle => 'Risultati della raccolta';

  @override
  String get achievementSubtitle => 'Sblocca traguardi utilizzando Invenicum';

  @override
  String get legendaryAchievementLabel => 'RISULTATO LEGGENDARIO';

  @override
  String get achievementCompleted => 'Riempito';

  @override
  String get achievementLocked => 'Bloccato';

  @override
  String achievementUnlockedDate(String date) {
    return 'Ho ricevuto $date';
  }

  @override
  String get achievementLockedMessage => 'Raggiungi l\'obiettivo per sbloccare';

  @override
  String get closeButtonLabel => 'Inteso';

  @override
  String get configurationGeneralSection => 'Impostazioni generali';

  @override
  String get assetTypeCollectionWarning =>
      'Questo contenitore è una raccolta. È possibile creare tipi seriali o non seriali, ma il possesso e i campi desiderati possono essere configurati solo su tipi non seriali.';

  @override
  String get updateAssetTypeButton => 'Aggiorna tipo di risorsa';

  @override
  String get createAssetTypeButtonDefault => 'Crea tipo di risorsa';

  @override
  String get noAssetTypesMessage =>
      'Non sono ancora stati definiti tipi di asset in questo contenitore.';

  @override
  String totalCountLabel(int count) {
    return 'Totale: $count';
  }

  @override
  String possessionCountLabel(int count) {
    return 'Possesso: $count';
  }

  @override
  String desiredCountLabel(int count) {
    return 'Desiderato: $count';
  }

  @override
  String get marketValueLabel => 'Mercato:';

  @override
  String get defaultSumFieldName => 'Aggiunta';

  @override
  String get calculatingLabel => 'Calcolato...';

  @override
  String get unknownError => 'Errore sconosciuto';

  @override
  String get noNameItem => 'Senza nome';

  @override
  String get loadingContainers => 'Caricamento contenitori...';

  @override
  String get fieldNameRequired => 'Il nome del campo è obbligatorio';

  @override
  String get selectImageButton => 'Seleziona Immagine';

  @override
  String assetTypeDeletedSuccess(String name) {
    return '$name rimosso';
  }

  @override
  String get noLocationValueData =>
      'Non esistono ancora asset con posizione e valore sufficienti per tracciare questo grafico.';

  @override
  String get requiredFieldValidation => 'Questo campo è obbligatorio';

  @override
  String get oceanTheme => 'Oceano Indiano';

  @override
  String get cherryBlossomTheme => 'Fiore di ciliegio';

  @override
  String get themeBrand => 'Invenicum (Marchio)';

  @override
  String get themeEmerald => 'Smeraldo';

  @override
  String get themeSunset => 'Tramonto';

  @override
  String get themeLavender => 'Lavanda morbida';

  @override
  String get themeForest => 'Foresta profonda';

  @override
  String get themeCherry => 'Ciliegia';

  @override
  String get themeElectricNight => 'Notte elettrica';

  @override
  String get themeAmberGold => 'Ambra Oro';

  @override
  String get themeModernSlate => 'Lavagna moderna';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeNordicArctic => 'Artico settentrionale';

  @override
  String get themeDeepNight => 'Notte profonda';

  @override
  String get loginSuccess => 'Accesso riuscito';

  @override
  String get reloadListError => 'Impossibile ricaricare l\'elenco';

  @override
  String get copyItemSuffix => 'Copia';

  @override
  String itemCopiedSuccess(String name) {
    return 'Elemento copiato: $name';
  }

  @override
  String get copyError => 'Errore di copia';

  @override
  String get imageColumnLabel => 'Immagine';

  @override
  String get viewImageTooltip => 'Vedi immagine';

  @override
  String get currentStockLabel => 'Scorte attuali';

  @override
  String get minimumStockLabel => 'Scorta minima';

  @override
  String get locationColumnLabel => 'Posizione';

  @override
  String get serialNumberColumnLabel => 'numero di serie';

  @override
  String get marketPriceLabel => 'Prezzo di mercato';

  @override
  String get conditionColumnLabel => 'Condizione';

  @override
  String get actionsColumnLabel => 'Azioni';

  @override
  String get imageLoadError => 'Impossibile caricare l\'immagine';

  @override
  String get imageUrlHint =>
      'Assicurati che l\'URL sia corretto e che il server sia attivo';

  @override
  String get assetTypeNameHint => 'Es: laptop, sostanza chimica';

  @override
  String get assetTypeNameLabel => 'Nome del tipo di risorsa';

  @override
  String get underConstruction => 'In costruzione';

  @override
  String get comingSoon => 'Presto';

  @override
  String get constructionSubtitle =>
      'Questa funzionalità è in fase di sviluppo';

  @override
  String get selectColor => 'Seleziona Colore';

  @override
  String get valueDistributionByLocation =>
      'Distribuzione del valore per località';

  @override
  String get heatmapDescription =>
      'La ciambella mostra come è distribuito il valore di mercato tra le località con il peso maggiore.';

  @override
  String locationsCount(int count) {
    return '$count posizioni';
  }

  @override
  String get unitsLabel => 'Voi';

  @override
  String get recordsLabel => 'record';

  @override
  String get totalValueFallback => 'Valore totale';

  @override
  String containerFallback(String id) {
    return 'Contenitore $id';
  }

  @override
  String locationFallback(String id) {
    return 'Posizione $id';
  }

  @override
  String get ofTheValueLabel => 'del valore';

  @override
  String get reportsDescription =>
      'Genera report in PDF o Excel da stampare o salvare sul tuo PC';

  @override
  String get reportSectionType => 'Tipo di rapporto';

  @override
  String get reportSectionFormat => 'Formato di uscita';

  @override
  String get reportSectionPreview => 'Impostazioni correnti';

  @override
  String get reportSelectContainerTitle => 'Seleziona un contenitore';

  @override
  String get reportGenerate => 'Genera rapporto';

  @override
  String get reportGenerating => 'Generazione...';

  @override
  String get reportTypeInventoryDescription =>
      'Elenco completo dell\'inventario';

  @override
  String get reportTypeLoansDescription => 'Prestiti attivi e loro status';

  @override
  String get reportTypeAssetsDescription => 'Elenco dei beni per categoria';

  @override
  String get reportLabelContainer => 'Contenitore';

  @override
  String get reportLabelType => 'Tipo di rapporto';

  @override
  String get reportLabelFormat => 'Formato';

  @override
  String get reportFormatPdf => 'PDF';

  @override
  String get reportFormatExcel => 'Eccellere';

  @override
  String get reportNotSelected => 'Non selezionato';

  @override
  String get reportUnknown => 'Uno sconosciuto';

  @override
  String get reportSelectContainerFirst => 'Seleziona un contenitore';

  @override
  String reportDownloadedSuccess(String format) {
    return 'Il rapporto $format è stato scaricato correttamente';
  }

  @override
  String reportGenerateError(String error) {
    return 'Errore durante la generazione del rapporto: $error';
  }

  @override
  String get firstRunWelcomeTitle => 'Benvenuto a Invenicum';

  @override
  String get firstRunConfigTitle => 'Configurazione iniziale';

  @override
  String get firstRunWelcomeDescription =>
      'Sembra che l\'app sia stata avviata per la prima volta. Creiamo il tuo account amministratore per iniziare.';

  @override
  String get firstRunStep1Label => 'Passaggio 1 di 2 · Benvenuto';

  @override
  String get firstRunStep2Label => 'Passaggio 2 di 2 · Crea amministratore';

  @override
  String get firstRunSuccessMessage => 'Il tuo account è stato creato';

  @override
  String get firstRunAdminTitle => 'Crea amministratore';

  @override
  String get firstRunAdminDescription =>
      'Questo utente avrà pieno accesso alla piattaforma.';

  @override
  String get firstRunFeature1 => 'Crea il tuo utente amministratore';

  @override
  String get firstRunFeature2 => 'Accesso sicuro con password';

  @override
  String get firstRunFeature3 => 'Pronto all\'uso in pochi secondi';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono.';

  @override
  String get firstRunSuccessTitle => 'Account creato!';

  @override
  String get firstRunSuccessSubtitle =>
      'Il tuo account amministratore è pronto.\\nPuoi ora accedere.';

  @override
  String get firstRunAccountCreatedLabel => 'ACCOUNT CREATO';

  @override
  String get firstRunCopyright => 'Invenicum ©';
}
