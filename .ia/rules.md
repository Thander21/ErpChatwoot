# Regras de Desenvolvimento do Projeto ErpChatwoot

## Arquitetura do Projeto

Este projeto utiliza uma arquitetura baseada em composição via Docker, mantendo o código original do Chatwoot isolado das personalizações.

### Componentes:

1.  **chatwoot-base**: Contém o código fonte original do Chatwoot.
    - **REGRA CRÍTICA**: Este diretório **NÃO DEVE** ser alterado diretamente. Ele serve como a fonte upstream imutável (ou atualizável separadamente) do projeto.
2.  **MenuPdvDmais**: Contém as personalizações e extensões do ERP.
    - Todas as alterações, novos recursos (Enterprise), patches de core e migrações devem residir aqui.
    - Estrutura interna:
      - `enterprise/`: Arquivos da versão Enterprise.
      - `core-patches/`: Arquivos que sobrescrevem o core do Chatwoot.
      - `db/migrate/`: Migrações de banco de dados adicionais.
3.  **Dockerfile**: Responsável por compilar o projeto final.
    - Copia o `chatwoot-base` para o diretório de trabalho.
    - Aplica as alterações do `MenuPdvDmais` sobre a base.
    - Realiza ajustes de configuração (Gemfile, vite.config.ts, etc.).

## Fluxo de Trabalho Para Modificações

- **Nunca edite arquivos dentro de `chatwoot-base`**.
- Para modificar um arquivo existente do core:
  1.  Copie o arquivo original ou crie a versão modificada em `MenuPdvDmais/core-patches/` (ou diretório apropriado dentro de `MenuPdvDmais`).
  2.  Adicione uma instrução `COPY` no `Dockerfile` para sobrescrever o arquivo original no momento da build ou garanta que a estrutura de diretórios em `MenuPdvDmais` reflita o destino para que a cópia em massa funcione (se configurada).
- Para adicionar novas funcionalidades (Enterprise):
  - Adicione os arquivos em `MenuPdvDmais/enterprise`.
- Para alterar dependências:
  - As alterações devem ser orquestradas via `Dockerfile` (ex: `RUN sed -i ... ./Gemfile`).

## Diretrizes para IA (Antigravity/Cursor)

1.  Ao analisar código, lembre-se que o código efetivo é uma fusão de `chatwoot-base` e `MenuPdvDmais`.
2.  Ao sugerir alterações de código, **sempre sugira alterações nos arquivos dentro de `MenuPdvDmais`** ou no `Dockerfile`. Jamais sugira `diffs` aplicados ao `chatwoot-base`.
3.  Se a alteração for em um arquivo que só existe em `chatwoot-base` e que ainda não foi modificado, o passo correto é criar a cópia modificada em `MenuPdvDmais` e atualizar o Dockerfile.
