// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get createdAt => 'Creation Date';

  @override
  String get updatedAt => 'Last Updated';

  @override
  String get assetDetail => 'Asset Details';

  @override
  String get assetNotFound => 'Asset not found';

  @override
  String get invalidAssetId => 'Invalid asset ID';

  @override
  String get noImageAvailable => 'No image available';

  @override
  String get minStock => 'Minimum stock';

  @override
  String get location => 'Location';

  @override
  String get aboutInvenicum => 'About Invenicum';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get active => 'Active';

  @override
  String get activeLoans => 'Active loans';

  @override
  String get activeLoansCount => 'Active loans';

  @override
  String get addAlert => 'Add Alert';

  @override
  String get addAsset => 'Add Asset';

  @override
  String get addContainer => 'Add container';

  @override
  String get addNewLocation => 'Add New Location';

  @override
  String get additionalThumbnails => 'Additional Thumbnails';

  @override
  String aiExtractionError(Object error) {
    return 'AI could not extract data: $error';
  }

  @override
  String get aiPasteUrlDescription =>
      'Paste the product link and AI will automatically extract information to populate fields.';

  @override
  String get all => 'All';

  @override
  String get alertCritical => 'Critical';

  @override
  String get alertCreated => 'Alert created';

  @override
  String get alertDeleted => 'Alert deleted';

  @override
  String get alertInfo => 'Information';

  @override
  String get alertMessage => 'Message';

  @override
  String get alertTitle => 'Title';

  @override
  String get alertType => 'Type';

  @override
  String get alertWarning => 'Warning';

  @override
  String get alerts => 'Alerts and Notifications';

  @override
  String get appTitle => 'Invenicum Inventory';

  @override
  String get applicationTheme => 'Application theme';

  @override
  String get apply => 'Apply';

  @override
  String get april => 'April';

  @override
  String get assetImages => 'Asset Images';

  @override
  String get assetImport => 'Asset Import';

  @override
  String get assetName => 'Asset Name';

  @override
  String assetTypeDeleted(Object name) {
    return 'Asset Type \"$name\" deleted successfully.';
  }

  @override
  String get assetTypes => 'Asset Types';

  @override
  String assetUpdated(Object name) {
    return 'Asset \"$name\" updated successfully.';
  }

  @override
  String get assets => 'Assets';

  @override
  String get assetsIn => 'Assets in';

  @override
  String get august => 'August';

  @override
  String get backToAssetTypes => 'Back to Asset Types';

  @override
  String get borrowerEmail => 'Borrower Email';

  @override
  String get borrowerName => 'Borrower Name';

  @override
  String get borrowerPhone => 'Borrower Phone';

  @override
  String get cancel => 'Cancel';

  @override
  String get centerView => 'Center View';

  @override
  String get chooseFile => 'Choose File';

  @override
  String get clearCounter => 'Clear Counter';

  @override
  String get collectionContainerInfo =>
      'Collection containers have collection tracking bars, invested value, market value and Exposure view';

  @override
  String get collectionFieldsConfigured => 'Collection fields configured.';

  @override
  String get configureCollectionFields => 'Configure Collection Fields';

  @override
  String get configureDeliveryVoucher => 'Configure Delivery Voucher';

  @override
  String get configureVoucherBody => 'Configure the voucher body...';

  @override
  String get confirmDeleteAlert => 'Delete Alert';

  @override
  String get confirmDeleteAlertMessage =>
      'Are you sure you want to delete this record?';

  @override
  String confirmDeleteAssetType(Object name) {
    return 'Are you sure you want to delete asset type \"$name\" and all its associated items? This action cannot be undone.';
  }

  @override
  String confirmDeleteContainer(Object name) {
    return 'Are you sure you want to delete the container \"$name\"? This action is irreversible and will remove all its assets and data.';
  }

  @override
  String confirmDeleteLocationMessage(String name) {
    return 'Are you sure you want to delete the location \"$name\"?';
  }

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get configurationSaved => 'Configuration saved successfully.';

  @override
  String containerCreated(Object name) {
    return 'Container \"$name\" created successfully.';
  }

  @override
  String containerDeleted(Object name) {
    return 'Container \"$name\" deleted successfully.';
  }

  @override
  String get containerName => 'Container name';

  @override
  String get containerOrAssetTypeNotFound =>
      'Container or Asset Type not found.';

  @override
  String containerRenamed(Object name) {
    return 'Container renamed to \"$name\".';
  }

  @override
  String get containers => 'Containers';

  @override
  String get countItemsByValue => 'Count items by specific value';

  @override
  String get create => 'Create';

  @override
  String get createFirstContainer => 'Create your first container.';

  @override
  String get current => 'Current';

  @override
  String get customColor => 'Custom Color';

  @override
  String get customFields => 'Custom Fields';

  @override
  String customFieldsOf(Object name) {
    return 'Custom Fields of $name';
  }

  @override
  String get customizeDeliveryVoucher => 'Customize the PDF template for loans';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get datalists => 'Custom Lists';

  @override
  String get december => 'December';

  @override
  String get definitionCustomFields => 'Custom Fields Definition';

  @override
  String get delete => 'Delete';

  @override
  String deleteError(String error) {
    return 'Error deleting: $error';
  }

  @override
  String get deleteSuccess => 'Location deleted successfully.';

  @override
  String get deliveryVoucher => 'DELIVERY VOUCHER';

  @override
  String get deliveryVoucherEditor => 'Delivery Voucher Editor';

  @override
  String get description => 'Description (optional)';

  @override
  String get desiredField => 'Desired Field';

  @override
  String get dueDate => 'Due Date';

  @override
  String get edit => 'Edit';

  @override
  String get enterContainerName => 'Enter the container name';

  @override
  String get enterDescription => 'Enter a description';

  @override
  String get enterURL => 'Enter URL';

  @override
  String get enterValidUrl => 'Enter a valid URL';

  @override
  String get errorCsvMinRows =>
      'Please select a CSV file with headers and at least one data row.';

  @override
  String errorDeletingAssetType(Object error) {
    return 'Error deleting asset type: $error';
  }

  @override
  String errorDeletingContainer(Object error) {
    return 'Error deleting container: $error';
  }

  @override
  String get errorDuringImport => 'Error during import';

  @override
  String get errorEmptyCsv => 'The CSV file is empty.';

  @override
  String errorGeneratingPDF(Object error) {
    return 'Error generating PDF: $error';
  }

  @override
  String get errorInvalidPath => 'Invalid file path.';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String errorLoadingListValues(Object error) {
    return 'Error loading list values: $error';
  }

  @override
  String errorLoadingLocations(String error) {
    return 'Error loading locations: $error';
  }

  @override
  String get errorNameMappingRequired =>
      'The \'Name\' field is required and must be mapped.';

  @override
  String get errorNoVoucherTemplate => 'No voucher template configured.';

  @override
  String get errorReadingBytes => 'Could not read file bytes.';

  @override
  String errorReadingFile(String error) {
    return 'Error reading file: $error';
  }

  @override
  String errorRegisteringLoan(Object error) {
    return 'Error registering loan: $error';
  }

  @override
  String errorRenaming(Object error) {
    return 'Error renaming: $error';
  }

  @override
  String errorSaving(Object error) {
    return 'Error saving: $error';
  }

  @override
  String errorUpdatingAsset(Object error) {
    return 'Error updating asset: $error';
  }

  @override
  String get exampleFilterHint => 'Ex: Damaged, Red, 50';

  @override
  String errorChangingLanguage(Object error) {
    return 'Error changing language: $error';
  }

  @override
  String get february => 'February';

  @override
  String get fieldChip => 'Field';

  @override
  String fieldRequiredWithName(Object field) {
    return 'The field \"$field\" is required.';
  }

  @override
  String get fieldToCount => 'Field to Count';

  @override
  String get fieldsFilledSuccess => 'Fields populated successfully!';

  @override
  String get formatsPNG => 'Formats: PNG, JPG';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get generateVoucher => 'Generate Delivery Voucher';

  @override
  String get globalSearch => 'Global Search';

  @override
  String get greeting => 'Hello, welcome!';

  @override
  String get guest => 'Guest';

  @override
  String get ignoreField => '🚫 Ignore Field';

  @override
  String get importAssetsTo => 'Import Assets to';

  @override
  String importSuccessMessage(String count) {
    return 'Import Successful! $count assets created.';
  }

  @override
  String get invalidNavigationIds => 'Error: invalid navigation IDs.';

  @override
  String get january => 'January';

  @override
  String get july => 'July';

  @override
  String get june => 'June';

  @override
  String get language => 'Language';

  @override
  String get languageNotImplemented =>
      'Language functionality to be implemented';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get loadingAssetType => 'Loading Asset Type...';

  @override
  String loadingListField(Object field) {
    return 'Loading $field...';
  }

  @override
  String get loanDate => 'Loan Date';

  @override
  String get languageChanged => 'Language changed to English!';

  @override
  String get loanLanguageNotImplemented =>
      'Language functionality to be implemented';

  @override
  String get loanManagement => 'Loan Management';

  @override
  String get loanObject => 'Loan Object';

  @override
  String get loans => 'Loans';

  @override
  String get locations => 'Locations';

  @override
  String get locationsScheme => 'Locations Scheme';

  @override
  String get login => 'Login';

  @override
  String get logoVoucher => 'Voucher Logo';

  @override
  String get logout => 'Logout';

  @override
  String get magicAssistant => 'Magic AI Assistant';

  @override
  String get march => 'March';

  @override
  String get may => 'May';

  @override
  String get myCustomTheme => 'My Theme';

  @override
  String get myProfile => 'My Profile';

  @override
  String get myThemesStored => 'My Themes Stored';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get nameSameAsCurrent => 'The name is the same as the current one';

  @override
  String get newAlert => 'New Manual Alert';

  @override
  String get newContainer => 'New container';

  @override
  String get newName => 'New name';

  @override
  String get noAssetsCreated => 'No assets created yet.';

  @override
  String get noAssetsMatch => 'No assets match the search/filter criteria.';

  @override
  String get noBooleanFields => 'No boolean fields defined.';

  @override
  String get noContainerMessage => 'Create your first container.';

  @override
  String get noCustomFields => 'This asset type does not have custom fields.';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get noImagesAdded =>
      'No images added yet. The first image will be the primary.';

  @override
  String get noLoansFound => 'No loans found in this container.';

  @override
  String get noLocationsMessage =>
      'No locations created in this container. Add the first one!';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noThemesSaved => 'No themes saved yet';

  @override
  String get none => 'None';

  @override
  String get november => 'November';

  @override
  String get obligatory => 'Obligatory';

  @override
  String get october => 'October';

  @override
  String get optional => 'Optional';

  @override
  String get overdue => 'Overdue';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get pleaseEnterUsername => 'Please enter your username';

  @override
  String get pleasePasteUrl => 'Please paste a URL';

  @override
  String get pleaseSelectCsvWithHeaders =>
      'Please select a CSV file with headers.';

  @override
  String get pleaseSelectLocation => 'Please select a location.';

  @override
  String get possessionFieldDef => 'Possession Field';

  @override
  String get possessionFieldName => 'In Possession';

  @override
  String get preferences => 'Preferences';

  @override
  String get previewPDF => 'PDF Preview';

  @override
  String get primaryImage => 'Primary Image';

  @override
  String get productUrlLabel => 'Product URL';

  @override
  String get quantity => 'Quantity';

  @override
  String get registerNewLoan => 'Register New Loan';

  @override
  String get reloadContainers => 'Reload containers';

  @override
  String get reloadLocations => 'Reload Locations';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get rename => 'Rename';

  @override
  String get renameContainer => 'Rename Container';

  @override
  String get returned => 'Returned';

  @override
  String get rowsPerPageTitle => 'Assets per page:';

  @override
  String get save => 'Save';

  @override
  String get saveAndApply => 'Save and Apply';

  @override
  String get saveAsset => 'Save Asset';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saveConfiguration => 'Save Configuration';

  @override
  String get saveCustomTheme => 'Save Custom Theme';

  @override
  String get searchInAllColumns => 'Search in all columns...';

  @override
  String get selectAndUploadImage => 'Select and Upload Image';

  @override
  String get selectApplicationLanguage => 'Select the application language';

  @override
  String get selectBooleanFields =>
      'Select boolean fields to control collection:';

  @override
  String get selectCsvColumn => 'Select CSV Column';

  @override
  String get selectField => 'Select field...';

  @override
  String get selectFieldType => 'Select field type';

  @override
  String get selectImage => 'Select Image';

  @override
  String get selectLocationRequired =>
      'You must select a location for the asset.';

  @override
  String selectedLocationLabel(String name) {
    return 'Selected: $name';
  }

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get september => 'September';

  @override
  String get settings => 'Settings';

  @override
  String get showAsGrid => 'Show as Grid';

  @override
  String get showAsList => 'Show as List';

  @override
  String get specificValueToCount => 'Specific Value to Count';

  @override
  String get startImport => 'Start Import';

  @override
  String get startMagic => 'Start Magic';

  @override
  String get status => 'Status';

  @override
  String get step1SelectFile => 'Step 1: Select CSV File';

  @override
  String get step2ColumnMapping => 'Step 2: Column Mapping (CSV -> System)';

  @override
  String get syncingSession => 'Syncing session...';

  @override
  String get systemThemes => 'System Themes';

  @override
  String get systemThemesModal => 'System Themes';

  @override
  String get themeNameLabel => 'Theme Name';

  @override
  String get thisFieldIsRequired => 'This field is required.';

  @override
  String get topLoanedItems => 'Top Loaned Items';

  @override
  String get totalAssets => 'Asset Types';

  @override
  String get totalItems => 'Assets';

  @override
  String get totals => 'Totals';

  @override
  String get upload => 'Upload';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get username => 'Username';

  @override
  String get veniChatTitle => 'Veni AI';

  @override
  String get veniChatStatus => 'Online';

  @override
  String get veniChatWelcome =>
      'Hi! I\'m Veni, your Invenicum assistant. How can I help you with your inventory today?';

  @override
  String get veniChatPlaceholder => 'Ask me anything...';

  @override
  String get veniChatPoweredBy => 'Powered by ';

  @override
  String veniChatProcessing(String query) {
    return 'I\'m processing your query about \"$query\"...';
  }

  @override
  String get veniCmdHelpTitle => 'Veni abilities';

  @override
  String get veniCmdDashboard => 'Go to the dashboard';

  @override
  String get veniCmdInventory => 'Check stock of an article';

  @override
  String get veniCmdLoans => 'View active loans';

  @override
  String get veniCmdReport => 'Generate inventory report';

  @override
  String get veniCmdScanQR => 'Scan QR/Barcode';

  @override
  String get veniCmdUnknown =>
      'I don\'t recognize that command. Write help to see what I can do.';

  @override
  String version(String name) {
    return 'Version $name';
  }

  @override
  String get yes => 'Yes';

  @override
  String get zoomToFit => 'Zoom to Fit';
}
