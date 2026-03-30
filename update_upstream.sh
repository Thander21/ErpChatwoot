#!/bin/bash

# Configuration
UPSTREAM_REPO="https://github.com/chatwoot/chatwoot.git"
TARGET_DIR="chatwoot-base"
TEMP_DIR="temp_upstream"
VERSION_FILE=".chatwoot_version"

# Determine branch/tag to checkout (default: master)
BRANCH=${1:-master}

# Read previous version
PREV_VERSION="desconhecida"
if [ -f "$VERSION_FILE" ]; then
  PREV_VERSION=$(cat "$VERSION_FILE")
fi

echo "=========================================================="
echo "🔄 Atualizando Chatwoot Base de: [$PREV_VERSION] para [$BRANCH]"
echo "=========================================================="

# 1. Clean previous temp
rm -rf $TEMP_DIR

# 2. Clone requested upstream version
echo "📥 Git Clone: $UPSTREAM_REPO (@$BRANCH)..."
git clone --depth 1 --branch "$BRANCH" "$UPSTREAM_REPO" "$TEMP_DIR"
if [ $? -ne 0 ]; then
  echo "❌ Falha ao clonar o repositório. Verifique a branch/tag."
  exit 1
fi

# 3. Create target if not exists
mkdir -p $TARGET_DIR

# 4. Sync files (excluding .git)
echo "📂 Sincronizando arquivos do repositório base..."
rsync -av --delete --exclude='.git' --exclude='.github' "$TEMP_DIR/" "$TARGET_DIR/"

# 5. Save the new version
echo "$BRANCH" > "$VERSION_FILE"

# 6. Cleanup
rm -rf $TEMP_DIR

echo ""
echo "=========================================================="
echo "🔍 MAPEAMENTO DE ARQUIVOS SOBRESCRITOS (MenuPdvDmais)"
echo "=========================================================="

if [ -d "MenuPdvDmais/core-patches" ] && [ -f ".ai/file-registry.md" ]; then
  # Extract correct origin paths from the markdown table
  ORIGINALS=$(sed -n '/^## 🔧 Core Patches/,/^---/p' .ai/file-registry.md | awk -F'|' '/^\| `.*` \|/ { gsub(/`| /, "", $2); print $2 }')
  CHANGED=0

  for FILE in $ORIGINALS; do
      ORIGINAL="$TARGET_DIR/$FILE"
      FILENAME=$(basename "$FILE")
      
      # Try to guess the patch location based on filename in core-patches
      PATCH=$(find MenuPdvDmais/core-patches -type f -name "$FILENAME" | head -n 1)
      
      if [ -f "$ORIGINAL" ]; then
          if git diff --name-only | grep -q "^$ORIGINAL$"; then
              echo "🔴 MODIFICADO NO UPSTREAM: $ORIGINAL"
              if [ ! -z "$PATCH" ]; then
                  echo "   ↳ Seu patch local está em: $PATCH"
              fi
              echo "   ↳ VERIFIQUE DIFF: git diff $ORIGINAL"
              CHANGED=$((CHANGED + 1))
          else
               echo "🟢 INTACTO NO UPSTREAM : $ORIGINAL"
          fi
      else
          echo "🟡 NÃO ENCONTRADO UPSTREAM: $ORIGINAL"
      fi
  done

  echo "=========================================================="
  if [ $CHANGED -gt 0 ]; then
      echo "🚨 ATENÇÃO: $CHANGED arquivo(s) core customizado(s) sofreram alterações do $PREV_VERSION para $BRANCH!"
      echo "Você precisará revisar as diferenças (verifique o log git diff acima)."
  else
      echo "✅ Ótimo! Nenhum dos seus core-patches foi afetado por alterações nesta nova versão."
  fi
else
  echo "Pasta MenuPdvDmais/core-patches não encontrada. Nenhuma verificação de diff acionada."
fi

echo ""
echo "⚠️  Não esqueça de commitar a atualização do base:"
echo "   git add chatwoot-base $VERSION_FILE"
echo "   git commit -m 'Update chatwoot-base do $PREV_VERSION par $BRANCH'"
