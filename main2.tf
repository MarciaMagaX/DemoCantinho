provider "aws" {
  region = "us-east-1"
}

# Recurso para criar a instância AWS
resource "aws_instance" "amb-prod15" {
  ami           = "ami-0a0e5d9c7acc336f1"
  instance_type = "t2.micro"
  key_name      = "terraform2"

  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_https.id,
    aws_security_group.allow_http.id
  ]

  user_data = <<-EOF
#!/bin/bash

# Cria o arquivo docker-compose.yml
cat << 'EOT' > docker-compose.yml
version: '3.8'

services:
  db:
    image: mysql:8.0
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
    image: wordpress:latest
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_PASSWORD: GAud4mZby8F3SD6P
    ports:
      - "8080:80"  # Mapeia a porta 80 do container para a porta 8080 no host
    networks:
      - wordpress_net

volumes:
  db_data:

networks:
  wordpress_net:
EOT

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

# Executa o Docker Compose
sudo -u ubuntu docker-compose up -d
EOF

  tags = {
    Name = "amb-prod15"
  }
}

# Security Group para permitir SSH
resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow_ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para permitir HTTP
resource "aws_security_group" "allow_http" {
  name_prefix = "allow_http"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para permitir HTTPS
resource "aws_security_group" "allow_https" {
  name_prefix = "allow_https"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
