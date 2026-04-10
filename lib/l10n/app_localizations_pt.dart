// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get aboutInvenicum => 'Sobre o Invenicum';

  @override
  String get deliveryVoucherTitle => 'RECIBO DE ENTREGA';

  @override
  String get aboutDialogTitle => 'Sobre o Invenicum';

  @override
  String get aboutDialogCoolText =>
      'Seu inventário, agora turbinado. Estamos verificando se existe uma versão mais nova esperando por você.';

  @override
  String get aboutCurrentVersionLabel => 'Versão atual';

  @override
  String get aboutLatestVersionLabel => 'Última versão';

  @override
  String get aboutCheckingVersion => 'Verificando versão online...';

  @override
  String get aboutVersionUnknown => 'Desconhecida';

  @override
  String get aboutVersionUpToDate => 'Seu app está atualizado.';

  @override
  String get aboutUpdateAvailable => 'Há uma nova versão disponível.';

  @override
  String get aboutVersionCheckFailed =>
      'Não foi possível verificar a versão online.';

  @override
  String get aboutOpenReleases => 'Ver lançamentos';

  @override
  String get active => 'Ativo';

  @override
  String get actives => 'Ativos';

  @override
  String get activeInsight => 'INFORMAÇÕES DE ATIVOS VIGENTES';

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
  String get additionalInformation => 'Informações adicionais';

  @override
  String get additionalThumbnails => 'Miniaturas adicionais';

  @override
  String get adquisition => 'AQUISIÇÃO';

  @override
  String aiExtractionError(String error) {
    return 'A IA não conseguiu extrair dados: $error';
  }

  @override
  String get aiPasteUrlDescription =>
      'Cole o link do produto e a IA extrairá automaticamente as informações para preencher os campos.';

  @override
  String get alertCritical => 'Crítico';

  @override
  String get alertCreated => 'Alerta criado';

  @override
  String get alertDeleted => 'Alerta excluído';

  @override
  String get alertInfo => 'Informação';

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
  String get all => 'Todos';

  @override
  String get allUpToDateStatus => 'Tudo em dia';

  @override
  String get appTitle => 'Invenicum Inventário';

  @override
  String get applicationTheme => 'Tema da aplicação';

  @override
  String get apply => 'Aplicar';

  @override
  String get april => 'Abril';

  @override
  String get assetDetail => 'Detalhes do ativo';

  @override
  String get assetImages => 'Imagens do ativo';

  @override
  String get assetImport => 'Importação de ativos';

  @override
  String get assetName => 'Nome';

  @override
  String get assetNotFound => 'Ativo não encontrado';

  @override
  String assetTypeDeleted(String name) {
    return 'Tipo de ativo \"$name\" excluído com sucesso.';
  }

  @override
  String get assetTypes => 'Tipos de ativos';

  @override
  String assetUpdated(String name) {
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
  String get averageMarketValue => 'Preço médio de mercado';

  @override
  String get barCode => 'Código de barras (EAN)';

  @override
  String get baseCostAccumulatedWithoutInflation =>
      'Custo base acumulado sem inflação';

  @override
  String get borrowerEmail => 'E-mail do mutuário';

  @override
  String get borrowerName => 'Nome do mutuário';

  @override
  String get borrowerPhone => 'Telefone do mutuário';

  @override
  String get cancel => 'Cancelar';

  @override
  String get centerView => 'Centralizar visualização';

  @override
  String get chooseFile => 'Escolher arquivo';

  @override
  String get clearCounter => 'Limpar contador';

  @override
  String get collectionContainerInfo =>
      'Recipientes de coleção têm barras de rastreamento, valor investido, valor de mercado e visualização de exposição';

  @override
  String get collectionFieldsConfigured => 'Campos de coleção configurados.';

  @override
  String get condition => 'Condição';

  @override
  String get condition_mint => 'Caixa original';

  @override
  String get condition_loose => 'Solto (sem caixa)';

  @override
  String get condition_incomplete => 'Incompleto';

  @override
  String get condition_damaged => 'Danificado / Marcas';

  @override
  String get condition_new => 'Novo';

  @override
  String get condition_digital => 'Digital / Intangível';

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
  String confirmDeleteAssetType(String name) {
    return 'Tem certeza de que deseja excluir o tipo de ativo \"$name\" e todos os seus itens associados? Esta ação não pode ser desfeita.';
  }

  @override
  String confirmDeleteContainer(String name) {
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
  String containerCreated(String name) {
    return 'Recipiente \"$name\" criado com sucesso.';
  }

  @override
  String containerDeleted(String name) {
    return 'Recipiente \"$name\" excluído com sucesso.';
  }

  @override
  String get containerName => 'Nome do recipiente';

  @override
  String get containerOrAssetTypeNotFound =>
      'Recipiente ou tipo de ativo não encontrado.';

  @override
  String containerRenamed(String name) {
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
  String get createdAt => 'Data de criação';

  @override
  String get currency => 'Moeda';

  @override
  String get current => 'Atual';

  @override
  String get customColor => 'Cor personalizada';

  @override
  String get customFields => 'Campos personalizados';

  @override
  String customFieldsOf(String name) {
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
  String get enterURL => 'Digite a URL';

  @override
  String get enterValidUrl => 'Digite uma URL válida';

  @override
  String errorChangingLanguage(String error) {
    return 'Erro ao alterar idioma: $error';
  }

  @override
  String get errorCsvMinRows =>
      'Selecione um arquivo CSV com cabeçalhos e pelo menos uma linha de dados.';

  @override
  String errorDeletingAssetType(String error) {
    return 'Erro ao excluir tipo de ativo: $error';
  }

  @override
  String errorDeletingContainer(String error) {
    return 'Erro ao excluir recipiente: $error';
  }

  @override
  String get errorDuringImport => 'Erro durante a importação';

  @override
  String get errorEmptyCsv => 'O arquivo CSV está vazio.';

  @override
  String errorGeneratingPDF(String error) {
    return 'Erro ao gerar PDF: $error';
  }

  @override
  String get errorInvalidPath => 'Caminho do arquivo inválido.';

  @override
  String get errorLoadingData => 'Erro ao carregar dados';

  @override
  String errorLoadingListValues(String error) {
    return 'Erro ao carregar valores da lista: $error';
  }

  @override
  String errorLoadingLocations(String error) {
    return 'Erro ao carregar localizações: $error';
  }

  @override
  String get errorNameMappingRequired =>
      'O campo \'Nome\' é obrigatório e deve ser mapeado.';

  @override
  String get errorNoVoucherTemplate =>
      'Nenhum modelo de comprovante configurado.';

  @override
  String get errorNotBarCode =>
      'O item não possui código de barras ou o código não é válido.';

  @override
  String get errorReadingBytes => 'Não foi possível ler os bytes do arquivo.';

  @override
  String errorReadingFile(String error) {
    return 'Erro ao ler arquivo: $error';
  }

  @override
  String errorRegisteringLoan(String error) {
    return 'Erro ao registrar empréstimo: $error';
  }

  @override
  String errorRenaming(String error) {
    return 'Erro ao renomear: $error';
  }

  @override
  String errorSaving(String error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String errorUpdatingAsset(String error) {
    return 'Erro ao atualizar ativo: $error';
  }

  @override
  String get exampleFilterHint => 'Ex: Danificado, Vermelho, 50';

  @override
  String get february => 'Fevereiro';

  @override
  String get fieldChip => 'Campo';

  @override
  String fieldRequiredWithName(String field) {
    return 'O campo \"$field\" é obrigatório.';
  }

  @override
  String get fieldToCount => 'Campo para contar';

  @override
  String get fieldsFilledSuccess => 'Campos preenchidos com sucesso!';

  @override
  String get formatsPNG => 'Formatos: PNG, JPG';

  @override
  String get forToday => 'Para hoje';

  @override
  String get geminiLabelModel =>
      'Modelo Gemini recomendado: gemini-3-flash-preview';

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
  String get helpDocs => 'Ajuda e documentação';

  @override
  String get helperGeminiKey =>
      'Insira sua chave de API do Gemini para ativar a integração. Obtenha em https://aistudio.google.com/';

  @override
  String get ignoreField => '🚫 Ignorar campo';

  @override
  String get importAssetsTo => 'Importar ativos para';

  @override
  String importSuccessMessage(int count) {
    return 'Importação bem-sucedida! $count ativos criados.';
  }

  @override
  String get importSerializedWarning =>
      'Importação correta. Este tipo de ativo é serializado — todos os itens foram criados com quantidade 1.';

  @override
  String get integrations => 'Integrações';

  @override
  String get integrationGeminiDesc =>
      'Conecte o Invenicum ao Gemini do Google para aproveitar recursos avançados de IA na gestão do seu inventário.';

  @override
  String get integrationTelegramDesc =>
      'Conecte o Invenicum ao Telegram para receber notificações instantâneas sobre o seu inventário diretamente no seu dispositivo.';

  @override
  String get invalidAssetId => 'ID de ativo inválido';

  @override
  String get invalidNavigationIds => 'Erro: IDs de navegação inválidos.';

  @override
  String get inventoryLabel => 'Inventário';

  @override
  String get january => 'Janeiro';

  @override
  String get july => 'Julho';

  @override
  String get june => 'Junho';

  @override
  String get language => 'Idioma';

  @override
  String get languageChanged => 'Idioma alterado para português!';

  @override
  String get languageNotImplemented =>
      'Funcionalidade de idioma a ser implementada';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get loadingAssetType => 'Carregando tipo de ativo...';

  @override
  String loadingListField(String field) {
    return 'Carregando $field...';
  }

  @override
  String get loanDate => 'Data do empréstimo';

  @override
  String get loanLanguageNotImplemented =>
      'Funcionalidade de idioma a ser implementada';

  @override
  String get loanManagement => 'Gestão de empréstimos';

  @override
  String get loanObject => 'Objeto a emprestar';

  @override
  String get loans => 'Empréstimos';

  @override
  String get location => 'Localização';

  @override
  String get locations => 'Localizações';

  @override
  String get locationsScheme => 'Esquema de localizações';

  @override
  String get login => 'Entrar';

  @override
  String get logoVoucher => 'Logo do comprovante';

  @override
  String get logout => 'Sair';

  @override
  String get lookForContainersOrAssets => 'Buscar recipientes ou ativos...';

  @override
  String get lowStockTitle => 'Estoque baixo';

  @override
  String get magicAssistant => 'Assistente mágico de IA';

  @override
  String get march => 'Março';

  @override
  String get marketPriceObtained => 'Preço de mercado obtido com sucesso';

  @override
  String get marketValueEvolution => 'Evolução do valor de mercado';

  @override
  String get marketValueField => 'Valor de mercado';

  @override
  String get maxStock => 'Estoque máximo';

  @override
  String get may => 'Maio';

  @override
  String get minStock => 'Estoque mínimo';

  @override
  String get myAchievements => 'Minhas conquistas';

  @override
  String get myCustomTheme => 'Meu tema';

  @override
  String get myProfile => 'Meu perfil';

  @override
  String get myThemesStored => 'Meus temas salvos';

  @override
  String get name => 'Nome';

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
  String get next => 'Próximo';

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
  String get noImageAvailable => 'Nenhuma imagem disponível';

  @override
  String get noImagesAdded =>
      'Nenhuma imagem adicionada ainda. A primeira imagem será a principal.';

  @override
  String get noLoansFound => 'Nenhum empréstimo encontrado neste recipiente.';

  @override
  String get noLocationsMessage =>
      'Nenhuma localização criada neste recipiente. Adicione a primeira!';

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
  String get optimalStockStatus => 'Estoque em níveis ideais';

  @override
  String get optional => 'Opcional';

  @override
  String get overdue => 'Vencido';

  @override
  String get password => 'Senha';

  @override
  String get pleaseEnterPassword => 'Por favor, insira sua senha';

  @override
  String get pleaseEnterUsername => 'Por favor, insira seu nome de usuário';

  @override
  String get pleasePasteUrl => 'Por favor, cole uma URL';

  @override
  String get pleaseSelectCsvWithHeaders =>
      'Por favor, selecione um arquivo CSV com cabeçalhos.';

  @override
  String get pleaseSelectLocation => 'Por favor, selecione uma localização.';

  @override
  String get plugins => 'Plugins';

  @override
  String get possessionFieldDef => 'Campo de posse';

  @override
  String get possessionFieldName => 'Em posse';

  @override
  String get preferences => 'Preferências';

  @override
  String get previewPDF => 'Visualização';

  @override
  String get previous => 'Anterior';

  @override
  String get primaryImage => 'Imagem principal';

  @override
  String get productUrlLabel => 'URL do produto';

  @override
  String get quantity => 'Quantidade';

  @override
  String get refresh => 'Recarregar dados';

  @override
  String get registerNewLoan => 'Registrar novo empréstimo';

  @override
  String get reloadContainers => 'Recarregar recipientes';

  @override
  String get reloadLocations => 'Recarregar localizações';

  @override
  String get reloadLoans => 'Recarregar empréstimos';

  @override
  String get removeImage => 'Remover imagem';

  @override
  String get rename => 'Renomear';

  @override
  String get renameContainer => 'Renomear recipiente';

  @override
  String get responsibleLabel => 'Responsável';

  @override
  String get reports => 'Relatórios';

  @override
  String get returned => 'Devolvido';

  @override
  String get returnsLabel => 'Devoluções';

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
  String get selectAndUploadImage => 'Selecionar e enviar imagem';

  @override
  String get selectApplicationCurrency => 'Selecionar moeda da aplicação';

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
  String get slotDashboardBottom => 'Painel inferior';

  @override
  String get slotDashboardTop => 'Painel superior';

  @override
  String get slotFloatingActionButton => 'Botão flutuante';

  @override
  String get slotInventoryHeader => 'Cabeçalho do inventário';

  @override
  String get slotLeftSidebar => 'Barra lateral esquerda';

  @override
  String get slotUnknown => 'Slot desconhecido';

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
  String get templates => 'Modelos';

  @override
  String get themeNameLabel => 'Nome do tema';

  @override
  String get thisFieldIsRequired => 'Este campo é obrigatório.';

  @override
  String get topDemanded => 'Mais solicitados';

  @override
  String get topLoanedItems => 'Itens mais emprestados por mês';

  @override
  String get totalAssets => 'Tipos de ativos';

  @override
  String get totalItems => 'Ativos';

  @override
  String get totals => 'Totais';

  @override
  String get totalSpending => 'Investimento total';

  @override
  String get totalMarketValue => 'Valor total de mercado';

  @override
  String get updatedAt => 'Última atualização';

  @override
  String get upload => 'Enviar';

  @override
  String get uploadImage => 'Enviar imagem';

  @override
  String get username => 'Nome de usuário';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get connectionTestFailed => 'O teste de conexão falhou';

  @override
  String get connectionVerified => 'Conexão verificada com sucesso';

  @override
  String get errorSavingConfiguration => 'Erro ao salvar a configuração';

  @override
  String get integrationsAndConnectionsTitle => 'Integrações e conexões';

  @override
  String get integrationsSectionAiTitle => 'Inteligência artificial';

  @override
  String get integrationsSectionAiSubtitle =>
      'Motores conversacionais e assistentes para enriquecer fluxos e automações.';

  @override
  String get integrationsSectionMessagingTitle => 'Mensageria e notificações';

  @override
  String get integrationsSectionMessagingSubtitle =>
      'Canais de saída para avisos, bots, relatórios e entregas automáticas.';

  @override
  String get integrationsSectionDataApisTitle => 'APIs de dados';

  @override
  String get integrationsSectionDataApisSubtitle =>
      'Fontes externas para enriquecer fichas, cartas, jogos e referências de catálogo.';

  @override
  String get integrationsSectionValuationTitle => 'Avaliação e mercado';

  @override
  String get integrationsSectionValuationSubtitle =>
      'Conectores para preços, códigos de barras e estimativa de valor atualizado.';

  @override
  String get integrationsSectionHardwareTitle => 'Hardware e etiquetas';

  @override
  String get integrationsSectionHardwareSubtitle =>
      'Ferramentas físicas e utilitários para impressão, codificação e operação.';

  @override
  String integrationsActiveConnections(int count) {
    return '$count conexões ativas';
  }

  @override
  String get integrationsModularDesign => 'Design modular por categorias';

  @override
  String get integrationsCheckingStatuses => 'Verificando status';

  @override
  String get integrationsStatusSynced => 'Status sincronizado';

  @override
  String get integrationsHeroHeadline =>
      'Conecte serviços, APIs e ferramentas em uma única visão clara.';

  @override
  String get integrationsHeroSubheadline =>
      'Agrupamos as integrações por propósito para que a configuração seja mais rápida, mais visual e mais fácil de manter também no celular.';

  @override
  String get integrationStatusConnected => 'Conectada';

  @override
  String get integrationStatusNotConfigured => 'Não configurada';

  @override
  String get integrationTypeDataSource => 'Fonte de dados';

  @override
  String get integrationTypeConnector => 'Conector';

  @override
  String integrationFieldsCount(int count) {
    return '$count campos';
  }

  @override
  String get integrationNoLocalCredentials => 'Sem credenciais locais';

  @override
  String get configureLabel => 'Configurar';

  @override
  String get integrationModelDefaultGemini => 'Padrão: gemini-3-flash-preview';

  @override
  String get integrationOpenaiDesc =>
      'Use GPT-4o e outros modelos da OpenAI como assistente inteligente.';

  @override
  String get integrationOpenaiApiKeyHint =>
      'Obtida em platform.openai.com/api-keys';

  @override
  String get integrationModelDefaultOpenai => 'Padrão: gpt-4o';

  @override
  String get integrationClaudeDesc =>
      'Use Claude Sonnet, Opus e Haiku como assistente inteligente.';

  @override
  String get integrationClaudeApiKeyHint =>
      'Obtida em console.anthropic.com/settings/keys';

  @override
  String get integrationModelDefaultClaude => 'Padrão: claude-sonnet-4-6';

  @override
  String get integrationTelegramBotTokenHint => 'De @BotFather';

  @override
  String get integrationTelegramChatIdHint =>
      'Use @userinfobot para obter seu ID';

  @override
  String get integrationEmailDesc =>
      'Envio de e-mails altamente confiável. Ideal para relatórios e alertas críticos.';

  @override
  String get integrationEmailApiKeyHint => 'Obtida em resend.com/api-keys';

  @override
  String get integrationEmailFromLabel => 'Remetente (De)';

  @override
  String get integrationEmailFromHint =>
      'Ex: Invenicum <onboarding@resend.dev>';

  @override
  String get integrationBggDesc =>
      'Conecte sua conta do BGG para sincronizar sua coleção e enriquecer seus dados automaticamente.';

  @override
  String get integrationPokemonDesc =>
      'Conecte-se à API do Pokémon para sincronizar sua coleção e enriquecer seus dados automaticamente.';

  @override
  String get integrationTcgdexDesc =>
      'Consulte cartas e expansões de jogos de cartas colecionáveis para enriquecer seu inventário automaticamente.';

  @override
  String get integrationQrGeneratorName => 'Gerador de QR';

  @override
  String get integrationQrLabelsDesc =>
      'Configure o formato das suas etiquetas imprimíveis.';

  @override
  String get integrationQrPageSizeLabel => 'Tamanho de página (A4, Carta)';

  @override
  String get integrationQrMarginLabel => 'Margem (mm)';

  @override
  String get integrationPriceChartingDesc =>
      'Configure sua chave de API para obter preços atualizados.';

  @override
  String get integrationUpcitemdbDesc =>
      'Pesquisa global de preços por código de barras.';

  @override
  String integrationConfiguredSuccess(String name) {
    return '$name configurado com sucesso';
  }

  @override
  String integrationUnlinkedWithName(String name) {
    return '$name foi desvinculado';
  }

  @override
  String get invalidUiFormat => 'Formato de UI inválido';

  @override
  String get loadingConfiguration => 'Carregando configuração...';

  @override
  String pageNotFoundUri(String uri) {
    return 'Página não encontrada: $uri';
  }

  @override
  String get pluginLoadError => 'Erro ao carregar a interface do plugin';

  @override
  String get pluginRenderError => 'Erro de renderização';

  @override
  String get testConnection => 'Testar conexão';

  @override
  String get testingConnection => 'Testando...';

  @override
  String get unableToUnlinkAccount => 'Não foi possível desvincular a conta';

  @override
  String get unlinkIntegrationUpper => 'DESVINCULAR INTEGRAÇÃO';

  @override
  String get upcFreeModeHint =>
      'Deixe este campo vazio para usar o modo gratuito (limitado).';

  @override
  String get alertsTabLabel => 'Alertas';

  @override
  String get alertMarkedAsRead => 'Marcado como lido';

  @override
  String get calendarTabLabel => 'Calendário';

  @override
  String get closeLabel => 'Fechar';

  @override
  String get closeLabelUpper => 'FECHAR';

  @override
  String get configureReminderLabel => 'Configurar aviso:';

  @override
  String get cannotFormatInvalidJson =>
      'Não é possível formatar um JSON inválido';

  @override
  String get createAlertOrEventTitle => 'Criar alerta/evento';

  @override
  String get createdSuccessfully => 'Criado com sucesso';

  @override
  String get createPluginTitle => 'Criar plugin';

  @override
  String get editPluginTitle => 'Editar plugin';

  @override
  String get deleteFromGithubLabel => 'Excluir do GitHub';

  @override
  String get deleteFromGithubSubtitle => 'Remove o arquivo do mercado público';

  @override
  String get deletePluginQuestion => 'Excluir plugin?';

  @override
  String get deletePluginLocalWarning =>
      'Será removido do seu banco de dados local.';

  @override
  String get deleteUpper => 'EXCLUIR';

  @override
  String get editEventTitle => 'Editar evento';

  @override
  String get editLabel => 'Editar';

  @override
  String get eventDataSection => 'Dados do evento';

  @override
  String get eventReminderAtTime => 'No horário do evento';

  @override
  String get eventUpdated => 'Evento atualizado';

  @override
  String get firstVersionHint => 'A primeira versão será sempre 1.0.0';

  @override
  String get fixJsonBeforeSave => 'Corrija o JSON antes de salvar';

  @override
  String get formatJson => 'Formatar JSON';

  @override
  String get goToProfileUpper => 'IR AO PERFIL';

  @override
  String get installPluginLabel => 'Instalar plugin';

  @override
  String get invalidVersionFormat => 'Formato inválido (ex: 1.0.1)';

  @override
  String get isEventQuestion => 'É um evento?';

  @override
  String get jsonErrorGeneric => 'Erro no JSON';

  @override
  String get makePublicLabel => 'Tornar público';

  @override
  String get markAsReadLabel => 'Marcar como lido';

  @override
  String get messageWithColon => 'Mensagem:';

  @override
  String minutesBeforeLabel(int minutes) {
    return '$minutes minutos antes';
  }

  @override
  String get newLabel => 'Novo';

  @override
  String get newPluginLabel => 'Novo plugin';

  @override
  String get noActiveAlerts => 'Nenhum alerta ativo';

  @override
  String get noDescriptionAvailable => 'Sem descrição disponível.';

  @override
  String get noEventsForDay => 'Sem eventos para este dia';

  @override
  String get noPluginsAvailable => 'Nenhum plugin disponível';

  @override
  String get notificationDeleted => 'Notificação excluída com sucesso';

  @override
  String get oneHourBeforeLabel => '1 hora antes';

  @override
  String get pluginPrivateDescription =>
      'Somente você poderá ver este plugin na sua lista.';

  @override
  String get pluginPublicDescription =>
      'Outros usuários poderão ver e instalar este plugin.';

  @override
  String get pluginTabLibrary => 'Biblioteca';

  @override
  String get pluginTabMarket => 'Mercado';

  @override
  String get pluginTabMine => 'Meus';

  @override
  String get previewLabel => 'Visualização';

  @override
  String get remindMeLabel => 'Me avisar:';

  @override
  String get requiredField => 'Obrigatório';

  @override
  String get requiresGithubDescription =>
      'Para publicar plugins na comunidade, você deve vincular sua conta do GitHub para ser creditado como autor.';

  @override
  String get requiresGithubTitle => 'Requer GitHub';

  @override
  String get slotLocationLabel => 'Localização (slot)';

  @override
  String get stacDocumentation => 'Documentação do Stac';

  @override
  String get stacJsonInterfaceLabel => 'JSON Stac (interface)';

  @override
  String get uninstallLabel => 'Desinstalar';

  @override
  String get unrecognizedStacStructure => 'Estrutura Stac não reconhecida';

  @override
  String get updateLabelUpper => 'ATUALIZAR';

  @override
  String updateToVersion(String version) {
    return 'Atualizar para v$version';
  }

  @override
  String get versionLabel => 'Versão';

  @override
  String get incrementVersionHint =>
      'Incremente a versão para sua proposta (ex: 1.1.0)';

  @override
  String get cancelUpper => 'CANCELAR';

  @override
  String get mustLinkGithubToPublishTemplate =>
      'Você deve vincular o GitHub no seu perfil para publicar.';

  @override
  String get templateNeedsAtLeastOneField =>
      'O modelo deve ter pelo menos um campo definido.';

  @override
  String get templatePullRequestCreated =>
      'Proposta enviada. Um Pull Request foi criado no GitHub.';

  @override
  String errorPublishingTemplate(String error) {
    return 'Erro ao publicar: $error';
  }

  @override
  String get createGlobalTemplateTitle => 'Criar modelo global';

  @override
  String get githubVerifiedLabel => 'GitHub verificado';

  @override
  String get githubNotLinkedLabel => 'GitHub não vinculado';

  @override
  String get veniDesignedTemplateBanner =>
      'Veni projetou esta estrutura com base na sua solicitação. Revise e ajuste antes de publicar.';

  @override
  String get templateNameLabel => 'Nome do modelo';

  @override
  String get templateNameHint => 'Ex: Minha coleção de quadrinhos';

  @override
  String get githubUserLabel => 'Usuário do GitHub';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get categoryHint => 'Ex: Livros, Eletrônicos...';

  @override
  String get templatePurposeDescription => 'Descrição do propósito';

  @override
  String get definedFieldsTitle => 'Campos definidos';

  @override
  String get addFieldButton => 'Adicionar campo';

  @override
  String get clickAddFieldToStart =>
      'Clique em \'Adicionar campo\' para começar a projetar.';

  @override
  String get configureOptionsUpper => 'CONFIGURAR OPÇÕES';

  @override
  String get writeOptionAndPressEnter => 'Escreva uma opção e pressione Enter';

  @override
  String get publishOnGithubUpper => 'PUBLICAR NO GITHUB';

  @override
  String get templateDetailFetchError =>
      'Não foi possível obter os detalhes do modelo';

  @override
  String get templateNotAvailable =>
      'O modelo não existe ou não está disponível';

  @override
  String get backLabel => 'Voltar';

  @override
  String get templateDetailTitle => 'Detalhe do modelo';

  @override
  String get saveToLibraryTooltip => 'Salvar na biblioteca';

  @override
  String templateByAuthor(String name) {
    return 'por @$name';
  }

  @override
  String get officialVerifiedTemplate => 'Modelo oficial verificado';

  @override
  String dataStructureFieldsUpper(int count) {
    return 'ESTRUTURA DE DADOS ($count CAMPOS)';
  }

  @override
  String get installInMyInventoryUpper => 'INSTALAR NO MEU INVENTÁRIO';

  @override
  String get addedToPersonalLibrary => 'Adicionado à sua biblioteca pessoal';

  @override
  String get whereDoYouWantToInstall => 'Onde você quer instalar?';

  @override
  String get noContainersCreateFirst =>
      'Você não tem recipientes. Crie um primeiro.';

  @override
  String get autoGeneratedListFromTemplate =>
      'Lista gerada automaticamente a partir do modelo';

  @override
  String get installationSuccessAutoLists =>
      'Instalação bem-sucedida. Listas configuradas automaticamente.';

  @override
  String errorInstallingTemplate(String error) {
    return 'Erro ao instalar: $error';
  }

  @override
  String get publishTemplateLabel => 'Publicar modelo';

  @override
  String get retryLabel => 'Tentar novamente';

  @override
  String get noTemplatesFoundInMarket => 'Nenhum modelo encontrado no mercado.';

  @override
  String get invenicumCommunity => 'Comunidade Invenicum';

  @override
  String get refreshMarketTooltip => 'Atualizar mercado';

  @override
  String get exploreCommunityConfigurations =>
      'Explore e baixe configurações da comunidade';

  @override
  String get searchByTemplateName => 'Buscar por nome do modelo...';

  @override
  String get filterByTagTooltip => 'Filtrar por etiqueta';

  @override
  String get noMoreTags => 'Não há mais etiquetas';

  @override
  String confirmDeleteDataList(String name) {
    return 'Tem certeza de que deseja excluir a lista \"$name\"? Esta ação é irreversível.';
  }

  @override
  String dataListDeletedSuccess(String name) {
    return 'Lista \"$name\" excluída com sucesso.';
  }

  @override
  String errorDeletingDataList(String error) {
    return 'Erro ao excluir a lista: $error';
  }

  @override
  String customListsWithContainer(String name) {
    return 'Listas personalizadas - $name';
  }

  @override
  String get newDataListLabel => 'Nova lista';

  @override
  String get noCustomListsCreateOne =>
      'Nenhuma lista personalizada. Crie uma nova.';

  @override
  String elementsCount(int count) {
    return '$count elementos';
  }

  @override
  String get dataListNeedsAtLeastOneElement =>
      'A lista deve ter pelo menos um elemento';

  @override
  String get customDataListCreated => 'Lista personalizada criada com sucesso';

  @override
  String errorCreatingDataList(String error) {
    return 'Erro ao criar a lista: $error';
  }

  @override
  String get newCustomDataListTitle => 'Nova lista personalizada';

  @override
  String get dataListNameLabel => 'Nome da lista';

  @override
  String get pleaseEnterAName => 'Por favor, insira um nome';

  @override
  String get dataListElementsTitle => 'Elementos da lista';

  @override
  String get newElementLabel => 'Novo elemento';

  @override
  String get addLabel => 'Adicionar';

  @override
  String get addElementsToListHint => 'Adicione elementos à lista';

  @override
  String get saveListLabel => 'Salvar lista';

  @override
  String get dataListUpdatedSuccessfully => 'Lista atualizada com sucesso';

  @override
  String errorUpdatingDataList(String error) {
    return 'Erro ao atualizar a lista: $error';
  }

  @override
  String editListWithName(String name) {
    return 'Editar lista: $name';
  }

  @override
  String get createNewLocationTitle => 'Criar nova localização';

  @override
  String get locationNameLabel => 'Nome da localização';

  @override
  String get locationNameHint => 'Ex: Prateleira B3, Sala de Servidores';

  @override
  String get locationDescriptionHint =>
      'Detalhes de acesso, tipo de conteúdo, etc.';

  @override
  String get parentLocationLabel => 'Localização pai (contém esta)';

  @override
  String get noParentRootLocation => 'Nenhum pai (localização raiz)';

  @override
  String get noneRootScheme => 'Nenhum (raiz do esquema)';

  @override
  String get savingLabel => 'Salvando...';

  @override
  String get saveLocationLabel => 'Salvar localização';

  @override
  String locationCreatedSuccessfully(String name) {
    return 'Localização \"$name\" criada com sucesso.';
  }

  @override
  String errorCreatingLocation(String error) {
    return 'Erro ao criar localização: $error';
  }

  @override
  String get locationCannotBeItsOwnParent =>
      'Uma localização não pode ser sua própria pai.';

  @override
  String locationUpdatedSuccessfully(String name) {
    return 'Localização \"$name\" atualizada.';
  }

  @override
  String errorUpdatingLocation(String error) {
    return 'Erro ao atualizar localização: $error';
  }

  @override
  String editLocationTitle(String name) {
    return 'Editar: $name';
  }

  @override
  String get updateLocationLabel => 'Atualizar localização';

  @override
  String get selectObjectTitle => 'Selecionar objeto';

  @override
  String get noObjectsAvailable => 'Nenhum objeto disponível';

  @override
  String availableQuantity(int quantity) {
    return 'Disponível: $quantity';
  }

  @override
  String errorSelectingObject(String error) {
    return 'Erro ao selecionar objeto: $error';
  }

  @override
  String get mustSelectAnObject => 'Você deve selecionar um objeto';

  @override
  String get loanRegisteredSuccessfully => 'Empréstimo registrado com sucesso';

  @override
  String get selectAnObject => 'Selecione um objeto';

  @override
  String get selectLabel => 'Selecionar';

  @override
  String get borrowerNameHint => 'Ex: João Silva';

  @override
  String get borrowerNameRequired => 'O nome é obrigatório';

  @override
  String loanQuantityAvailable(int quantity) {
    return 'Quantidade a emprestar (Disponível: $quantity)';
  }

  @override
  String get enterQuantity => 'Insira uma quantidade';

  @override
  String get invalidQuantity => 'Quantidade inválida';

  @override
  String get notEnoughStock => 'Estoque insuficiente';

  @override
  String get invalidEmail => 'E-mail inválido';

  @override
  String expectedReturnDateLabel(String date) {
    return 'Devolução esperada: $date';
  }

  @override
  String get selectReturnDate => 'Selecione a data de devolução';

  @override
  String get additionalNotes => 'Notas adicionais';

  @override
  String get registerLoanLabel => 'Registrar empréstimo';

  @override
  String get totalLabel => 'Total';

  @override
  String get newLocationLabel => 'Nova localização';

  @override
  String get newLocationHint => 'Ex: Prateleira A1, Armário 3...';

  @override
  String get parentLocationOptionalLabel => 'Localização pai (opcional)';

  @override
  String get noneRootLabel => 'Nenhuma (raiz)';

  @override
  String locationCreatedShort(String name) {
    return 'Localização \"$name\" criada';
  }

  @override
  String get newLocationEllipsis => 'Nova localização...';

  @override
  String get couldNotReloadList => 'Não foi possível recarregar a lista';

  @override
  String get deleteAssetTitle => 'Excluir ativo';

  @override
  String confirmDeleteAssetItem(String name) {
    return 'Confirma que deseja excluir \"$name\"?';
  }

  @override
  String get assetDeletedShort => 'Ativo excluído.';

  @override
  String viewColumnsLabel(int count) {
    return 'Vista: $count col.';
  }

  @override
  String get notValuedLabel => 'Sem valor';

  @override
  String get manageSearchSyncAssets =>
      'Gerencie, pesquise e sincronize seus ativos em um único painel.';

  @override
  String get filterLabel => 'Filtro';

  @override
  String get activeFilterLabel => 'Filtro ativo';

  @override
  String get importLabel => 'Importar';

  @override
  String get exportLabel => 'Exportar';

  @override
  String get csvExportNoData => 'Nenhum item para exportar.';

  @override
  String csvExportSuccess(int count) {
    return 'CSV exportado com sucesso ($count itens).';
  }

  @override
  String get csvExportError => 'Não foi possível exportar o CSV';

  @override
  String get syncLabel => 'Sincronizar preços';

  @override
  String get syncingLabel => 'Sincronizando...';

  @override
  String get newAssetLabel => 'Novo ativo';

  @override
  String get statusAndPreferences => 'Status e preferências';

  @override
  String get itemStatusLabel => 'Status do item';

  @override
  String get availableLabel => 'Disponível';

  @override
  String get mustBeGreaterThanZero => 'Deve ser maior que 0.';

  @override
  String get alertThresholdLabel => 'Limite de alerta';

  @override
  String get enterMinimumStock => 'Insira um estoque mínimo.';

  @override
  String get serializedItemFixedQuantity =>
      'Este é um item serializado. A quantidade é fixa em 1.';

  @override
  String get serialNumberLabel => 'Número de série';

  @override
  String get serialNumberHint => 'Ex: SN-2024-00123';

  @override
  String get mainDataTitle => 'Dados principais';

  @override
  String get currentMarketValueLabel => 'VALOR DE MERCADO ATUAL';

  @override
  String get updatePriceLabel => 'Atualizar preço';

  @override
  String get viewLabel => 'Visualização';

  @override
  String get visualGalleryTitle => 'Galeria visual';

  @override
  String get statusAndMarketTitle => 'Status e mercado';

  @override
  String get valuationHistoryTitle => 'Histórico de avaliação';

  @override
  String get specificationsTitle => 'Especificações';

  @override
  String get traceabilityTitle => 'Rastreabilidade';

  @override
  String get stockLabel => 'Estoque';

  @override
  String get internalReferenceLabel => 'Referência interna';

  @override
  String get noSpecificationsAvailable => 'Nenhuma especificação disponível';

  @override
  String get trueLabel => 'Verdadeiro';

  @override
  String get falseLabel => 'Falso';

  @override
  String get openLinkLabel => 'Abrir link';

  @override
  String get scannerFocusTip =>
      'Dica: Se não focar, afaste o produto cerca de 30 cm da câmera.';

  @override
  String get scanCodeTitle => 'Escanear código';

  @override
  String get scanOrEnterProductCode => 'Escaneie ou insira o código do produto';

  @override
  String possessionProgressLabel(String name) {
    return 'Progresso de $name';
  }

  @override
  String get externalImportTitle => 'Importar de fonte externa';

  @override
  String get galleryTitle => 'Galeria';

  @override
  String get stockAndCodingTitle => 'Estoque e codificação';

  @override
  String get cameraPermissionRequired =>
      'Permissão de câmera necessária para escanear';

  @override
  String get cloudDataFound => 'Dados encontrados na nuvem!';

  @override
  String get typeSomethingToSearch => 'Digite algo para pesquisar';

  @override
  String get importCancelled => 'Importação cancelada.';

  @override
  String get couldNotCompleteImport => 'Não foi possível concluir a importação';

  @override
  String get yearLabel => 'Ano';

  @override
  String get authorLabel => 'Autor';

  @override
  String get selectResultTitle => 'Selecione um resultado';

  @override
  String get unnamedLabel => 'Sem nome';

  @override
  String get completeRequiredFields =>
      'Por favor, preencha os campos obrigatórios.';

  @override
  String get assetCreatedSuccess => 'Ativo criado!';

  @override
  String errorCreatingAsset(String error) {
    return 'Erro ao criar ativo: $error';
  }

  @override
  String get technicalDetailsTitle => 'Detalhes técnicos';

  @override
  String itemImportedSuccessfully(String name) {
    return '$name importado com sucesso!';
  }

  @override
  String newImagesSelected(int count) {
    return '$count novas imagens selecionadas.';
  }

  @override
  String get newFileRemoved => 'Novo arquivo removido.';

  @override
  String get imageMarkedForDeletion =>
      'Imagem marcada para exclusão ao salvar.';

  @override
  String get couldNotIdentifyImage => 'Não foi possível identificar a imagem.';

  @override
  String editAssetTitle(String name) {
    return 'Editar: $name';
  }

  @override
  String get syncPricesTitle => 'Sincronizar preços';

  @override
  String get syncPricesDescription =>
      'A API será consultada para atualizar o valor de mercado.';

  @override
  String get syncingMarketPrices => 'Sincronizando preços de mercado...';

  @override
  String get couldNotSyncPrices => 'Não foi possível sincronizar os preços';

  @override
  String get syncCompletedTitle => 'Sincronização concluída';

  @override
  String get updatedLabel => 'Atualizados';

  @override
  String get noApiPriceLabel => 'Sem preço na API';

  @override
  String get errorsLabel => 'Erros';

  @override
  String get totalProcessedLabel => 'Total processados';

  @override
  String get noAssetsToShow => 'Nenhum ativo para exibir';

  @override
  String get noImageLabel => 'Sem imagem';

  @override
  String get aiMagicQuestion => 'Você tem um link?';

  @override
  String get aiAutocompleteAsset =>
      'Preencher este ativo automaticamente com IA';

  @override
  String get magicLabel => 'MAGIA';

  @override
  String get skuBarcodeLabel => 'SKU / EAN / UPC';

  @override
  String get veniChatPlaceholder => 'Pergunte-me qualquer coisa...';

  @override
  String get veniChatPoweredBy => 'Powered by ';

  @override
  String veniChatProcessing(String query) {
    return 'Estou processando sua pergunta sobre \"$query\"...';
  }

  @override
  String get veniChatStatus => 'Online';

  @override
  String get veniChatTitle => 'Venibot IA';

  @override
  String get veniChatWelcome =>
      'Olá! Sou o Venibot, seu assistente Invenicum. Como posso ajudá-lo com seu inventário hoje?';

  @override
  String get veniCmdDashboard => 'Ir para o painel';

  @override
  String get veniCmdHelpTitle => 'Habilidades do Veni';

  @override
  String get veniCmdInventory => 'Verificar estoque de um artigo';

  @override
  String get veniCmdLoans => 'Ver empréstimos ativos';

  @override
  String get veniCmdReport => 'Gerar relatório de inventário';

  @override
  String get veniCmdScanQR => 'Escanear QR/código de barras';

  @override
  String get veniCmdUnknown =>
      'Não reconheço esse comando. Digite ajuda para ver o que posso fazer.';

  @override
  String version(String name) {
    return 'Versão $name';
  }

  @override
  String get yes => 'Sim';

  @override
  String get zoomToFit => 'Ajustar visualização';

  @override
  String get generalSettingsMenuLabel => 'Configurações gerais';

  @override
  String get aiAssistantMenuLabel => 'Assistente de IA';

  @override
  String get notificationsMenuLabel => 'Notificações';

  @override
  String get loanManagementMenuLabel => 'Gestão de empréstimos';

  @override
  String get aboutMenuLabel => 'Sobre';

  @override
  String get automaticDarkModeLabel => 'Modo escuro automático';

  @override
  String get syncWithSystemLabel => 'Sincronizar com o sistema';

  @override
  String get manualDarkModeLabel => 'Modo escuro manual';

  @override
  String get disableAutomaticToChange =>
      'Desative o modo automático para alterá-lo';

  @override
  String get changeLightDark => 'Alternar entre claro e escuro';

  @override
  String get enableAiAndChatbot => 'Ativar inteligência artificial e chatbot';

  @override
  String get requiresGeminiLinking =>
      'Requer vínculo com o Gemini em Integrações';

  @override
  String get aiOrganizeInventory =>
      'Use IA para organizar seu inventário de forma inteligente';

  @override
  String get aiAssistantTitle => 'Assistente de Inteligência Artificial';

  @override
  String get selectAiProvider =>
      'Escolha qual provedor de IA o Veni vai usar. Certifique-se de que a chave de API está configurada em Integrações.';

  @override
  String get aiProviderLabel => 'Provedor';

  @override
  String get aiModelLabel => 'Modelo';

  @override
  String get aiProviderUpdated => 'Provedor de IA atualizado';

  @override
  String get purgeChatHistoryTitle => 'Histórico do chat';

  @override
  String get purgeChatHistoryDescription =>
      'Exclui permanentemente todo o histórico salvo de conversas do Veni.';

  @override
  String get purgeChatHistoryButton => 'Limpar histórico';

  @override
  String get purgeChatHistoryConfirmTitle => 'Limpar histórico do chat?';

  @override
  String get purgeChatHistoryConfirmMessage =>
      'Esta ação excluirá todas as mensagens salvas e não pode ser desfeita.';

  @override
  String get purgeChatHistoryConfirmAction => 'Sim, limpar';

  @override
  String get purgeChatHistorySuccess =>
      'Histórico do chat removido com sucesso.';

  @override
  String get purgeChatHistoryError =>
      'Não foi possível remover o histórico do chat.';

  @override
  String get notificationSettingsTitle => 'Gestão de notificações';

  @override
  String get channelPriorityLabel =>
      'Prioridade dos canais (arraste para ordenar)';

  @override
  String get telegramBotLabel => 'Telegram Bot';

  @override
  String get resendEmailLabel => 'Resend Email';

  @override
  String get lowStockLabel => 'Estoque baixo';

  @override
  String get lowStockHint => 'Avisar quando um produto cair abaixo do mínimo.';

  @override
  String get newPresalesLabel => 'Novas pré-vendas';

  @override
  String get newPresalesHint => 'Notificar lançamentos detectados pela IA.';

  @override
  String get loanReminderLabel => 'Lembrete de empréstimos';

  @override
  String get loanReminderHint => 'Avisar antes da data de devolução.';

  @override
  String get overdueLoansLabel => 'Empréstimos vencidos';

  @override
  String get overdueLoansHint =>
      'Alerta crítico se um objeto não for devolvido a tempo.';

  @override
  String get maintenanceLabel => 'Manutenção';

  @override
  String get maintenanceHint => 'Avisar quando um ativo precisar ser revisado.';

  @override
  String get priceChangeLabel => 'Mudanças de preço';

  @override
  String get priceChangeHint => 'Notificar variações de valor no mercado.';

  @override
  String get unlinkGithubTitle => 'Desconectar GitHub';

  @override
  String get unlinkGithubMessage =>
      'Tem certeza de que deseja desvincular sua conta do GitHub?';

  @override
  String get updatePasswordButton => 'ATUALIZAR SENHA';

  @override
  String get profileFillAllFieldsError => 'Por favor, preencha todos os campos';

  @override
  String get profilePasswordUpdatedSuccess => 'Senha atualizada com sucesso!';

  @override
  String get profileDisconnectActionUpper => 'DESCONECTAR';

  @override
  String get profileGithubUnlinkedSuccess => 'GitHub desvinculado com sucesso';

  @override
  String get profileGithubLinkedSuccess => 'GitHub vinculado com sucesso!';

  @override
  String profileGithubProcessError(String error) {
    return 'Erro ao processar a vinculação do GitHub: $error';
  }

  @override
  String get profileGithubConfigUnavailableError =>
      'Erro: configuração do GitHub não disponível';

  @override
  String profileServerConnectionError(String error) {
    return 'Não foi possível conectar ao servidor: $error';
  }

  @override
  String get profileUpdatedSuccess => 'Perfil atualizado com sucesso';

  @override
  String profileUpdateError(String error) {
    return 'Erro ao atualizar perfil: $error';
  }

  @override
  String get profileUsernameCommunityLabel => 'Usuário (Comunidade)';

  @override
  String get profileUsernameCommunityHelper =>
      'Obrigatório para publicar plugins.';

  @override
  String get profileUpdateButtonUpper => 'ATUALIZAR PERFIL';

  @override
  String get profileGithubIdentityTitle => 'Identidade GitHub';

  @override
  String profileGithubLinkedAs(String username) {
    return 'Vinculado como @$username';
  }

  @override
  String get profileGithubLinkPrompt =>
      'Vincule sua conta para publicar plugins';

  @override
  String get profileGithubUsernameHint => 'Seu usuário do GitHub';

  @override
  String get profileGithubFieldHint =>
      'Este campo é preenchido automaticamente após a autenticação com o GitHub.';

  @override
  String get profileGithubDefaultMissingKeys =>
      'GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET';

  @override
  String profileGithubOAuthNotConfigured(String missing) {
    return 'GitHub OAuth não configurado. Faltando: $missing. Configure GITHUB_CLIENT_ID e GITHUB_CLIENT_SECRET no backend e reinicie o servidor.';
  }

  @override
  String get profileDisconnectGithubButton => 'Desconectar GitHub';

  @override
  String get profileLinkGithubButton => 'Vincular com GitHub';

  @override
  String get profileSecurityTitle => 'Segurança';

  @override
  String get profileChangeUpper => 'ALTERAR';

  @override
  String get profileCurrentPasswordLabel => 'Senha atual';

  @override
  String get profileNewPasswordLabel => 'Nova senha';

  @override
  String get profileConfirmNewPasswordLabel => 'Confirmar nova senha';

  @override
  String get profileChangePasswordHint =>
      'Altere sua senha periodicamente para manter sua conta segura.';

  @override
  String get newContainerDialog => 'Novo recipiente';

  @override
  String get descriptionField => 'Descrição';

  @override
  String get isCollectionQuestion => 'É uma coleção?';

  @override
  String get createContainerButton => 'Criar recipiente';

  @override
  String get selectContainerHint => 'Selecione um recipiente';

  @override
  String get newAssetTypeTitle => 'Novo tipo de ativo';

  @override
  String get generalConfiguration => 'Configuração geral';

  @override
  String get collectionContainerWarning =>
      'Este recipiente é uma coleção. Você pode criar tipos serializados ou não serializados, mas os campos de posse e desejados só poderão ser configurados em tipos não serializados.';

  @override
  String get createAssetTypeButton => 'Criar tipo de ativo';

  @override
  String assetTypesInContainer(String name) {
    return 'Tipos de ativo em \"$name\"';
  }

  @override
  String get createNewTypeButton => 'Criar novo tipo';

  @override
  String get isSerializedQuestion => 'É um artigo serializado?';

  @override
  String get addNewFieldButton => 'Adicionar novo campo';

  @override
  String get deleteFieldTooltip => 'Excluir campo';

  @override
  String get fieldsOptions => 'Opções:';

  @override
  String get isRequiredField => 'É obrigatório';

  @override
  String get isSummativeFieldLabel => 'É somativo (somado ao total do tipo)';

  @override
  String get isMonetaryValueLabel => 'É valor monetário';

  @override
  String get monetaryValueDescription =>
      'Será usado para calcular o investimento total no painel';

  @override
  String get noDataListsAvailable =>
      '⚠️ Nenhuma lista de dados disponível neste recipiente.';

  @override
  String get selectDataList => 'Selecionar lista de dados';

  @override
  String get chooseList => 'Escolha uma lista';

  @override
  String get goToPageLabel => 'Ir para a página:';

  @override
  String get conditionLabel => 'Condição';

  @override
  String get actionsLabel => 'Ações';

  @override
  String get editButtonLabel => 'Editar';

  @override
  String get deleteButtonLabel => 'Excluir';

  @override
  String get printLabel => 'Imprimir etiqueta';

  @override
  String get collectionFieldsTooltip => 'Campos de coleção';

  @override
  String totalLocations(int count) {
    return '$count localizações';
  }

  @override
  String withoutLocationLabel(int count) {
    return '$count sem localização · ';
  }

  @override
  String get objectIdColumn => 'ID Obj';

  @override
  String containerNotFoundError(String id) {
    return 'Recipiente com ID $id não encontrado.';
  }

  @override
  String get invalidContainerIdError => 'Erro: ID de recipiente inválido.';

  @override
  String get startConfigurationButton => 'Iniciar configuração';

  @override
  String get fullNameField => 'Nome completo';

  @override
  String get emailField => 'E-mail';

  @override
  String get passwordField => 'Senha';

  @override
  String get confirmPasswordField => 'Confirmar senha';

  @override
  String get goBackButton => 'Voltar';

  @override
  String get createAccountButton => 'Criar conta';

  @override
  String get goToLoginButton => 'Ir para o login';

  @override
  String get deleteConfirmationTitle => 'Confirmar exclusão';

  @override
  String deleteItemMessage(String name) {
    return 'Deseja excluir \"$name\"?';
  }

  @override
  String get elementDeletedSuccess => 'Elemento excluído com sucesso';

  @override
  String get enterYourNameValidation => 'Insira seu nome.';

  @override
  String get minTwoCharactersValidation => 'Mínimo 2 caracteres.';

  @override
  String get enterEmailValidation => 'Insira um e-mail.';

  @override
  String get invalidEmailValidation => 'E-mail inválido.';

  @override
  String get enterPasswordValidation => 'Insira uma senha.';

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
    return 'Erro ao carregar dados: $error';
  }

  @override
  String get assetTypeUpdateSuccess => 'Tipo de ativo atualizado com sucesso';

  @override
  String assetTypeUpdateError(String error) {
    return 'Erro ao atualizar: $error';
  }

  @override
  String editAssetTypeTitle(String name) {
    return 'Editar: $name';
  }

  @override
  String get achievementCollectionTitle => 'Conquistas de coleção';

  @override
  String get achievementSubtitle => 'Desbloqueie marcos usando o Invenicum';

  @override
  String get legendaryAchievementLabel => 'CONQUISTA LENDÁRIA';

  @override
  String get achievementCompleted => 'Concluído';

  @override
  String get achievementLocked => 'Bloqueado';

  @override
  String achievementUnlockedDate(String date) {
    return 'Conquistado em $date';
  }

  @override
  String get achievementLockedMessage => 'Cumpra o objetivo para desbloquear';

  @override
  String get closeButtonLabel => 'Entendido';

  @override
  String get configurationGeneralSection => 'Configuração geral';

  @override
  String get assetTypeCollectionWarning =>
      'Este recipiente é uma coleção. Você pode criar tipos serializados ou não serializados, mas os campos de posse e desejados só poderão ser configurados em tipos não serializados.';

  @override
  String get updateAssetTypeButton => 'Atualizar tipo de ativo';

  @override
  String get createAssetTypeButtonDefault => 'Criar tipo de ativo';

  @override
  String get noAssetTypesMessage =>
      'Ainda não há tipos de ativo definidos neste recipiente.';

  @override
  String totalCountLabel(int count) {
    return 'Total: $count';
  }

  @override
  String possessionCountLabel(int count) {
    return 'Posse: $count';
  }

  @override
  String desiredCountLabel(int count) {
    return 'Desejados: $count';
  }

  @override
  String get marketValueLabel => 'Mercado: ';

  @override
  String get defaultSumFieldName => 'Soma';

  @override
  String get calculatingLabel => 'Calculando...';

  @override
  String get unknownError => 'Erro desconhecido';

  @override
  String get noNameItem => 'Sem nome';

  @override
  String get loadingContainers => 'Carregando recipientes...';

  @override
  String get fieldNameRequired => 'O nome do campo é obrigatório';

  @override
  String get selectImageButton => 'Selecionar imagem';

  @override
  String assetTypeDeletedSuccess(String name) {
    return '$name excluído';
  }

  @override
  String get noLocationValueData =>
      'Ainda não há ativos com localização e valor suficiente para gerar este gráfico.';

  @override
  String get requiredFieldValidation => 'Este campo é obrigatório';

  @override
  String get oceanTheme => 'Oceano Índico';

  @override
  String get cherryBlossomTheme => 'Flor de cerejeira';

  @override
  String get themeBrand => 'Invenicum (Marca)';

  @override
  String get themeEmerald => 'Esmeralda';

  @override
  String get themeSunset => 'Pôr do sol';

  @override
  String get themeLavender => 'Lavanda suave';

  @override
  String get themeForest => 'Floresta profunda';

  @override
  String get themeCherry => 'Cereja';

  @override
  String get themeElectricNight => 'Noite elétrica';

  @override
  String get themeAmberGold => 'Ouro âmbar';

  @override
  String get themeModernSlate => 'Ardósia moderna';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeNordicArctic => 'Ártico nórdico';

  @override
  String get themeDeepNight => 'Noite profunda';

  @override
  String get loginSuccess => 'Login bem-sucedido';

  @override
  String get reloadListError => 'Não foi possível recarregar a lista';

  @override
  String get copyItemSuffix => 'Cópia';

  @override
  String itemCopiedSuccess(String name) {
    return 'Elemento copiado: $name';
  }

  @override
  String get copyError => 'Erro ao copiar';

  @override
  String get imageColumnLabel => 'Imagem';

  @override
  String get viewImageTooltip => 'Ver imagem';

  @override
  String get currentStockLabel => 'Estoque atual';

  @override
  String get minimumStockLabel => 'Estoque mínimo';

  @override
  String get locationColumnLabel => 'Localização';

  @override
  String get serialNumberColumnLabel => 'Número de série';

  @override
  String get marketPriceLabel => 'Preço de mercado';

  @override
  String get conditionColumnLabel => 'Condição';

  @override
  String get actionsColumnLabel => 'Ações';

  @override
  String get imageLoadError => 'Não foi possível carregar a imagem';

  @override
  String get imageUrlHint =>
      'Certifique-se de que a URL está correta e o servidor está ativo';

  @override
  String get assetTypeNameHint => 'Ex: Notebook, Substância química';

  @override
  String get assetTypeNameLabel => 'Nome do tipo de ativo';

  @override
  String get underConstruction => 'Em construção';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get constructionSubtitle =>
      'Esta funcionalidade está sendo desenvolvida';

  @override
  String get selectColor => 'Selecionar cor';

  @override
  String get valueDistributionByLocation =>
      'Distribuição de valor por localização';

  @override
  String get heatmapDescription =>
      'O gráfico de rosca mostra como o valor de mercado é distribuído entre as localizações mais relevantes.';

  @override
  String locationsCount(int count) {
    return '$count localizações';
  }

  @override
  String get unitsLabel => 'un.';

  @override
  String get recordsLabel => 'registros';

  @override
  String get totalValueFallback => 'Valor total';

  @override
  String containerFallback(String id) {
    return 'Recipiente $id';
  }

  @override
  String locationFallback(String id) {
    return 'Localização $id';
  }

  @override
  String get ofTheValueLabel => 'do valor';

  @override
  String get reportsDescription =>
      'Gere relatórios em PDF ou Excel para imprimir ou salvar no seu PC';

  @override
  String get reportSectionType => 'Tipo de relatório';

  @override
  String get reportSectionFormat => 'Formato de saída';

  @override
  String get reportSectionPreview => 'Configuração atual';

  @override
  String get reportSelectContainerTitle => 'Selecione um recipiente';

  @override
  String get reportGenerate => 'Gerar relatório';

  @override
  String get reportGenerating => 'Gerando...';

  @override
  String get reportTypeInventoryDescription =>
      'Listagem completa do inventário';

  @override
  String get reportTypeLoansDescription => 'Empréstimos ativos e seu status';

  @override
  String get reportTypeAssetsDescription => 'Listagem de ativos por categoria';

  @override
  String get reportLabelContainer => 'Recipiente';

  @override
  String get reportLabelType => 'Tipo de relatório';

  @override
  String get reportLabelFormat => 'Formato';

  @override
  String get reportFormatPdf => 'PDF';

  @override
  String get reportFormatExcel => 'Excel';

  @override
  String get reportNotSelected => 'Não selecionado';

  @override
  String get reportUnknown => 'Desconhecido';

  @override
  String get reportSelectContainerFirst => 'Por favor, selecione um recipiente';

  @override
  String reportDownloadedSuccess(String format) {
    return 'Relatório $format baixado com sucesso';
  }

  @override
  String reportGenerateError(String error) {
    return 'Erro ao gerar relatório: $error';
  }

  @override
  String get firstRunWelcomeTitle => 'Bem-vindo ao Invenicum';

  @override
  String get firstRunConfigTitle => 'Configuração inicial';

  @override
  String get firstRunWelcomeDescription =>
      'Parece que é a primeira vez que você inicia o aplicativo. Vamos criar sua conta de administrador para começar.';

  @override
  String get firstRunStep1Label => 'Etapa 1 de 2 · Bem-vindo';

  @override
  String get firstRunStep2Label => 'Etapa 2 de 2 · Criar administrador';

  @override
  String get firstRunSuccessMessage => 'Sua conta foi criada';

  @override
  String get firstRunAdminTitle => 'Criar administrador';

  @override
  String get firstRunAdminDescription =>
      'Este usuário terá acesso completo à plataforma.';

  @override
  String get firstRunFeature1 => 'Crie seu usuário administrador';

  @override
  String get firstRunFeature2 => 'Acesso seguro com senha';

  @override
  String get firstRunFeature3 => 'Pronto para usar em segundos';

  @override
  String get passwordsDoNotMatch => 'As senhas não correspondem.';

  @override
  String get firstRunSuccessTitle => 'Conta criada!';

  @override
  String get firstRunSuccessSubtitle =>
      'Sua conta de administrador está pronta.\nVocê pode fazer login agora.';

  @override
  String get firstRunAccountCreatedLabel => 'CONTA CRIADA';

  @override
  String get firstRunCopyright => 'Invenicum ©';
}
