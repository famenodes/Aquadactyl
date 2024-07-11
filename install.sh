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

echo "Установка завершена! Apache2 и UFW настроены."
