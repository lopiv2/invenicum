// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get aboutInvenicum => 'À propos d\'Invenicum';

  @override
  String get active => 'Actif';

  @override
  String get activeLoans => 'Prêts actifs';

  @override
  String get activeLoansCount => 'Prêts actifs';

  @override
  String get addAlert => 'Ajouter une alerte';

  @override
  String get addAsset => 'Ajouter une ressource';

  @override
  String get addContainer => 'Ajouter un conteneur';

  @override
  String get addNewLocation => 'Ajouter une nouvelle localisation';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get additionalThumbnails => 'Miniatures supplémentaires';

  @override
  String aiExtractionError(String error) {
    return 'L\'IA n\'a pas pu extraire les données: $error';
  }

  @override
  String get aiPasteUrlDescription =>
      'Collez le lien du produit et l\'IA extraira automatiquement les informations pour remplir les champs.';

  @override
  String get alertCritical => 'Critique';

  @override
  String get alertCreated => 'Alerte créée';

  @override
  String get alertDeleted => 'Alerte supprimée';

  @override
  String get alertInfo => 'Information';

  @override
  String get alertMessage => 'Message';

  @override
  String get alertTitle => 'Titre';

  @override
  String get alertType => 'Type';

  @override
  String get alertWarning => 'Avertissement';

  @override
  String get alerts => 'Alertes et notifications';

  @override
  String get all => 'Tous';

  @override
  String get appTitle => 'Invenicum Inventaire';

  @override
  String get applicationTheme => 'Thème de l\'application';

  @override
  String get apply => 'Appliquer';

  @override
  String get april => 'Avril';

  @override
  String get assetDetail => 'Asset Details';

  @override
  String get assetImages => 'Images des ressources';

  @override
  String get assetImport => 'Importation des ressources';

  @override
  String get assetName => 'Nom de la ressource';

  @override
  String get assetNotFound => 'Asset not found';

  @override
  String assetTypeDeleted(String name) {
    return 'Type de ressource \"$name\" supprimé avec succès.';
  }

  @override
  String get assetTypes => 'Types de ressources';

  @override
  String assetUpdated(String name) {
    return 'Ressource \"$name\" mise à jour avec succès.';
  }

  @override
  String get assets => 'Ressources';

  @override
  String get assetsIn => 'Ressources dans';

  @override
  String get august => 'Août';

  @override
  String get backToAssetTypes => 'Retour aux types de ressources';

  @override
  String get borrowerEmail => 'Email de l\'emprunteur';

  @override
  String get borrowerName => 'Nom de l\'emprunteur';

  @override
  String get borrowerPhone => 'Téléphone de l\'emprunteur';

  @override
  String get cancel => 'Annuler';

  @override
  String get centerView => 'Vue centrale';

  @override
  String get chooseFile => 'Choisir un fichier';

  @override
  String get clearCounter => 'Effacer le compteur';

  @override
  String get collectionContainerInfo =>
      'Les conteneurs de collection ont des barres de suivi de collection, une valeur investie, une valeur marchande et une vue d\'exposition';

  @override
  String get collectionFieldsConfigured => 'Champs de collection configurés.';

  @override
  String get configureCollectionFields => 'Configurer les champs de collection';

  @override
  String get configureDeliveryVoucher => 'Configurer le bon de livraison';

  @override
  String get configureVoucherBody => 'Configurer le corps du bon...';

  @override
  String get confirmDeleteAlert => 'Supprimer l\'alerte';

  @override
  String get confirmDeleteAlertMessage =>
      'Êtes-vous sûr de vouloir supprimer cet enregistrement?';

  @override
  String confirmDeleteAssetType(String name) {
    return 'Êtes-vous sûr de vouloir supprimer le type de ressource \"$name\" et tous les éléments associés? Cette action ne peut pas être annulée.';
  }

  @override
  String confirmDeleteContainer(String name) {
    return 'Êtes-vous sûr de vouloir supprimer le conteneur \"$name\"? Cette action est irréversible et supprimera toutes ses ressources et données.';
  }

  @override
  String confirmDeleteLocationMessage(String name) {
    return 'Êtes-vous sûr de vouloir supprimer la localisation \"$name\"?';
  }

  @override
  String get confirmDeletion => 'Confirmer la suppression';

  @override
  String get configurationSaved => 'Configuration enregistrée avec succès.';

  @override
  String containerCreated(String name) {
    return 'Conteneur \"$name\" créé avec succès.';
  }

  @override
  String containerDeleted(String name) {
    return 'Conteneur \"$name\" supprimé avec succès.';
  }

  @override
  String get containerName => 'Nom du conteneur';

  @override
  String get containerOrAssetTypeNotFound =>
      'Conteneur ou type de ressource non trouvé.';

  @override
  String containerRenamed(String name) {
    return 'Conteneur renommé en \"$name\".';
  }

  @override
  String get containers => 'Conteneurs';

  @override
  String get countItemsByValue => 'Compter les éléments par valeur spécifique';

  @override
  String get create => 'Créer';

  @override
  String get createFirstContainer => 'Créez votre premier conteneur.';

  @override
  String get createdAt => 'Creation Date';

  @override
  String get current => 'Actuel';

  @override
  String get customColor => 'Couleur personnalisée';

  @override
  String get customFields => 'Champs personnalisés';

  @override
  String customFieldsOf(String name) {
    return 'Champs personnalisés de $name';
  }

  @override
  String get customizeDeliveryVoucher =>
      'Personnalisez le modèle PDF pour les prêts';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get datalists => 'Listes personnalisées';

  @override
  String get december => 'Décembre';

  @override
  String get definitionCustomFields => 'Définition des champs personnalisés';

  @override
  String get delete => 'Supprimer';

  @override
  String deleteError(String error) {
    return 'Erreur de suppression: $error';
  }

  @override
  String get deleteSuccess => 'Localisation supprimée avec succès.';

  @override
  String get deliveryVoucher => 'BON DE LIVRAISON';

  @override
  String get deliveryVoucherEditor => 'Éditeur de bon de livraison';

  @override
  String get description => 'Description (optionnel)';

  @override
  String get desiredField => 'Champ désiré';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get edit => 'Modifier';

  @override
  String get enterContainerName => 'Entrez le nom du conteneur';

  @override
  String get enterDescription => 'Entrez une description';

  @override
  String get enterURL => 'Entrez une URL';

  @override
  String get enterValidUrl => 'Entrez une URL valide';

  @override
  String errorChangingLanguage(String error) {
    return 'Erreur lors du changement de langue: $error';
  }

  @override
  String get errorCsvMinRows =>
      'Veuillez sélectionner un fichier CSV avec en-têtes et au moins une ligne de données.';

  @override
  String errorDeletingAssetType(String error) {
    return 'Erreur lors de la suppression du type de ressource: $error';
  }

  @override
  String errorDeletingContainer(String error) {
    return 'Erreur lors de la suppression du conteneur: $error';
  }

  @override
  String get errorDuringImport => 'Erreur lors de l\'importation';

  @override
  String get errorEmptyCsv => 'Le fichier CSV est vide.';

  @override
  String errorGeneratingPDF(String error) {
    return 'Erreur lors de la génération du PDF: $error';
  }

  @override
  String get errorInvalidPath => 'Chemin de fichier invalide.';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String errorLoadingListValues(String error) {
    return 'Erreur lors du chargement des valeurs de liste: $error';
  }

  @override
  String errorLoadingLocations(String error) {
    return 'Erreur lors du chargement des localisations: $error';
  }

  @override
  String get errorNameMappingRequired =>
      'Le champ \"Nom\" est obligatoire et doit être mappé.';

  @override
  String get errorNoVoucherTemplate => 'Aucun modèle de bon configuré.';

  @override
  String get errorReadingBytes => 'Impossible de lire les octets du fichier.';

  @override
  String errorReadingFile(String error) {
    return 'Erreur lors de la lecture du fichier: $error';
  }

  @override
  String errorRegisteringLoan(String error) {
    return 'Erreur lors de l\'enregistrement du prêt: $error';
  }

  @override
  String errorRenaming(String error) {
    return 'Erreur lors du renommage: $error';
  }

  @override
  String errorSaving(String error) {
    return 'Erreur lors de l\'enregistrement: $error';
  }

  @override
  String errorUpdatingAsset(String error) {
    return 'Erreur lors de la mise à jour de la ressource: $error';
  }

  @override
  String get exampleFilterHint => 'Ex: Endommagé, Rouge, 50';

  @override
  String get february => 'Février';

  @override
  String get fieldChip => 'Champ';

  @override
  String fieldRequiredWithName(String field) {
    return 'Le champ \"$field\" est obligatoire.';
  }

  @override
  String get fieldToCount => 'Champ à compter';

  @override
  String get fieldsFilledSuccess => 'Champs remplis avec succès!';

  @override
  String get formatsPNG => 'Formats: PNG, JPG';

  @override
  String get generalSettings => 'Paramètres généraux';

  @override
  String get generateVoucher => 'Générer un bon de livraison';

  @override
  String get globalSearch => 'Recherche globale';

  @override
  String get greeting => 'Bonjour, bienvenue!';

  @override
  String get guest => 'Invité';

  @override
  String get helpDocs => 'Help & Documentation';

  @override
  String get ignoreField => '🚫 Ignorer le champ';

  @override
  String get importAssetsTo => 'Importer les ressources vers';

  @override
  String importSuccessMessage(int count) {
    return 'Importation réussie! $count ressources créées.';
  }

  @override
  String get integrations => 'Integrations';

  @override
  String get invalidAssetId => 'Invalid asset ID';

  @override
  String get invalidNavigationIds => 'Erreur: ID de navigation non valides.';

  @override
  String get january => 'Janvier';

  @override
  String get july => 'Juillet';

  @override
  String get june => 'Juin';

  @override
  String get language => 'Langue';

  @override
  String get languageChanged => 'Langue changée en français!';

  @override
  String get languageNotImplemented => 'Fonctionnalité de langue à implémenter';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get loadingAssetType => 'Chargement du type de ressource...';

  @override
  String loadingListField(String field) {
    return 'Chargement de $field...';
  }

  @override
  String get loanDate => 'Date du prêt';

  @override
  String get loanLanguageNotImplemented =>
      'Language feature not yet implemented';

  @override
  String get loanManagement => 'Gestion des prêts';

  @override
  String get loanObject => 'Objet du prêt';

  @override
  String get loans => 'Prêts';

  @override
  String get location => 'Location';

  @override
  String get locations => 'Localisations';

  @override
  String get locationsScheme => 'Schéma des localisations';

  @override
  String get login => 'Connexion';

  @override
  String get logoVoucher => 'Logo du bon';

  @override
  String get logout => 'Déconnexion';

  @override
  String get magicAssistant => 'Assistant IA magique';

  @override
  String get march => 'Mars';

  @override
  String get may => 'Mai';

  @override
  String get minStock => 'Min stock';

  @override
  String get myCustomTheme => 'Mon thème';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get myThemesStored => 'Mes thèmes enregistrés';

  @override
  String get name => 'Name';

  @override
  String get nameCannotBeEmpty => 'Le nom ne peut pas être vide';

  @override
  String get nameSameAsCurrent => 'Le nom est identique à celui actuel';

  @override
  String get newAlert => 'Nouvelle alerte manuelle';

  @override
  String get newContainer => 'Nouveau conteneur';

  @override
  String get newName => 'Nouveau nom';

  @override
  String get next => 'Next';

  @override
  String get noAssetsCreated => 'Aucune ressource créée pour le moment.';

  @override
  String get noAssetsMatch =>
      'Aucune ressource ne correspond aux critères de recherche/filtrage.';

  @override
  String get noBooleanFields => 'Aucun champ booléen défini.';

  @override
  String get noContainerMessage => 'Créez votre premier conteneur.';

  @override
  String get noCustomFields =>
      'Ce type de ressource n\'a pas de champs personnalisés.';

  @override
  String get noFileSelected => 'Aucun fichier sélectionné';

  @override
  String get noImageAvailable => 'No image available';

  @override
  String get noImagesAdded =>
      'Aucune image ajoutée pour le moment. La première image sera la principale.';

  @override
  String get noLoansFound => 'Aucun prêt trouvé dans ce conteneur.';

  @override
  String get noLocationsMessage =>
      'Aucune localisation créée dans ce conteneur. Ajoutez la première!';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get noThemesSaved => 'Aucun thème enregistré pour le moment';

  @override
  String get none => 'Aucun';

  @override
  String get november => 'Novembre';

  @override
  String get obligatory => 'Obligatoire';

  @override
  String get october => 'Octobre';

  @override
  String get optional => 'Optionnel';

  @override
  String get overdue => 'En retard';

  @override
  String get password => 'Mot de passe';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get pleaseEnterUsername => 'Veuillez entrer votre nom d\'utilisateur';

  @override
  String get pleasePasteUrl => 'Veuillez coller une URL';

  @override
  String get pleaseSelectCsvWithHeaders =>
      'Veuillez sélectionner un fichier CSV avec en-têtes.';

  @override
  String get pleaseSelectLocation => 'Veuillez sélectionner une localisation.';

  @override
  String get plugins => 'Plugins';

  @override
  String get possessionFieldDef => 'Champ de possession';

  @override
  String get possessionFieldName => 'En possession';

  @override
  String get preferences => 'Préférences';

  @override
  String get previewPDF => 'Aperçu PDF';

  @override
  String get previous => 'Previous';

  @override
  String get primaryImage => 'Image principale';

  @override
  String get productUrlLabel => 'URL du produit';

  @override
  String get quantity => 'Quantité';

  @override
  String get registerNewLoan => 'Enregistrer un nouveau prêt';

  @override
  String get reloadContainers => 'Recharger les conteneurs';

  @override
  String get reloadLocations => 'Recharger les localisations';

  @override
  String get removeImage => 'Supprimer l\'image';

  @override
  String get rename => 'Renommer';

  @override
  String get renameContainer => 'Renommer le conteneur';

  @override
  String get returned => 'Retourné';

  @override
  String get rowsPerPageTitle => 'Ressources par page:';

  @override
  String get save => 'Enregistrer';

  @override
  String get saveAndApply => 'Enregistrer et appliquer';

  @override
  String get saveAsset => 'Enregistrer la ressource';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get saveConfiguration => 'Enregistrer la configuration';

  @override
  String get saveCustomTheme => 'Enregistrer le thème personnalisé';

  @override
  String get searchInAllColumns => 'Rechercher dans toutes les colonnes...';

  @override
  String get selectAndUploadImage => 'Sélectionner et télécharger une image';

  @override
  String get selectApplicationLanguage =>
      'Sélectionnez la langue de l\'application';

  @override
  String get selectBooleanFields =>
      'Sélectionnez les champs booléens pour contrôler la collection:';

  @override
  String get selectCsvColumn => 'Sélectionner la colonne CSV';

  @override
  String get selectField => 'Sélectionner un champ...';

  @override
  String get selectFieldType => 'Sélectionner le type de champ';

  @override
  String get selectImage => 'Sélectionner une image';

  @override
  String get selectLocationRequired =>
      'Vous devez sélectionner une localisation pour la ressource.';

  @override
  String selectedLocationLabel(String name) {
    return 'Sélectionné: $name';
  }

  @override
  String get selectTheme => 'Sélectionner un thème';

  @override
  String get september => 'Septembre';

  @override
  String get settings => 'Paramètres';

  @override
  String get showAsGrid => 'Afficher en tant que grille';

  @override
  String get showAsList => 'Afficher sous forme de liste';

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
  String get specificValueToCount => 'Valeur spécifique à compter';

  @override
  String get startImport => 'Démarrer l\'importation';

  @override
  String get startMagic => 'Démarrer la magie';

  @override
  String get status => 'Statut';

  @override
  String get step1SelectFile => 'Étape 1: Sélectionnez un fichier CSV';

  @override
  String get step2ColumnMapping =>
      'Étape 2: Mappage des colonnes (CSV -> Système)';

  @override
  String get syncingSession => 'Synchronisation de la session...';

  @override
  String get systemThemes => 'Thèmes du système';

  @override
  String get systemThemesModal => 'Thèmes du système';

  @override
  String get themeNameLabel => 'Nom du thème';

  @override
  String get thisFieldIsRequired => 'Ce champ est obligatoire.';

  @override
  String get topLoanedItems => 'Articles les plus empruntés';

  @override
  String get totalAssets => 'Types de ressources';

  @override
  String get totalItems => 'Ressources';

  @override
  String get totals => 'Totaux';

  @override
  String get updatedAt => 'Last Update';

  @override
  String get upload => 'Télécharger';

  @override
  String get uploadImage => 'Télécharger l\'image';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get veniChatPlaceholder => 'Posez-moi n\'importe quelle question...';

  @override
  String get veniChatPoweredBy => 'Powered by ';

  @override
  String veniChatProcessing(String query) {
    return 'Je traite votre question sur \"$query\"...';
  }

  @override
  String get veniChatStatus => 'En ligne';

  @override
  String get veniChatTitle => 'Veni IA';

  @override
  String get veniChatWelcome =>
      'Bonjour! Je suis Veni, votre assistant Invenicum. Comment puis-je vous aider avec votre inventaire aujourd\'hui?';

  @override
  String get veniCmdDashboard => 'Aller au tableau de bord';

  @override
  String get veniCmdHelpTitle => 'Capacités de Veni';

  @override
  String get veniCmdInventory => 'Vérifier le stock d\'un article';

  @override
  String get veniCmdLoans => 'Afficher les prêts actifs';

  @override
  String get veniCmdReport => 'Générer un rapport d\'inventaire';

  @override
  String get veniCmdScanQR => 'Scanner QR/Code-barres';

  @override
  String get veniCmdUnknown =>
      'Je ne reconnais pas cette commande. Écrivez help pour voir ce que je peux faire.';

  @override
  String version(String name) {
    return 'Version $name';
  }

  @override
  String get yes => 'Oui';

  @override
  String get zoomToFit => 'Zoom pour ajuster';
}
