# ERP Chatwoot Modifications

Este repositório contém **APENAS** as modificações enterprise para o ERP Chatwoot, separadas do projeto Chatwoot original para facilitar atualizações upstream.

## 🏗️ Nova Abordagem: Clone Limpo + Modificações Separadas

Diferentemente do fork tradicional, esta abordagem usa:
- ✅ **Clone limpo** do `chatwoot/chatwoot` (sem fork no GitHub)
- ✅ **Repositório separado** só com suas modificações enterprise
- ✅ **Aplicação sob demanda** via script automatizado
- ✅ **Zero conflitos** com upstream

## 📁 Estrutura

```
~/Projetos/
├── ErpChatwoot/                    # Clone limpo do chatwoot/chatwoot
│   ├── enterprise/                 # (vazio - será preenchido pelo script)
│   ├── app/javascript/dashboard/   # (original - será modificado pelo script)
│   └── docs/                       # (original - será estendido pelo script)
│
├── erp-chatwoot-modifications/      # Suas modificações enterprise
│   ├── enterprise/                 # Código enterprise completo
│   ├── docs/                       # Documentação adicional
│   ├── core-patches/               # Patches para arquivos Chatwoot base
│   │   ├── dashboard.routes.js     # Rotas modificadas
│   │   ├── Sidebar.vue            # Sidebar com menu enterprise
│   │   └── settings.json          # Traduções enterprise
│   ├── apply-modifications.sh     # Script de aplicação
│   └── README.md                  # Este arquivo
│
└── ErpChatwoot.backup/             # Backup do fork anterior (opcional)
```

## 🚀 Como Usar

### 1. Configuração Inicial

```bash
# 1. Clonar Chatwoot original limpo
cd ~/Projetos
git clone https://github.com/chatwoot/chatwoot.git ErpChatwoot

# 2. Aplicar modificações enterprise
cd erp-chatwoot-modifications
./apply-modifications.sh

# 3. Pronto! O projeto está configurado
cd ../ErpChatwoot
docker-compose up
```

### 2. Desenvolvimento

```bash
# Modificar apenas neste repositório
cd ~/Projetos/erp-chatwoot-modifications

# Editar código enterprise
vim enterprise/app/javascript/dashboard/composables/useEnterpriseSidebar.js

# Commitar mudanças
git add .
git commit -m "feat: adicionar nova funcionalidade"

# Aplicar no projeto principal
./apply-modifications.sh
```

### 3. Atualização do Upstream

```bash
# Atualizar Chatwoot original
cd ~/Projetos/ErpChatwoot
git pull origin develop

# Reaplicar modificações
cd ../erp-chatwoot-modifications
./apply-modifications.sh
```

## 🎯 Vantagens desta Abordagem

### ✅ Para Desenvolvimento
- **Fork não necessário**: Clone direto do repositório oficial
- **Sem commits extras**: Histórico upstream limpo
- **Aplicação seletiva**: Modificações aplicadas sob demanda
- **Versionamento isolado**: Suas mudanças em repositório separado

### ✅ Para Manutenção
- **Atualizações fáceis**: Pull direto do upstream
- **Conflitos zero**: Não há commits conflitantes
- **Reversível**: Fácil remover/aplicar modificações
- **Backup automático**: Fork antigo preservado

### ✅ Para Deploy
- **Docker ready**: Funciona perfeitamente com containers
- **CI/CD compatível**: Processo de build limpo
- **Rollback fácil**: Voltar à versão upstream original

## 📝 Desenvolvimento Detalhado

### Adicionar Novos Recursos Enterprise

1. **Criar código enterprise**:
   ```bash
   cd ~/Projetos/erp-chatwoot-modifications
   # Adicionar em enterprise/app/...
   ```

2. **Modificar arquivos core** (se necessário):
   ```bash
   # Fazer modificação no ErpChatwoot primeiro
   # Depois copiar arquivo modificado para core-patches/
   cp ../ErpChatwoot/app/javascript/dashboard/routes/dashboard.routes.js core-patches/
   ```

3. **Atualizar script** (se necessário):
   ```bash
   vim apply-modifications.sh
   # Adicionar novas cópias se criou novos arquivos
   ```

### Modificar Traduções

```bash
# Arquivo principal de traduções
vim core-patches/settings.json

# Ou adicionar novos arquivos de tradução
cp ../ErpChatwoot/app/javascript/dashboard/i18n/locale/pt_BR/ core-patches/
```

## 🐛 Troubleshooting

### "Diretório ../ErpChatwoot não encontrado"
```bash
# Verificar estrutura
ls -la ~/Projetos/

# O diretório deve existir e conter o clone do Chatwoot
# Se não existir, refazer o clone:
cd ~/Projetos
git clone https://github.com/chatwoot/chatwoot.git ErpChatwoot
```

### Modificações não aplicam
```bash
# Verificar permissões do script
chmod +x apply-modifications.sh

# Executar com debug
bash -x apply-modifications.sh
```

### Conflitos após atualização upstream
```bash
# Resetar projeto e reaplicar
cd ~/Projetos/ErpChatwoot
git reset --hard origin/develop
git clean -fd

cd ../erp-chatwoot-modifications
./apply-modifications.sh
```

## 🔄 Migração do Fork Antigo

Se você tinha um fork anterior:

```bash
# 1. Backup já foi feito (ErpChatwoot.backup)
# 2. Setup da nova estrutura conforme acima
# 3. Comparar diferenças se necessário:
diff -r ErpChatwoot.backup/ ErpChatwoot/
# 4. Remover backup quando não precisar mais
rm -rf ErpChatwoot.backup/
```

## 📊 Comparação de Abordagens

| Aspecto | Fork Tradicional | Clone Limpo + Modificações |
|---------|------------------|-----------------------------|
| **GitHub** | Fork público | Sem fork |
| **Commits** | Misturados | Separados |
| **Atualização** | `git pull upstream` | `git pull origin` |
| **Conflitos** | Possíveis | Zero |
| **Deploy** | Precisa limpar | Sempre limpo |
| **Histórico** | Poluído | Limpo |

## 🎯 Resultado Final

Com esta abordagem você tem:
- ✅ **Projeto upstream limpo** para atualizações
- ✅ **Modificações enterprise versionadas** separadamente
- ✅ **Deploy confiável** sem conflitos
- ✅ **Desenvolvimento ágil** sem preocupações com upstream

---

**📝 Resumo**: Clone limpo + modificações separadas = desenvolvimento enterprise profissional!

**Autor**: Thander21
**Projeto**: ERP Chatwoot Enterprise
**Última atualização**: 2026