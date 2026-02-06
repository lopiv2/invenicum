// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

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
  String get aboutInvenicum => 'Sobre Invenicum';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get active => 'Ativo';

  @override
  String get activeLoans => 'Empréstimos ativos';

  @override
  String get activeLoansCount => 'Empréstimos ativos';

  @override
  String get addAlert => 'Adicionar alerta';

  @override
  String get addAsset => 'Adicionar ativo';

  @override
  String get addContainer => 'Adicionar recipiente';

  @override
  String get addNewLocation => 'Adicionar nova localização';

  @override
  String get additionalThumbnails => 'Miniaturas adicionais';

  @override
  String aiExtractionError(Object error) {
    return 'A IA não conseguiu extrair dados: $error';
  }

  @override
  String get aiPasteUrlDescription =>
      'Cole o link do produto e a IA extrairá automaticamente as informações para preencher os campos.';

  @override
  String get all => 'Tudo';

  @override
  String get alertCritical => 'Crítico';

  @override
  String get alertCreated => 'Alerta criado';

  @override
  String get alertDeleted => 'Alerta deletado';

  @override
  String get alertInfo => 'Informações';

  @override
  String get alertMessage => 'Mensagem';

  @override
  String get alertTitle => 'Título';

  @override
  String get alertType => 'Tipo';

  @override
  String get alertWarning => 'Aviso';

  @override
  String get alerts => 'Alertas e notificações';

  @override
  String get appTitle => 'Invenicum Inventário';

  @override
  String get applicationTheme => 'Tema da aplicação';

  @override
  String get apply => 'Aplicar';

  @override
  String get april => 'Abril';

  @override
  String get assetImages => 'Imagens de ativos';

  @override
  String get assetImport => 'Importação de ativos';

  @override
  String get assetName => 'Nome do ativo';

  @override
  String assetTypeDeleted(Object name) {
    return 'Tipo de ativo \"$name\" excluído com sucesso.';
  }

  @override
  String get assetTypes => 'Tipos de ativos';

  @override
  String assetUpdated(Object name) {
    return 'Ativo \"$name\" atualizado com sucesso.';
  }

  @override
  String get assets => 'Ativos';

  @override
  String get assetsIn => 'Ativos em';

  @override
  String get august => 'Agosto';

  @override
  String get backToAssetTypes => 'Voltar aos tipos de ativos';

  @override
  String get borrowerEmail => 'Email do mutuário';

  @override
  String get borrowerName => 'Nome do mutuário';

  @override
  String get borrowerPhone => 'Telefone do mutuário';

  @override
  String get cancel => 'Cancelar';

  @override
  String get centerView => 'Visualização central';

  @override
  String get chooseFile => 'Escolher arquivo';

  @override
  String get clearCounter => 'Limpar contador';

  @override
  String get collectionContainerInfo =>
      'Recipientes de coleção têm barras de rastreamento de coleção, valor investido, valor de mercado e visualização de exposição';

  @override
  String get collectionFieldsConfigured => 'Campos de coleção configurados.';

  @override
  String get configureCollectionFields => 'Configurar campos de coleção';

  @override
  String get configureDeliveryVoucher => 'Configurar comprovante de entrega';

  @override
  String get configureVoucherBody => 'Configurar corpo do comprovante...';

  @override
  String get confirmDeleteAlert => 'Excluir alerta';

  @override
  String get confirmDeleteAlertMessage =>
      'Tem certeza de que deseja excluir este registro?';

  @override
  String confirmDeleteAssetType(Object name) {
    return 'Tem certeza de que deseja excluir o tipo de ativo \"$name\" e todos os seus itens associados? Esta ação não pode ser desfeita.';
  }

  @override
  String confirmDeleteContainer(Object name) {
    return 'Tem certeza de que deseja excluir o recipiente \"$name\"? Esta ação é irreversível e removerá todos os seus ativos e dados.';
  }

  @override
  String confirmDeleteLocationMessage(String name) {
    return 'Tem certeza de que deseja excluir a localização \"$name\"?';
  }

  @override
  String get confirmDeletion => 'Confirmar exclusão';

  @override
  String get configurationSaved => 'Configuração salva com sucesso.';

  @override
  String containerCreated(Object name) {
    return 'Recipiente \"$name\" criado com sucesso.';
  }

  @override
  String containerDeleted(Object name) {
    return 'Recipiente \"$name\" excluído com sucesso.';
  }

  @override
  String get containerName => 'Nome do recipiente';

  @override
  String get containerOrAssetTypeNotFound =>
      'Recipiente ou tipo de ativo não encontrado.';

  @override
  String containerRenamed(Object name) {
    return 'Recipiente renomeado para \"$name\".';
  }

  @override
  String get containers => 'Recipientes';

  @override
  String get countItemsByValue => 'Contar itens por valor específico';

  @override
  String get create => 'Criar';

  @override
  String get createFirstContainer => 'Crie seu primeiro recipiente.';

  @override
  String get current => 'Atual';

  @override
  String get customColor => 'Cor personalizada';

  @override
  String get customFields => 'Campos personalizados';

  @override
  String customFieldsOf(Object name) {
    return 'Campos personalizados de $name';
  }

  @override
  String get customizeDeliveryVoucher =>
      'Personalize o modelo PDF para empréstimos';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get dashboard => 'Painel';

  @override
  String get datalists => 'Listas personalizadas';

  @override
  String get december => 'Dezembro';

  @override
  String get definitionCustomFields => 'Definição de campos personalizados';

  @override
  String get delete => 'Excluir';

  @override
  String deleteError(String error) {
    return 'Erro ao excluir: $error';
  }

  @override
  String get deleteSuccess => 'Localização excluída com sucesso.';

  @override
  String get deliveryVoucher => 'COMPROVANTE DE ENTREGA';

  @override
  String get deliveryVoucherEditor => 'Editor de comprovante de entrega';

  @override
  String get description => 'Descrição (opcional)';

  @override
  String get desiredField => 'Campo desejado';

  @override
  String get dueDate => 'Data de vencimento';

  @override
  String get edit => 'Editar';

  @override
  String get enterContainerName => 'Digite o nome do recipiente';

  @override
  String get enterDescription => 'Digite uma descrição';

  @override
  String get enterURL => 'Digite URL';

  @override
  String get enterValidUrl => 'Digite uma URL válida';

  @override
  String get errorCsvMinRows =>
      'Selecione um arquivo CSV com cabeçalhos e pelo menos uma linha de dados.';

  @override
  String errorDeletingAssetType(Object error) {
    return 'Erro ao excluir tipo de ativo: $error';
  }

  @override
  String errorDeletingContainer(Object error) {
    return 'Erro ao excluir recipiente: $error';
  }

  @override
  String get errorDuringImport => 'Erro durante a importação';

  @override
  String get errorEmptyCsv => 'O arquivo CSV está vazio.';

  @override
  String errorGeneratingPDF(Object error) {
    return 'Erro ao gerar PDF: $error';
  }

  @override
  String get errorInvalidPath => 'Caminho do arquivo inválido.';

  @override
  String get errorLoadingData => 'Erro ao carregar dados';

  @override
  String errorLoadingListValues(Object error) {
    return 'Erro ao carregar valores da lista: $error';
  }

  @override
  String errorLoadingLocations(String error) {
    return 'Erro ao carregar localizações: $error';
  }

  @override
  String get errorNameMappingRequired =>
      'O campo \"Nome\" é obrigatório e deve ser mapeado.';

  @override
  String get errorNoVoucherTemplate =>
      'Nenhum modelo de comprovante configurado.';

  @override
  String get errorReadingBytes => 'Não foi possível ler bytes do arquivo.';

  @override
  String errorReadingFile(String error) {
    return 'Erro ao ler arquivo: $error';
  }

  @override
  String errorRegisteringLoan(Object error) {
    return 'Erro ao registrar empréstimo: $error';
  }

  @override
  String errorRenaming(Object error) {
    return 'Erro ao renomear: $error';
  }

  @override
  String errorSaving(Object error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String errorUpdatingAsset(Object error) {
    return 'Erro ao atualizar ativo: $error';
  }

  @override
  String get exampleFilterHint => 'Ex: Danificado, Vermelho, 50';

  @override
  String errorChangingLanguage(Object error) {
    return 'Erro ao alterar idioma: $error';
  }

  @override
  String get february => 'Fevereiro';

  @override
  String get fieldChip => 'Campo';

  @override
  String fieldRequiredWithName(Object field) {
    return 'O campo \"$field\" é obrigatório.';
  }

  @override
  String get fieldToCount => 'Campo para contar';

  @override
  String get fieldsFilledSuccess => 'Campos preenchidos com sucesso!';

  @override
  String get formatsPNG => 'Formatos: PNG, JPG';

  @override
  String get generalSettings => 'Configurações gerais';

  @override
  String get generateVoucher => 'Gerar comprovante de entrega';

  @override
  String get globalSearch => 'Pesquisa global';

  @override
  String get greeting => 'Olá, bem-vindo!';

  @override
  String get guest => 'Convidado';

  @override
  String get ignoreField => '🚫 Ignorar campo';

  @override
  String get importAssetsTo => 'Importar ativos para';

  @override
  String importSuccessMessage(String count) {
    return 'Importação bem-sucedida! $count ativos criados.';
  }

  @override
  String get invalidNavigationIds => 'Erro: IDs de navegação inválidos.';

  @override
  String get january => 'Janeiro';

  @override
  String get july => 'Julho';

  @override
  String get june => 'Junho';

  @override
  String get language => 'Idioma';

  @override
  String get languageNotImplemented =>
      'Funcionalidade de idioma a ser implementada';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get loadingAssetType => 'Carregando tipo de ativo...';

  @override
  String loadingListField(Object field) {
    return 'Carregando $field...';
  }

  @override
  String get loanDate => 'Data do empréstimo';

  @override
  String get languageChanged => 'Idioma alterado para português!';

  @override
  String get loanLanguageNotImplemented =>
      'Language functionality to be implemented';

  @override
  String get loanManagement => 'Gestão de empréstimos';

  @override
  String get loanObject => 'Objeto de empréstimo';

  @override
  String get loans => 'Empréstimos';

  @override
  String get locations => 'Localizações';

  @override
  String get locationsScheme => 'Esquema de localizações';

  @override
  String get login => 'Login';

  @override
  String get logoVoucher => 'Logo do comprovante';

  @override
  String get logout => 'Logout';

  @override
  String get magicAssistant => 'Assistente IA mágico';

  @override
  String get march => 'Março';

  @override
  String get may => 'Maio';

  @override
  String get myCustomTheme => 'Meu tema';

  @override
  String get myProfile => 'Meu perfil';

  @override
  String get myThemesStored => 'Meus temas salvos';

  @override
  String get nameCannotBeEmpty => 'O nome não pode estar vazio';

  @override
  String get nameSameAsCurrent => 'O nome é igual ao atual';

  @override
  String get newAlert => 'Novo alerta manual';

  @override
  String get newContainer => 'Novo recipiente';

  @override
  String get newName => 'Novo nome';

  @override
  String get noAssetsCreated => 'Nenhum ativo criado ainda.';

  @override
  String get noAssetsMatch =>
      'Nenhum ativo corresponde aos critérios de pesquisa/filtro.';

  @override
  String get noBooleanFields => 'Nenhum campo booleano definido.';

  @override
  String get noContainerMessage => 'Crie seu primeiro recipiente.';

  @override
  String get noCustomFields =>
      'Este tipo de ativo não tem campos personalizados.';

  @override
  String get noFileSelected => 'Nenhum arquivo selecionado';

  @override
  String get noImagesAdded =>
      'Nenhuma imagem adicionada ainda. A primeira imagem será a principal.';

  @override
  String get noLoansFound => 'Nenhum empréstimo encontrado neste recipiente.';

  @override
  String get noLocationsMessage =>
      'Nenhuma localização criada neste recipiente. Adicione uma!';

  @override
  String get noNotifications => 'Sem notificações';

  @override
  String get noThemesSaved => 'Nenhum tema salvo ainda';

  @override
  String get none => 'Nenhum';

  @override
  String get november => 'Novembro';

  @override
  String get obligatory => 'Obrigatório';

  @override
  String get october => 'Outubro';

  @override
  String get optional => 'Opcional';

  @override
  String get overdue => 'Vencido';

  @override
  String get password => 'Senha';

  @override
  String get pleaseEnterPassword => 'Digite sua senha';

  @override
  String get pleaseEnterUsername => 'Digite seu nome de usuário';

  @override
  String get pleasePasteUrl => 'Cole uma URL';

  @override
  String get pleaseSelectCsvWithHeaders =>
      'Selecione um arquivo CSV com cabeçalhos.';

  @override
  String get pleaseSelectLocation => 'Selecione uma localização.';

  @override
  String get possessionFieldDef => 'Campo de posse';

  @override
  String get possessionFieldName => 'Em posse';

  @override
  String get preferences => 'Preferências';

  @override
  String get previewPDF => 'Visualização em PDF';

  @override
  String get primaryImage => 'Imagem principal';

  @override
  String get productUrlLabel => 'URL do produto';

  @override
  String get quantity => 'Quantidade';

  @override
  String get registerNewLoan => 'Registrar novo empréstimo';

  @override
  String get reloadContainers => 'Recarregar recipientes';

  @override
  String get reloadLocations => 'Recarregar localizações';

  @override
  String get removeImage => 'Remover imagem';

  @override
  String get rename => 'Renomear';

  @override
  String get renameContainer => 'Renomear recipiente';

  @override
  String get returned => 'Retornado';

  @override
  String get rowsPerPageTitle => 'Ativos por página:';

  @override
  String get save => 'Salvar';

  @override
  String get saveAndApply => 'Salvar e aplicar';

  @override
  String get saveAsset => 'Salvar ativo';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get saveConfiguration => 'Salvar configuração';

  @override
  String get saveCustomTheme => 'Salvar tema personalizado';

  @override
  String get searchInAllColumns => 'Pesquisar em todas as colunas...';

  @override
  String get selectAndUploadImage => 'Selecionar e fazer upload de imagem';

  @override
  String get selectApplicationLanguage => 'Selecionar idioma da aplicação';

  @override
  String get selectBooleanFields =>
      'Selecione campos booleanos para controlar a coleção:';

  @override
  String get selectCsvColumn => 'Selecionar coluna CSV';

  @override
  String get selectField => 'Selecionar campo...';

  @override
  String get selectFieldType => 'Selecionar tipo de campo';

  @override
  String get selectImage => 'Selecionar imagem';

  @override
  String get selectLocationRequired =>
      'Você deve selecionar uma localização para o ativo.';

  @override
  String selectedLocationLabel(String name) {
    return 'Selecionado: $name';
  }

  @override
  String get selectTheme => 'Selecionar tema';

  @override
  String get september => 'Setembro';

  @override
  String get settings => 'Configurações';

  @override
  String get showAsGrid => 'Mostrar como grade';

  @override
  String get showAsList => 'Mostrar como lista';

  @override
  String get specificValueToCount => 'Valor específico para contar';

  @override
  String get startImport => 'Iniciar importação';

  @override
  String get startMagic => 'Iniciar magia';

  @override
  String get status => 'Status';

  @override
  String get step1SelectFile => 'Etapa 1: Selecionar arquivo CSV';

  @override
  String get step2ColumnMapping =>
      'Etapa 2: Mapeamento de colunas (CSV -> Sistema)';

  @override
  String get syncingSession => 'Sincronizando sessão...';

  @override
  String get systemThemes => 'Temas do sistema';

  @override
  String get systemThemesModal => 'Temas do sistema';

  @override
  String get themeNameLabel => 'Nome do tema';

  @override
  String get thisFieldIsRequired => 'Este campo é obrigatório.';

  @override
  String get topLoanedItems => 'Itens mais emprestados';

  @override
  String get totalAssets => 'Tipos de ativos';

  @override
  String get totalItems => 'Ativos';

  @override
  String get totals => 'Totais';

  @override
  String get upload => 'Upload';

  @override
  String get uploadImage => 'Fazer upload de imagem';

  @override
  String get username => 'Nome de usuário';

  @override
  String get veniChatTitle => 'Veni IA';

  @override
  String get veniChatStatus => 'Online';

  @override
  String get veniChatWelcome =>
      'Oi! Sou Veni, seu assistente Invenicum. Como posso ajudá-lo com seu inventário hoje?';

  @override
  String get veniChatPlaceholder => 'Pergunte-me qualquer coisa...';

  @override
  String get veniChatPoweredBy => 'Powered by ';

  @override
  String veniChatProcessing(String query) {
    return 'Estou processando sua pergunta sobre \"$query\"...';
  }

  @override
  String get veniCmdHelpTitle => 'Habilidades do Veni';

  @override
  String get veniCmdDashboard => 'Ir para o painel';

  @override
  String get veniCmdInventory => 'Verificar estoque de um artigo';

  @override
  String get veniCmdLoans => 'Ver empréstimos ativos';

  @override
  String get veniCmdReport => 'Gerar relatório de inventário';

  @override
  String get veniCmdScanQR => 'Digitalizar QR/Código de barras';

  @override
  String get veniCmdUnknown =>
      'Não reconheço esse comando. Escreva ajuda para ver o que posso fazer.';

  @override
  String version(String name) {
    return 'Versão $name';
  }

  @override
  String get yes => 'Sim';

  @override
  String get zoomToFit => 'Zoom para ajustar';
}
