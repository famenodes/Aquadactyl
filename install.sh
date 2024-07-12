#!/bin/bash

# Обновление пакетов и установка необходимых утилит
sudo apt-get update -y
sudo apt-get upgrade -y

# Установка UFW (Uncomplicated Firewall)
sudo apt-get install ufw -y

# Настройка UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Установка Apache2
sudo apt-get install apache2 -y

# Запуск и включение Apache2 при старте системы
sudo systemctl start apache2
sudo systemctl enable apache2

# Установка Git
sudo apt-get install git -y

# Запрос доменов у пользователя
read -p "Введите домен для вингсов (wings.domain.com): " wings_domain
read -p "Введите домен панели (domain.com): " panel_domain

# Клонирование репозитория с GitHub
repo_url="https://github.com/famenodes/Aquadactyl.git"
git clone $repo_url /var/www/html/aquadactyl

# Перемещение файлов в нужные директории
mkdir -p /var/www/html/aquadactyl/files
mv /var/www/html/aquadactyl/styles.css /var/www/html/aquadactyl/files/
mv /var/www/html/aquadactyl/script.js /var/www/html/aquadactyl/files/

# Настройка прав доступа для веб-сервера
sudo chown -R www-data:www-data /var/www/html/aquadactyl
sudo chmod -R 755 /var/www/html/aquadactyl

# Создание виртуального хоста для панели
sudo bash -c "cat > /etc/apache2/sites-available/$panel_domain.conf <<EOF
<VirtualHost *:80>
    ServerName $panel_domain
    DocumentRoot /var/www/html/aquadactyl
    <Directory /var/www/html/aquadactyl>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

# Установка и настройка Wings
curl -sSL https://get.docker.com/ | sh
sudo systemctl start docker
sudo systemctl enable docker

curl -Lo /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings

sudo mkdir -p /etc/pterodactyl
sudo bash -c "cat > /etc/pterodactyl/config.yml <<EOF
# Example Wings Configuration
# https://pterodactyl.io/wings/1.0/configuration.html
# This is a simplified example for basic configuration.

# The panel url used to fetch the node configuration
panel_url: 'http://$panel_domain'

# This is the token used to authenticate this node with the panel
token_id: 'YourTokenID'
token: 'YourToken'

# Set the domain for the node
domain: '$wings_domain'

# Bind settings for Wings
bind:
  host: 0.0.0.0
  port: 8080

EOF"

# Создание виртуального хоста для Wings
sudo bash -c "cat > /etc/apache2/sites-available/$wings_domain.conf <<EOF
<VirtualHost *:80>
    ServerName $wings_domain
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
    ProxyPreserveHost On
</VirtualHost>
EOF"

# Активация виртуальных хостов
sudo a2ensite $panel_domain.conf
sudo a2ensite $wings_domain.conf

# Перезапуск Apache2 для применения изменений
sudo systemctl reload apache2

# Запуск Wings
sudo wings --config /etc/pterodactyl/config.yml

echo "Установка завершена! Ваша панель доступна по адресу http://$panel_domain, а вингсы по адресу http://$wings_domain"
