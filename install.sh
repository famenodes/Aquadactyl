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

# Клонирование репозитория с GitHub
repo_url="https://github.com/famenodes/Aquadactyl.git"
git clone $repo_url /var/www/html/aquadactyl

# Настройка прав доступа для веб-сервера
sudo chown -R www-data:www-data /var/www/html/aquadactyl
sudo chmod -R 755 /var/www/html/aquadactyl

# Перезапуск Apache2 для применения изменений
sudo systemctl restart apache2

echo "Установка завершена! Ваш проект доступен по адресу http://your_server_ip/aquadactyl"
