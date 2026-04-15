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

  /// Title used in generated delivery voucher PDF
  ///
  /// In en, this message translates to:
  /// **'DELIVERY VOUCHER'**
  String get deliveryVoucherTitle;

  /// No description provided for @aboutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'About Invenicum'**
  String get aboutDialogTitle;

  /// No description provided for @aboutDialogCoolText.
  ///
  /// In en, this message translates to:
  /// **'Your inventory, now with extra horsepower. Checking if a fresher version is waiting for you.'**
  String get aboutDialogCoolText;

  /// No description provided for @aboutCurrentVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get aboutCurrentVersionLabel;

  /// No description provided for @aboutLatestVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest version'**
  String get aboutLatestVersionLabel;

  /// No description provided for @aboutCheckingVersion.
  ///
  /// In en, this message translates to:
  /// **'Checking online version...'**
  String get aboutCheckingVersion;

  /// No description provided for @aboutVersionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get aboutVersionUnknown;

  /// No description provided for @aboutVersionUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Your app is up to date.'**
  String get aboutVersionUpToDate;

  /// No description provided for @aboutUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A newer version is available.'**
  String get aboutUpdateAvailable;

  /// No description provided for @aboutVersionCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check online version.'**
  String get aboutVersionCheckFailed;

  /// No description provided for @aboutOpenReleases.
  ///
  /// In en, this message translates to:
  /// **'View releases'**
  String get aboutOpenReleases;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @actives.
  ///
  /// In en, this message translates to:
  /// **'Actives'**
  String get actives;

  /// No description provided for @activeInsight.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE ASSETS INSIGHTS'**
  String get activeInsight;

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

  /// No description provided for @adquisition.
  ///
  /// In en, this message translates to:
  /// **'ADQUISITION'**
  String get adquisition;

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

  /// No description provided for @allUpToDateStatus.
  ///
  /// In en, this message translates to:
  /// **'All up to date'**
  String get allUpToDateStatus;

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

  /// No description provided for @averageMarketValue.
  ///
  /// In en, this message translates to:
  /// **'Average market price'**
  String get averageMarketValue;

  /// No description provided for @barCode.
  ///
  /// In en, this message translates to:
  /// **'Barcode (UPC)'**
  String get barCode;

  /// No description provided for @baseCostAccumulatedWithoutInflation.
  ///
  /// In en, this message translates to:
  /// **'Base cost accumulated without inflation'**
  String get baseCostAccumulatedWithoutInflation;

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

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @condition_mint.
  ///
  /// In en, this message translates to:
  /// **'Mint (Original box)'**
  String get condition_mint;

  /// No description provided for @condition_loose.
  ///
  /// In en, this message translates to:
  /// **'Loose (No box)'**
  String get condition_loose;

  /// No description provided for @condition_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get condition_incomplete;

  /// No description provided for @condition_damaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get condition_damaged;

  /// No description provided for @condition_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get condition_new;

  /// No description provided for @condition_digital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get condition_digital;

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

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

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

  /// No description provided for @errorNotBarCode.
  ///
  /// In en, this message translates to:
  /// **'The article does not have a barcode or is invalid.'**
  String get errorNotBarCode;

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

  /// No description provided for @forToday.
  ///
  /// In en, this message translates to:
  /// **'For today'**
  String get forToday;

  /// No description provided for @geminiLabelModel.
  ///
  /// In en, this message translates to:
  /// **'Recommended Gemini model: gemini-3-flash-preview'**
  String get geminiLabelModel;

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

  /// No description provided for @helperGeminiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your Gemini API key to enable integration. Get it at https://aistudio.google.com/'**
  String get helperGeminiKey;

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

  /// No description provided for @importSerializedWarning.
  ///
  /// In en, this message translates to:
  /// **'Import successful. This asset type is serialized — all items were created with quantity 1.'**
  String get importSerializedWarning;

  /// No description provided for @integrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get integrations;

  /// No description provided for @integrationGeminiDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect Invenicum with Google\'s Gemini to leverage advanced AI capabilities in managing your inventory.'**
  String get integrationGeminiDesc;

  /// No description provided for @integrationTelegramDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect Invenicum with Telegram to receive instant notifications about your inventory directly on your device.'**
  String get integrationTelegramDesc;

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

  /// No description provided for @inventoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryLabel;

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

  /// No description provided for @lookForContainersOrAssets.
  ///
  /// In en, this message translates to:
  /// **'Look for containers or assets...'**
  String get lookForContainersOrAssets;

  /// No description provided for @lowStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStockTitle;

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

  /// No description provided for @marketPriceObtained.
  ///
  /// In en, this message translates to:
  /// **'Market price obtained successfully'**
  String get marketPriceObtained;

  /// No description provided for @marketValueEvolution.
  ///
  /// In en, this message translates to:
  /// **'Market Value Evolution'**
  String get marketValueEvolution;

  /// No description provided for @marketValueField.
  ///
  /// In en, this message translates to:
  /// **'Market Value'**
  String get marketValueField;

  /// No description provided for @marketRealRate.
  ///
  /// In en, this message translates to:
  /// **'Real market rate'**
  String get marketRealRate;

  /// No description provided for @maxStock.
  ///
  /// In en, this message translates to:
  /// **'Max stock'**
  String get maxStock;

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

  /// No description provided for @myAchievements.
  ///
  /// In en, this message translates to:
  /// **'My Achievements'**
  String get myAchievements;

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

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

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

  /// No description provided for @optimalStockStatus.
  ///
  /// In en, this message translates to:
  /// **'Stock at optimal levels'**
  String get optimalStockStatus;

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

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

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

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh data'**
  String get refresh;

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
  /// **'Reload locations'**
  String get reloadLocations;

  /// No description provided for @reloadLoans.
  ///
  /// In en, this message translates to:
  /// **'Reload loans'**
  String get reloadLoans;

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

  /// No description provided for @responsibleLabel.
  ///
  /// In en, this message translates to:
  /// **'Responsible'**
  String get responsibleLabel;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @returnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returnsLabel;

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

  /// No description provided for @selectApplicationCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select application currency'**
  String get selectApplicationCurrency;

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

  /// No description provided for @sortAsc.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortAsc;

  /// No description provided for @sortDesc.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDesc;

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

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

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

  /// No description provided for @topDemanded.
  ///
  /// In en, this message translates to:
  /// **'Top Demanded'**
  String get topDemanded;

  /// No description provided for @topLoanedItems.
  ///
  /// In en, this message translates to:
  /// **'Top loaned items per months'**
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

  /// No description provided for @totalSpending.
  ///
  /// In en, this message translates to:
  /// **'Total Economic Investment'**
  String get totalSpending;

  /// No description provided for @totalMarketValue.
  ///
  /// In en, this message translates to:
  /// **'Total Market Value'**
  String get totalMarketValue;

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

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @connectionTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection test failed'**
  String get connectionTestFailed;

  /// No description provided for @connectionVerified.
  ///
  /// In en, this message translates to:
  /// **'Connection verified successfully'**
  String get connectionVerified;

  /// No description provided for @errorSavingConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Error saving configuration'**
  String get errorSavingConfiguration;

  /// No description provided for @integrationsAndConnectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Integrations and connections'**
  String get integrationsAndConnectionsTitle;

  /// No description provided for @integrationsSectionAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Artificial intelligence'**
  String get integrationsSectionAiTitle;

  /// No description provided for @integrationsSectionAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Conversational engines and assistants to enhance workflows and automations.'**
  String get integrationsSectionAiSubtitle;

  /// No description provided for @integrationsSectionMessagingTitle.
  ///
  /// In en, this message translates to:
  /// **'Messaging and notifications'**
  String get integrationsSectionMessagingTitle;

  /// No description provided for @integrationsSectionMessagingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Output channels for alerts, bots, reports, and automated deliveries.'**
  String get integrationsSectionMessagingSubtitle;

  /// No description provided for @integrationsSectionDataApisTitle.
  ///
  /// In en, this message translates to:
  /// **'Data APIs'**
  String get integrationsSectionDataApisTitle;

  /// No description provided for @integrationsSectionDataApisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'External sources to enrich cards, games, and catalog references.'**
  String get integrationsSectionDataApisSubtitle;

  /// No description provided for @integrationsSectionValuationTitle.
  ///
  /// In en, this message translates to:
  /// **'Valuation and market'**
  String get integrationsSectionValuationTitle;

  /// No description provided for @integrationsSectionValuationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connectors for pricing, barcodes, and up-to-date value estimation.'**
  String get integrationsSectionValuationSubtitle;

  /// No description provided for @integrationsSectionHardwareTitle.
  ///
  /// In en, this message translates to:
  /// **'Hardware and labels'**
  String get integrationsSectionHardwareTitle;

  /// No description provided for @integrationsSectionHardwareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Physical tools and utilities for printing, coding, and operations.'**
  String get integrationsSectionHardwareSubtitle;

  /// No description provided for @integrationsActiveConnections.
  ///
  /// In en, this message translates to:
  /// **'{count} active connections'**
  String integrationsActiveConnections(int count);

  /// No description provided for @integrationsModularDesign.
  ///
  /// In en, this message translates to:
  /// **'Modular design by categories'**
  String get integrationsModularDesign;

  /// No description provided for @integrationsCheckingStatuses.
  ///
  /// In en, this message translates to:
  /// **'Checking statuses'**
  String get integrationsCheckingStatuses;

  /// No description provided for @integrationsStatusSynced.
  ///
  /// In en, this message translates to:
  /// **'Status synchronized'**
  String get integrationsStatusSynced;

  /// No description provided for @integrationsHeroHeadline.
  ///
  /// In en, this message translates to:
  /// **'Connect services, APIs, and tools from one clear view.'**
  String get integrationsHeroHeadline;

  /// No description provided for @integrationsHeroSubheadline.
  ///
  /// In en, this message translates to:
  /// **'We group integrations by purpose so setup is faster, more visual, and easier to maintain on mobile too.'**
  String get integrationsHeroSubheadline;

  /// No description provided for @integrationStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get integrationStatusConnected;

  /// No description provided for @integrationStatusNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get integrationStatusNotConfigured;

  /// No description provided for @integrationTypeDataSource.
  ///
  /// In en, this message translates to:
  /// **'Data source'**
  String get integrationTypeDataSource;

  /// No description provided for @integrationTypeConnector.
  ///
  /// In en, this message translates to:
  /// **'Connector'**
  String get integrationTypeConnector;

  /// No description provided for @integrationFieldsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} fields'**
  String integrationFieldsCount(int count);

  /// No description provided for @integrationNoLocalCredentials.
  ///
  /// In en, this message translates to:
  /// **'No local credentials'**
  String get integrationNoLocalCredentials;

  /// No description provided for @configureLabel.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configureLabel;

  /// No description provided for @integrationModelDefaultGemini.
  ///
  /// In en, this message translates to:
  /// **'Default: gemini-3-flash-preview'**
  String get integrationModelDefaultGemini;

  /// No description provided for @integrationOpenaiDesc.
  ///
  /// In en, this message translates to:
  /// **'Use GPT-4o and other OpenAI models as an intelligent assistant.'**
  String get integrationOpenaiDesc;

  /// No description provided for @integrationOpenaiApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Generated at platform.openai.com/api-keys'**
  String get integrationOpenaiApiKeyHint;

  /// No description provided for @integrationModelDefaultOpenai.
  ///
  /// In en, this message translates to:
  /// **'Default: gpt-4o'**
  String get integrationModelDefaultOpenai;

  /// No description provided for @integrationClaudeDesc.
  ///
  /// In en, this message translates to:
  /// **'Use Claude Sonnet, Opus, and Haiku as an intelligent assistant.'**
  String get integrationClaudeDesc;

  /// No description provided for @integrationClaudeApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Generated at console.anthropic.com/settings/keys'**
  String get integrationClaudeApiKeyHint;

  /// No description provided for @integrationModelDefaultClaude.
  ///
  /// In en, this message translates to:
  /// **'Default: claude-sonnet-4-6'**
  String get integrationModelDefaultClaude;

  /// No description provided for @integrationTelegramBotTokenHint.
  ///
  /// In en, this message translates to:
  /// **'From @BotFather'**
  String get integrationTelegramBotTokenHint;

  /// No description provided for @integrationTelegramChatIdHint.
  ///
  /// In en, this message translates to:
  /// **'Use @userinfobot to get your ID'**
  String get integrationTelegramChatIdHint;

  /// No description provided for @integrationEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Ultra-reliable email delivery. Ideal for reports and critical alerts.'**
  String get integrationEmailDesc;

  /// No description provided for @integrationEmailApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Generated at resend.com/api-keys'**
  String get integrationEmailApiKeyHint;

  /// No description provided for @integrationEmailFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Sender (From)'**
  String get integrationEmailFromLabel;

  /// No description provided for @integrationEmailFromHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Invenicum <onboarding@resend.dev>'**
  String get integrationEmailFromHint;

  /// No description provided for @integrationBggDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect your BGG account to sync your collection and enrich your data automatically.'**
  String get integrationBggDesc;

  /// No description provided for @integrationPokemonDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect to the Pokemon API to sync your collection and enrich your data automatically.'**
  String get integrationPokemonDesc;

  /// No description provided for @integrationTcgdexDesc.
  ///
  /// In en, this message translates to:
  /// **'Query cards and sets from collectible card games to enrich your inventory automatically.'**
  String get integrationTcgdexDesc;

  /// No description provided for @integrationQrGeneratorName.
  ///
  /// In en, this message translates to:
  /// **'QR Generator'**
  String get integrationQrGeneratorName;

  /// No description provided for @integrationQrLabelsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure the format of your printable labels.'**
  String get integrationQrLabelsDesc;

  /// No description provided for @integrationQrPageSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Page size (A4, Letter)'**
  String get integrationQrPageSizeLabel;

  /// No description provided for @integrationQrMarginLabel.
  ///
  /// In en, this message translates to:
  /// **'Margin (mm)'**
  String get integrationQrMarginLabel;

  /// No description provided for @integrationPriceChartingDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure your API key to fetch updated prices.'**
  String get integrationPriceChartingDesc;

  /// No description provided for @integrationUpcitemdbDesc.
  ///
  /// In en, this message translates to:
  /// **'Global price lookup by barcode.'**
  String get integrationUpcitemdbDesc;

  /// No description provided for @integrationConfiguredSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} configured successfully'**
  String integrationConfiguredSuccess(String name);

  /// No description provided for @integrationUnlinkedWithName.
  ///
  /// In en, this message translates to:
  /// **'{name} has been unlinked'**
  String integrationUnlinkedWithName(String name);

  /// No description provided for @invalidUiFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid UI format'**
  String get invalidUiFormat;

  /// No description provided for @loadingConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Loading configuration...'**
  String get loadingConfiguration;

  /// No description provided for @pageNotFoundUri.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {uri}'**
  String pageNotFoundUri(String uri);

  /// No description provided for @pluginLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading plugin UI'**
  String get pluginLoadError;

  /// No description provided for @pluginRenderError.
  ///
  /// In en, this message translates to:
  /// **'Render error'**
  String get pluginRenderError;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @testingConnection.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get testingConnection;

  /// No description provided for @unableToUnlinkAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not unlink account'**
  String get unableToUnlinkAccount;

  /// No description provided for @unlinkIntegrationUpper.
  ///
  /// In en, this message translates to:
  /// **'UNLINK INTEGRATION'**
  String get unlinkIntegrationUpper;

  /// No description provided for @upcFreeModeHint.
  ///
  /// In en, this message translates to:
  /// **'Leave this field empty to use Free mode (Limited).'**
  String get upcFreeModeHint;

  /// No description provided for @alertsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTabLabel;

  /// No description provided for @alertMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'Marked as read'**
  String get alertMarkedAsRead;

  /// No description provided for @calendarTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTabLabel;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @closeLabelUpper.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get closeLabelUpper;

  /// No description provided for @configureReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Configure reminder:'**
  String get configureReminderLabel;

  /// No description provided for @cannotFormatInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Cannot format an invalid JSON'**
  String get cannotFormatInvalidJson;

  /// No description provided for @createAlertOrEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Create alert/event'**
  String get createAlertOrEventTitle;

  /// No description provided for @createdSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Created successfully'**
  String get createdSuccessfully;

  /// No description provided for @createPluginTitle.
  ///
  /// In en, this message translates to:
  /// **'Create plugin'**
  String get createPluginTitle;

  /// No description provided for @editPluginTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit plugin'**
  String get editPluginTitle;

  /// No description provided for @deleteFromGithubLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete from GitHub'**
  String get deleteFromGithubLabel;

  /// No description provided for @deleteFromGithubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes the file from the public market'**
  String get deleteFromGithubSubtitle;

  /// No description provided for @deletePluginQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete plugin?'**
  String get deletePluginQuestion;

  /// No description provided for @deletePluginLocalWarning.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from your local database.'**
  String get deletePluginLocalWarning;

  /// No description provided for @deleteUpper.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteUpper;

  /// No description provided for @editEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEventTitle;

  /// No description provided for @editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// No description provided for @eventDataSection.
  ///
  /// In en, this message translates to:
  /// **'Event data'**
  String get eventDataSection;

  /// No description provided for @eventReminderAtTime.
  ///
  /// In en, this message translates to:
  /// **'At event time'**
  String get eventReminderAtTime;

  /// No description provided for @eventUpdated.
  ///
  /// In en, this message translates to:
  /// **'Event updated'**
  String get eventUpdated;

  /// No description provided for @firstVersionHint.
  ///
  /// In en, this message translates to:
  /// **'The first version will always be 1.0.0'**
  String get firstVersionHint;

  /// No description provided for @fixJsonBeforeSave.
  ///
  /// In en, this message translates to:
  /// **'Fix the JSON before saving'**
  String get fixJsonBeforeSave;

  /// No description provided for @formatJson.
  ///
  /// In en, this message translates to:
  /// **'Format JSON'**
  String get formatJson;

  /// No description provided for @goToProfileUpper.
  ///
  /// In en, this message translates to:
  /// **'GO TO PROFILE'**
  String get goToProfileUpper;

  /// No description provided for @installPluginLabel.
  ///
  /// In en, this message translates to:
  /// **'Install plugin'**
  String get installPluginLabel;

  /// No description provided for @invalidVersionFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format (e.g., 1.0.1)'**
  String get invalidVersionFormat;

  /// No description provided for @isEventQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is this an event?'**
  String get isEventQuestion;

  /// No description provided for @jsonErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'JSON error'**
  String get jsonErrorGeneric;

  /// No description provided for @makePublicLabel.
  ///
  /// In en, this message translates to:
  /// **'Make public'**
  String get makePublicLabel;

  /// No description provided for @markAsReadLabel.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsReadLabel;

  /// No description provided for @messageWithColon.
  ///
  /// In en, this message translates to:
  /// **'Message:'**
  String get messageWithColon;

  /// No description provided for @minutesBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before'**
  String minutesBeforeLabel(int minutes);

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @newPluginLabel.
  ///
  /// In en, this message translates to:
  /// **'New plugin'**
  String get newPluginLabel;

  /// No description provided for @noActiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'No active alerts'**
  String get noActiveAlerts;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailable;

  /// No description provided for @noEventsForDay.
  ///
  /// In en, this message translates to:
  /// **'No events for this day'**
  String get noEventsForDay;

  /// No description provided for @noPluginsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plugins'**
  String get noPluginsAvailable;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted successfully'**
  String get notificationDeleted;

  /// No description provided for @oneHourBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get oneHourBeforeLabel;

  /// No description provided for @pluginPrivateDescription.
  ///
  /// In en, this message translates to:
  /// **'Only you can see this plugin in your list.'**
  String get pluginPrivateDescription;

  /// No description provided for @pluginPublicDescription.
  ///
  /// In en, this message translates to:
  /// **'Other users will be able to see and install this plugin.'**
  String get pluginPublicDescription;

  /// No description provided for @pluginTabLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get pluginTabLibrary;

  /// No description provided for @pluginTabMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get pluginTabMarket;

  /// No description provided for @pluginTabMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get pluginTabMine;

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewLabel;

  /// No description provided for @remindMeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remind me:'**
  String get remindMeLabel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @requiresGithubDescription.
  ///
  /// In en, this message translates to:
  /// **'To publish plugins in the community, you need to link your GitHub account to get author credit.'**
  String get requiresGithubDescription;

  /// No description provided for @requiresGithubTitle.
  ///
  /// In en, this message translates to:
  /// **'GitHub required'**
  String get requiresGithubTitle;

  /// No description provided for @slotLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location (slot)'**
  String get slotLocationLabel;

  /// No description provided for @stacDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Stac documentation'**
  String get stacDocumentation;

  /// No description provided for @stacJsonInterfaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Stac JSON (interface)'**
  String get stacJsonInterfaceLabel;

  /// No description provided for @uninstallLabel.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstallLabel;

  /// No description provided for @unrecognizedStacStructure.
  ///
  /// In en, this message translates to:
  /// **'Unrecognized Stac structure'**
  String get unrecognizedStacStructure;

  /// No description provided for @updateLabelUpper.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get updateLabelUpper;

  /// No description provided for @updateToVersion.
  ///
  /// In en, this message translates to:
  /// **'Update to v{version}'**
  String updateToVersion(String version);

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @incrementVersionHint.
  ///
  /// In en, this message translates to:
  /// **'Increase the version for your proposal (e.g., 1.1.0)'**
  String get incrementVersionHint;

  /// No description provided for @cancelUpper.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelUpper;

  /// No description provided for @mustLinkGithubToPublishTemplate.
  ///
  /// In en, this message translates to:
  /// **'You must link GitHub in your profile to publish.'**
  String get mustLinkGithubToPublishTemplate;

  /// No description provided for @templateNeedsAtLeastOneField.
  ///
  /// In en, this message translates to:
  /// **'The template must have at least one defined field.'**
  String get templateNeedsAtLeastOneField;

  /// No description provided for @templatePullRequestCreated.
  ///
  /// In en, this message translates to:
  /// **'Proposal sent. A Pull Request has been created on GitHub.'**
  String get templatePullRequestCreated;

  /// No description provided for @errorPublishingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Error publishing: {error}'**
  String errorPublishingTemplate(String error);

  /// No description provided for @createGlobalTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create global template'**
  String get createGlobalTemplateTitle;

  /// No description provided for @githubVerifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'GitHub verified'**
  String get githubVerifiedLabel;

  /// No description provided for @githubNotLinkedLabel.
  ///
  /// In en, this message translates to:
  /// **'GitHub not linked'**
  String get githubNotLinkedLabel;

  /// No description provided for @veniDesignedTemplateBanner.
  ///
  /// In en, this message translates to:
  /// **'Veni designed this structure based on your request. Review and adjust it before publishing.'**
  String get veniDesignedTemplateBanner;

  /// No description provided for @templateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get templateNameLabel;

  /// No description provided for @templateNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: My comics collection'**
  String get templateNameHint;

  /// No description provided for @githubUserLabel.
  ///
  /// In en, this message translates to:
  /// **'GitHub user'**
  String get githubUserLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categoryHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Books, Electronics...'**
  String get categoryHint;

  /// No description provided for @templatePurposeDescription.
  ///
  /// In en, this message translates to:
  /// **'Purpose description'**
  String get templatePurposeDescription;

  /// No description provided for @definedFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Defined fields'**
  String get definedFieldsTitle;

  /// No description provided for @addFieldButton.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get addFieldButton;

  /// No description provided for @clickAddFieldToStart.
  ///
  /// In en, this message translates to:
  /// **'Click \'Add field\' to start designing.'**
  String get clickAddFieldToStart;

  /// No description provided for @configureOptionsUpper.
  ///
  /// In en, this message translates to:
  /// **'CONFIGURE OPTIONS'**
  String get configureOptionsUpper;

  /// No description provided for @writeOptionAndPressEnter.
  ///
  /// In en, this message translates to:
  /// **'Type an option and press Enter'**
  String get writeOptionAndPressEnter;

  /// No description provided for @publishOnGithubUpper.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH ON GITHUB'**
  String get publishOnGithubUpper;

  /// No description provided for @templateDetailFetchError.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch template details'**
  String get templateDetailFetchError;

  /// No description provided for @templateNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'The template does not exist or is not available'**
  String get templateNotAvailable;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @templateDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Template detail'**
  String get templateDetailTitle;

  /// No description provided for @saveToLibraryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save to library'**
  String get saveToLibraryTooltip;

  /// No description provided for @templateByAuthor.
  ///
  /// In en, this message translates to:
  /// **'by @{name}'**
  String templateByAuthor(String name);

  /// No description provided for @officialVerifiedTemplate.
  ///
  /// In en, this message translates to:
  /// **'Official verified template'**
  String get officialVerifiedTemplate;

  /// No description provided for @dataStructureFieldsUpper.
  ///
  /// In en, this message translates to:
  /// **'DATA STRUCTURE ({count} FIELDS)'**
  String dataStructureFieldsUpper(int count);

  /// No description provided for @installInMyInventoryUpper.
  ///
  /// In en, this message translates to:
  /// **'INSTALL IN MY INVENTORY'**
  String get installInMyInventoryUpper;

  /// No description provided for @addedToPersonalLibrary.
  ///
  /// In en, this message translates to:
  /// **'Added to your personal library'**
  String get addedToPersonalLibrary;

  /// No description provided for @whereDoYouWantToInstall.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to install it?'**
  String get whereDoYouWantToInstall;

  /// No description provided for @noContainersCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'You have no containers. Create one first.'**
  String get noContainersCreateFirst;

  /// No description provided for @autoGeneratedListFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Auto-generated list from template'**
  String get autoGeneratedListFromTemplate;

  /// No description provided for @installationSuccessAutoLists.
  ///
  /// In en, this message translates to:
  /// **'Installation successful. Lists configured automatically.'**
  String get installationSuccessAutoLists;

  /// No description provided for @errorInstallingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Error installing: {error}'**
  String errorInstallingTemplate(String error);

  /// No description provided for @publishTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'Publish template'**
  String get publishTemplateLabel;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @noTemplatesFoundInMarket.
  ///
  /// In en, this message translates to:
  /// **'No templates were found in the market.'**
  String get noTemplatesFoundInMarket;

  /// No description provided for @invenicumCommunity.
  ///
  /// In en, this message translates to:
  /// **'Invenicum Community'**
  String get invenicumCommunity;

  /// No description provided for @refreshMarketTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh market'**
  String get refreshMarketTooltip;

  /// No description provided for @exploreCommunityConfigurations.
  ///
  /// In en, this message translates to:
  /// **'Explore and download community configurations'**
  String get exploreCommunityConfigurations;

  /// No description provided for @searchByTemplateName.
  ///
  /// In en, this message translates to:
  /// **'Search by template name...'**
  String get searchByTemplateName;

  /// No description provided for @filterByTagTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter by tag'**
  String get filterByTagTooltip;

  /// No description provided for @noMoreTags.
  ///
  /// In en, this message translates to:
  /// **'No more tags'**
  String get noMoreTags;

  /// No description provided for @confirmDeleteDataList.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete list \"{name}\"? This action is irreversible.'**
  String confirmDeleteDataList(String name);

  /// No description provided for @dataListDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'List \"{name}\" deleted successfully.'**
  String dataListDeletedSuccess(String name);

  /// No description provided for @errorDeletingDataList.
  ///
  /// In en, this message translates to:
  /// **'Error deleting list: {error}'**
  String errorDeletingDataList(String error);

  /// No description provided for @customListsWithContainer.
  ///
  /// In en, this message translates to:
  /// **'Custom lists - {name}'**
  String customListsWithContainer(String name);

  /// No description provided for @newDataListLabel.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newDataListLabel;

  /// No description provided for @noCustomListsCreateOne.
  ///
  /// In en, this message translates to:
  /// **'There are no custom lists. Create a new one.'**
  String get noCustomListsCreateOne;

  /// No description provided for @elementsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} elements'**
  String elementsCount(int count);

  /// No description provided for @dataListNeedsAtLeastOneElement.
  ///
  /// In en, this message translates to:
  /// **'The list must have at least one element'**
  String get dataListNeedsAtLeastOneElement;

  /// No description provided for @customDataListCreated.
  ///
  /// In en, this message translates to:
  /// **'Custom list created successfully'**
  String get customDataListCreated;

  /// No description provided for @errorCreatingDataList.
  ///
  /// In en, this message translates to:
  /// **'Error creating list: {error}'**
  String errorCreatingDataList(String error);

  /// No description provided for @newCustomDataListTitle.
  ///
  /// In en, this message translates to:
  /// **'New custom list'**
  String get newCustomDataListTitle;

  /// No description provided for @dataListNameLabel.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get dataListNameLabel;

  /// No description provided for @pleaseEnterAName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterAName;

  /// No description provided for @dataListElementsTitle.
  ///
  /// In en, this message translates to:
  /// **'List elements'**
  String get dataListElementsTitle;

  /// No description provided for @newElementLabel.
  ///
  /// In en, this message translates to:
  /// **'New element'**
  String get newElementLabel;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @addElementsToListHint.
  ///
  /// In en, this message translates to:
  /// **'Add elements to the list'**
  String get addElementsToListHint;

  /// No description provided for @saveListLabel.
  ///
  /// In en, this message translates to:
  /// **'Save list'**
  String get saveListLabel;

  /// No description provided for @dataListUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'List updated successfully'**
  String get dataListUpdatedSuccessfully;

  /// No description provided for @errorUpdatingDataList.
  ///
  /// In en, this message translates to:
  /// **'Error updating list: {error}'**
  String errorUpdatingDataList(String error);

  /// No description provided for @editListWithName.
  ///
  /// In en, this message translates to:
  /// **'Edit list: {name}'**
  String editListWithName(String name);

  /// No description provided for @createNewLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Location'**
  String get createNewLocationTitle;

  /// No description provided for @locationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get locationNameLabel;

  /// No description provided for @locationNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Shelf B3, Server Room'**
  String get locationNameHint;

  /// No description provided for @locationDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Access details, content type, etc.'**
  String get locationDescriptionHint;

  /// No description provided for @parentLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent Location (Contains this one)'**
  String get parentLocationLabel;

  /// No description provided for @noParentRootLocation.
  ///
  /// In en, this message translates to:
  /// **'No parent (Root Location)'**
  String get noParentRootLocation;

  /// No description provided for @noneRootScheme.
  ///
  /// In en, this message translates to:
  /// **'None (Scheme Root)'**
  String get noneRootScheme;

  /// No description provided for @savingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingLabel;

  /// No description provided for @saveLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get saveLocationLabel;

  /// No description provided for @locationCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Location \"{name}\" created successfully.'**
  String locationCreatedSuccessfully(String name);

  /// No description provided for @errorCreatingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error creating location: {error}'**
  String errorCreatingLocation(String error);

  /// No description provided for @locationCannotBeItsOwnParent.
  ///
  /// In en, this message translates to:
  /// **'A location cannot be its own parent.'**
  String get locationCannotBeItsOwnParent;

  /// No description provided for @locationUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Location \"{name}\" updated.'**
  String locationUpdatedSuccessfully(String name);

  /// No description provided for @errorUpdatingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error updating location: {error}'**
  String errorUpdatingLocation(String error);

  /// No description provided for @editLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit: {name}'**
  String editLocationTitle(String name);

  /// No description provided for @updateLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get updateLocationLabel;

  /// No description provided for @selectObjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Object'**
  String get selectObjectTitle;

  /// No description provided for @noObjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No objects available'**
  String get noObjectsAvailable;

  /// No description provided for @availableQuantity.
  ///
  /// In en, this message translates to:
  /// **'Available: {quantity}'**
  String availableQuantity(int quantity);

  /// No description provided for @errorSelectingObject.
  ///
  /// In en, this message translates to:
  /// **'Error selecting object: {error}'**
  String errorSelectingObject(String error);

  /// No description provided for @mustSelectAnObject.
  ///
  /// In en, this message translates to:
  /// **'You must select an object'**
  String get mustSelectAnObject;

  /// No description provided for @loanRegisteredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Loan registered successfully'**
  String get loanRegisteredSuccessfully;

  /// No description provided for @selectAnObject.
  ///
  /// In en, this message translates to:
  /// **'Select an object'**
  String get selectAnObject;

  /// No description provided for @selectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectLabel;

  /// No description provided for @borrowerNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: John Doe'**
  String get borrowerNameHint;

  /// No description provided for @borrowerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get borrowerNameRequired;

  /// No description provided for @loanQuantityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Quantity to loan (Available: {quantity})'**
  String loanQuantityAvailable(int quantity);

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity'**
  String get enterQuantity;

  /// No description provided for @invalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Invalid quantity'**
  String get invalidQuantity;

  /// No description provided for @notEnoughStock.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock'**
  String get notEnoughStock;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @expectedReturnDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected return: {date}'**
  String expectedReturnDateLabel(String date);

  /// No description provided for @selectReturnDate.
  ///
  /// In en, this message translates to:
  /// **'Select return date'**
  String get selectReturnDate;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @registerLoanLabel.
  ///
  /// In en, this message translates to:
  /// **'Register Loan'**
  String get registerLoanLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @newLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'New location'**
  String get newLocationLabel;

  /// No description provided for @newLocationHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Shelf A1, Cabinet 3...'**
  String get newLocationHint;

  /// No description provided for @parentLocationOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent location (optional)'**
  String get parentLocationOptionalLabel;

  /// No description provided for @noneRootLabel.
  ///
  /// In en, this message translates to:
  /// **'None (root)'**
  String get noneRootLabel;

  /// No description provided for @locationCreatedShort.
  ///
  /// In en, this message translates to:
  /// **'Location \"{name}\" created'**
  String locationCreatedShort(String name);

  /// No description provided for @newLocationEllipsis.
  ///
  /// In en, this message translates to:
  /// **'New location...'**
  String get newLocationEllipsis;

  /// No description provided for @couldNotReloadList.
  ///
  /// In en, this message translates to:
  /// **'Could not reload the list'**
  String get couldNotReloadList;

  /// No description provided for @deleteAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Asset'**
  String get deleteAssetTitle;

  /// No description provided for @confirmDeleteAssetItem.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm deleting \"{name}\"?'**
  String confirmDeleteAssetItem(String name);

  /// No description provided for @assetDeletedShort.
  ///
  /// In en, this message translates to:
  /// **'Asset deleted.'**
  String get assetDeletedShort;

  /// No description provided for @viewColumnsLabel.
  ///
  /// In en, this message translates to:
  /// **'View: {count} col.'**
  String viewColumnsLabel(int count);

  /// No description provided for @notValuedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not valued'**
  String get notValuedLabel;

  /// No description provided for @manageSearchSyncAssets.
  ///
  /// In en, this message translates to:
  /// **'Manage, search and sync your assets from a single panel.'**
  String get manageSearchSyncAssets;

  /// No description provided for @filterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterLabel;

  /// No description provided for @activeFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Active filter'**
  String get activeFilterLabel;

  /// No description provided for @importLabel.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importLabel;

  /// No description provided for @exportLabel.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportLabel;

  /// No description provided for @csvExportNoData.
  ///
  /// In en, this message translates to:
  /// **'There are no items to export.'**
  String get csvExportNoData;

  /// No description provided for @csvExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'CSV exported successfully ({count} items).'**
  String csvExportSuccess(int count);

  /// No description provided for @csvExportError.
  ///
  /// In en, this message translates to:
  /// **'Could not export CSV'**
  String get csvExportError;

  /// No description provided for @syncLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync prices'**
  String get syncLabel;

  /// No description provided for @syncingLabel.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncingLabel;

  /// No description provided for @newAssetLabel.
  ///
  /// In en, this message translates to:
  /// **'New asset'**
  String get newAssetLabel;

  /// No description provided for @statusAndPreferences.
  ///
  /// In en, this message translates to:
  /// **'Status and Preferences'**
  String get statusAndPreferences;

  /// No description provided for @itemStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Item status'**
  String get itemStatusLabel;

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableLabel;

  /// No description provided for @mustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0.'**
  String get mustBeGreaterThanZero;

  /// No description provided for @alertThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Alert threshold'**
  String get alertThresholdLabel;

  /// No description provided for @enterMinimumStock.
  ///
  /// In en, this message translates to:
  /// **'Enter a minimum stock'**
  String get enterMinimumStock;

  /// No description provided for @serializedItemFixedQuantity.
  ///
  /// In en, this message translates to:
  /// **'This is a serialized item. Quantity is fixed at 1.'**
  String get serializedItemFixedQuantity;

  /// No description provided for @serialNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Serial number'**
  String get serialNumberLabel;

  /// No description provided for @serialNumberHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: SN-2024-00123'**
  String get serialNumberHint;

  /// No description provided for @mainDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Main Data'**
  String get mainDataTitle;

  /// No description provided for @currentMarketValueLabel.
  ///
  /// In en, this message translates to:
  /// **'CURRENT MARKET VALUE'**
  String get currentMarketValueLabel;

  /// No description provided for @updatePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Update Price'**
  String get updatePriceLabel;

  /// No description provided for @viewLabel.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewLabel;

  /// No description provided for @visualGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual Gallery'**
  String get visualGalleryTitle;

  /// No description provided for @statusAndMarketTitle.
  ///
  /// In en, this message translates to:
  /// **'Status and Market'**
  String get statusAndMarketTitle;

  /// No description provided for @valuationHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Valuation History'**
  String get valuationHistoryTitle;

  /// No description provided for @specificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specificationsTitle;

  /// No description provided for @traceabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Traceability'**
  String get traceabilityTitle;

  /// No description provided for @stockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockLabel;

  /// No description provided for @internalReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Internal Reference'**
  String get internalReferenceLabel;

  /// No description provided for @noSpecificationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No specifications available'**
  String get noSpecificationsAvailable;

  /// No description provided for @trueLabel.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get trueLabel;

  /// No description provided for @falseLabel.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get falseLabel;

  /// No description provided for @openLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openLinkLabel;

  /// No description provided for @scannerFocusTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: If it does not focus, move the product about 30 cm away from the camera.'**
  String get scannerFocusTip;

  /// No description provided for @scanCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Code'**
  String get scanCodeTitle;

  /// No description provided for @scanOrEnterProductCode.
  ///
  /// In en, this message translates to:
  /// **'Scan or enter the product code'**
  String get scanOrEnterProductCode;

  /// No description provided for @possessionProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress of {name}'**
  String possessionProgressLabel(String name);

  /// No description provided for @externalImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from External Source'**
  String get externalImportTitle;

  /// No description provided for @galleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryTitle;

  /// No description provided for @stockAndCodingTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock and Coding'**
  String get stockAndCodingTitle;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan'**
  String get cameraPermissionRequired;

  /// No description provided for @cloudDataFound.
  ///
  /// In en, this message translates to:
  /// **'Data found in the cloud!'**
  String get cloudDataFound;

  /// No description provided for @typeSomethingToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type something to search'**
  String get typeSomethingToSearch;

  /// No description provided for @importCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled.'**
  String get importCancelled;

  /// No description provided for @couldNotCompleteImport.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the import'**
  String get couldNotCompleteImport;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorLabel;

  /// No description provided for @selectResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a result'**
  String get selectResultTitle;

  /// No description provided for @unnamedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get unnamedLabel;

  /// No description provided for @completeRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete the required fields.'**
  String get completeRequiredFields;

  /// No description provided for @assetCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Asset created!'**
  String get assetCreatedSuccess;

  /// No description provided for @errorCreatingAsset.
  ///
  /// In en, this message translates to:
  /// **'Error creating asset: {error}'**
  String errorCreatingAsset(String error);

  /// No description provided for @technicalDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Technical Details'**
  String get technicalDetailsTitle;

  /// No description provided for @itemImportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{name} imported successfully!'**
  String itemImportedSuccessfully(String name);

  /// No description provided for @newImagesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} new images were selected.'**
  String newImagesSelected(int count);

  /// No description provided for @newFileRemoved.
  ///
  /// In en, this message translates to:
  /// **'New file removed.'**
  String get newFileRemoved;

  /// No description provided for @imageMarkedForDeletion.
  ///
  /// In en, this message translates to:
  /// **'Image marked for deletion when saving.'**
  String get imageMarkedForDeletion;

  /// No description provided for @couldNotIdentifyImage.
  ///
  /// In en, this message translates to:
  /// **'Could not identify the image.'**
  String get couldNotIdentifyImage;

  /// No description provided for @editAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit: {name}'**
  String editAssetTitle(String name);

  /// No description provided for @syncPricesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync prices'**
  String get syncPricesTitle;

  /// No description provided for @syncPricesDescription.
  ///
  /// In en, this message translates to:
  /// **'The API will be queried to update the market value.'**
  String get syncPricesDescription;

  /// No description provided for @syncingMarketPrices.
  ///
  /// In en, this message translates to:
  /// **'Syncing market prices...'**
  String get syncingMarketPrices;

  /// No description provided for @couldNotSyncPrices.
  ///
  /// In en, this message translates to:
  /// **'Could not sync prices'**
  String get couldNotSyncPrices;

  /// No description provided for @syncCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Synchronization completed'**
  String get syncCompletedTitle;

  /// No description provided for @updatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedLabel;

  /// No description provided for @noApiPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'No price in API'**
  String get noApiPriceLabel;

  /// No description provided for @errorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get errorsLabel;

  /// No description provided for @totalProcessedLabel.
  ///
  /// In en, this message translates to:
  /// **'Total processed'**
  String get totalProcessedLabel;

  /// No description provided for @noAssetsToShow.
  ///
  /// In en, this message translates to:
  /// **'No assets to display'**
  String get noAssetsToShow;

  /// No description provided for @noImageLabel.
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get noImageLabel;

  /// No description provided for @aiMagicQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you have a link?'**
  String get aiMagicQuestion;

  /// No description provided for @aiAutocompleteAsset.
  ///
  /// In en, this message translates to:
  /// **'Autocomplete this asset with AI'**
  String get aiAutocompleteAsset;

  /// No description provided for @magicLabel.
  ///
  /// In en, this message translates to:
  /// **'MAGIC'**
  String get magicLabel;

  /// No description provided for @skuBarcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'SKU / EAN / UPC'**
  String get skuBarcodeLabel;

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

  /// No description provided for @generalSettingsMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettingsMenuLabel;

  /// No description provided for @aiAssistantMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistantMenuLabel;

  /// No description provided for @notificationsMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsMenuLabel;

  /// No description provided for @loanManagementMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Loan Management'**
  String get loanManagementMenuLabel;

  /// No description provided for @aboutMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutMenuLabel;

  /// No description provided for @automaticDarkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Automatic dark mode'**
  String get automaticDarkModeLabel;

  /// No description provided for @syncWithSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync with system'**
  String get syncWithSystemLabel;

  /// No description provided for @manualDarkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Manual dark mode'**
  String get manualDarkModeLabel;

  /// No description provided for @disableAutomaticToChange.
  ///
  /// In en, this message translates to:
  /// **'Disable automatic mode to change it'**
  String get disableAutomaticToChange;

  /// No description provided for @changeLightDark.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark'**
  String get changeLightDark;

  /// No description provided for @enableAiAndChatbot.
  ///
  /// In en, this message translates to:
  /// **'Enable Artificial Intelligence and Chatbot'**
  String get enableAiAndChatbot;

  /// No description provided for @requiresGeminiLinking.
  ///
  /// In en, this message translates to:
  /// **'Requires linking with Gemini in Integrations'**
  String get requiresGeminiLinking;

  /// No description provided for @aiOrganizeInventory.
  ///
  /// In en, this message translates to:
  /// **'Use AI to organize your inventory intelligently'**
  String get aiOrganizeInventory;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Artificial Intelligence Assistant'**
  String get aiAssistantTitle;

  /// No description provided for @selectAiProvider.
  ///
  /// In en, this message translates to:
  /// **'Choose which AI provider Veni will use. Make sure you have the API Key configured in Integrations.'**
  String get selectAiProvider;

  /// No description provided for @aiProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get aiProviderLabel;

  /// No description provided for @aiModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get aiModelLabel;

  /// No description provided for @aiProviderUpdated.
  ///
  /// In en, this message translates to:
  /// **'AI Provider updated'**
  String get aiProviderUpdated;

  /// No description provided for @purgeChatHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat history'**
  String get purgeChatHistoryTitle;

  /// No description provided for @purgeChatHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all saved Veni conversation history.'**
  String get purgeChatHistoryDescription;

  /// No description provided for @purgeChatHistoryButton.
  ///
  /// In en, this message translates to:
  /// **'Purge history'**
  String get purgeChatHistoryButton;

  /// No description provided for @purgeChatHistoryConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Purge chat history?'**
  String get purgeChatHistoryConfirmTitle;

  /// No description provided for @purgeChatHistoryConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action will delete all saved messages and cannot be undone.'**
  String get purgeChatHistoryConfirmMessage;

  /// No description provided for @purgeChatHistoryConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Yes, purge'**
  String get purgeChatHistoryConfirmAction;

  /// No description provided for @purgeChatHistorySuccess.
  ///
  /// In en, this message translates to:
  /// **'Chat history deleted successfully.'**
  String get purgeChatHistorySuccess;

  /// No description provided for @purgeChatHistoryError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete chat history.'**
  String get purgeChatHistoryError;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Management'**
  String get notificationSettingsTitle;

  /// No description provided for @channelPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Channel Priority (Drag to reorder)'**
  String get channelPriorityLabel;

  /// No description provided for @telegramBotLabel.
  ///
  /// In en, this message translates to:
  /// **'Telegram Bot'**
  String get telegramBotLabel;

  /// No description provided for @resendEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmailLabel;

  /// No description provided for @lowStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStockLabel;

  /// No description provided for @lowStockHint.
  ///
  /// In en, this message translates to:
  /// **'Alert when a product falls below the minimum.'**
  String get lowStockHint;

  /// No description provided for @newPresalesLabel.
  ///
  /// In en, this message translates to:
  /// **'New Pre-sales'**
  String get newPresalesLabel;

  /// No description provided for @newPresalesHint.
  ///
  /// In en, this message translates to:
  /// **'Notify launches detected by AI.'**
  String get newPresalesHint;

  /// No description provided for @loanReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Loan Reminder'**
  String get loanReminderLabel;

  /// No description provided for @loanReminderHint.
  ///
  /// In en, this message translates to:
  /// **'Alert before the return date.'**
  String get loanReminderHint;

  /// No description provided for @overdueLoansLabel.
  ///
  /// In en, this message translates to:
  /// **'Overdue Loans'**
  String get overdueLoansLabel;

  /// No description provided for @overdueLoansHint.
  ///
  /// In en, this message translates to:
  /// **'Critical alert if an object is not returned on time.'**
  String get overdueLoansHint;

  /// No description provided for @maintenanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenanceLabel;

  /// No description provided for @maintenanceHint.
  ///
  /// In en, this message translates to:
  /// **'Alert when an asset needs review.'**
  String get maintenanceHint;

  /// No description provided for @priceChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Price Changes'**
  String get priceChangeLabel;

  /// No description provided for @priceChangeHint.
  ///
  /// In en, this message translates to:
  /// **'Notify market value variations.'**
  String get priceChangeHint;

  /// No description provided for @unlinkGithubTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect GitHub'**
  String get unlinkGithubTitle;

  /// No description provided for @unlinkGithubMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlink your GitHub account?'**
  String get unlinkGithubMessage;

  /// No description provided for @updatePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'UPDATE PASSWORD'**
  String get updatePasswordButton;

  /// No description provided for @profileFillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get profileFillAllFieldsError;

  /// No description provided for @profilePasswordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get profilePasswordUpdatedSuccess;

  /// No description provided for @profileDisconnectActionUpper.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECT'**
  String get profileDisconnectActionUpper;

  /// No description provided for @profileGithubUnlinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'GitHub account unlinked successfully'**
  String get profileGithubUnlinkedSuccess;

  /// No description provided for @profileGithubLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'GitHub account linked successfully!'**
  String get profileGithubLinkedSuccess;

  /// No description provided for @profileGithubProcessError.
  ///
  /// In en, this message translates to:
  /// **'Error processing GitHub link: {error}'**
  String profileGithubProcessError(String error);

  /// No description provided for @profileGithubConfigUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Error: GitHub configuration not available'**
  String get profileGithubConfigUnavailableError;

  /// No description provided for @profileServerConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server: {error}'**
  String profileServerConnectionError(String error);

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {error}'**
  String profileUpdateError(String error);

  /// No description provided for @profileUsernameCommunityLabel.
  ///
  /// In en, this message translates to:
  /// **'Username (Community)'**
  String get profileUsernameCommunityLabel;

  /// No description provided for @profileUsernameCommunityHelper.
  ///
  /// In en, this message translates to:
  /// **'Required to publish plugins.'**
  String get profileUsernameCommunityHelper;

  /// No description provided for @profileUpdateButtonUpper.
  ///
  /// In en, this message translates to:
  /// **'UPDATE PROFILE'**
  String get profileUpdateButtonUpper;

  /// No description provided for @profileGithubIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'GitHub Identity'**
  String get profileGithubIdentityTitle;

  /// No description provided for @profileGithubLinkedAs.
  ///
  /// In en, this message translates to:
  /// **'Linked as @{username}'**
  String profileGithubLinkedAs(String username);

  /// No description provided for @profileGithubLinkPrompt.
  ///
  /// In en, this message translates to:
  /// **'Link your account to publish plugins'**
  String get profileGithubLinkPrompt;

  /// No description provided for @profileGithubUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Your GitHub username'**
  String get profileGithubUsernameHint;

  /// No description provided for @profileGithubFieldHint.
  ///
  /// In en, this message translates to:
  /// **'This field is filled automatically after authenticating with GitHub.'**
  String get profileGithubFieldHint;

  /// No description provided for @profileGithubDefaultMissingKeys.
  ///
  /// In en, this message translates to:
  /// **'GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET'**
  String get profileGithubDefaultMissingKeys;

  /// No description provided for @profileGithubOAuthNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'GitHub OAuth not configured. Missing: {missing}. Set GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET in the backend and restart the server.'**
  String profileGithubOAuthNotConfigured(String missing);

  /// No description provided for @profileDisconnectGithubButton.
  ///
  /// In en, this message translates to:
  /// **'Disconnect GitHub'**
  String get profileDisconnectGithubButton;

  /// No description provided for @profileLinkGithubButton.
  ///
  /// In en, this message translates to:
  /// **'Link with GitHub'**
  String get profileLinkGithubButton;

  /// No description provided for @profileSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecurityTitle;

  /// No description provided for @profileChangeUpper.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get profileChangeUpper;

  /// No description provided for @profileCurrentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get profileCurrentPasswordLabel;

  /// No description provided for @profileNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get profileNewPasswordLabel;

  /// No description provided for @profileConfirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get profileConfirmNewPasswordLabel;

  /// No description provided for @profileChangePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Change your password periodically to keep your account secure.'**
  String get profileChangePasswordHint;

  /// No description provided for @newContainerDialog.
  ///
  /// In en, this message translates to:
  /// **'New Container'**
  String get newContainerDialog;

  /// No description provided for @descriptionField.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionField;

  /// No description provided for @isCollectionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is it a collection?'**
  String get isCollectionQuestion;

  /// No description provided for @createContainerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Container'**
  String get createContainerButton;

  /// No description provided for @selectContainerHint.
  ///
  /// In en, this message translates to:
  /// **'Select a container'**
  String get selectContainerHint;

  /// No description provided for @newAssetTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'New Asset Type'**
  String get newAssetTypeTitle;

  /// No description provided for @generalConfiguration.
  ///
  /// In en, this message translates to:
  /// **'General Configuration'**
  String get generalConfiguration;

  /// No description provided for @collectionContainerWarning.
  ///
  /// In en, this message translates to:
  /// **'This container is a collection. You can create serialized or non-serialized types, but possession and desired fields can only be configured on non-serialized types.'**
  String get collectionContainerWarning;

  /// No description provided for @createAssetTypeButton.
  ///
  /// In en, this message translates to:
  /// **'Create Asset Type'**
  String get createAssetTypeButton;

  /// No description provided for @assetTypesInContainer.
  ///
  /// In en, this message translates to:
  /// **'Asset Types in \"{name}\"'**
  String assetTypesInContainer(String name);

  /// No description provided for @createNewTypeButton.
  ///
  /// In en, this message translates to:
  /// **'Create New Type'**
  String get createNewTypeButton;

  /// No description provided for @isSerializedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is it a serialized item?'**
  String get isSerializedQuestion;

  /// No description provided for @addNewFieldButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Field'**
  String get addNewFieldButton;

  /// No description provided for @deleteFieldTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete field'**
  String get deleteFieldTooltip;

  /// No description provided for @fieldsOptions.
  ///
  /// In en, this message translates to:
  /// **'Options:'**
  String get fieldsOptions;

  /// No description provided for @isRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Is Required'**
  String get isRequiredField;

  /// No description provided for @isSummativeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Is Summative (Added to type total)'**
  String get isSummativeFieldLabel;

  /// No description provided for @isMonetaryValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Is Monetary Value'**
  String get isMonetaryValueLabel;

  /// No description provided for @monetaryValueDescription.
  ///
  /// In en, this message translates to:
  /// **'Will be used to calculate total investment in Dashboard'**
  String get monetaryValueDescription;

  /// No description provided for @noDataListsAvailable.
  ///
  /// In en, this message translates to:
  /// **'⚠️ No data lists available in this container.'**
  String get noDataListsAvailable;

  /// No description provided for @selectDataList.
  ///
  /// In en, this message translates to:
  /// **'Select Data List'**
  String get selectDataList;

  /// No description provided for @chooseList.
  ///
  /// In en, this message translates to:
  /// **'Choose a list'**
  String get chooseList;

  /// No description provided for @goToPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Go to page:'**
  String get goToPageLabel;

  /// No description provided for @conditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionLabel;

  /// No description provided for @actionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsLabel;

  /// No description provided for @editButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButtonLabel;

  /// No description provided for @deleteButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonLabel;

  /// No description provided for @printLabel.
  ///
  /// In en, this message translates to:
  /// **'debugPrint label'**
  String get printLabel;

  /// No description provided for @collectionFieldsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collection Fields'**
  String get collectionFieldsTooltip;

  /// No description provided for @totalLocations.
  ///
  /// In en, this message translates to:
  /// **'{count} locations'**
  String totalLocations(int count);

  /// No description provided for @withoutLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} without location · '**
  String withoutLocationLabel(int count);

  /// No description provided for @objectIdColumn.
  ///
  /// In en, this message translates to:
  /// **'Object ID'**
  String get objectIdColumn;

  /// No description provided for @containerNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Container with ID {id} not found.'**
  String containerNotFoundError(String id);

  /// No description provided for @invalidContainerIdError.
  ///
  /// In en, this message translates to:
  /// **'Error: Invalid container ID.'**
  String get invalidContainerIdError;

  /// No description provided for @startConfigurationButton.
  ///
  /// In en, this message translates to:
  /// **'Start configuration'**
  String get startConfigurationButton;

  /// No description provided for @fullNameField.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameField;

  /// No description provided for @emailField.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailField;

  /// No description provided for @passwordField.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordField;

  /// No description provided for @confirmPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordField;

  /// No description provided for @goBackButton.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBackButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountButton;

  /// No description provided for @goToLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLoginButton;

  /// No description provided for @deleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get deleteConfirmationTitle;

  /// No description provided for @deleteItemMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you wish to delete \"{name}\"?'**
  String deleteItemMessage(String name);

  /// No description provided for @elementDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Element deleted successfully'**
  String get elementDeletedSuccess;

  /// No description provided for @enterYourNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get enterYourNameValidation;

  /// No description provided for @minTwoCharactersValidation.
  ///
  /// In en, this message translates to:
  /// **'Minimum 2 characters.'**
  String get minTwoCharactersValidation;

  /// No description provided for @enterEmailValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter an email.'**
  String get enterEmailValidation;

  /// No description provided for @invalidEmailValidation.
  ///
  /// In en, this message translates to:
  /// **'Invalid email.'**
  String get invalidEmailValidation;

  /// No description provided for @enterPasswordValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a password.'**
  String get enterPasswordValidation;

  /// No description provided for @minEightCharactersValidation.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters.'**
  String get minEightCharactersValidation;

  /// No description provided for @threeDbuttonLabel.
  ///
  /// In en, this message translates to:
  /// **'3D'**
  String get threeDbuttonLabel;

  /// No description provided for @barcodeCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String barcodeCount(String count);

  /// No description provided for @rotationSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String rotationSpeedLabel(String count);

  /// No description provided for @tagLabel.
  ///
  /// In en, this message translates to:
  /// **'#{tag}'**
  String tagLabel(String tag);

  /// No description provided for @invalidIdError.
  ///
  /// In en, this message translates to:
  /// **'Invalid ID'**
  String get invalidIdError;

  /// No description provided for @assetTypeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String assetTypeLoadError(String error);

  /// No description provided for @assetTypeUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Asset type updated successfully'**
  String get assetTypeUpdateSuccess;

  /// No description provided for @assetTypeUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating: {error}'**
  String assetTypeUpdateError(String error);

  /// No description provided for @editAssetTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit: {name}'**
  String editAssetTypeTitle(String name);

  /// Title for achievement collection section
  ///
  /// In en, this message translates to:
  /// **'Achievement Collection'**
  String get achievementCollectionTitle;

  /// Subtitle for achievements screen
  ///
  /// In en, this message translates to:
  /// **'Unlock milestones using Invenicum'**
  String get achievementSubtitle;

  /// Label for legendary achievements
  ///
  /// In en, this message translates to:
  /// **'LEGENDARY ACHIEVEMENT'**
  String get legendaryAchievementLabel;

  /// Status label for completed achievements
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get achievementCompleted;

  /// Status label for locked achievements
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get achievementLocked;

  /// Shows the date when achievement was unlocked
  ///
  /// In en, this message translates to:
  /// **'Unlocked on {date}'**
  String achievementUnlockedDate(String date);

  /// Message explaining how to unlock an achievement
  ///
  /// In en, this message translates to:
  /// **'Fulfill the objective to unlock'**
  String get achievementLockedMessage;

  /// Label for close button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get closeButtonLabel;

  /// No description provided for @configurationGeneralSection.
  ///
  /// In en, this message translates to:
  /// **'General Configuration'**
  String get configurationGeneralSection;

  /// No description provided for @assetTypeCollectionWarning.
  ///
  /// In en, this message translates to:
  /// **'This container is a collection. You can create serialized or non-serialized types, but possession and desired fields can only be configured in non-serialized types.'**
  String get assetTypeCollectionWarning;

  /// No description provided for @updateAssetTypeButton.
  ///
  /// In en, this message translates to:
  /// **'Update Asset Type'**
  String get updateAssetTypeButton;

  /// No description provided for @createAssetTypeButtonDefault.
  ///
  /// In en, this message translates to:
  /// **'Create Asset Type'**
  String get createAssetTypeButtonDefault;

  /// No description provided for @noAssetTypesMessage.
  ///
  /// In en, this message translates to:
  /// **'No Asset Types defined yet in this container.'**
  String get noAssetTypesMessage;

  /// No description provided for @totalCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {count}'**
  String totalCountLabel(int count);

  /// No description provided for @possessionCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Owned: {count}'**
  String possessionCountLabel(int count);

  /// No description provided for @desiredCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Desired: {count}'**
  String desiredCountLabel(int count);

  /// No description provided for @marketValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Market: '**
  String get marketValueLabel;

  /// No description provided for @defaultSumFieldName.
  ///
  /// In en, this message translates to:
  /// **'Sum'**
  String get defaultSumFieldName;

  /// No description provided for @calculatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculatingLabel;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @noNameItem.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get noNameItem;

  /// No description provided for @loadingContainers.
  ///
  /// In en, this message translates to:
  /// **'Loading containers...'**
  String get loadingContainers;

  /// No description provided for @fieldNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Field name is required'**
  String get fieldNameRequired;

  /// No description provided for @selectImageButton.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImageButton;

  /// No description provided for @assetTypeDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String assetTypeDeletedSuccess(String name);

  /// No description provided for @noLocationValueData.
  ///
  /// In en, this message translates to:
  /// **'No assets with location and sufficient value yet to display this chart.'**
  String get noLocationValueData;

  /// No description provided for @requiredFieldValidation.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredFieldValidation;

  /// No description provided for @oceanTheme.
  ///
  /// In en, this message translates to:
  /// **'Indian Ocean'**
  String get oceanTheme;

  /// No description provided for @cherryBlossomTheme.
  ///
  /// In en, this message translates to:
  /// **'Cherry Blossom'**
  String get cherryBlossomTheme;

  /// No description provided for @themeBrand.
  ///
  /// In en, this message translates to:
  /// **'Invenicum (Brand)'**
  String get themeBrand;

  /// No description provided for @themeEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get themeEmerald;

  /// No description provided for @themeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get themeSunset;

  /// No description provided for @themeLavender.
  ///
  /// In en, this message translates to:
  /// **'Soft Lavender'**
  String get themeLavender;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Deep Forest'**
  String get themeForest;

  /// No description provided for @themeCherry.
  ///
  /// In en, this message translates to:
  /// **'Cherry'**
  String get themeCherry;

  /// No description provided for @themeElectricNight.
  ///
  /// In en, this message translates to:
  /// **'Electric Night'**
  String get themeElectricNight;

  /// No description provided for @themeAmberGold.
  ///
  /// In en, this message translates to:
  /// **'Amber Gold'**
  String get themeAmberGold;

  /// No description provided for @themeModernSlate.
  ///
  /// In en, this message translates to:
  /// **'Modern Slate'**
  String get themeModernSlate;

  /// No description provided for @themeCyberpunk.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk'**
  String get themeCyberpunk;

  /// No description provided for @themeNordicArctic.
  ///
  /// In en, this message translates to:
  /// **'Nordic Arctic'**
  String get themeNordicArctic;

  /// No description provided for @themeDeepNight.
  ///
  /// In en, this message translates to:
  /// **'Deep Night'**
  String get themeDeepNight;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @reloadListError.
  ///
  /// In en, this message translates to:
  /// **'Failed to reload the list'**
  String get reloadListError;

  /// No description provided for @copyItemSuffix.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyItemSuffix;

  /// No description provided for @itemCopiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item copied: {name}'**
  String itemCopiedSuccess(String name);

  /// No description provided for @copyError.
  ///
  /// In en, this message translates to:
  /// **'Error copying item'**
  String get copyError;

  /// No description provided for @imageColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageColumnLabel;

  /// No description provided for @viewImageTooltip.
  ///
  /// In en, this message translates to:
  /// **'View image'**
  String get viewImageTooltip;

  /// No description provided for @currentStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStockLabel;

  /// No description provided for @minimumStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Stock'**
  String get minimumStockLabel;

  /// No description provided for @locationColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationColumnLabel;

  /// No description provided for @serialNumberColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get serialNumberColumnLabel;

  /// No description provided for @marketPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Market Price'**
  String get marketPriceLabel;

  /// No description provided for @conditionColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionColumnLabel;

  /// No description provided for @actionsColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsColumnLabel;

  /// No description provided for @imageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get imageLoadError;

  /// No description provided for @imageUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Make sure the URL is correct and the server is active'**
  String get imageUrlHint;

  /// No description provided for @assetTypeNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: Laptop, Chemical Substance'**
  String get assetTypeNameHint;

  /// No description provided for @assetTypeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Asset Type Name'**
  String get assetTypeNameLabel;

  /// No description provided for @underConstruction.
  ///
  /// In en, this message translates to:
  /// **'Under Construction'**
  String get underConstruction;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @constructionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This feature is being developed'**
  String get constructionSubtitle;

  /// Label for color selection button or dialog
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// Title for value distribution widget by location
  ///
  /// In en, this message translates to:
  /// **'Value Distribution by Location'**
  String get valueDistributionByLocation;

  /// Description of heatmap widget
  ///
  /// In en, this message translates to:
  /// **'The donut shows how the market value is distributed among the highest-weight locations.'**
  String get heatmapDescription;

  /// Label for number of locations
  ///
  /// In en, this message translates to:
  /// **'{count} locations'**
  String locationsCount(int count);

  /// Label for units
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get unitsLabel;

  /// Label for records
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get recordsLabel;

  /// Fallback label for total value
  ///
  /// In en, this message translates to:
  /// **'Total value'**
  String get totalValueFallback;

  /// Fallback label for container
  ///
  /// In en, this message translates to:
  /// **'Container {id}'**
  String containerFallback(String id);

  /// Fallback label for location
  ///
  /// In en, this message translates to:
  /// **'Location {id}'**
  String locationFallback(String id);

  /// Label for 'of the value'
  ///
  /// In en, this message translates to:
  /// **'of the value'**
  String get ofTheValueLabel;

  /// No description provided for @reportsDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF or Excel reports to debugPrint or save on your PC'**
  String get reportsDescription;

  /// No description provided for @reportSectionType.
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get reportSectionType;

  /// No description provided for @reportSectionFormat.
  ///
  /// In en, this message translates to:
  /// **'Output Format'**
  String get reportSectionFormat;

  /// No description provided for @reportSectionPreview.
  ///
  /// In en, this message translates to:
  /// **'Current Configuration'**
  String get reportSectionPreview;

  /// No description provided for @reportSelectContainerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Container'**
  String get reportSelectContainerTitle;

  /// No description provided for @reportGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get reportGenerate;

  /// No description provided for @reportGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get reportGenerating;

  /// No description provided for @reportTypeInventoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete inventory listing'**
  String get reportTypeInventoryDescription;

  /// No description provided for @reportTypeLoansDescription.
  ///
  /// In en, this message translates to:
  /// **'Active loans and their status'**
  String get reportTypeLoansDescription;

  /// No description provided for @reportTypeAssetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Assets listed by category'**
  String get reportTypeAssetsDescription;

  /// No description provided for @reportLabelContainer.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get reportLabelContainer;

  /// No description provided for @reportLabelType.
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get reportLabelType;

  /// No description provided for @reportLabelFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get reportLabelFormat;

  /// No description provided for @reportFormatPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get reportFormatPdf;

  /// No description provided for @reportFormatExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel'**
  String get reportFormatExcel;

  /// No description provided for @reportNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get reportNotSelected;

  /// No description provided for @reportUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get reportUnknown;

  /// No description provided for @reportSelectContainerFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a container'**
  String get reportSelectContainerFirst;

  /// No description provided for @reportDownloadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{format} report downloaded successfully'**
  String reportDownloadedSuccess(String format);

  /// No description provided for @reportGenerateError.
  ///
  /// In en, this message translates to:
  /// **'Error generating report: {error}'**
  String reportGenerateError(String error);

  /// No description provided for @firstRunWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Invenicum'**
  String get firstRunWelcomeTitle;

  /// No description provided for @firstRunConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Initial Setup'**
  String get firstRunConfigTitle;

  /// No description provided for @firstRunWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'It looks like this is your first time launching the app. Let\'s create your admin account to get started.'**
  String get firstRunWelcomeDescription;

  /// No description provided for @firstRunStep1Label.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2 · Welcome'**
  String get firstRunStep1Label;

  /// No description provided for @firstRunStep2Label.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2 · Create Admin'**
  String get firstRunStep2Label;

  /// No description provided for @firstRunSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created'**
  String get firstRunSuccessMessage;

  /// No description provided for @firstRunAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Admin'**
  String get firstRunAdminTitle;

  /// No description provided for @firstRunAdminDescription.
  ///
  /// In en, this message translates to:
  /// **'This user will have full access to the platform.'**
  String get firstRunAdminDescription;

  /// No description provided for @firstRunFeature1.
  ///
  /// In en, this message translates to:
  /// **'Create your admin user'**
  String get firstRunFeature1;

  /// No description provided for @firstRunFeature2.
  ///
  /// In en, this message translates to:
  /// **'Secure access with password'**
  String get firstRunFeature2;

  /// No description provided for @firstRunFeature3.
  ///
  /// In en, this message translates to:
  /// **'Ready to use in seconds'**
  String get firstRunFeature3;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @firstRunSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Created!'**
  String get firstRunSuccessTitle;

  /// No description provided for @firstRunSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your admin account is ready.\nYou can now log in.'**
  String get firstRunSuccessSubtitle;

  /// No description provided for @firstRunAccountCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT CREATED'**
  String get firstRunAccountCreatedLabel;

  /// No description provided for @firstRunCopyright.
  ///
  /// In en, this message translates to:
  /// **'Invenicum ©'**
  String get firstRunCopyright;
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
