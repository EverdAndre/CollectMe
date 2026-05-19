# CollectMe

CollectMe e um aplicativo Flutter para organizar itens de colecao pessoal. Ele ajuda a cadastrar itens, controlar valores, acompanhar status, registrar emprestimos e gerar relatorios em PDF para impressao ou compartilhamento.

O projeto Flutter fica na pasta [`collection_app`](collection_app).

## O Que O Projeto Resolve

Quem tem uma colecao fisica costuma perder informacoes importantes com facilidade: onde o item esta guardado, quanto custou, quanto vale, se foi vendido, emprestado ou se ainda precisa ser comprado (lista de desejos).

O CollectMe centraliza esses dados em um app desktop simples, com armazenamento local em SQLite e telas voltadas para uso diario.

## Funcionalidades

- Cadastro de itens com nome, descricao, imagem, local de armazenamento, valor de compra, valor de venda e estado de conservacao.
- Listagem dos itens ativos em formato de tabela.
- Busca por nome, descricao ou local.
- Filtros por status e ordenacao.
- Edicao de itens cadastrados.
- Exclusao logica de itens, mantendo o registro salvo como inativo.
- Registro de emprestimo, com dados da pessoa, datas, observacoes e imagens.
- Relatorios em PDF por tipo: geral, acervo, vendidos, comprar e emprestados.
- Selecao manual dos itens que entram no relatorio.
- Impressao e compartilhamento do PDF.

## Imagens Do App

Adicione aqui prints do aplicativo funcionando.

### Tela Inicial

![Tela inicial](collection_app/docs/images/tela-inicial.png)

### Cadastro De Item

![Cadastro de item](collection_app/docs/images/cadastro-item.png)

### Relatorio

![Relatorio](collection_app/docs/images/relatorio.png)

## Compatibilidade Atual

| Plataforma | Status | Observacao |
| --- | --- | --- |
| Windows | Suportado no escopo atual | Plataforma principal do projeto neste momento. |
| Linux | Possivel como desktop | Pode exigir bibliotecas nativas do SQLite instaladas no sistema. |
| macOS | Possivel como desktop | Pode exigir ajustes de assinatura/permissoes dependendo do ambiente. |
| Web | Nao garantido no estado atual | A camada de banco usa `sqflite_common_ffi`, voltado para desktop. |
| Android | Nao garantido no estado atual | Para mobile, o ideal e adaptar a persistencia para `sqflite`. |
| iOS | Nao garantido no estado atual | Para mobile, o ideal e adaptar a persistencia para `sqflite`. |

O projeto foi desenvolvido com foco em desktop. As pastas de Web, Android, iOS, Linux e macOS existem porque o Flutter cria essa estrutura, mas isso nao significa que todas as plataformas estejam validadas.

Para suportar Web, Android ou iOS com seguranca, o ponto principal e adaptar a camada de banco de dados em `collection_app/lib/data/datasources/collection_datasource.dart`.

## Requisitos

| Requisito | Versao usada pelo projeto | Download |
| --- | --- | --- |
| Flutter | `>= 3.35.0` | [flutter.dev/install](https://docs.flutter.dev/get-started/install) |
| Dart SDK | `>= 3.11.4 < 4.0.0` | Incluido no Flutter |
| Git | Versao atual estavel | [git-scm.com/downloads](https://git-scm.com/downloads) |
| Visual Studio | 2022 ou superior, com workload Desktop development with C++ | [visualstudio.microsoft.com/downloads](https://visualstudio.microsoft.com/downloads/) |
| Linux desktop | Ambiente configurado para Flutter desktop | [docs.flutter.dev/platform-integration/linux](https://docs.flutter.dev/platform-integration/linux/setup) |
| macOS desktop | macOS com Xcode instalado | [docs.flutter.dev/platform-integration/macos](https://docs.flutter.dev/platform-integration/macos/setup) |

Observacoes:

- O Dart SDK vem junto com o Flutter, entao nao e necessario instalar o Dart separadamente.
- No Windows, o Visual Studio e necessario para compilar e executar o app desktop.
- Web, Android e iOS exigem revisao da persistencia local antes de serem considerados suportados.

Para conferir se o ambiente esta pronto:

```bash
flutter doctor
```

Para verificar as versoes instaladas:

```bash
flutter --version
dart --version
git --version
```

Para listar os dispositivos e plataformas disponiveis:

```bash
flutter devices
```

## Como Baixar

Clone o repositorio:

```bash
git clone <url-do-repositorio>
```

Entre na pasta do projeto:

```bash
cd collection_app
```

## Como Instalar As Dependencias

```bash
flutter pub get
```

## Como Executar

No Windows:

```bash
flutter run -d windows
```

No Linux:

```bash
flutter run -d linux
```

No macOS:

```bash
flutter run -d macos
```

Se tentar executar em Web, Android ou iOS no estado atual, podem ocorrer erros relacionados ao banco local. Antes de liberar essas plataformas, adapte a persistencia para cada ambiente.

## Comandos Uteis

Analisar o projeto:

```bash
flutter analyze
```

Rodar testes:

```bash
flutter test
```

Formatar o codigo:

```bash
dart format lib test
```

Gerar build para Windows:

```bash
flutter build windows
```

## Tecnologias Usadas

- Flutter `>= 3.35.0`
- Dart `>= 3.11.4 < 4.0.0`
- SQLite com `sqflite_common_ffi`
- `pdf` para geracao dos relatorios
- `printing` para preview, impressao e compartilhamento dos PDFs
- `file_picker` para selecao de imagens
- `path` para manipulacao de caminhos de arquivos

## Estrutura De Pastas

```text
collection_app/
  lib/
    controllers/       Controladores dos formularios
    core/
      enum/            Enums de filtro e status
    data/
      datasources/     Acesso ao SQLite
      models/          Modelos de dados
      repositories/    Camada de repositorio
    pages/             Telas do aplicativo
    routes/            Rotas do app
    services/          Servicos de imagem e relatorio
    widgets/           Componentes reutilizaveis

  images/              Imagens salvas dos itens
  test/                Testes automatizados
  windows/             Configuracoes nativas do Windows
  linux/               Configuracoes nativas do Linux
  macos/               Configuracoes nativas do macOS
  android/             Configuracoes nativas do Android
  ios/                 Configuracoes nativas do iOS
  web/                 Configuracoes para web
```

## Banco De Dados

Os dados sao salvos localmente em SQLite, no arquivo `collection_app.db`.

A tabela principal e `collections`. Cada item e salvo com um `id` e um `payload` em JSON, o que facilita manter os dados do item agrupados, incluindo informacoes de emprestimo.

## Observacoes

- A exclusao de itens e logica: o item fica marcado como inativo.
- Os relatorios usam os itens selecionados na tela de relatorio.
- O nome tecnico do pacote Dart continua sendo `collection_app`, por isso os imports usam `package:collection_app/...`.
- As versoes especificas do projeto ficam registradas em `collection_app/pubspec.yaml` e `collection_app/pubspec.lock`.
