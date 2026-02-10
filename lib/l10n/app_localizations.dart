import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
  ];

  /// No description provided for @aboutInvenicum.
  ///
  /// In en, this message translates to:
  /// **'About Invenicum'**
  String get aboutInvenicum;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activeLoans.
  ///
  /// In en, this message translates to:
  /// **'Current Loans'**
  String get activeLoans;

  /// No description provided for @activeLoansCount.
  ///
  /// In en, this message translates to:
  /// **'Active Loans'**
  String get activeLoansCount;

  /// No description provided for @addAlert.
  ///
  /// In en, this message translates to:
  /// **'Add Alert'**
  String get addAlert;

  /// No description provided for @addAsset.
  ///
  /// In en, this message translates to:
  /// **'Add Asset'**
  String get addAsset;

  /// No description provided for @addContainer.
  ///
  /// In en, this message translates to:
  /// **'Add container'**
  String get addContainer;

  /// No description provided for @addNewLocation.
  ///
  /// In en, this message translates to:
  /// **'Add New Location'**
  String get addNewLocation;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @additionalThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Additional Thumbnails'**
  String get additionalThumbnails;

  /// No description provided for @aiExtractionError.
  ///
  /// In en, this message translates to:
  /// **'AI could not extract data: {error}'**
  String aiExtractionError(String error);

  /// No description provided for @aiPasteUrlDescription.
  ///
  /// In en, this message translates to:
  /// **'Paste the product link and AI will automatically extract information to fill the fields.'**
  String get aiPasteUrlDescription;

  /// No description provided for @alertCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get alertCritical;

  /// No description provided for @alertCreated.
  ///
  /// In en, this message translates to:
  /// **'Alert created'**
  String get alertCreated;

  /// No description provided for @alertDeleted.
  ///
  /// In en, this message translates to:
  /// **'Alert deleted'**
  String get alertDeleted;

  /// No description provided for @alertInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get alertInfo;

  /// No description provided for @alertMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get alertMessage;

  /// No description provided for @alertTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get alertTitle;

  /// No description provided for @alertType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get alertType;

  /// No description provided for @alertWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get alertWarning;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Notifications'**
  String get alerts;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Invenicum Inventory'**
  String get appTitle;

  /// No description provided for @applicationTheme.
  ///
  /// In en, this message translates to:
  /// **'Application Theme'**
  String get applicationTheme;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @assetDetail.
  ///
  /// In en, this message translates to:
  /// **'Asset Details'**
  String get assetDetail;

  /// No description provided for @assetImages.
  ///
  /// In en, this message translates to:
  /// **'Asset Images'**
  String get assetImages;

  /// No description provided for @assetImport.
  ///
  /// In en, this message translates to:
  /// **'Asset Import'**
  String get assetImport;

  /// No description provided for @assetName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get assetName;

  /// No description provided for @assetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Asset not found'**
  String get assetNotFound;

  /// No description provided for @assetTypeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Asset Type \"{name}\" deleted successfully.'**
  String assetTypeDeleted(String name);

  /// No description provided for @assetTypes.
  ///
  /// In en, this message translates to:
  /// **'Asset Types'**
  String get assetTypes;

  /// No description provided for @assetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Asset \"{name}\" updated successfully.'**
  String assetUpdated(String name);

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @assetsIn.
  ///
  /// In en, this message translates to:
  /// **'Assets in'**
  String get assetsIn;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @backToAssetTypes.
  ///
  /// In en, this message translates to:
  /// **'Back to Asset Types'**
  String get backToAssetTypes;

  /// No description provided for @borrowerEmail.
  ///
  /// In en, this message translates to:
  /// **'Borrower Email'**
  String get borrowerEmail;

  /// No description provided for @borrowerName.
  ///
  /// In en, this message translates to:
  /// **'Borrower Name'**
  String get borrowerName;

  /// No description provided for @borrowerPhone.
  ///
  /// In en, this message translates to:
  /// **'Borrower Phone'**
  String get borrowerPhone;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @centerView.
  ///
  /// In en, this message translates to:
  /// **'Center View'**
  String get centerView;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get chooseFile;

  /// No description provided for @clearCounter.
  ///
  /// In en, this message translates to:
  /// **'Clear Counter'**
  String get clearCounter;

  /// No description provided for @collectionContainerInfo.
  ///
  /// In en, this message translates to:
  /// **'Collection containers have collection tracking bars, invested value, market value and Exhibition view'**
  String get collectionContainerInfo;

  /// No description provided for @collectionFieldsConfigured.
  ///
  /// In en, this message translates to:
  /// **'Collection fields configured.'**
  String get collectionFieldsConfigured;

  /// No description provided for @configureCollectionFields.
  ///
  /// In en, this message translates to:
  /// **'Configure Collection Fields'**
  String get configureCollectionFields;

  /// No description provided for @configureDeliveryVoucher.
  ///
  /// In en, this message translates to:
  /// **'Configure Delivery Voucher'**
  String get configureDeliveryVoucher;

  /// No description provided for @configureVoucherBody.
  ///
  /// In en, this message translates to:
  /// **'Configure voucher body...'**
  String get configureVoucherBody;

  /// No description provided for @confirmDeleteAlert.
  ///
  /// In en, this message translates to:
  /// **'Delete Alert'**
  String get confirmDeleteAlert;

  /// No description provided for @confirmDeleteAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get confirmDeleteAlertMessage;

  /// No description provided for @confirmDeleteAssetType.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete asset type \"{name}\" and all associated items? This action cannot be undone.'**
  String confirmDeleteAssetType(String name);

  /// No description provided for @confirmDeleteContainer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete container \"{name}\"? This action is irreversible and will delete all its assets and data.'**
  String confirmDeleteContainer(String name);

  /// No description provided for @confirmDeleteLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete location \"{name}\"?'**
  String confirmDeleteLocationMessage(String name);

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// No description provided for @configurationSaved.
  ///
  /// In en, this message translates to:
  /// **'Configuration saved successfully.'**
  String get configurationSaved;

  /// No description provided for @containerCreated.
  ///
  /// In en, this message translates to:
  /// **'Container \"{name}\" created successfully.'**
  String containerCreated(String name);

  /// No description provided for @containerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Container \"{name}\" deleted successfully.'**
  String containerDeleted(String name);

  /// No description provided for @containerName.
  ///
  /// In en, this message translates to:
  /// **'Container Name'**
  String get containerName;

  /// No description provided for @containerOrAssetTypeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Container or Asset Type not found.'**
  String get containerOrAssetTypeNotFound;

  /// No description provided for @containerRenamed.
  ///
  /// In en, this message translates to:
  /// **'Container renamed to \"{name}\".'**
  String containerRenamed(String name);

  /// No description provided for @containers.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get containers;

  /// No description provided for @countItemsByValue.
  ///
  /// In en, this message translates to:
  /// **'Count items by specific value'**
  String get countItemsByValue;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createFirstContainer.
  ///
  /// In en, this message translates to:
  /// **'Create your first container.'**
  String get createFirstContainer;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Creation Date'**
  String get createdAt;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get customColor;

  /// No description provided for @customFields.
  ///
  /// In en, this message translates to:
  /// **'Custom Fields'**
  String get customFields;

  /// No description provided for @customFieldsOf.
  ///
  /// In en, this message translates to:
  /// **'Custom Fields for {name}'**
  String customFieldsOf(String name);

  /// No description provided for @customizeDeliveryVoucher.
  ///
  /// In en, this message translates to:
  /// **'Customize the PDF template for loans'**
  String get customizeDeliveryVoucher;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @datalists.
  ///
  /// In en, this message translates to:
  /// **'Custom Lists'**
  String get datalists;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @definitionCustomFields.
  ///
  /// In en, this message translates to:
  /// **'Custom Fields Definition'**
  String get definitionCustomFields;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Delete error: {error}'**
  String deleteError(String error);

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location deleted successfully.'**
  String get deleteSuccess;

  /// No description provided for @deliveryVoucher.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY VOUCHER'**
  String get deliveryVoucher;

  /// No description provided for @deliveryVoucherEditor.
  ///
  /// In en, this message translates to:
  /// **'Delivery Voucher Editor'**
  String get deliveryVoucherEditor;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get description;

  /// No description provided for @desiredField.
  ///
  /// In en, this message translates to:
  /// **'Wishlist Field'**
  String get desiredField;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @enterContainerName.
  ///
  /// In en, this message translates to:
  /// **'Enter container name'**
  String get enterContainerName;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter a description'**
  String get enterDescription;

  /// No description provided for @enterURL.
  ///
  /// In en, this message translates to:
  /// **'Enter URL'**
  String get enterURL;

  /// No description provided for @enterValidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL'**
  String get enterValidUrl;

  /// No description provided for @errorChangingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Error changing language: {error}'**
  String errorChangingLanguage(String error);

  /// No description provided for @errorCsvMinRows.
  ///
  /// In en, this message translates to:
  /// **'Please select a CSV file with headers and at least one data row.'**
  String get errorCsvMinRows;

  /// No description provided for @errorDeletingAssetType.
  ///
  /// In en, this message translates to:
  /// **'Error deleting asset type: {error}'**
  String errorDeletingAssetType(String error);

  /// No description provided for @errorDeletingContainer.
  ///
  /// In en, this message translates to:
  /// **'Error deleting container: {error}'**
  String errorDeletingContainer(String error);

  /// No description provided for @errorDuringImport.
  ///
  /// In en, this message translates to:
  /// **'Error during import'**
  String get errorDuringImport;

  /// No description provided for @errorEmptyCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV file is empty.'**
  String get errorEmptyCsv;

  /// No description provided for @errorGeneratingPDF.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF: {error}'**
  String errorGeneratingPDF(String error);

  /// No description provided for @errorInvalidPath.
  ///
  /// In en, this message translates to:
  /// **'Invalid file path.'**
  String get errorInvalidPath;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @errorLoadingListValues.
  ///
  /// In en, this message translates to:
  /// **'Error loading list values: {error}'**
  String errorLoadingListValues(String error);

  /// No description provided for @errorLoadingLocations.
  ///
  /// In en, this message translates to:
  /// **'Error loading locations: {error}'**
  String errorLoadingLocations(String error);

  /// No description provided for @errorNameMappingRequired.
  ///
  /// In en, this message translates to:
  /// **'The \'Name\' field is required and must be mapped.'**
  String get errorNameMappingRequired;

  /// No description provided for @errorNoVoucherTemplate.
  ///
  /// In en, this message translates to:
  /// **'No voucher template configured.'**
  String get errorNoVoucherTemplate;

  /// No description provided for @errorReadingBytes.
  ///
  /// In en, this message translates to:
  /// **'Could not read file bytes.'**
  String get errorReadingBytes;

  /// No description provided for @errorReadingFile.
  ///
  /// In en, this message translates to:
  /// **'Error reading file: {error}'**
  String errorReadingFile(String error);

  /// No description provided for @errorRegisteringLoan.
  ///
  /// In en, this message translates to:
  /// **'Error registering loan: {error}'**
  String errorRegisteringLoan(String error);

  /// No description provided for @errorRenaming.
  ///
  /// In en, this message translates to:
  /// **'Error renaming: {error}'**
  String errorRenaming(String error);

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSaving(String error);

  /// No description provided for @errorUpdatingAsset.
  ///
  /// In en, this message translates to:
  /// **'Error updating asset: {error}'**
  String errorUpdatingAsset(String error);

  /// No description provided for @exampleFilterHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Damaged, Red, 50'**
  String get exampleFilterHint;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @fieldChip.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get fieldChip;

  /// No description provided for @fieldRequiredWithName.
  ///
  /// In en, this message translates to:
  /// **'Field \"{field}\" is required.'**
  String fieldRequiredWithName(String field);

  /// No description provided for @fieldToCount.
  ///
  /// In en, this message translates to:
  /// **'Field to Count'**
  String get fieldToCount;

  /// No description provided for @fieldsFilledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Fields filled successfully!'**
  String get fieldsFilledSuccess;

  /// No description provided for @formatsPNG.
  ///
  /// In en, this message translates to:
  /// **'Formats: PNG, JPG'**
  String get formatsPNG;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @generateVoucher.
  ///
  /// In en, this message translates to:
  /// **'Generate Delivery Voucher'**
  String get generateVoucher;

  /// No description provided for @globalSearch.
  ///
  /// In en, this message translates to:
  /// **'Global Search'**
  String get globalSearch;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, welcome!'**
  String get greeting;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @helpDocs.
  ///
  /// In en, this message translates to:
  /// **'Help & Documentation'**
  String get helpDocs;

  /// No description provided for @ignoreField.
  ///
  /// In en, this message translates to:
  /// **'🚫 Ignore Field'**
  String get ignoreField;

  /// No description provided for @importAssetsTo.
  ///
  /// In en, this message translates to:
  /// **'Import Assets To'**
  String get importAssetsTo;

  /// No description provided for @importSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Import Successful! {count} assets created.'**
  String importSuccessMessage(int count);

  /// No description provided for @invalidAssetId.
  ///
  /// In en, this message translates to:
  /// **'Invalid asset ID'**
  String get invalidAssetId;

  /// No description provided for @invalidNavigationIds.
  ///
  /// In en, this message translates to:
  /// **'Error: Invalid navigation IDs.'**
  String get invalidNavigationIds;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to English!'**
  String get languageChanged;

  /// No description provided for @languageNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Language feature not yet implemented'**
  String get languageNotImplemented;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @loadingAssetType.
  ///
  /// In en, this message translates to:
  /// **'Loading Asset Type...'**
  String get loadingAssetType;

  /// No description provided for @loadingListField.
  ///
  /// In en, this message translates to:
  /// **'Loading {field}...'**
  String loadingListField(String field);

  /// No description provided for @loanDate.
  ///
  /// In en, this message translates to:
  /// **'Loan Date'**
  String get loanDate;

  /// No description provided for @loanLanguageNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Language feature not yet implemented'**
  String get loanLanguageNotImplemented;

  /// No description provided for @loanManagement.
  ///
  /// In en, this message translates to:
  /// **'Loan Management'**
  String get loanManagement;

  /// No description provided for @loanObject.
  ///
  /// In en, this message translates to:
  /// **'Object to Loan'**
  String get loanObject;

  /// No description provided for @loans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loans;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get locations;

  /// No description provided for @locationsScheme.
  ///
  /// In en, this message translates to:
  /// **'Locations Scheme'**
  String get locationsScheme;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logoVoucher.
  ///
  /// In en, this message translates to:
  /// **'Voucher Logo'**
  String get logoVoucher;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @magicAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Magic Assistant'**
  String get magicAssistant;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @minStock.
  ///
  /// In en, this message translates to:
  /// **'Min stock'**
  String get minStock;

  /// No description provided for @myCustomTheme.
  ///
  /// In en, this message translates to:
  /// **'My Theme'**
  String get myCustomTheme;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @myThemesStored.
  ///
  /// In en, this message translates to:
  /// **'My Stored Themes'**
  String get myThemesStored;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @nameSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Name is the same as current'**
  String get nameSameAsCurrent;

  /// No description provided for @newAlert.
  ///
  /// In en, this message translates to:
  /// **'New Manual Alert'**
  String get newAlert;

  /// No description provided for @newContainer.
  ///
  /// In en, this message translates to:
  /// **'New container'**
  String get newContainer;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newName;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noAssetsCreated.
  ///
  /// In en, this message translates to:
  /// **'No assets created yet.'**
  String get noAssetsCreated;

  /// No description provided for @noAssetsMatch.
  ///
  /// In en, this message translates to:
  /// **'No assets match search/filter criteria.'**
  String get noAssetsMatch;

  /// No description provided for @noBooleanFields.
  ///
  /// In en, this message translates to:
  /// **'No boolean fields defined.'**
  String get noBooleanFields;

  /// No description provided for @noContainerMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first container.'**
  String get noContainerMessage;

  /// No description provided for @noCustomFields.
  ///
  /// In en, this message translates to:
  /// **'This asset type has no custom fields.'**
  String get noCustomFields;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @noImageAvailable.
  ///
  /// In en, this message translates to:
  /// **'No image available'**
  String get noImageAvailable;

  /// No description provided for @noImagesAdded.
  ///
  /// In en, this message translates to:
  /// **'No images added yet. The first image will be the primary one.'**
  String get noImagesAdded;

  /// No description provided for @noLoansFound.
  ///
  /// In en, this message translates to:
  /// **'No loans found in this container.'**
  String get noLoansFound;

  /// No description provided for @noLocationsMessage.
  ///
  /// In en, this message translates to:
  /// **'No locations created in this container. Add the first one!'**
  String get noLocationsMessage;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noThemesSaved.
  ///
  /// In en, this message translates to:
  /// **'No themes saved yet'**
  String get noThemesSaved;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @obligatory.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get obligatory;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleasePasteUrl.
  ///
  /// In en, this message translates to:
  /// **'Please paste a URL'**
  String get pleasePasteUrl;

  /// No description provided for @pleaseSelectCsvWithHeaders.
  ///
  /// In en, this message translates to:
  /// **'Please select a CSV file with headers.'**
  String get pleaseSelectCsvWithHeaders;

  /// No description provided for @pleaseSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select a location.'**
  String get pleaseSelectLocation;

  /// No description provided for @plugins.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get plugins;

  /// No description provided for @possessionFieldDef.
  ///
  /// In en, this message translates to:
  /// **'Possession Field'**
  String get possessionFieldDef;

  /// No description provided for @possessionFieldName.
  ///
  /// In en, this message translates to:
  /// **'In Possession'**
  String get possessionFieldName;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @previewPDF.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewPDF;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @primaryImage.
  ///
  /// In en, this message translates to:
  /// **'Primary Image'**
  String get primaryImage;

  /// No description provided for @productUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Product URL'**
  String get productUrlLabel;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @registerNewLoan.
  ///
  /// In en, this message translates to:
  /// **'Register New Loan'**
  String get registerNewLoan;

  /// No description provided for @reloadContainers.
  ///
  /// In en, this message translates to:
  /// **'Reload containers'**
  String get reloadContainers;

  /// No description provided for @reloadLocations.
  ///
  /// In en, this message translates to:
  /// **'Reload Locations'**
  String get reloadLocations;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameContainer.
  ///
  /// In en, this message translates to:
  /// **'Rename Container'**
  String get renameContainer;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @rowsPerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Assets per page:'**
  String get rowsPerPageTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAndApply.
  ///
  /// In en, this message translates to:
  /// **'Save and Apply'**
  String get saveAndApply;

  /// No description provided for @saveAsset.
  ///
  /// In en, this message translates to:
  /// **'Save Asset'**
  String get saveAsset;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saveConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get saveConfiguration;

  /// No description provided for @saveCustomTheme.
  ///
  /// In en, this message translates to:
  /// **'Save Custom Theme'**
  String get saveCustomTheme;

  /// No description provided for @searchInAllColumns.
  ///
  /// In en, this message translates to:
  /// **'Search in all columns...'**
  String get searchInAllColumns;

  /// No description provided for @selectAndUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Select and Upload Image'**
  String get selectAndUploadImage;

  /// No description provided for @selectApplicationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select application language'**
  String get selectApplicationLanguage;

  /// No description provided for @selectBooleanFields.
  ///
  /// In en, this message translates to:
  /// **'Select boolean fields to control collection:'**
  String get selectBooleanFields;

  /// No description provided for @selectCsvColumn.
  ///
  /// In en, this message translates to:
  /// **'Select CSV Column'**
  String get selectCsvColumn;

  /// No description provided for @selectField.
  ///
  /// In en, this message translates to:
  /// **'Select field...'**
  String get selectField;

  /// No description provided for @selectFieldType.
  ///
  /// In en, this message translates to:
  /// **'Select field type'**
  String get selectFieldType;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @selectLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'You must select a location for the asset.'**
  String get selectLocationRequired;

  /// No description provided for @selectedLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String selectedLocationLabel(String name);

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @showAsGrid.
  ///
  /// In en, this message translates to:
  /// **'Show as Grid'**
  String get showAsGrid;

  /// No description provided for @showAsList.
  ///
  /// In en, this message translates to:
  /// **'Show as List'**
  String get showAsList;

  /// No description provided for @slotDashboardBottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom Dashboard Panel'**
  String get slotDashboardBottom;

  /// No description provided for @slotDashboardTop.
  ///
  /// In en, this message translates to:
  /// **'Top Dashboard Panel'**
  String get slotDashboardTop;

  /// No description provided for @slotFloatingActionButton.
  ///
  /// In en, this message translates to:
  /// **'Floating Button'**
  String get slotFloatingActionButton;

  /// No description provided for @slotInventoryHeader.
  ///
  /// In en, this message translates to:
  /// **'Inventory Header'**
  String get slotInventoryHeader;

  /// No description provided for @slotLeftSidebar.
  ///
  /// In en, this message translates to:
  /// **'Sidebar'**
  String get slotLeftSidebar;

  /// No description provided for @slotUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Slot'**
  String get slotUnknown;

  /// No description provided for @specificValueToCount.
  ///
  /// In en, this message translates to:
  /// **'Specific Value to Count'**
  String get specificValueToCount;

  /// No description provided for @startImport.
  ///
  /// In en, this message translates to:
  /// **'Start Import'**
  String get startImport;

  /// No description provided for @startMagic.
  ///
  /// In en, this message translates to:
  /// **'Start Magic'**
  String get startMagic;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @step1SelectFile.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Select CSV File'**
  String get step1SelectFile;

  /// No description provided for @step2ColumnMapping.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Column Mapping (CSV -> System)'**
  String get step2ColumnMapping;

  /// No description provided for @syncingSession.
  ///
  /// In en, this message translates to:
  /// **'Syncing session...'**
  String get syncingSession;

  /// No description provided for @systemThemes.
  ///
  /// In en, this message translates to:
  /// **'System Themes'**
  String get systemThemes;

  /// No description provided for @systemThemesModal.
  ///
  /// In en, this message translates to:
  /// **'System Themes'**
  String get systemThemesModal;

  /// No description provided for @themeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme Name'**
  String get themeNameLabel;

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get thisFieldIsRequired;

  /// No description provided for @topLoanedItems.
  ///
  /// In en, this message translates to:
  /// **'Top Loaned Items'**
  String get topLoanedItems;

  /// No description provided for @totalAssets.
  ///
  /// In en, this message translates to:
  /// **'Asset Types'**
  String get totalAssets;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get totalItems;

  /// No description provided for @totals.
  ///
  /// In en, this message translates to:
  /// **'Totals'**
  String get totals;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get updatedAt;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @veniChatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask me something...'**
  String get veniChatPlaceholder;

  /// No description provided for @veniChatPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by '**
  String get veniChatPoweredBy;

  /// Mensaje de carga de la IA
  ///
  /// In en, this message translates to:
  /// **'I\'m processing your query about \"{query}\"...'**
  String veniChatProcessing(String query);

  /// No description provided for @veniChatStatus.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get veniChatStatus;

  /// No description provided for @veniChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Venibot AI'**
  String get veniChatTitle;

  /// No description provided for @veniChatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m Venibot, your Invenicum assistant. How can I help you with your inventory today?'**
  String get veniChatWelcome;

  /// No description provided for @veniCmdDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to dashboard'**
  String get veniCmdDashboard;

  /// No description provided for @veniCmdHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Veni\'s Skills'**
  String get veniCmdHelpTitle;

  /// No description provided for @veniCmdInventory.
  ///
  /// In en, this message translates to:
  /// **'Check stock for an item'**
  String get veniCmdInventory;

  /// No description provided for @veniCmdLoans.
  ///
  /// In en, this message translates to:
  /// **'View active loans'**
  String get veniCmdLoans;

  /// No description provided for @veniCmdReport.
  ///
  /// In en, this message translates to:
  /// **'Generate inventory report'**
  String get veniCmdReport;

  /// No description provided for @veniCmdScanQR.
  ///
  /// In en, this message translates to:
  /// **'Scan QR/Barcode'**
  String get veniCmdScanQR;

  /// No description provided for @veniCmdUnknown.
  ///
  /// In en, this message translates to:
  /// **'I don\'t recognize that command. Type help to see what I can do.'**
  String get veniCmdUnknown;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {name}'**
  String version(String name);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @zoomToFit.
  ///
  /// In en, this message translates to:
  /// **'Zoom to Fit'**
  String get zoomToFit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
