# Projeto 1 – Aplicação PHP + MySQL no Kubernetes (local)

Formulário simples (frontend) que envia nome, e-mail e comentário para um backend PHP, que grava os dados em um MySQL. Tudo roda em contêineres no Kubernetes local (Docker Desktop).

## Arquitetura

```
frontend/index.html  --(POST http://localhost/index.php)-->  Service "php" (LoadBalancer :80)
                                                                  |
                                                         3 pods PHP/Apache
                                                                  |
                                                  Service "mysql-connection" (headless :3306)
                                                                  |
                                                         1 pod MySQL  --> PVC "mysql-dados" (10Gi)
```

## Estrutura

| Arquivo | Função |
|---|---|
| `backend/dockerfile` | Imagem `php:8.2-apache` com a extensão `mysqli`; copia `index.php` e `conexao.php` para o Apache. |
| `backend/conexao.php` | Conexão com o MySQL usando o host `mysql-connection` (nome do Service). |
| `backend/index.php` | Recebe o POST e insere na tabela `mensagens`. |
| `database/dockerfile` | Imagem `mysql:8.0` com senha root e banco `meubanco`; copia `sql.sql` para a inicialização. |
| `database/sql.sql` | Cria a tabela `mensagens` (`id`, `nome`, `email`, `comentario`). |
| `services.yml` | Service `php` (LoadBalancer, porta 80) e Service `mysql-connection` (headless, porta 3306). |
| `deployment.yml` | PVC `mysql-dados`, Deployment `mysql` (1 réplica) e Deployment `php` (3 réplicas). |
| `script.bat` | Faz o build das imagens e aplica os YAMLs no cluster. |
| `frontend/` | Página HTML, CSS e JS (jQuery) com o formulário. |

## O que foi feito

### Novos arquivos
- Dockerfiles do backend e do banco.
- `database/sql.sql` com a criação da tabela.
- `services.yml`, `deployment.yml` e `script.bat`.

### Alterações em arquivos existentes
- **`backend/conexao.php`**: o host do banco passou de vazio para `mysql-connection`.
- **`backend/index.php`**: `<?` virou `<?php`, porque a tag curta não funciona na imagem oficial do PHP.
- **`frontend/js.js`**: a URL do ajax passou de vazia para `http://localhost/index.php`.

### Diferenças em relação ao vídeo do curso
- **Sem push para o Docker Hub.** As imagens são locais (`projeto-backend:1.0` e `projeto-database:1.0`) e os Deployments usam `imagePullPolicy: IfNotPresent`.
- **PVC sem `storageClassName`.** Usa a classe padrão do Docker Desktop.
- **MySQL 8.** A opção `--ignore-db-dir=lost+found` não existe nessa versão e foi removida. Foi adicionado `--mysql-native-password=ON` para garantir compatibilidade com o cliente PHP.
- **`strategy: Recreate` no MySQL.** Evita dois pods usando o mesmo volume durante uma atualização.

## Como executar

**Pré-requisitos:** Docker Desktop com o Kubernetes ativado (Settings → Kubernetes → Enable Kubernetes).

1. Na pasta do projeto, execute:
   ```bat
   .\script.bat
   ```
2. Acompanhe os pods até ficarem `Running`:
   ```bash
   kubectl get pods
   kubectl get services
   ```
3. Abra `frontend/index.html` no navegador, preencha o formulário e clique em **Enviar**.
4. Confira os dados gravados:
   ```bash
   kubectl exec -it deploy/mysql -- mysql -uroot -pSenha123 meubanco -e "SELECT * FROM mensagens;"
   ```

## Limpeza

```bash
kubectl delete -f deployment.yml
kubectl delete -f services.yml
```

O PVC está em `deployment.yml`, então esse comando também apaga os dados.

## Observações

- Se o Kubernetes do Docker Desktop estiver no modo **kind**, ele não enxerga as imagens locais. Use `kind load docker-image` ou faça o push para um registry.
- O `id` das mensagens é gerado com `rand(1, 999)`, como no código original, então pode haver colisão. O ideal seria `AUTO_INCREMENT` na tabela.
- O `index.php` monta o SQL concatenando os valores do formulário, o que permite SQL injection. Para produção, use prepared statements.
- A senha do banco está fixa nos arquivos. Em produção, use um `Secret` do Kubernetes.
- Esta configuração não foi testada, porque o Docker Desktop não estava em execução quando foi criada.
