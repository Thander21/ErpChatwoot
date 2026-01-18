# Guia: Deploy Rápido com Pre-Build (GitHub Actions)

Para evitar que o Coolify demore compilando o projeto do zero, configuramos um fluxo de **Pre-Build**.
O GitHub vai construir a imagem Docker e o Coolify apenas fará o download dela.

## 1. O que já foi feito

Criamos um arquivo `.github/workflows/docker-publish.yml`.
Toda vez que você fizer um `git push` para a branch `main`, o GitHub Actions vai:
1.  Baixar o código.
2.  Construir a imagem Docker completa.
3.  Publicar no **GitHub Container Registry (GHCR)**.

A imagem ficará disponível em: `ghcr.io/SEU_USUARIO/erpchatwoot:latest`

## 2. Configurar o Coolify para usar a Imagem Pronta

No painel do Coolify:

1.  **Vá nas configurações do recurso Chatwoot.**
2.  **Build Pack:** Mude de `Docker Compose` (Build Local) para `Docker Image`.
3.  **Docker Image:** Insira o endereço da imagem gerada:
    `ghcr.io/thander21/erpchatwoot:latest`
    *(Substitua `thander21` pelo seu usuário do GitHub, tudo em minúsculo)*.
4.  **Registry:** Se o repositório for privado, você precisará adicionar o GitHub Container Registry nas configurações de "Sources/Registries" do Coolify com um Token (PAT). Se for público, não precisa.

## 3. Vantagens

*   **Tempo de Deploy:** Cai de ~15 minutos para ~30 segundos.
*   **Estabilidade:** Se o build quebrar, ele quebra no GitHub, não no seu servidor de produção.
*   **Performance:** Seu servidor não gasta CPU compilando assets.

## 4. Como testar

1.  Faça um commit e push deste código.
2.  Vá na aba "Actions" do seu repositório no GitHub.
3.  Aguarde o job "Docker Build & Publish" ficar verde ✅.
4.  No Coolify, clique em "Deploy".
