#!/bin/bash

# Установка зависимостей
sudo apt-get update
sudo apt-get install -y curl git unzip

# Запрос данных у пользователя
read -p "Введите никнейм: " admin_username
read -p "Введите фамилию: " admin_lastname
read -p "Введите почту: " admin_email
read -p "Введите пароль: " admin_password
read -p "Введите домен для вингсов (wings.domain.com): " wings_domain
read -p "Введите домен панели (domain.com): " panel_domain

# Установка UFW (Uncomplicated Firewall) и настройка
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Установка Apache2
sudo apt-get install -y apache2

# Установка PHP и модулей
sudo apt-get install -y php libapache2-mod-php php-mysql

# Установка MySQL
sudo apt-get install -y mysql-server

# Настройка MySQL
sudo mysql -e "CREATE DATABASE aquadactyl;"
sudo mysql -e "CREATE USER 'aquadactyl_user'@'localhost' IDENTIFIED BY 'yourpassword';"
sudo mysql -e "GRANT ALL PRIVILEGES ON aquadactyl.* TO 'aquadactyl_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Создание таблицы пользователей
sudo mysql -u root -e "USE aquadactyl; CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(255) NOT NULL, lastname VARCHAR(255) NOT NULL, email VARCHAR(255) NOT NULL, password VARCHAR(255) NOT NULL); INSERT INTO users (username, lastname, email, password) VALUES ('$admin_username', '$admin_lastname', '$admin_email', '$admin_password');"

# Клонирование репозитория Aquadactyl с GitHub
repo_url="https://github.com/famenodes/Aquadactyl.git"
git clone $repo_url /var/www/html/aquadactyl

# Перемещение файлов стилей и скриптов
mkdir -p /var/www/html/aquadactyl/files
mv /var/www/html/aquadactyl/styles.css /var/www/html/aquadactyl/files/
mv /var/www/html/aquadactyl/script.js /var/www/html/aquadactyl/files/

# Настройка прав доступа для Apache2
sudo chown -R www-data:www-data /var/www/html/aquadactyl
sudo chmod -R 755 /var/www/html/aquadactyl

# Создание виртуального хоста для панели Aquadactyl
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
# Пример конфигурации Wings
panel_url: 'http://$panel_domain'
token_id: 'YourTokenID'
token: 'YourToken'
domain: '$wings_domain'
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