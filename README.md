# DemoCantinho

Este projeto tem como objetivo:
1) criar uma VM
2) instalar docker utilizando um script de inicialização
3) subir um container com o WordPress instalado na VM
4) configurar containers separados para o WordPress e o banco de dados, garantindo a retenção de dados durante o upgrade da aplicação
5) fornecer um arquivo docker-compose.yml para facilitar a criação dos containers
6) configurar senha do usuário root do banco de dados 

# Terraform AWS WordPress Deployment

Este projeto utiliza o Terraform para criar uma instância AWS e configurar um ambiente WordPress usando Docker Compose. 

Índice
Pré-requisitos
Planejamento
Configuração
1. Arquivo main.tf
2. Arquivo docker-compose.yml
3. Arquivo Dockerfile-mysql
4. Arquivo Dockerfile-wordpress
5. Arquivo init.sql

Como Usar
Passo 1: Configurar Credenciais AWS
Passo 2: Inicializar o Terraform no VS Code
Passo 3: Planejar a Execução
Passo 4: Aplicar o Plano

Acesso
Limpeza
Contribuição
Licença
Referências e Documentação

Pré-requisitos
Antes de começar, certifique-se de ter os seguintes pré-requisitos instalados:

Terraform
AWS CLI
Visual Studio Code
Extensão do Terraform no VS Code
Uma conta AWS com permissões suficientes para criar instâncias e grupos de segurança


Planejamento
Este projeto tem como objetivo automatizar a criação de um ambiente WordPress em uma instância AWS usando Docker e Docker Compose. O Terraform será utilizado para provisionar a infraestrutura na AWS, e o Docker Compose será usado para orquestrar os contêineres do WordPress e MySQL.

Configuração
1. Arquivo main.tf
O arquivo main.tf contém a definição dos recursos AWS e a configuração necessária para iniciar uma instância EC2 com Docker e Docker Compose instalados.

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "amb-prod14" {
  ami           = "ami-0a0e5d9c7acc336f1"
  instance_type = "t2.micro"
  key_name      = "terraform2"

  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_https.id,
    aws_security_group.allow_http.id
  ]

...
}

# Atualiza os pacotes e instala o Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Adiciona o usuário 'ubuntu' ao grupo 'docker'
sudo usermod -aG docker ubuntu

# Instala o Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Clona o repositório com o Dockerfile e docker-compose.yml
git clone <URL_DO_SEU_REPOSITORIO_GIT> /home/ubuntu/projeto

# Navega até o diretório clonado
cd /home/ubuntu/projeto

# Executa o Docker Compose
sudo -u ubuntu docker-compose up -d

2. Arquivo docker-compose.yml

version: '3.8'

services:
  db:
    build:
      context: .
      dockerfile: Dockerfile-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: GAud4mZby8F3SD6P
      MYSQL_PASSWORD: GAud4mZby8F3SD6P
      MYSQL_USER: wordpress
      MYSQL_DATABASE: wordpress
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - wordpress_net

  wordpress:
    build:
      context: .
      dockerfile: Dockerfile-wordpress
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_PASSWORD: GAud4mZby8F3SD6P
    ports:
      - "8080:80"
    networks:
      - wordpress_net

volumes:
  db_data:

networks:
  wordpress_net:

3. Arquivo Dockerfile-mysql
FROM mysql:8.0

# Copia o script de inicialização para o container
COPY init.sql /docker-entrypoint-initdb.d/

# Define variáveis de ambiente
ENV MYSQL_ROOT_PASSWORD=GAud4mZby8F3SD6P
ENV MYSQL_DATABASE=wordpress
ENV MYSQL_USER=wordpress
ENV MYSQL_PASSWORD=GAud4mZby8F3SD6P

EXPOSE 3306

4. Arquivo Dockerfile-wordpress
FROM wordpress:latest

# Define variáveis de ambiente
ENV WORDPRESS_DB_HOST=db:3306
ENV WORDPRESS_DB_USER=wordpress
ENV WORDPRESS_DB_NAME=wordpress
ENV WORDPRESS_DB_PASSWORD=GAud4mZby8F3SD6P

EXPOSE 80

5. Arquivo init.sql
-- Script SQL de inicialização
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER 'wordpress'@'%' IDENTIFIED BY 'GAud4mZby8F3SD6P';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';
FLUSH PRIVILEGES;


# Como Usar
Passo 1: Configurar Credenciais AWS
Configure suas credenciais AWS usando a AWS CLI:
aws configure

AWS Access Key ID [SUA CHAVE]:
AWS Secret Access Key [SEU SECRET]:
Default region name [us-east-1]:
Default output format [json]:


Passo 2: Inicializar o Terraform no VS Code
Abra o VS Code e navegue até o diretório do projeto.
Certifique-se de ter a extensão do Terraform instalada no VS Code.
Abra um terminal integrado no VS Code.
Inicialize o Terraform no diretório do projeto:

terraform init


Passo 3: Planejar a Execução
Crie um plano de execução para revisar as mudanças que o Terraform irá fazer na infraestrutura:

terraform plan


Passo 4: Aplicar o Plano
Aplique o plano para criar a infraestrutura na AWS:

terraform apply

Digite yes quando solicitado para confirmar a aplicação do plano.


# Acesso

Após a conclusão da aplicação do Terraform, você pode acessar a instância WordPress através do endereço IP público da instância EC2 na porta 8080, da seguinte maneira "http://IPPÚBLICO:8080


# Limpeza
Para destruir a infraestrutura criada pelo Terraform, execute:

terraform destroy


# Contribuição
Se você deseja contribuir com este projeto, sinta-se à vontade para abrir um pull request ou relatar problemas através das issues do repositório.

# Licença
Este projeto está licenciado sob a Licença MIT.

# Referências e Documentação:

Documentação do Terraform: https://registry.terraform.io/
Documentação da AWS CLI: https://docs.aws.amazon.com/pt_br/cli/latest/userguide/cli-chap-configure.html
Documentação do Docker: https://docs.docker.com/
Documentação do Docker Compose: https://docs.docker.com/compose/ 
Documentação do VS Code https://code.visualstudio.com/docs

Este README fornece uma visão geral completa do projeto, desde o planejamento até a execução e limpeza da infraestrutura, utilizando o Visual Studio Code para facilitar a edição e execução dos comandos.