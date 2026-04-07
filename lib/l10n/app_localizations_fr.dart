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
  String get aboutDialogTitle => 'À propos d\'Invenicum';

  @override
  String get aboutDialogCoolText =>
      'Votre inventaire, mais sous stéroïdes. On vérifie si une version plus fraîche vous attend.';

  @override
  String get aboutCurrentVersionLabel => 'Version actuelle';

  @override
  String get aboutLatestVersionLabel => 'Dernière version';

  @override
  String get aboutCheckingVersion => 'Vérification de la version en ligne...';

  @override
  String get aboutVersionUnknown => 'Inconnue';

  @override
  String get aboutVersionUpToDate => 'Votre application est à jour.';

  @override
  String get aboutUpdateAvailable => 'Une nouvelle version est disponible.';

  @override
  String get aboutVersionCheckFailed =>
      'Impossible de vérifier la version en ligne.';

  @override
  String get aboutOpenReleases => 'Voir les releases';

  @override
  String get active => 'Actif';

  @override
  String get actives => 'Actifs';

  @override
  String get activeInsight => 'APERÇU DES RESSOURCES ACTIVES';

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
  String get additionalInformation => 'Informations supplémentaires';

  @override
  String get additionalThumbnails => 'Miniatures supplémentaires';

  @override
  String get adquisition => 'ACQUISITION';

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
  String get allUpToDateStatus => 'Tout est à jour';

  @override
  String get appTitle => 'Invenicum Inventaire';

  @override
  String get applicationTheme => 'Thème de l\'application';

  @override
  String get apply => 'Appliquer';

  @override
  String get april => 'Avril';

  @override
  String get assetDetail => 'Détails de la ressource';

  @override
  String get assetImages => 'Images des ressources';

  @override
  String get assetImport => 'Importation des ressources';

  @override
  String get assetName => 'Nom de la ressource';

  @override
  String get assetNotFound => 'Ressource introuvable';

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
  String get averageMarketValue => 'Prix moyen du marché';

  @override
  String get barCode => 'Code-barres (EAN)';

  @override
  String get baseCostAccumulatedWithoutInflation =>
      'Coût de base cumulé hors inflation';

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
  String get condition => 'État';

  @override
  String get condition_mint => 'Boîte d\'origine';

  @override
  String get condition_loose => 'En vrac (sans boîte)';

  @override
  String get condition_incomplete => 'Incomplet';

  @override
  String get condition_damaged => 'Abîmé / Marques';

  @override
  String get condition_new => 'Neuf';

  @override
  String get condition_digital => 'Numérique / Intangible';

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
  String get createdAt => 'Date de création';

  @override
  String get currency => 'Devise';

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
  String get errorNotBarCode =>
      'L\'article n\'a pas de code-barres ou il n\'est pas valide.';

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
  String get forToday => 'Pour aujourd\'hui';

  @override
  String get geminiLabelModel =>
      'Modèle Gemini recommandé : gemini-3-flash-preview';

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
  String get helpDocs => 'Aide et documentation';

  @override
  String get helperGeminiKey =>
      'Entrez votre clé API Gemini pour activer l\'intégration. Obtenez-la sur https://aistudio.google.com/';

  @override
  String get ignoreField => 'Ignorer le champ';

  @override
  String get importAssetsTo => 'Importer les ressources vers';

  @override
  String importSuccessMessage(int count) {
    return 'Importation réussie! $count ressources créées.';
  }

  @override
  String get importSerializedWarning =>
      'Importation réussie. Ce type de ressource est sérialisé : tous les éléments ont été créés avec une quantité de 1.';

  @override
  String get integrations => 'Intégrations';

  @override
  String get integrationGeminiDesc =>
      'Connectez Invenicum à Gemini de Google pour exploiter des capacités d\'IA avancées dans la gestion de votre inventaire.';

  @override
  String get integrationTelegramDesc =>
      'Connectez Invenicum à Telegram pour recevoir des notifications instantanées sur votre inventaire directement sur votre appareil.';

  @override
  String get invalidAssetId => 'ID de ressource non valide';

  @override
  String get invalidNavigationIds => 'Erreur: ID de navigation non valides.';

  @override
  String get inventoryLabel => 'Inventaire';

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
      'Fonctionnalité de langue à implémenter';

  @override
  String get loanManagement => 'Gestion des prêts';

  @override
  String get loanObject => 'Objet du prêt';

  @override
  String get loans => 'Prêts';

  @override
  String get location => 'Emplacement';

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
  String get lookForContainersOrAssets =>
      'Rechercher des conteneurs ou des ressources...';

  @override
  String get lowStockTitle => 'Stock faible';

  @override
  String get magicAssistant => 'Assistant IA magique';

  @override
  String get march => 'Mars';

  @override
  String get marketPriceObtained => 'Prix du marché obtenu avec succès';

  @override
  String get marketValueEvolution => 'Évolution de la valeur de marché';

  @override
  String get marketValueField => 'Valeur de marché';

  @override
  String get maxStock => 'Stock maximum';

  @override
  String get may => 'Mai';

  @override
  String get minStock => 'Stock minimum';

  @override
  String get myAchievements => 'Mes réalisations';

  @override
  String get myCustomTheme => 'Mon thème';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get myThemesStored => 'Mes thèmes enregistrés';

  @override
  String get name => 'Nom';

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
  String get next => 'Suivant';

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
  String get noImageAvailable => 'Aucune image disponible';

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
  String get optimalStockStatus => 'Stock à des niveaux optimaux';

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
  String get previous => 'Précédent';

  @override
  String get primaryImage => 'Image principale';

  @override
  String get productUrlLabel => 'URL du produit';

  @override
  String get quantity => 'Quantité';

  @override
  String get refresh => 'Recharger les données';

  @override
  String get registerNewLoan => 'Enregistrer un nouveau prêt';

  @override
  String get reloadContainers => 'Recharger les conteneurs';

  @override
  String get reloadLocations => 'Recharger les localisations';

  @override
  String get reloadLoans => 'Recharger les prêts';

  @override
  String get removeImage => 'Supprimer l\'image';

  @override
  String get rename => 'Renommer';

  @override
  String get renameContainer => 'Renommer le conteneur';

  @override
  String get responsibleLabel => 'Responsable';

  @override
  String get reports => 'Rapports';

  @override
  String get returned => 'Retourné';

  @override
  String get returnsLabel => 'Retours';

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
  String get selectApplicationCurrency =>
      'Sélectionnez la devise de l\'application';

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
  String get slotDashboardBottom => 'Panneau inférieur du tableau de bord';

  @override
  String get slotDashboardTop => 'Panneau supérieur du tableau de bord';

  @override
  String get slotFloatingActionButton => 'Bouton flottant';

  @override
  String get slotInventoryHeader => 'En-tête de l\'inventaire';

  @override
  String get slotLeftSidebar => 'Barre latérale';

  @override
  String get slotUnknown => 'Emplacement inconnu';

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
  String get templates => 'Modèles';

  @override
  String get themeNameLabel => 'Nom du thème';

  @override
  String get thisFieldIsRequired => 'Ce champ est obligatoire.';

  @override
  String get topDemanded => 'Les plus demandés';

  @override
  String get topLoanedItems => 'Articles les plus empruntés';

  @override
  String get totalAssets => 'Types de ressources';

  @override
  String get totalItems => 'Ressources';

  @override
  String get totals => 'Totaux';

  @override
  String get totalSpending => 'Investissement économique total';

  @override
  String get totalMarketValue => 'Valeur totale du marché';

  @override
  String get updatedAt => 'Dernière mise à jour';

  @override
  String get upload => 'Télécharger';

  @override
  String get uploadImage => 'Télécharger l\'image';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get connectionTestFailed => 'Le test de connexion a échoué';

  @override
  String get connectionVerified => 'Connexion vérifiée avec succès';

  @override
  String get errorSavingConfiguration =>
      'Erreur lors de l\'enregistrement de la configuration';

  @override
  String get integrationsAndConnectionsTitle => 'Intégrations et connexions';

  @override
  String get integrationsSectionAiTitle => 'Intelligence artificielle';

  @override
  String get integrationsSectionAiSubtitle =>
      'Moteurs conversationnels et assistants pour enrichir les flux et automatisations.';

  @override
  String get integrationsSectionMessagingTitle => 'Messagerie et notifications';

  @override
  String get integrationsSectionMessagingSubtitle =>
      'Canaux de sortie pour alertes, bots, rapports et envois automatiques.';

  @override
  String get integrationsSectionDataApisTitle => 'API de données';

  @override
  String get integrationsSectionDataApisSubtitle =>
      'Sources externes pour enrichir fiches, cartes, jeux et références de catalogue.';

  @override
  String get integrationsSectionValuationTitle => 'Valorisation et marché';

  @override
  String get integrationsSectionValuationSubtitle =>
      'Connecteurs pour les prix, codes-barres et estimation de valeur actualisée.';

  @override
  String get integrationsSectionHardwareTitle => 'Matériel et étiquettes';

  @override
  String get integrationsSectionHardwareSubtitle =>
      'Outils physiques et utilitaires pour l\'impression, le codage et l\'exploitation.';

  @override
  String integrationsActiveConnections(int count) {
    return '$count connexions actives';
  }

  @override
  String get integrationsModularDesign => 'Conception modulaire par catégories';

  @override
  String get integrationsCheckingStatuses => 'Vérification des statuts';

  @override
  String get integrationsStatusSynced => 'Statut synchronisé';

  @override
  String get integrationsHeroHeadline =>
      'Connectez services, API et outils depuis une vue unique et claire.';

  @override
  String get integrationsHeroSubheadline =>
      'Nous regroupons les intégrations par objectif pour rendre la configuration plus rapide, plus visuelle et plus simple à maintenir, y compris sur mobile.';

  @override
  String get integrationStatusConnected => 'Connectée';

  @override
  String get integrationStatusNotConfigured => 'Non configurée';

  @override
  String get integrationTypeDataSource => 'Source de données';

  @override
  String get integrationTypeConnector => 'Connecteur';

  @override
  String integrationFieldsCount(int count) {
    return '$count champs';
  }

  @override
  String get integrationNoLocalCredentials => 'Aucun identifiant local';

  @override
  String get configureLabel => 'Configurer';

  @override
  String get integrationModelDefaultGemini =>
      'Par défaut : gemini-3-flash-preview';

  @override
  String get integrationOpenaiDesc =>
      'Utilisez GPT-4o et d\'autres modèles OpenAI comme assistant intelligent.';

  @override
  String get integrationOpenaiApiKeyHint =>
      'Obtenue sur platform.openai.com/api-keys';

  @override
  String get integrationModelDefaultOpenai => 'Par défaut : gpt-4o';

  @override
  String get integrationClaudeDesc =>
      'Utilisez Claude Sonnet, Opus et Haiku comme assistant intelligent.';

  @override
  String get integrationClaudeApiKeyHint =>
      'Obtenue sur console.anthropic.com/settings/keys';

  @override
  String get integrationModelDefaultClaude => 'Par défaut : claude-sonnet-4-6';

  @override
  String get integrationTelegramBotTokenHint => 'Depuis @BotFather';

  @override
  String get integrationTelegramChatIdHint =>
      'Utilisez @userinfobot pour obtenir votre identifiant';

  @override
  String get integrationEmailDesc =>
      'Envoi d\'e-mails ultra fiable. Idéal pour les rapports et alertes critiques.';

  @override
  String get integrationEmailApiKeyHint => 'Obtenue sur resend.com/api-keys';

  @override
  String get integrationEmailFromLabel => 'Expéditeur (From)';

  @override
  String get integrationEmailFromHint =>
      'Ex. : Invenicum <onboarding@resend.dev>';

  @override
  String get integrationBggDesc =>
      'Connectez votre compte BGG pour synchroniser votre collection et enrichir automatiquement vos données.';

  @override
  String get integrationPokemonDesc =>
      'Connectez-vous à l\'API Pokemon pour synchroniser votre collection et enrichir automatiquement vos données.';

  @override
  String get integrationTcgdexDesc =>
      'Consultez cartes et extensions de jeux de cartes à collectionner pour enrichir automatiquement votre inventaire.';

  @override
  String get integrationQrGeneratorName => 'Générateur QR';

  @override
  String get integrationQrLabelsDesc =>
      'Configurez le format de vos étiquettes imprimables.';

  @override
  String get integrationQrPageSizeLabel => 'Taille de page (A4, Lettre)';

  @override
  String get integrationQrMarginLabel => 'Marge (mm)';

  @override
  String get integrationPriceChartingDesc =>
      'Configurez votre clé API pour obtenir des prix actualisés.';

  @override
  String get integrationUpcitemdbDesc =>
      'Recherche mondiale de prix par code-barres.';

  @override
  String integrationConfiguredSuccess(String name) {
    return '$name configuré avec succès';
  }

  @override
  String integrationUnlinkedWithName(String name) {
    return '$name a été dissocié';
  }

  @override
  String get invalidUiFormat => 'Format d\'interface invalide';

  @override
  String get loadingConfiguration => 'Chargement de la configuration...';

  @override
  String pageNotFoundUri(String uri) {
    return 'Page introuvable : $uri';
  }

  @override
  String get pluginLoadError =>
      'Erreur lors du chargement de l\'interface du plugin';

  @override
  String get pluginRenderError => 'Erreur de rendu';

  @override
  String get testConnection => 'Tester la connexion';

  @override
  String get testingConnection => 'Test en cours...';

  @override
  String get unableToUnlinkAccount => 'Impossible de dissocier le compte';

  @override
  String get unlinkIntegrationUpper => 'DISSOCIER L\'INTÉGRATION';

  @override
  String get upcFreeModeHint =>
      'Laissez ce champ vide pour utiliser le mode Gratuit (limité).';

  @override
  String get alertsTabLabel => 'Alertes';

  @override
  String get alertMarkedAsRead => 'Marquée comme lue';

  @override
  String get calendarTabLabel => 'Calendrier';

  @override
  String get closeLabel => 'Fermer';

  @override
  String get closeLabelUpper => 'FERMER';

  @override
  String get configureReminderLabel => 'Configurer le rappel :';

  @override
  String get cannotFormatInvalidJson =>
      'Impossible de formater un JSON invalide';

  @override
  String get createAlertOrEventTitle => 'Créer une alerte/un événement';

  @override
  String get createdSuccessfully => 'Créé avec succès';

  @override
  String get createPluginTitle => 'Créer un plugin';

  @override
  String get editPluginTitle => 'Modifier le plugin';

  @override
  String get deleteFromGithubLabel => 'Supprimer de GitHub';

  @override
  String get deleteFromGithubSubtitle => 'Supprime le fichier du marché public';

  @override
  String get deletePluginQuestion => 'Supprimer le plugin ?';

  @override
  String get deletePluginLocalWarning =>
      'Il sera supprimé de votre base de données locale.';

  @override
  String get deleteUpper => 'SUPPRIMER';

  @override
  String get editEventTitle => 'Modifier l\'événement';

  @override
  String get editLabel => 'Modifier';

  @override
  String get eventDataSection => 'Données de l\'événement';

  @override
  String get eventReminderAtTime => 'À l\'heure de l\'événement';

  @override
  String get eventUpdated => 'Événement mis à jour';

  @override
  String get firstVersionHint => 'La première version sera toujours 1.0.0';

  @override
  String get fixJsonBeforeSave => 'Corrigez le JSON avant d\'enregistrer';

  @override
  String get formatJson => 'Formater le JSON';

  @override
  String get goToProfileUpper => 'ALLER AU PROFIL';

  @override
  String get installPluginLabel => 'Installer le plugin';

  @override
  String get invalidVersionFormat => 'Format invalide (ex : 1.0.1)';

  @override
  String get isEventQuestion => 'S\'agit-il d\'un événement ?';

  @override
  String get jsonErrorGeneric => 'Erreur JSON';

  @override
  String get makePublicLabel => 'Rendre public';

  @override
  String get markAsReadLabel => 'Marquer comme lu';

  @override
  String get messageWithColon => 'Message :';

  @override
  String minutesBeforeLabel(int minutes) {
    return '$minutes minutes avant';
  }

  @override
  String get newLabel => 'Nouveau';

  @override
  String get newPluginLabel => 'Nouveau plugin';

  @override
  String get noActiveAlerts => 'Aucune alerte active';

  @override
  String get noDescriptionAvailable => 'Aucune description disponible.';

  @override
  String get noEventsForDay => 'Aucun événement pour cette journée';

  @override
  String get noPluginsAvailable => 'Aucun plugin';

  @override
  String get notificationDeleted => 'Notification supprimée avec succès';

  @override
  String get oneHourBeforeLabel => '1 hora antes';

  @override
  String get pluginPrivateDescription =>
      'Vous seul pourrez voir ce plugin dans votre liste.';

  @override
  String get pluginPublicDescription =>
      'Les autres utilisateurs pourront voir et installer ce plugin.';

  @override
  String get pluginTabLibrary => 'Bibliothèque';

  @override
  String get pluginTabMarket => 'Market';

  @override
  String get pluginTabMine => 'Les miens';

  @override
  String get previewLabel => 'Aperçu';

  @override
  String get remindMeLabel => 'Me rappeler :';

  @override
  String get requiredField => 'Requis';

  @override
  String get requiresGithubDescription =>
      'Pour publier des plugins dans la communauté, vous devez lier votre compte GitHub pour être crédité comme auteur.';

  @override
  String get requiresGithubTitle => 'GitHub requis';

  @override
  String get slotLocationLabel => 'Emplacement (slot)';

  @override
  String get stacDocumentation => 'Documentation Stac';

  @override
  String get stacJsonInterfaceLabel => 'JSON Stac (interface)';

  @override
  String get uninstallLabel => 'Désinstaller';

  @override
  String get unrecognizedStacStructure => 'Structure Stac non reconnue';

  @override
  String get updateLabelUpper => 'UPDATE';

  @override
  String updateToVersion(String version) {
    return 'Mettre à jour vers v$version';
  }

  @override
  String get versionLabel => 'Version';

  @override
  String get incrementVersionHint =>
      'Augmentez la version de votre proposition (ex : 1.1.0)';

  @override
  String get cancelUpper => 'ANNULER';

  @override
  String get mustLinkGithubToPublishTemplate =>
      'Vous devez lier GitHub dans votre profil pour publier.';

  @override
  String get templateNeedsAtLeastOneField =>
      'Le modèle doit contenir au moins un champ défini.';

  @override
  String get templatePullRequestCreated =>
      'Propuesta enviada. Se ha creado un Pull Request en GitHub.';

  @override
  String errorPublishingTemplate(String error) {
    return 'Erreur lors de la publication : $error';
  }

  @override
  String get createGlobalTemplateTitle => 'Créer un modèle global';

  @override
  String get githubVerifiedLabel => 'GitHub verificado';

  @override
  String get githubNotLinkedLabel => 'GitHub no vinculado';

  @override
  String get veniDesignedTemplateBanner =>
      'Veni a conçu cette structure à partir de votre demande. Vérifiez-la et ajustez-la avant de publier.';

  @override
  String get templateNameLabel => 'Nom du modèle';

  @override
  String get templateNameHint => 'Ex. : Ma collection de bandes dessinées';

  @override
  String get githubUserLabel => 'Utilisateur GitHub';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get categoryHint => 'Ex. : Livres, électronique...';

  @override
  String get templatePurposeDescription => 'Description de l\'objectif';

  @override
  String get definedFieldsTitle => 'Champs définis';

  @override
  String get addFieldButton => 'Ajouter un champ';

  @override
  String get clickAddFieldToStart =>
      'Cliquez sur \'Ajouter un champ\' pour commencer à concevoir.';

  @override
  String get configureOptionsUpper => 'CONFIGURER LES OPTIONS';

  @override
  String get writeOptionAndPressEnter =>
      'Saisissez une option et appuyez sur Entrée';

  @override
  String get publishOnGithubUpper => 'PUBLIER SUR GITHUB';

  @override
  String get templateDetailFetchError =>
      'Impossible de récupérer le détail du modèle';

  @override
  String get templateNotAvailable =>
      'Le modèle n\'existe pas ou n\'est pas disponible';

  @override
  String get backLabel => 'Retour';

  @override
  String get templateDetailTitle => 'Détail du modèle';

  @override
  String get saveToLibraryTooltip => 'Enregistrer dans la bibliothèque';

  @override
  String templateByAuthor(String name) {
    return 'par @$name';
  }

  @override
  String get officialVerifiedTemplate => 'Modèle officiel vérifié';

  @override
  String dataStructureFieldsUpper(int count) {
    return 'STRUCTURE DE DONNÉES ($count CHAMPS)';
  }

  @override
  String get installInMyInventoryUpper => 'INSTALLER DANS MON INVENTAIRE';

  @override
  String get addedToPersonalLibrary =>
      'Ajouté à votre bibliothèque personnelle';

  @override
  String get whereDoYouWantToInstall => 'Où voulez-vous l\'installer ?';

  @override
  String get noContainersCreateFirst =>
      'Vous n\'avez aucun conteneur. Créez-en un d\'abord.';

  @override
  String get autoGeneratedListFromTemplate =>
      'Liste générée automatiquement depuis le modèle';

  @override
  String get installationSuccessAutoLists =>
      'Installation réussie. Listes configurées automatiquement.';

  @override
  String errorInstallingTemplate(String error) {
    return 'Erreur lors de l\'installation : $error';
  }

  @override
  String get publishTemplateLabel => 'Publier le modèle';

  @override
  String get retryLabel => 'Réessayer';

  @override
  String get noTemplatesFoundInMarket => 'Aucun modèle trouvé dans le marché.';

  @override
  String get invenicumCommunity => 'Communauté Invenicum';

  @override
  String get refreshMarketTooltip => 'Actualiser le marché';

  @override
  String get exploreCommunityConfigurations =>
      'Explorez et téléchargez les configurations de la communauté';

  @override
  String get searchByTemplateName => 'Rechercher par nom de modèle...';

  @override
  String get filterByTagTooltip => 'Filtrer par étiquette';

  @override
  String get noMoreTags => 'Il n\'y a plus d\'étiquettes';

  @override
  String confirmDeleteDataList(String name) {
    return 'Êtes-vous sûr de vouloir supprimer la liste \"$name\" ? Cette action est irréversible.';
  }

  @override
  String dataListDeletedSuccess(String name) {
    return 'Liste \"$name\" supprimée avec succès.';
  }

  @override
  String errorDeletingDataList(String error) {
    return 'Erreur lors de la suppression de la liste : $error';
  }

  @override
  String customListsWithContainer(String name) {
    return 'Listes personnalisées - $name';
  }

  @override
  String get newDataListLabel => 'Nouvelle liste';

  @override
  String get noCustomListsCreateOne =>
      'Il n\'y a pas de listes personnalisées. Créez-en une nouvelle.';

  @override
  String elementsCount(int count) {
    return '$count éléments';
  }

  @override
  String get dataListNeedsAtLeastOneElement =>
      'La liste doit contenir au moins un élément';

  @override
  String get customDataListCreated => 'Liste personnalisée créée avec succès';

  @override
  String errorCreatingDataList(String error) {
    return 'Erreur lors de la création de la liste : $error';
  }

  @override
  String get newCustomDataListTitle => 'Nouvelle liste personnalisée';

  @override
  String get dataListNameLabel => 'Nom de la liste';

  @override
  String get pleaseEnterAName => 'Veuillez saisir un nom';

  @override
  String get dataListElementsTitle => 'Éléments de la liste';

  @override
  String get newElementLabel => 'Nouvel élément';

  @override
  String get addLabel => 'Ajouter';

  @override
  String get addElementsToListHint => 'Ajoutez des éléments à la liste';

  @override
  String get saveListLabel => 'Enregistrer la liste';

  @override
  String get dataListUpdatedSuccessfully => 'Liste mise à jour avec succès';

  @override
  String errorUpdatingDataList(String error) {
    return 'Erreur lors de la mise à jour de la liste : $error';
  }

  @override
  String editListWithName(String name) {
    return 'Modifier la liste : $name';
  }

  @override
  String get createNewLocationTitle => 'Créer un nouvel emplacement';

  @override
  String get locationNameLabel => 'Nom de l\'emplacement';

  @override
  String get locationNameHint => 'Ex. : Étagère B3, salle serveurs';

  @override
  String get locationDescriptionHint =>
      'Détails d\'accès, type de contenu, etc.';

  @override
  String get parentLocationLabel => 'Emplacement parent (contient celui-ci)';

  @override
  String get noParentRootLocation => 'Aucun parent (emplacement racine)';

  @override
  String get noneRootScheme => 'Aucun (racine du schéma)';

  @override
  String get savingLabel => 'Enregistrement...';

  @override
  String get saveLocationLabel => 'Enregistrer l\'emplacement';

  @override
  String locationCreatedSuccessfully(String name) {
    return 'Emplacement \"$name\" créé avec succès.';
  }

  @override
  String errorCreatingLocation(String error) {
    return 'Erreur lors de la création de l\'emplacement : $error';
  }

  @override
  String get locationCannotBeItsOwnParent =>
      'Un emplacement ne peut pas être son propre parent.';

  @override
  String locationUpdatedSuccessfully(String name) {
    return 'Emplacement \"$name\" mis à jour.';
  }

  @override
  String errorUpdatingLocation(String error) {
    return 'Erreur lors de la mise à jour de l\'emplacement : $error';
  }

  @override
  String editLocationTitle(String name) {
    return 'Modifier : $name';
  }

  @override
  String get updateLocationLabel => 'Mettre à jour l\'emplacement';

  @override
  String get selectObjectTitle => 'Sélectionner un objet';

  @override
  String get noObjectsAvailable => 'Aucun objet disponible';

  @override
  String availableQuantity(int quantity) {
    return 'Disponible : $quantity';
  }

  @override
  String errorSelectingObject(String error) {
    return 'Erreur lors de la sélection de l\'objet : $error';
  }

  @override
  String get mustSelectAnObject => 'Vous devez sélectionner un objet';

  @override
  String get loanRegisteredSuccessfully => 'Prêt enregistré avec succès';

  @override
  String get selectAnObject => 'Sélectionnez un objet';

  @override
  String get selectLabel => 'Sélectionner';

  @override
  String get borrowerNameHint => 'Ex. : Jean Dupont';

  @override
  String get borrowerNameRequired => 'Le nom est obligatoire';

  @override
  String loanQuantityAvailable(int quantity) {
    return 'Quantité à prêter (Disponible : $quantity)';
  }

  @override
  String get enterQuantity => 'Saisissez une quantité';

  @override
  String get invalidQuantity => 'Quantité invalide';

  @override
  String get notEnoughStock => 'Stock insuffisant';

  @override
  String get invalidEmail => 'Adresse e-mail invalide';

  @override
  String expectedReturnDateLabel(String date) {
    return 'Retour prévu : $date';
  }

  @override
  String get selectReturnDate => 'Sélectionnez une date de retour';

  @override
  String get additionalNotes => 'Notes supplémentaires';

  @override
  String get registerLoanLabel => 'Enregistrer le prêt';

  @override
  String get totalLabel => 'Total';

  @override
  String get newLocationLabel => 'Nueva ubicación';

  @override
  String get newLocationHint => 'Ej: Estantería A1, Armario 3...';

  @override
  String get parentLocationOptionalLabel => 'Ubicación padre (opcional)';

  @override
  String get noneRootLabel => 'Ninguna (raíz)';

  @override
  String locationCreatedShort(String name) {
    return 'Ubicación \"$name\" creada';
  }

  @override
  String get newLocationEllipsis => 'Nueva ubicación...';

  @override
  String get couldNotReloadList => 'No se pudo recargar la lista';

  @override
  String get deleteAssetTitle => 'Eliminar Activo';

  @override
  String confirmDeleteAssetItem(String name) {
    return '¿Confirmas que deseas eliminar \"$name\"?';
  }

  @override
  String get assetDeletedShort => 'Activo eliminado.';

  @override
  String viewColumnsLabel(int count) {
    return 'Vista: $count col.';
  }

  @override
  String get notValuedLabel => 'Sin valorar';

  @override
  String get manageSearchSyncAssets =>
      'Gestiona, busca y sincroniza tus activos desde un solo panel.';

  @override
  String get filterLabel => 'Filtro';

  @override
  String get activeFilterLabel => 'Filtro activo';

  @override
  String get importLabel => 'Importar';

  @override
  String get exportLabel => 'Exportar';

  @override
  String get csvExportNoData => 'No hay items para exportar.';

  @override
  String csvExportSuccess(int count) {
    return 'CSV exportado correctamente ($count items).';
  }

  @override
  String get csvExportError => 'No se pudo exportar el CSV';

  @override
  String get syncLabel => 'Sincronizar precios';

  @override
  String get syncingLabel => 'Sincronizando...';

  @override
  String get newAssetLabel => 'Nuevo activo';

  @override
  String get statusAndPreferences => 'Estado y Preferencias';

  @override
  String get itemStatusLabel => 'Estado del ítem';

  @override
  String get availableLabel => 'Disponible';

  @override
  String get mustBeGreaterThanZero => 'Debe ser mayor a 0.';

  @override
  String get alertThresholdLabel => 'Umbral de alerta';

  @override
  String get enterMinimumStock => 'Introduce un stock mínimo.';

  @override
  String get serializedItemFixedQuantity =>
      'Este es un artículo seriado. La cantidad es fija a 1.';

  @override
  String get serialNumberLabel => 'Número de serie';

  @override
  String get serialNumberHint => 'Ej: SN-2024-00123';

  @override
  String get mainDataTitle => 'Datos Principales';

  @override
  String get currentMarketValueLabel => 'VALOR DE MERCADO ACTUAL';

  @override
  String get updatePriceLabel => 'Actualizar Precio';

  @override
  String get viewLabel => 'Vista';

  @override
  String get visualGalleryTitle => 'Galería Visual';

  @override
  String get statusAndMarketTitle => 'Estado y Mercado';

  @override
  String get valuationHistoryTitle => 'Historial de Valoración';

  @override
  String get specificationsTitle => 'Especificaciones';

  @override
  String get traceabilityTitle => 'Trazabilidad';

  @override
  String get stockLabel => 'Stock';

  @override
  String get internalReferenceLabel => 'Referencia Interna';

  @override
  String get noSpecificationsAvailable => 'No hay especificaciones disponibles';

  @override
  String get trueLabel => 'Verdadero';

  @override
  String get falseLabel => 'Falso';

  @override
  String get openLinkLabel => 'Abrir enlace';

  @override
  String get scannerFocusTip =>
      'Consejo: Si no enfoca, aleje el producto unos 30 cm de la cámara.';

  @override
  String get scanCodeTitle => 'Escanear Código';

  @override
  String get scanOrEnterProductCode =>
      'Escanee o introduzca el código del producto';

  @override
  String possessionProgressLabel(String name) {
    return 'Progreso de $name';
  }

  @override
  String get externalImportTitle => 'Importar desde Fuente Externa';

  @override
  String get galleryTitle => 'Galería';

  @override
  String get stockAndCodingTitle => 'Stock y Codificación';

  @override
  String get cameraPermissionRequired =>
      'Se requiere permiso de cámara para escanear';

  @override
  String get cloudDataFound => '¡Datos encontrados en la nube!';

  @override
  String get typeSomethingToSearch => 'Escribe algo para buscar';

  @override
  String get importCancelled => 'Importación cancelada.';

  @override
  String get couldNotCompleteImport => 'No se pudo completar la importación';

  @override
  String get yearLabel => 'Año';

  @override
  String get authorLabel => 'Autor';

  @override
  String get selectResultTitle => 'Selecciona un resultado';

  @override
  String get unnamedLabel => 'Sin nombre';

  @override
  String get completeRequiredFields =>
      'Por favor, complete los campos obligatorios.';

  @override
  String get assetCreatedSuccess => 'Activo creado!';

  @override
  String errorCreatingAsset(String error) {
    return 'Error al crear activo: $error';
  }

  @override
  String get technicalDetailsTitle => 'Detalles Técnicos';

  @override
  String itemImportedSuccessfully(String name) {
    return '¡$name importado con éxito!';
  }

  @override
  String newImagesSelected(int count) {
    return 'Se seleccionaron $count nuevas imágenes.';
  }

  @override
  String get newFileRemoved => 'Archivo nuevo removido.';

  @override
  String get imageMarkedForDeletion =>
      'Imagen marcada para eliminación al guardar.';

  @override
  String get couldNotIdentifyImage => 'No se pudo identificar la imagen.';

  @override
  String editAssetTitle(String name) {
    return 'Editar: $name';
  }

  @override
  String get syncPricesTitle => 'Sincronizar precios';

  @override
  String get syncPricesDescription =>
      'Se consultará la API para actualizar el valor de mercado.';

  @override
  String get syncingMarketPrices => 'Sincronizando precios de mercado...';

  @override
  String get couldNotSyncPrices => 'No se pudieron sincronizar los precios';

  @override
  String get syncCompletedTitle => 'Sincronización completada';

  @override
  String get updatedLabel => 'Actualizados';

  @override
  String get noApiPriceLabel => 'Sin precio en API';

  @override
  String get errorsLabel => 'Errores';

  @override
  String get totalProcessedLabel => 'Total procesados';

  @override
  String get noAssetsToShow => 'No hay activos para mostrar';

  @override
  String get noImageLabel => 'Sin imagen';

  @override
  String get aiMagicQuestion => '¿Tienes un link?';

  @override
  String get aiAutocompleteAsset => 'Autocompleta este activo con IA';

  @override
  String get magicLabel => 'MAGIA';

  @override
  String get skuBarcodeLabel => 'SKU / EAN / UPC';

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

  @override
  String get generalSettingsMenuLabel => 'Paramètres généraux';

  @override
  String get aiAssistantMenuLabel => 'Assistant IA';

  @override
  String get notificationsMenuLabel => 'Notifications';

  @override
  String get loanManagementMenuLabel => 'Gestion des prêts';

  @override
  String get aboutMenuLabel => 'À propos';

  @override
  String get automaticDarkModeLabel => 'Mode sombre automatique';

  @override
  String get syncWithSystemLabel => 'Synchroniser avec le système';

  @override
  String get manualDarkModeLabel => 'Mode sombre manuel';

  @override
  String get disableAutomaticToChange =>
      'Désactivez le mode automatique pour le modifier';

  @override
  String get changeLightDark => 'Basculer entre clair et sombre';

  @override
  String get enableAiAndChatbot =>
      'Activer l\'intelligence artificielle et le chatbot';

  @override
  String get requiresGeminiLinking =>
      'Nécessite une liaison avec Gemini dans Intégrations';

  @override
  String get aiOrganizeInventory =>
      'Usa IA para organizar tu inventario de manera inteligente';

  @override
  String get aiAssistantTitle => 'Asistente de Inteligencia Artificial';

  @override
  String get selectAiProvider =>
      'Choisissez le fournisseur d\'IA utilisé par Veni. Assurez-vous d\'avoir configuré la clé API dans Intégrations.';

  @override
  String get aiProviderLabel => 'Proveedor';

  @override
  String get aiModelLabel => 'Modelo';

  @override
  String get aiProviderUpdated => 'Proveedor de IA actualizado';

  @override
  String get purgeChatHistoryTitle => 'Historique du chat';

  @override
  String get purgeChatHistoryDescription =>
      'Supprime définitivement tout l\'historique des conversations Veni enregistrées.';

  @override
  String get purgeChatHistoryButton => 'Purger l\'historique';

  @override
  String get purgeChatHistoryConfirmTitle => 'Purger l\'historique du chat ?';

  @override
  String get purgeChatHistoryConfirmMessage =>
      'Cette action supprimera tous les messages enregistrés et ne peut pas être annulée.';

  @override
  String get purgeChatHistoryConfirmAction => 'Oui, purger';

  @override
  String get purgeChatHistorySuccess =>
      'Historique du chat supprimé avec succès.';

  @override
  String get purgeChatHistoryError =>
      'Impossible de supprimer l\'historique du chat.';

  @override
  String get notificationSettingsTitle => 'Gestion des notifications';

  @override
  String get channelPriorityLabel =>
      'Priorité des canaux (glissez pour réordonner)';

  @override
  String get telegramBotLabel => 'Telegram Bot';

  @override
  String get resendEmailLabel => 'Resend Email';

  @override
  String get lowStockLabel => 'Stock Bajo';

  @override
  String get lowStockHint => 'Avisar cuando un producto baje del mínimo.';

  @override
  String get newPresalesLabel => 'Nuevas Preventas';

  @override
  String get newPresalesHint => 'Notificar lanzamientos detectados por la IA.';

  @override
  String get loanReminderLabel => 'Recordatorio de Préstamos';

  @override
  String get loanReminderHint => 'Avisar antes de la fecha de devolución.';

  @override
  String get overdueLoansLabel => 'Préstamos Vencidos';

  @override
  String get overdueLoansHint =>
      'Alerta crítica si un objeto no se devuelve a tiempo.';

  @override
  String get maintenanceLabel => 'Mantenimiento';

  @override
  String get maintenanceHint => 'Avisar cuando toque revisar un activo.';

  @override
  String get priceChangeLabel => 'Cambios de Precio';

  @override
  String get priceChangeHint => 'Notificar variaciones de valor en el mercado.';

  @override
  String get unlinkGithubTitle => 'Desconectar GitHub';

  @override
  String get unlinkGithubMessage =>
      '¿Estás seguro de que quieres desvincular tu cuenta de GitHub?';

  @override
  String get updatePasswordButton => 'ACTUALIZAR CONTRASEÑA';

  @override
  String get newContainerDialog => 'Nuevo Contenedor';

  @override
  String get descriptionField => 'Descripción';

  @override
  String get isCollectionQuestion => '¿Es una colección?';

  @override
  String get createContainerButton => 'Crear Contenedor';

  @override
  String get selectContainerHint => 'Selecciona un contenedor';

  @override
  String get newAssetTypeTitle => 'Nuevo Tipo de Activo';

  @override
  String get generalConfiguration => 'Configuración General';

  @override
  String get collectionContainerWarning =>
      'Este contenedor es una colección. Puedes crear tipos seriados o no seriados, pero los campos de posesión y deseados solo se podrán configurar en tipos no seriados.';

  @override
  String get createAssetTypeButton => 'Crear Tipo de Activo';

  @override
  String assetTypesInContainer(String name) {
    return 'Tipos de Activo en \"$name\"';
  }

  @override
  String get createNewTypeButton => 'Crear Nuevo Tipo';

  @override
  String get isSerializedQuestion => '¿Es un artículo seriado?';

  @override
  String get addNewFieldButton => 'Añadir Nuevo Campo';

  @override
  String get deleteFieldTooltip => 'Eliminar campo';

  @override
  String get fieldsOptions => 'Opciones:';

  @override
  String get isRequiredField => 'Es Requerido';

  @override
  String get isSummativeFieldLabel =>
      'Es Sumatorio (Se suma en el total del tipo)';

  @override
  String get isMonetaryValueLabel => 'Es Valor Monetario';

  @override
  String get monetaryValueDescription =>
      'Se usará para calcular la inversión total en el Dashboard';

  @override
  String get noDataListsAvailable =>
      '⚠️ No hay listas de datos disponibles en este contenedor.';

  @override
  String get selectDataList => 'Seleccionar Lista de Datos';

  @override
  String get chooseList => 'Elija una lista';

  @override
  String get goToPageLabel => 'Ir a página:';

  @override
  String get conditionLabel => 'Condición';

  @override
  String get actionsLabel => 'Acciones';

  @override
  String get editButtonLabel => 'Editar';

  @override
  String get deleteButtonLabel => 'Eliminar';

  @override
  String get printLabel => 'Imprimir etiqueta';

  @override
  String get collectionFieldsTooltip => 'Campos de colección';

  @override
  String totalLocations(int count) {
    return '$count ubicaciones';
  }

  @override
  String withoutLocationLabel(int count) {
    return '$count sin ubicación · ';
  }

  @override
  String get objectIdColumn => 'ID Obj';

  @override
  String containerNotFoundError(String id) {
    return 'Contenedor con ID $id no encontrado.';
  }

  @override
  String get invalidContainerIdError => 'Error: ID de contenedor inválido.';

  @override
  String get startConfigurationButton => 'Comenzar configuración';

  @override
  String get fullNameField => 'Nombre completo';

  @override
  String get emailField => 'Correo electrónico';

  @override
  String get passwordField => 'Contraseña';

  @override
  String get confirmPasswordField => 'Confirmar contraseña';

  @override
  String get goBackButton => 'Volver';

  @override
  String get createAccountButton => 'Crear cuenta';

  @override
  String get goToLoginButton => 'Ir al inicio de sesión';

  @override
  String get deleteConfirmationTitle => 'Confirmar Eliminación';

  @override
  String deleteItemMessage(String name) {
    return '¿Deseas eliminar \"$name\"?';
  }

  @override
  String get elementDeletedSuccess => 'Elemento eliminado correctamente';

  @override
  String get enterYourNameValidation => 'Introduce tu nombre.';

  @override
  String get minTwoCharactersValidation => 'Mínimo 2 caracteres.';

  @override
  String get enterEmailValidation => 'Introduce un email.';

  @override
  String get invalidEmailValidation => 'Email no válido.';

  @override
  String get enterPasswordValidation => 'Introduce una contraseña.';

  @override
  String get minEightCharactersValidation => 'Mínimo 8 caracteres.';

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
  String get invalidIdError => 'ID inválido';

  @override
  String assetTypeLoadError(String error) {
    return 'Error al cargar datos: $error';
  }

  @override
  String get assetTypeUpdateSuccess => 'Tipo de activo actualizado con éxito';

  @override
  String assetTypeUpdateError(String error) {
    return 'Error al actualizar: $error';
  }

  @override
  String editAssetTypeTitle(String name) {
    return 'Editar: $name';
  }

  @override
  String get achievementCollectionTitle => 'Logros de Colección';

  @override
  String get achievementSubtitle => 'Desbloquea hitos usando Invenicum';

  @override
  String get legendaryAchievementLabel => 'LOGRO LEGENDARIO';

  @override
  String get achievementCompleted => 'Completado';

  @override
  String get achievementLocked => 'Bloqueado';

  @override
  String achievementUnlockedDate(String date) {
    return 'Conseguido el $date';
  }

  @override
  String get achievementLockedMessage => 'Cumple el objetivo para desbloquear';

  @override
  String get closeButtonLabel => 'Entendido';

  @override
  String get configurationGeneralSection => 'Configuración General';

  @override
  String get assetTypeCollectionWarning =>
      'Este contenedor es una colección. Puedes crear tipos seriados o no seriados, pero los campos de posesión y deseados solo se podrán configurar en tipos no seriados.';

  @override
  String get updateAssetTypeButton => 'Actualizar Tipo de Activo';

  @override
  String get createAssetTypeButtonDefault => 'Crear Tipo de Activo';

  @override
  String get noAssetTypesMessage =>
      'Aún no hay Tipos de Activo definidos en este contenedor.';

  @override
  String totalCountLabel(int count) {
    return 'Total: $count';
  }

  @override
  String possessionCountLabel(int count) {
    return 'Posesión: $count';
  }

  @override
  String desiredCountLabel(int count) {
    return 'Deseados: $count';
  }

  @override
  String get marketValueLabel => 'Mercado: ';

  @override
  String get defaultSumFieldName => 'Suma';

  @override
  String get calculatingLabel => 'Calculando...';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get noNameItem => 'Sin nombre';

  @override
  String get loadingContainers => 'Cargando contenedores...';

  @override
  String get fieldNameRequired => 'El nombre del campo es obligatorio';

  @override
  String get selectImageButton => 'Seleccionar Imagen';

  @override
  String assetTypeDeletedSuccess(String name) {
    return '$name eliminado';
  }

  @override
  String get noLocationValueData =>
      'Aún no hay activos con ubicación y valor suficiente para dibujar esta gráfica.';

  @override
  String get requiredFieldValidation => 'Este campo es obligatorio';

  @override
  String get oceanTheme => 'Océano Índico';

  @override
  String get cherryBlossomTheme => 'Flor de Cerezo';

  @override
  String get themeBrand => 'Invenicum (Marca)';

  @override
  String get themeEmerald => 'Esmeralda';

  @override
  String get themeSunset => 'Atardecer';

  @override
  String get themeLavender => 'Lavanda Suave';

  @override
  String get themeForest => 'Bosque Profundo';

  @override
  String get themeCherry => 'Cereza';

  @override
  String get themeElectricNight => 'Noche Eléctrica';

  @override
  String get themeAmberGold => 'Oro Ámbar';

  @override
  String get themeModernSlate => 'Pizarra Moderna';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeNordicArctic => 'Ártico Nord';

  @override
  String get themeDeepNight => 'Noche Profunda';

  @override
  String get loginSuccess => 'Inicio de sesión exitoso';

  @override
  String get reloadListError => 'No se pudo recargar la lista';

  @override
  String get copyItemSuffix => 'Copia';

  @override
  String itemCopiedSuccess(String name) {
    return 'Elemento copiado: $name';
  }

  @override
  String get copyError => 'Error al copiar';

  @override
  String get imageColumnLabel => 'Imagen';

  @override
  String get viewImageTooltip => 'Ver imagen';

  @override
  String get currentStockLabel => 'Stock actual';

  @override
  String get minimumStockLabel => 'Stock mínimo';

  @override
  String get locationColumnLabel => 'Ubicación';

  @override
  String get serialNumberColumnLabel => 'Numero de serie';

  @override
  String get marketPriceLabel => 'Precio de mercado';

  @override
  String get conditionColumnLabel => 'Condición';

  @override
  String get actionsColumnLabel => 'Acciones';

  @override
  String get imageLoadError => 'No se pudo cargar la imagen';

  @override
  String get imageUrlHint =>
      'Asegúrate de que la URL es correcta y el servidor está activo';

  @override
  String get assetTypeNameHint => 'Ej: Ordenador Portátil, Sustancia Química';

  @override
  String get assetTypeNameLabel => 'Nombre del Tipo de Activo';

  @override
  String get underConstruction => 'En Construcción';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get constructionSubtitle => 'Esta funcionalidad se está desarrollando';

  @override
  String get selectColor => 'Seleccionar Color';

  @override
  String get valueDistributionByLocation =>
      'Distribución de valor por ubicación';

  @override
  String get heatmapDescription =>
      'El donut muestra cómo se reparte el valor de mercado entre las ubicaciones con más peso.';

  @override
  String locationsCount(int count) {
    return '$count ubicaciones';
  }

  @override
  String get unitsLabel => 'uds';

  @override
  String get recordsLabel => 'registros';

  @override
  String get totalValueFallback => 'Valor total';

  @override
  String containerFallback(String id) {
    return 'Contenedor $id';
  }

  @override
  String locationFallback(String id) {
    return 'Ubicación $id';
  }

  @override
  String get ofTheValueLabel => 'del valor';

  @override
  String get reportsDescription =>
      'Générez des rapports PDF ou Excel à imprimer ou à enregistrer sur votre PC';

  @override
  String get reportSectionType => 'Type de rapport';

  @override
  String get reportSectionFormat => 'Format de sortie';

  @override
  String get reportSectionPreview => 'Configuration actuelle';

  @override
  String get reportSelectContainerTitle => 'Sélectionnez un conteneur';

  @override
  String get reportGenerate => 'Générer le rapport';

  @override
  String get reportGenerating => 'Génération...';

  @override
  String get reportTypeInventoryDescription =>
      'Liste complète de l\'inventaire';

  @override
  String get reportTypeLoansDescription => 'Prêts actifs et leur statut';

  @override
  String get reportTypeAssetsDescription =>
      'Liste des ressources par catégorie';

  @override
  String get reportLabelContainer => 'Conteneur';

  @override
  String get reportLabelType => 'Type de rapport';

  @override
  String get reportLabelFormat => 'Format';

  @override
  String get reportFormatPdf => 'PDF';

  @override
  String get reportFormatExcel => 'Excel';

  @override
  String get reportNotSelected => 'Non sélectionné';

  @override
  String get reportUnknown => 'Inconnu';

  @override
  String get reportSelectContainerFirst => 'Veuillez sélectionner un conteneur';

  @override
  String reportDownloadedSuccess(String format) {
    return 'Rapport $format téléchargé avec succès';
  }

  @override
  String reportGenerateError(String error) {
    return 'Erreur lors de la génération du rapport : $error';
  }

  @override
  String get firstRunWelcomeTitle => 'Bienvenue chez Invenicum';

  @override
  String get firstRunConfigTitle => 'Configuration initiale';

  @override
  String get firstRunWelcomeDescription =>
      'Il semble que ce soit votre première utilisation de l\'application. Créons votre compte administrateur pour commencer.';

  @override
  String get firstRunStep1Label => 'Étape 1 sur 2 · Bienvenue';

  @override
  String get firstRunStep2Label => 'Étape 2 sur 2 · Créer un administrateur';

  @override
  String get firstRunSuccessMessage => 'Votre compte a été créé';

  @override
  String get firstRunAdminTitle => 'Créer un administrateur';

  @override
  String get firstRunAdminDescription =>
      'Cet utilisateur aura un accès complet à la plateforme.';

  @override
  String get firstRunFeature1 => 'Créez votre utilisateur administrateur';

  @override
  String get firstRunFeature2 => 'Accès sécurisé par mot de passe';

  @override
  String get firstRunFeature3 => 'Prêt à l\'emploi en quelques secondes';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get firstRunSuccessTitle => 'Compte créé !';

  @override
  String get firstRunSuccessSubtitle =>
      'Votre compte d\'administrateur est prêt.\nVous pouvez maintenant vous connecter.';

  @override
  String get firstRunAccountCreatedLabel => 'COMPTE CRÉÉ';

  @override
  String get firstRunCopyright => 'Invenicum ©';
}
