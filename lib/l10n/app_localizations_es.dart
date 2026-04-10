// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get aboutInvenicum => 'Sobre Invenicum';

  @override
  String get deliveryVoucherTitle => 'VALE DE ENTREGA';

  @override
  String get aboutDialogTitle => 'Sobre Invenicum';

  @override
  String get aboutDialogCoolText =>
      'Tu inventario, pero con esteroides. Estamos comprobando si hay una versión más fresca para que sigas a tope.';

  @override
  String get aboutCurrentVersionLabel => 'Versión actual';

  @override
  String get aboutLatestVersionLabel => 'Última versión';

  @override
  String get aboutCheckingVersion => 'Comprobando versión online...';

  @override
  String get aboutVersionUnknown => 'Desconocida';

  @override
  String get aboutVersionUpToDate => 'Tu app está al día.';

  @override
  String get aboutUpdateAvailable => 'Hay una nueva versión disponible.';

  @override
  String get aboutVersionCheckFailed =>
      'No se pudo comprobar la versión online.';

  @override
  String get aboutOpenReleases => 'Ver releases';

  @override
  String get active => 'Activo';

  @override
  String get actives => 'Activos';

  @override
  String get activeInsight => 'INFORMACION DE ACTIVOS VIGENTES';

  @override
  String get activeLoans => 'Préstamos vigentes';

  @override
  String get activeLoansCount => 'Préstamos vigentes';

  @override
  String get addAlert => 'Añadir Alerta';

  @override
  String get addAsset => 'Añadir Activo';

  @override
  String get addContainer => 'Añadir contenedor';

  @override
  String get addNewLocation => 'Añadir Nueva Ubicación';

  @override
  String get additionalInformation => 'Información adicional';

  @override
  String get additionalThumbnails => 'Miniaturas Adicionales';

  @override
  String get adquisition => 'ADQUISICIÓN';

  @override
  String aiExtractionError(String error) {
    return 'La IA no pudo extraer los datos: $error';
  }

  @override
  String get aiPasteUrlDescription =>
      'Pega el enlace del producto y la IA extraerá automáticamente la información para rellenar los campos.';

  @override
  String get alertCritical => 'Crítico';

  @override
  String get alertCreated => 'Alerta creada';

  @override
  String get alertDeleted => 'Alerta eliminada';

  @override
  String get alertInfo => 'Información';

  @override
  String get alertMessage => 'Mensaje';

  @override
  String get alertTitle => 'Título';

  @override
  String get alertType => 'Tipo';

  @override
  String get alertWarning => 'Advertencia';

  @override
  String get alerts => 'Alertas y Notificaciones';

  @override
  String get all => 'Todos';

  @override
  String get allUpToDateStatus => 'Todo al día';

  @override
  String get appTitle => 'Invenicum Inventario';

  @override
  String get applicationTheme => 'Tema de la aplicación';

  @override
  String get apply => 'Aplicar';

  @override
  String get april => 'Abril';

  @override
  String get assetDetail => 'Detalles del Activo';

  @override
  String get assetImages => 'Imágenes del Activo';

  @override
  String get assetImport => 'Importación de Activos';

  @override
  String get assetName => 'Nombre';

  @override
  String get assetNotFound => 'Activo no encontrado';

  @override
  String assetTypeDeleted(String name) {
    return 'Tipo de Activo \"$name\" eliminado con éxito.';
  }

  @override
  String get assetTypes => 'Tipos de Activos';

  @override
  String assetUpdated(String name) {
    return 'Activo \"$name\" actualizado correctamente.';
  }

  @override
  String get assets => 'Activos';

  @override
  String get assetsIn => 'Activos en';

  @override
  String get august => 'Agosto';

  @override
  String get backToAssetTypes => 'Volver a Tipos de Activo';

  @override
  String get averageMarketValue => 'Precio medio de mercado';

  @override
  String get barCode => 'Código de Barras (EAN)';

  @override
  String get baseCostAccumulatedWithoutInflation =>
      'Costo base acumulado sin inflación';

  @override
  String get borrowerEmail => 'Email del Prestatario';

  @override
  String get borrowerName => 'Nombre del Prestatario';

  @override
  String get borrowerPhone => 'Teléfono del Prestatario';

  @override
  String get cancel => 'Cancelar';

  @override
  String get centerView => 'Centrar Vista';

  @override
  String get chooseFile => 'Elegir Archivo';

  @override
  String get clearCounter => 'Limpiar Contador';

  @override
  String get collectionContainerInfo =>
      'Los contenedores de colección tienen barras de seguimiento de colecciones, valor invertido, valor de mercado y vista de Exposición';

  @override
  String get collectionFieldsConfigured => 'Campos de colección configurados.';

  @override
  String get condition => 'Condición';

  @override
  String get condition_mint => 'Caja original';

  @override
  String get condition_loose => 'Suelto (Sin caja)';

  @override
  String get condition_incomplete => 'Incompleto';

  @override
  String get condition_damaged => 'Dañado / Marcas';

  @override
  String get condition_new => 'Nuevo';

  @override
  String get condition_digital => 'Digital / Intangible';

  @override
  String get configureCollectionFields => 'Configurar Campos de Colección';

  @override
  String get configureDeliveryVoucher => 'Configurar Vale de Entrega';

  @override
  String get configureVoucherBody => 'Configura el cuerpo del vale...';

  @override
  String get confirmDeleteAlert => 'Eliminar Alerta';

  @override
  String get confirmDeleteAlertMessage =>
      '¿Estás seguro de que deseas eliminar este registro?';

  @override
  String confirmDeleteAssetType(String name) {
    return '¿Estás seguro de que deseas eliminar el tipo de activo \"$name\" y todos sus elementos asociados? Esta acción no se puede deshacer.';
  }

  @override
  String confirmDeleteContainer(String name) {
    return '¿Estás seguro de que quieres eliminar el contenedor \"$name\"? Esta acción es irreversible y eliminará todos sus activos y datos.';
  }

  @override
  String confirmDeleteLocationMessage(String name) {
    return '¿Estás seguro de que quieres eliminar la ubicación \"$name\"?';
  }

  @override
  String get confirmDeletion => 'Confirmar eliminación';

  @override
  String get configurationSaved => 'Configuración guardada correctamente.';

  @override
  String containerCreated(String name) {
    return 'Contenedor \"$name\" creado correctamente.';
  }

  @override
  String containerDeleted(String name) {
    return 'Contenedor \"$name\" eliminado correctamente.';
  }

  @override
  String get containerName => 'Nombre del contenedor';

  @override
  String get containerOrAssetTypeNotFound =>
      'Contenedor o Tipo de Activo no encontrado.';

  @override
  String containerRenamed(String name) {
    return 'Contenedor renombrado a \"$name\".';
  }

  @override
  String get containers => 'Contenedores';

  @override
  String get countItemsByValue => 'Contar ítems por valor específico';

  @override
  String get create => 'Crear';

  @override
  String get createFirstContainer => 'Crea tu primer contenedor.';

  @override
  String get createdAt => 'Fecha de creación';

  @override
  String get currency => 'Moneda';

  @override
  String get current => 'Actual';

  @override
  String get customColor => 'Personalizar color';

  @override
  String get customFields => 'Campos Personalizados';

  @override
  String customFieldsOf(String name) {
    return 'Campos Personalizados de $name';
  }

  @override
  String get customizeDeliveryVoucher =>
      'Personaliza la plantilla PDF para préstamos';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get dashboard => 'Panel de Control';

  @override
  String get datalists => 'Listas Personalizadas';

  @override
  String get december => 'Diciembre';

  @override
  String get definitionCustomFields => 'Definición de Campos Personalizados';

  @override
  String get delete => 'Eliminar';

  @override
  String deleteError(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get deleteSuccess => 'Ubicación eliminada exitosamente.';

  @override
  String get deliveryVoucher => 'VALE DE ENTREGA';

  @override
  String get deliveryVoucherEditor => 'Editor de Vales de Entrega';

  @override
  String get description => 'Descripción (opcional)';

  @override
  String get desiredField => 'Campo de Deseados';

  @override
  String get dueDate => 'Fecha Vencimiento';

  @override
  String get edit => 'Editar';

  @override
  String get enterContainerName => 'Ingrese el nombre del contenedor';

  @override
  String get enterDescription => 'Ingrese una descripción';

  @override
  String get enterURL => 'Ingrese la URL';

  @override
  String get enterValidUrl => 'Introduce una URL válida';

  @override
  String errorChangingLanguage(String error) {
    return 'Error al cambiar idioma: $error';
  }

  @override
  String get errorCsvMinRows =>
      'Por favor, selecciona un archivo CSV con encabezados y al menos una fila de datos.';

  @override
  String errorDeletingAssetType(String error) {
    return 'Error al eliminar el tipo de activo: $error';
  }

  @override
  String errorDeletingContainer(String error) {
    return 'Error al eliminar el contenedor: $error';
  }

  @override
  String get errorDuringImport => 'Error durante la importación';

  @override
  String get errorEmptyCsv => 'El archivo CSV está vacío.';

  @override
  String errorGeneratingPDF(String error) {
    return 'Error al generar PDF: $error';
  }

  @override
  String get errorInvalidPath => 'Ruta de archivo no válida.';

  @override
  String get errorLoadingData => 'Error al cargar los datos';

  @override
  String errorLoadingListValues(String error) {
    return 'Error al cargar los valores de la lista: $error';
  }

  @override
  String errorLoadingLocations(String error) {
    return 'Error al cargar ubicaciones: $error';
  }

  @override
  String get errorNameMappingRequired =>
      'El campo \'Nombre\' es obligatorio y debe ser mapeado.';

  @override
  String get errorNoVoucherTemplate =>
      'No hay una plantilla de vale configurada.';

  @override
  String get errorNotBarCode =>
      'El articulo no tiene código de barras o no es válido.';

  @override
  String get errorReadingBytes => 'No se pudieron leer los bytes del archivo.';

  @override
  String errorReadingFile(String error) {
    return 'Error al leer el archivo: $error';
  }

  @override
  String errorRegisteringLoan(String error) {
    return 'Error al registrar préstamo: $error';
  }

  @override
  String errorRenaming(String error) {
    return 'Error al renombrar: $error';
  }

  @override
  String errorSaving(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String errorUpdatingAsset(String error) {
    return 'Error al actualizar activo: $error';
  }

  @override
  String get exampleFilterHint => 'Ej: Dañado, Rojo, 50';

  @override
  String get february => 'Febrero';

  @override
  String get fieldChip => 'Campo';

  @override
  String fieldRequiredWithName(String field) {
    return 'El campo \"$field\" es obligatorio.';
  }

  @override
  String get fieldToCount => 'Campo a Contar';

  @override
  String get fieldsFilledSuccess => '¡Campos completados con éxito!';

  @override
  String get formatsPNG => 'Formatos: PNG, JPG';

  @override
  String get forToday => 'Para hoy';

  @override
  String get geminiLabelModel =>
      'Modelo Gemini recomendado: gemini-3-flash-preview';

  @override
  String get generalSettings => 'Configuración General';

  @override
  String get generateVoucher => 'Generar Vale de Entrega';

  @override
  String get globalSearch => 'Búsqueda Global';

  @override
  String get greeting => '¡Hola, bienvenido!';

  @override
  String get guest => 'Invitado';

  @override
  String get helpDocs => 'Ayuda y Documentación';

  @override
  String get helperGeminiKey =>
      'Introduce tu clave de API de Gemini para habilitar la integración. Consiguela en https://aistudio.google.com/';

  @override
  String get ignoreField => '🚫 Ignorar Campo';

  @override
  String get importAssetsTo => 'Importar Activos a';

  @override
  String importSuccessMessage(int count) {
    return '¡Importación Exitosa! $count activos creados.';
  }

  @override
  String get importSerializedWarning =>
      'Importación correcta. Este tipo de activo es serializado — todos los ítems se han creado con cantidad 1.';

  @override
  String get integrations => 'Integraciones';

  @override
  String get integrationGeminiDesc =>
      'Conecta Invenicum con Gemini de Google para aprovechar las capacidades avanzadas de IA en la gestión de tu inventario.';

  @override
  String get integrationTelegramDesc =>
      'Conecta Invenicum con Telegram para recibir notificaciones instantáneas sobre tu inventario directamente en tu dispositivo.';

  @override
  String get invalidAssetId => 'ID de activo no válido';

  @override
  String get invalidNavigationIds => 'Error: IDs de navegación no válidos.';

  @override
  String get inventoryLabel => 'Inventario';

  @override
  String get january => 'Enero';

  @override
  String get july => 'Julio';

  @override
  String get june => 'Junio';

  @override
  String get language => 'Idioma';

  @override
  String get languageChanged => '¡Idioma cambiado a Español!';

  @override
  String get languageNotImplemented =>
      'Funcionalidad de idioma por implementar';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get loadingAssetType => 'Cargando Tipo de Activo...';

  @override
  String loadingListField(String field) {
    return 'Cargando $field...';
  }

  @override
  String get loanDate => 'Fecha Préstamo';

  @override
  String get loanLanguageNotImplemented =>
      'Funcionalidad de idioma por implementar';

  @override
  String get loanManagement => 'Gestión de Préstamos';

  @override
  String get loanObject => 'Objeto a Prestar';

  @override
  String get loans => 'Préstamos';

  @override
  String get location => 'Ubicación';

  @override
  String get locations => 'Ubicaciones';

  @override
  String get locationsScheme => 'Esquema de Ubicaciones';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get logoVoucher => 'Logo del Vale';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get lookForContainersOrAssets => 'Buscar contenedores o activos...';

  @override
  String get lowStockTitle => 'Stock Bajo';

  @override
  String get magicAssistant => 'Asistente Mágico IA';

  @override
  String get march => 'Marzo';

  @override
  String get marketPriceObtained => 'Precio de mercado obtenido correctamente';

  @override
  String get marketValueEvolution => 'Evolución del valor de mercado';

  @override
  String get marketValueField => 'Valor de mercado';

  @override
  String get marketRealRate => 'Tasa real de mercado';

  @override
  String get maxStock => 'Stock máximo';

  @override
  String get may => 'Mayo';

  @override
  String get minStock => 'Stock mínimo';

  @override
  String get myAchievements => 'Mis Logros';

  @override
  String get myCustomTheme => 'Mi Tema';

  @override
  String get myProfile => 'Mi Perfil';

  @override
  String get myThemesStored => 'Mis Temas Guardados';

  @override
  String get name => 'Nombre';

  @override
  String get nameCannotBeEmpty => 'El nombre no puede estar vacío';

  @override
  String get nameSameAsCurrent => 'El nombre es el mismo que el actual';

  @override
  String get newAlert => 'Nueva Alerta Manual';

  @override
  String get newContainer => 'Nuevo contenedor';

  @override
  String get newName => 'Nuevo nombre';

  @override
  String get next => 'Siguiente';

  @override
  String get noAssetsCreated => 'No hay activos creados aún.';

  @override
  String get noAssetsMatch =>
      'Ningún activo coincide con los criterios de búsqueda/filtro.';

  @override
  String get noBooleanFields => 'No hay campos booleanos definidos.';

  @override
  String get noContainerMessage => 'Crea tu primer contenedor.';

  @override
  String get noCustomFields =>
      'Este tipo de activo no tiene campos personalizados.';

  @override
  String get noFileSelected => 'Ningún archivo seleccionado';

  @override
  String get noImageAvailable => 'No hay imagen disponible';

  @override
  String get noImagesAdded =>
      'Aún no hay imágenes añadidas. La primera imagen será la principal.';

  @override
  String get noLoansFound => 'No se encontraron préstamos en este contenedor.';

  @override
  String get noLocationsMessage =>
      'No hay ubicaciones creadas en este contenedor. ¡Añade la primera!';

  @override
  String get noNotifications => 'No hay notificaciones';

  @override
  String get noThemesSaved => 'Aún no hay temas guardados';

  @override
  String get none => 'Ninguno';

  @override
  String get november => 'Noviembre';

  @override
  String get obligatory => 'Obligatorio';

  @override
  String get october => 'Octubre';

  @override
  String get optimalStockStatus => 'Stock en niveles óptimos';

  @override
  String get optional => 'Opcional';

  @override
  String get overdue => 'Atrasado';

  @override
  String get password => 'Contraseña';

  @override
  String get pleaseEnterPassword => 'Por favor ingrese su contraseña';

  @override
  String get pleaseEnterUsername => 'Por favor ingrese su usuario';

  @override
  String get pleasePasteUrl => 'Por favor, pega una URL';

  @override
  String get pleaseSelectCsvWithHeaders =>
      'Por favor, selecciona un archivo CSV con encabezados.';

  @override
  String get pleaseSelectLocation => 'Por favor, selecciona una ubicación.';

  @override
  String get plugins => 'Plugins';

  @override
  String get possessionFieldDef => 'Campo de Posesión';

  @override
  String get possessionFieldName => 'En Posesión';

  @override
  String get preferences => 'Preferencias';

  @override
  String get previewPDF => 'Vista Previa';

  @override
  String get previous => 'Anterior';

  @override
  String get primaryImage => 'Imagen Principal';

  @override
  String get productUrlLabel => 'URL del producto';

  @override
  String get quantity => 'Cantidad';

  @override
  String get refresh => 'Recargar datos';

  @override
  String get registerNewLoan => 'Registrar Nuevo Préstamo';

  @override
  String get reloadContainers => 'Recargar contenedores';

  @override
  String get reloadLocations => 'Recargar ubicaciones';

  @override
  String get reloadLoans => 'Recargar préstamos';

  @override
  String get removeImage => 'Eliminar Imagen';

  @override
  String get rename => 'Renombrar';

  @override
  String get renameContainer => 'Renombrar Contenedor';

  @override
  String get responsibleLabel => 'Responsable';

  @override
  String get reports => 'Informes';

  @override
  String get returned => 'Devuelto';

  @override
  String get returnsLabel => 'Devoluciones';

  @override
  String get rowsPerPageTitle => 'Activos por página:';

  @override
  String get save => 'Guardar';

  @override
  String get saveAndApply => 'Guardar y Aplicar';

  @override
  String get saveAsset => 'Guardar Activo';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get saveConfiguration => 'Guardar Configuración';

  @override
  String get saveCustomTheme => 'Guardar Tema Personalizado';

  @override
  String get searchInAllColumns => 'Buscar en todas las columnas...';

  @override
  String get selectAndUploadImage => 'Seleccionar y Subir Imagen';

  @override
  String get selectApplicationCurrency =>
      'Selecciona la moneda de la aplicación';

  @override
  String get selectApplicationLanguage =>
      'Selecciona el idioma de la aplicación';

  @override
  String get selectBooleanFields =>
      'Selecciona los campos booleanos para controlar la colección:';

  @override
  String get selectCsvColumn => 'Seleccionar Columna CSV';

  @override
  String get selectField => 'Seleccionar campo...';

  @override
  String get selectFieldType => 'Seleccionar tipo de campo';

  @override
  String get selectImage => 'Seleccionar Imagen';

  @override
  String get selectLocationRequired =>
      'Debe seleccionar una ubicación para el activo.';

  @override
  String selectedLocationLabel(String name) {
    return 'Seleccionado: $name';
  }

  @override
  String get selectTheme => 'Seleccionar Tema';

  @override
  String get september => 'Septiembre';

  @override
  String get settings => 'Ajustes';

  @override
  String get showAsGrid => 'Mostrar como Grid';

  @override
  String get showAsList => 'Mostrar como Lista';

  @override
  String get slotDashboardBottom => 'Panel de control Inferior';

  @override
  String get slotDashboardTop => 'Panel de control Superior';

  @override
  String get slotFloatingActionButton => 'Botón Flotante';

  @override
  String get slotInventoryHeader => 'Cabecera Inventario';

  @override
  String get slotLeftSidebar => 'Barra Lateral';

  @override
  String get slotUnknown => 'Ranura desconocida';

  @override
  String get specificValueToCount => 'Valor Específico a Contar';

  @override
  String get startImport => 'Iniciar Importación';

  @override
  String get startMagic => 'Empezar Magia';

  @override
  String get status => 'Estado';

  @override
  String get step1SelectFile => 'Paso 1: Seleccionar Archivo CSV';

  @override
  String get step2ColumnMapping => 'Paso 2: Mapeo de Columnas (CSV -> Sistema)';

  @override
  String get syncingSession => 'Sincronizando sesión...';

  @override
  String get systemThemes => 'Temas del Sistema';

  @override
  String get systemThemesModal => 'Temas del Sistema';

  @override
  String get templates => 'Plantillas';

  @override
  String get themeNameLabel => 'Nombre del Tema';

  @override
  String get thisFieldIsRequired => 'Este campo es obligatorio.';

  @override
  String get topDemanded => 'Top Demandados';

  @override
  String get topLoanedItems => 'Productos más prestados por meses';

  @override
  String get totalAssets => 'Tipos de Activos';

  @override
  String get totalItems => 'Activos';

  @override
  String get totals => 'Totales';

  @override
  String get totalSpending => 'Inversión Total Económica';

  @override
  String get totalMarketValue => 'Valor de Mercado Total';

  @override
  String get updatedAt => 'Última actualización';

  @override
  String get upload => 'Subir';

  @override
  String get uploadImage => 'Subir Imagen';

  @override
  String get username => 'Usuario';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get connectionTestFailed => 'La prueba de conexión falló';

  @override
  String get connectionVerified => 'Conexión verificada con éxito';

  @override
  String get errorSavingConfiguration => 'Error al guardar la configuración';

  @override
  String get integrationsAndConnectionsTitle => 'Integraciones y conexiones';

  @override
  String get integrationsSectionAiTitle => 'Inteligencia artificial';

  @override
  String get integrationsSectionAiSubtitle =>
      'Motores conversacionales y asistentes para enriquecer flujos y automatizaciones.';

  @override
  String get integrationsSectionMessagingTitle => 'Mensajería y notificaciones';

  @override
  String get integrationsSectionMessagingSubtitle =>
      'Canales de salida para avisos, bots, reportes y entregas automáticas.';

  @override
  String get integrationsSectionDataApisTitle => 'APIs de datos';

  @override
  String get integrationsSectionDataApisSubtitle =>
      'Fuentes externas para enriquecer fichas, cartas, juegos y referencias de catálogo.';

  @override
  String get integrationsSectionValuationTitle => 'Valoración y mercado';

  @override
  String get integrationsSectionValuationSubtitle =>
      'Conectores para precios, códigos de barras y estimación de valor actualizado.';

  @override
  String get integrationsSectionHardwareTitle => 'Hardware y etiquetas';

  @override
  String get integrationsSectionHardwareSubtitle =>
      'Herramientas físicas y utilidades para impresión, codificación y operación.';

  @override
  String integrationsActiveConnections(int count) {
    return '$count conexiones activas';
  }

  @override
  String get integrationsModularDesign => 'Diseño modular por categorías';

  @override
  String get integrationsCheckingStatuses => 'Comprobando estados';

  @override
  String get integrationsStatusSynced => 'Estado sincronizado';

  @override
  String get integrationsHeroHeadline =>
      'Conecta servicios, APIs y herramientas desde una única vista clara.';

  @override
  String get integrationsHeroSubheadline =>
      'Agrupamos las integraciones por propósito para que la configuración sea más rápida, más visual y más fácil de mantener también en móvil.';

  @override
  String get integrationStatusConnected => 'Conectada';

  @override
  String get integrationStatusNotConfigured => 'Sin configurar';

  @override
  String get integrationTypeDataSource => 'Fuente de datos';

  @override
  String get integrationTypeConnector => 'Conector';

  @override
  String integrationFieldsCount(int count) {
    return '$count campos';
  }

  @override
  String get integrationNoLocalCredentials => 'Sin credenciales locales';

  @override
  String get configureLabel => 'Configurar';

  @override
  String get integrationModelDefaultGemini =>
      'Predeterminado: gemini-3-flash-preview';

  @override
  String get integrationOpenaiDesc =>
      'Usa GPT-4o y otros modelos de OpenAI como asistente inteligente.';

  @override
  String get integrationOpenaiApiKeyHint =>
      'Obtenida en platform.openai.com/api-keys';

  @override
  String get integrationModelDefaultOpenai => 'Predeterminado: gpt-4o';

  @override
  String get integrationClaudeDesc =>
      'Usa Claude Sonnet, Opus y Haiku como asistente inteligente.';

  @override
  String get integrationClaudeApiKeyHint =>
      'Obtenida en console.anthropic.com/settings/keys';

  @override
  String get integrationModelDefaultClaude =>
      'Predeterminado: claude-sonnet-4-6';

  @override
  String get integrationTelegramBotTokenHint => 'De @BotFather';

  @override
  String get integrationTelegramChatIdHint =>
      'Usa @userinfobot para obtener tu ID';

  @override
  String get integrationEmailDesc =>
      'Envío de correos ultra-confiable. Ideal para reportes y alertas críticas.';

  @override
  String get integrationEmailApiKeyHint => 'Obtenida en resend.com/api-keys';

  @override
  String get integrationEmailFromLabel => 'Remitente (From)';

  @override
  String get integrationEmailFromHint =>
      'Ej: Invenicum <onboarding@resend.dev>';

  @override
  String get integrationBggDesc =>
      'Conecta tu cuenta de BGG para sincronizar tu colección y enriquecer tus datos automáticamente.';

  @override
  String get integrationPokemonDesc =>
      'Conéctate a la API de Pokemon para sincronizar tu colección y enriquecer tus datos automáticamente.';

  @override
  String get integrationTcgdexDesc =>
      'Consulta cartas y expansiones de juegos de cartas coleccionables para enriquecer tu inventario automáticamente.';

  @override
  String get integrationQrGeneratorName => 'Generador QR';

  @override
  String get integrationQrLabelsDesc =>
      'Configura el formato de tus etiquetas imprimibles.';

  @override
  String get integrationQrPageSizeLabel => 'Tamaño de página (A4, Carta)';

  @override
  String get integrationQrMarginLabel => 'Margen (mm)';

  @override
  String get integrationPriceChartingDesc =>
      'Configura tu API Key para obtener precios actualizados.';

  @override
  String get integrationUpcitemdbDesc =>
      'Búsqueda global de precios por código de barras.';

  @override
  String integrationConfiguredSuccess(String name) {
    return '$name configurado con éxito';
  }

  @override
  String integrationUnlinkedWithName(String name) {
    return 'Se ha desvinculado $name';
  }

  @override
  String get invalidUiFormat => 'Formato de UI no válido';

  @override
  String get loadingConfiguration => 'Cargando configuración...';

  @override
  String pageNotFoundUri(String uri) {
    return 'Página no encontrada: $uri';
  }

  @override
  String get pluginLoadError => 'Error al cargar la interfaz del plugin';

  @override
  String get pluginRenderError => 'Error de renderizado';

  @override
  String get testConnection => 'Probar conexión';

  @override
  String get testingConnection => 'Probando...';

  @override
  String get unableToUnlinkAccount => 'No se pudo desvincular la cuenta';

  @override
  String get unlinkIntegrationUpper => 'DESVINCULAR INTEGRACIÓN';

  @override
  String get upcFreeModeHint =>
      'Deja este campo vacío para usar el modo Gratuito (Limitado).';

  @override
  String get alertsTabLabel => 'Alertas';

  @override
  String get alertMarkedAsRead => 'Marcada como leída';

  @override
  String get calendarTabLabel => 'Calendario';

  @override
  String get closeLabel => 'Cerrar';

  @override
  String get closeLabelUpper => 'CERRAR';

  @override
  String get configureReminderLabel => 'Configurar aviso:';

  @override
  String get cannotFormatInvalidJson =>
      'No se puede formatear un JSON inválido';

  @override
  String get createAlertOrEventTitle => 'Crear alerta/evento';

  @override
  String get createdSuccessfully => 'Creado correctamente';

  @override
  String get createPluginTitle => 'Crear plugin';

  @override
  String get editPluginTitle => 'Editar plugin';

  @override
  String get deleteFromGithubLabel => 'Borrar de GitHub';

  @override
  String get deleteFromGithubSubtitle =>
      'Elimina el archivo del market público';

  @override
  String get deletePluginQuestion => '¿Eliminar plugin?';

  @override
  String get deletePluginLocalWarning =>
      'Se eliminará de tu base de datos local.';

  @override
  String get deleteUpper => 'BORRAR';

  @override
  String get editEventTitle => 'Editar evento';

  @override
  String get editLabel => 'Editar';

  @override
  String get eventDataSection => 'Datos del evento';

  @override
  String get eventReminderAtTime => 'A la hora del evento';

  @override
  String get eventUpdated => 'Evento actualizado';

  @override
  String get firstVersionHint => 'La primera versión será siempre 1.0.0';

  @override
  String get fixJsonBeforeSave => 'Corrige el JSON antes de guardar';

  @override
  String get formatJson => 'Formatear JSON';

  @override
  String get goToProfileUpper => 'IR AL PERFIL';

  @override
  String get installPluginLabel => 'Instalar plugin';

  @override
  String get invalidVersionFormat => 'Formato inválido (ej: 1.0.1)';

  @override
  String get isEventQuestion => '¿Es un evento?';

  @override
  String get jsonErrorGeneric => 'Error en el JSON';

  @override
  String get makePublicLabel => 'Hacer público';

  @override
  String get markAsReadLabel => 'Marcar como leído';

  @override
  String get messageWithColon => 'Mensaje:';

  @override
  String minutesBeforeLabel(int minutes) {
    return '$minutes minutos antes';
  }

  @override
  String get newLabel => 'Nuevo';

  @override
  String get newPluginLabel => 'Nuevo plugin';

  @override
  String get noActiveAlerts => 'No hay alertas activas';

  @override
  String get noDescriptionAvailable => 'Sin descripción disponible.';

  @override
  String get noEventsForDay => 'Sin eventos para este día';

  @override
  String get noPluginsAvailable => 'No hay plugins';

  @override
  String get notificationDeleted => 'Notificación eliminada correctamente';

  @override
  String get oneHourBeforeLabel => '1 hora antes';

  @override
  String get pluginPrivateDescription =>
      'Solo tú podrás ver este plugin en tu lista.';

  @override
  String get pluginPublicDescription =>
      'Otros usuarios podrán ver e instalar este plugin.';

  @override
  String get pluginTabLibrary => 'Librería';

  @override
  String get pluginTabMarket => 'Market';

  @override
  String get pluginTabMine => 'Míos';

  @override
  String get previewLabel => 'Vista previa';

  @override
  String get remindMeLabel => 'Avisarme:';

  @override
  String get requiredField => 'Requerido';

  @override
  String get requiresGithubDescription =>
      'Para publicar plugins en la comunidad, debes vincular tu cuenta de GitHub para darte crédito como autor.';

  @override
  String get requiresGithubTitle => 'Requiere GitHub';

  @override
  String get slotLocationLabel => 'Ubicación (slot)';

  @override
  String get stacDocumentation => 'Documentación de Stac';

  @override
  String get stacJsonInterfaceLabel => 'JSON Stac (interfaz)';

  @override
  String get uninstallLabel => 'Desinstalar';

  @override
  String get unrecognizedStacStructure => 'Estructura Stac no reconocida';

  @override
  String get updateLabelUpper => 'UPDATE';

  @override
  String updateToVersion(String version) {
    return 'Actualizar a v$version';
  }

  @override
  String get versionLabel => 'Versión';

  @override
  String get incrementVersionHint =>
      'Incrementa la versión para tu propuesta (ej: 1.1.0)';

  @override
  String get cancelUpper => 'CANCELAR';

  @override
  String get mustLinkGithubToPublishTemplate =>
      'Debes vincular GitHub en tu perfil para publicar.';

  @override
  String get templateNeedsAtLeastOneField =>
      'La plantilla debe tener al menos un campo definido.';

  @override
  String get templatePullRequestCreated =>
      'Propuesta enviada. Se ha creado un Pull Request en GitHub.';

  @override
  String errorPublishingTemplate(String error) {
    return 'Error al publicar: $error';
  }

  @override
  String get createGlobalTemplateTitle => 'Crear plantilla global';

  @override
  String get githubVerifiedLabel => 'GitHub verificado';

  @override
  String get githubNotLinkedLabel => 'GitHub no vinculado';

  @override
  String get veniDesignedTemplateBanner =>
      'Veni ha diseñado esta estructura basándose en tu solicitud. Revísala y ajústala antes de publicar.';

  @override
  String get templateNameLabel => 'Nombre de la plantilla';

  @override
  String get templateNameHint => 'Ej: Mi colección de cómics';

  @override
  String get githubUserLabel => 'Usuario de GitHub';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get categoryHint => 'Ej: Libros, Electrónica...';

  @override
  String get templatePurposeDescription => 'Descripción del propósito';

  @override
  String get definedFieldsTitle => 'Campos definidos';

  @override
  String get addFieldButton => 'Añadir campo';

  @override
  String get clickAddFieldToStart =>
      'Haz clic en \'Añadir campo\' para empezar a diseñar.';

  @override
  String get configureOptionsUpper => 'CONFIGURAR OPCIONES';

  @override
  String get writeOptionAndPressEnter => 'Escribe una opción y pulsa Intro';

  @override
  String get publishOnGithubUpper => 'PUBLICAR EN GITHUB';

  @override
  String get templateDetailFetchError =>
      'No se pudo obtener el detalle de la plantilla';

  @override
  String get templateNotAvailable =>
      'La plantilla no existe o no está disponible';

  @override
  String get backLabel => 'Volver';

  @override
  String get templateDetailTitle => 'Detalle de plantilla';

  @override
  String get saveToLibraryTooltip => 'Guardar en biblioteca';

  @override
  String templateByAuthor(String name) {
    return 'por @$name';
  }

  @override
  String get officialVerifiedTemplate => 'Plantilla oficial verificada';

  @override
  String dataStructureFieldsUpper(int count) {
    return 'ESTRUCTURA DE DATOS ($count CAMPOS)';
  }

  @override
  String get installInMyInventoryUpper => 'INSTALAR EN MI INVENTARIO';

  @override
  String get addedToPersonalLibrary => 'Añadida a tu biblioteca personal';

  @override
  String get whereDoYouWantToInstall => '¿Dónde quieres instalarlo?';

  @override
  String get noContainersCreateFirst =>
      'No tienes contenedores. Crea uno primero.';

  @override
  String get autoGeneratedListFromTemplate =>
      'Lista generada automáticamente desde plantilla';

  @override
  String get installationSuccessAutoLists =>
      'Instalación exitosa. Listas configuradas automáticamente.';

  @override
  String errorInstallingTemplate(String error) {
    return 'Error al instalar: $error';
  }

  @override
  String get publishTemplateLabel => 'Publicar plantilla';

  @override
  String get retryLabel => 'Reintentar';

  @override
  String get noTemplatesFoundInMarket =>
      'No se encontraron plantillas en el mercado.';

  @override
  String get invenicumCommunity => 'Comunidad Invenicum';

  @override
  String get refreshMarketTooltip => 'Actualizar mercado';

  @override
  String get exploreCommunityConfigurations =>
      'Explora y descarga configuraciones de la comunidad';

  @override
  String get searchByTemplateName => 'Buscar por nombre de plantilla...';

  @override
  String get filterByTagTooltip => 'Filtrar por etiqueta';

  @override
  String get noMoreTags => 'No hay más etiquetas';

  @override
  String confirmDeleteDataList(String name) {
    return '¿Estás seguro de que quieres eliminar la lista \"$name\"? Esta acción es irreversible.';
  }

  @override
  String dataListDeletedSuccess(String name) {
    return 'Lista \"$name\" eliminada con éxito.';
  }

  @override
  String errorDeletingDataList(String error) {
    return 'Error al eliminar la lista: $error';
  }

  @override
  String customListsWithContainer(String name) {
    return 'Listas personalizadas - $name';
  }

  @override
  String get newDataListLabel => 'Nueva lista';

  @override
  String get noCustomListsCreateOne =>
      'No hay listas personalizadas. Crea una nueva.';

  @override
  String elementsCount(int count) {
    return '$count elementos';
  }

  @override
  String get dataListNeedsAtLeastOneElement =>
      'La lista debe tener al menos un elemento';

  @override
  String get customDataListCreated => 'Lista personalizada creada con éxito';

  @override
  String errorCreatingDataList(String error) {
    return 'Error al crear la lista: $error';
  }

  @override
  String get newCustomDataListTitle => 'Nueva lista personalizada';

  @override
  String get dataListNameLabel => 'Nombre de la lista';

  @override
  String get pleaseEnterAName => 'Por favor introduce un nombre';

  @override
  String get dataListElementsTitle => 'Elementos de la lista';

  @override
  String get newElementLabel => 'Nuevo elemento';

  @override
  String get addLabel => 'Agregar';

  @override
  String get addElementsToListHint => 'Agrega elementos a la lista';

  @override
  String get saveListLabel => 'Guardar lista';

  @override
  String get dataListUpdatedSuccessfully => 'Lista actualizada con éxito';

  @override
  String errorUpdatingDataList(String error) {
    return 'Error al actualizar la lista: $error';
  }

  @override
  String editListWithName(String name) {
    return 'Editar lista: $name';
  }

  @override
  String get createNewLocationTitle => 'Crear Nueva Ubicación';

  @override
  String get locationNameLabel => 'Nombre de la Ubicación';

  @override
  String get locationNameHint => 'Ej: Estantería B3, Sala de Servidores';

  @override
  String get locationDescriptionHint =>
      'Detalles de acceso, tipo de contenido, etc.';

  @override
  String get parentLocationLabel => 'Ubicación Padre (Contiene a esta)';

  @override
  String get noParentRootLocation => 'Ningún padre (Ubicación Raíz)';

  @override
  String get noneRootScheme => 'Ninguno (Raíz del Esquema)';

  @override
  String get savingLabel => 'Guardando...';

  @override
  String get saveLocationLabel => 'Guardar Ubicación';

  @override
  String locationCreatedSuccessfully(String name) {
    return 'Ubicación \"$name\" creada exitosamente.';
  }

  @override
  String errorCreatingLocation(String error) {
    return 'Error al crear ubicación: $error';
  }

  @override
  String get locationCannotBeItsOwnParent =>
      'Una ubicación no puede ser su propio padre.';

  @override
  String locationUpdatedSuccessfully(String name) {
    return 'Ubicación \"$name\" actualizada.';
  }

  @override
  String errorUpdatingLocation(String error) {
    return 'Error al actualizar ubicación: $error';
  }

  @override
  String editLocationTitle(String name) {
    return 'Editar: $name';
  }

  @override
  String get updateLocationLabel => 'Actualizar Ubicación';

  @override
  String get selectObjectTitle => 'Seleccionar Objeto';

  @override
  String get noObjectsAvailable => 'No hay objetos disponibles';

  @override
  String availableQuantity(int quantity) {
    return 'Disponible: $quantity';
  }

  @override
  String errorSelectingObject(String error) {
    return 'Error al seleccionar objeto: $error';
  }

  @override
  String get mustSelectAnObject => 'Debes seleccionar un objeto';

  @override
  String get loanRegisteredSuccessfully => 'Préstamo registrado exitosamente';

  @override
  String get selectAnObject => 'Selecciona un objeto';

  @override
  String get selectLabel => 'Seleccionar';

  @override
  String get borrowerNameHint => 'Ej: Juan Perez';

  @override
  String get borrowerNameRequired => 'El nombre es obligatorio';

  @override
  String loanQuantityAvailable(int quantity) {
    return 'Cantidad a prestar (Disponible: $quantity)';
  }

  @override
  String get enterQuantity => 'Ingresa una cantidad';

  @override
  String get invalidQuantity => 'Cantidad no válida';

  @override
  String get notEnoughStock => 'No hay suficiente stock';

  @override
  String get invalidEmail => 'Correo inválido';

  @override
  String expectedReturnDateLabel(String date) {
    return 'Devolución esperada: $date';
  }

  @override
  String get selectReturnDate => 'Selecciona fecha de devolución';

  @override
  String get additionalNotes => 'Notas Adicionales';

  @override
  String get registerLoanLabel => 'Registrar Préstamo';

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
  String get veniChatPlaceholder => 'Pregúntame algo...';

  @override
  String get veniChatPoweredBy => 'Powered by ';

  @override
  String veniChatProcessing(String query) {
    return 'Estoy procesando tu consulta sobre \"$query\"...';
  }

  @override
  String get veniChatStatus => 'En línea';

  @override
  String get veniChatTitle => 'Venibot AI';

  @override
  String get veniChatWelcome =>
      '¡Hola! Soy Venibot, tu asistente de Invenicum. ¿En qué puedo ayudarte con tu inventario hoy?';

  @override
  String get veniCmdDashboard => 'Ir al panel de control';

  @override
  String get veniCmdHelpTitle => 'Habilidades de Veni';

  @override
  String get veniCmdInventory => 'Consultar stock de un artículo';

  @override
  String get veniCmdLoans => 'Ver préstamos activos';

  @override
  String get veniCmdReport => 'Generar reporte de inventario';

  @override
  String get veniCmdScanQR => 'Escanear código QR/Barras';

  @override
  String get veniCmdUnknown =>
      'No reconozco ese comando. Escribe ayuda para ver qué puedo hacer.';

  @override
  String version(String name) {
    return 'Versión $name';
  }

  @override
  String get yes => 'Sí';

  @override
  String get zoomToFit => 'Ajustar Vista';

  @override
  String get generalSettingsMenuLabel => 'Ajustes Generales';

  @override
  String get aiAssistantMenuLabel => 'Asistente IA';

  @override
  String get notificationsMenuLabel => 'Notificaciones';

  @override
  String get loanManagementMenuLabel => 'Gestión Préstamos';

  @override
  String get aboutMenuLabel => 'Información';

  @override
  String get automaticDarkModeLabel => 'Modo oscuro automático';

  @override
  String get syncWithSystemLabel => 'Sincronizar con el sistema';

  @override
  String get manualDarkModeLabel => 'Modo oscuro manual';

  @override
  String get disableAutomaticToChange =>
      'Desactiva el modo automático para cambiarlo';

  @override
  String get changeLightDark => 'Cambiar entre claro y oscuro';

  @override
  String get enableAiAndChatbot =>
      'Habilitar Inteligencia Artificial y Chatbot';

  @override
  String get requiresGeminiLinking =>
      'Requiere vinculación con Gemini en Integraciones';

  @override
  String get aiOrganizeInventory =>
      'Usa IA para organizar tu inventario de manera inteligente';

  @override
  String get aiAssistantTitle => 'Asistente de Inteligencia Artificial';

  @override
  String get selectAiProvider =>
      'Elige qué proveedor de IA usará Veni. Asegúrate de tener la API Key configurada en Integraciones.';

  @override
  String get aiProviderLabel => 'Proveedor';

  @override
  String get aiModelLabel => 'Modelo';

  @override
  String get aiProviderUpdated => 'Proveedor de IA actualizado';

  @override
  String get purgeChatHistoryTitle => 'Historial de chat';

  @override
  String get purgeChatHistoryDescription =>
      'Elimina permanentemente todo el historial de conversaciones guardado de Veni.';

  @override
  String get purgeChatHistoryButton => 'Purgar historial';

  @override
  String get purgeChatHistoryConfirmTitle => '¿Purgar historial de chat?';

  @override
  String get purgeChatHistoryConfirmMessage =>
      'Esta acción eliminará todos los mensajes guardados y no se puede deshacer.';

  @override
  String get purgeChatHistoryConfirmAction => 'Sí, purgar';

  @override
  String get purgeChatHistorySuccess =>
      'Historial de chat eliminado correctamente.';

  @override
  String get purgeChatHistoryError =>
      'No se pudo eliminar el historial de chat.';

  @override
  String get notificationSettingsTitle => 'Gestión de Notificaciones';

  @override
  String get channelPriorityLabel =>
      'Prioridad de Canales (Arrastra para ordenar)';

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
  String get profileFillAllFieldsError => 'Por favor, rellena todos los campos';

  @override
  String get profilePasswordUpdatedSuccess => '¡Contraseña actualizada!';

  @override
  String get profileDisconnectActionUpper => 'DESCONECTAR';

  @override
  String get profileGithubUnlinkedSuccess =>
      'GitHub desvinculado correctamente';

  @override
  String get profileGithubLinkedSuccess => '¡GitHub vinculado correctamente!';

  @override
  String profileGithubProcessError(String error) {
    return 'Error al procesar la vinculación: $error';
  }

  @override
  String get profileGithubConfigUnavailableError =>
      'Error: Configuración de GitHub no disponible';

  @override
  String profileServerConnectionError(String error) {
    return 'No se pudo conectar con el servidor: $error';
  }

  @override
  String get profileUpdatedSuccess => 'Perfil actualizado correctamente';

  @override
  String profileUpdateError(String error) {
    return 'Error al actualizar el perfil: $error';
  }

  @override
  String get profileUsernameCommunityLabel => 'Username (Comunidad)';

  @override
  String get profileUsernameCommunityHelper =>
      'Requerido para publicar plugins.';

  @override
  String get profileUpdateButtonUpper => 'ACTUALIZAR PERFIL';

  @override
  String get profileGithubIdentityTitle => 'Identidad de GitHub';

  @override
  String profileGithubLinkedAs(String username) {
    return 'Vinculado como @$username';
  }

  @override
  String get profileGithubLinkPrompt =>
      'Vincula tu cuenta para publicar plugins';

  @override
  String get profileGithubUsernameHint => 'Tu usuario de GitHub';

  @override
  String get profileGithubFieldHint =>
      'Este campo se completa automáticamente tras autenticar con GitHub.';

  @override
  String get profileGithubDefaultMissingKeys =>
      'GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET';

  @override
  String profileGithubOAuthNotConfigured(String missing) {
    return 'GitHub OAuth no configurado. Faltan: $missing. Configura GITHUB_CLIENT_ID y GITHUB_CLIENT_SECRET en el backend y reinicia el servidor.';
  }

  @override
  String get profileDisconnectGithubButton => 'Desconectar GitHub';

  @override
  String get profileLinkGithubButton => 'Vincular con GitHub';

  @override
  String get profileSecurityTitle => 'Seguridad';

  @override
  String get profileChangeUpper => 'CAMBIAR';

  @override
  String get profileCurrentPasswordLabel => 'Contraseña actual';

  @override
  String get profileNewPasswordLabel => 'Nueva contraseña';

  @override
  String get profileConfirmNewPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get profileChangePasswordHint =>
      'Cambia tu contraseña periódicamente para mantener tu cuenta segura.';

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
      'Genera informes en PDF o Excel para imprimir o guardar en tu PC';

  @override
  String get reportSectionType => 'Tipo de informe';

  @override
  String get reportSectionFormat => 'Formato de salida';

  @override
  String get reportSectionPreview => 'Configuración actual';

  @override
  String get reportSelectContainerTitle => 'Selecciona un contenedor';

  @override
  String get reportGenerate => 'Generar informe';

  @override
  String get reportGenerating => 'Generando...';

  @override
  String get reportTypeInventoryDescription =>
      'Listado completo del inventario';

  @override
  String get reportTypeLoansDescription => 'Préstamos activos y su estado';

  @override
  String get reportTypeAssetsDescription => 'Listado de activos por categoría';

  @override
  String get reportLabelContainer => 'Contenedor';

  @override
  String get reportLabelType => 'Tipo de informe';

  @override
  String get reportLabelFormat => 'Formato';

  @override
  String get reportFormatPdf => 'PDF';

  @override
  String get reportFormatExcel => 'Excel';

  @override
  String get reportNotSelected => 'Sin seleccionar';

  @override
  String get reportUnknown => 'Desconocido';

  @override
  String get reportSelectContainerFirst => 'Por favor selecciona un contenedor';

  @override
  String reportDownloadedSuccess(String format) {
    return 'Informe $format descargado correctamente';
  }

  @override
  String reportGenerateError(String error) {
    return 'Error al generar informe: $error';
  }

  @override
  String get firstRunWelcomeTitle => 'Bienvenido a Invenicum';

  @override
  String get firstRunConfigTitle => 'Primera configuración';

  @override
  String get firstRunWelcomeDescription =>
      'Parece que es la primera vez que arrancas la app. Vamos a crear tu cuenta de administrador para empezar.';

  @override
  String get firstRunStep1Label => 'Paso 1 de 2 · Bienvenida';

  @override
  String get firstRunStep2Label => 'Paso 2 de 2 · Crear administrador';

  @override
  String get firstRunSuccessMessage => 'Tu cuenta ha sido creada';

  @override
  String get firstRunAdminTitle => 'Crear administrador';

  @override
  String get firstRunAdminDescription =>
      'Este usuario tendrá acceso total a la plataforma.';

  @override
  String get firstRunFeature1 => 'Crea tu usuario administrador';

  @override
  String get firstRunFeature2 => 'Acceso seguro con contraseña';

  @override
  String get firstRunFeature3 => 'Listo para usar en segundos';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get firstRunSuccessTitle => '¡Cuenta creada!';

  @override
  String get firstRunSuccessSubtitle =>
      'Tu cuenta de administrador está lista.\nYa puedes iniciar sesión.';

  @override
  String get firstRunAccountCreatedLabel => 'CUENTA CREADA';

  @override
  String get firstRunCopyright => 'Invenicum ©';
}
