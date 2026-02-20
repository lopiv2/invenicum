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
  String get active => 'Activo';

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
  String get magicAssistant => 'Asistente Mágico IA';

  @override
  String get march => 'Marzo';

  @override
  String get may => 'Mayo';

  @override
  String get minStock => 'Stock mínimo';

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
  String get returned => 'Devuelto';

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
  String get themeNameLabel => 'Nombre del Tema';

  @override
  String get thisFieldIsRequired => 'Este campo es obligatorio.';

  @override
  String get topLoanedItems => 'Productos más prestados por meses';

  @override
  String get totalAssets => 'Tipos de Activos';

  @override
  String get totalItems => 'Activos';

  @override
  String get totals => 'Totales';

  @override
  String get updatedAt => 'Última actualización';

  @override
  String get upload => 'Subir';

  @override
  String get uploadImage => 'Subir Imagen';

  @override
  String get username => 'Usuario';

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
}
