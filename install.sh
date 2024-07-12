#!/bin/bash

echo "Выберите действие:"
echo "1 - Установка панели (установка)"
echo "2 - Удаление панели (удаляет все файлы панели)"

read -p "Ваш выбор: " choice

case $choice in
    1)
        read -p "На каком языке установить? (RU/EN): " lang
        case $lang in
            "RU")
                echo "Вы выбрали установку на русском языке."
                ;;
            "EN")
                echo "You chose to install in English."
                ;;
            *)
                echo "Выбран неверный язык, установка отменена."
                exit 1
                ;;
        esac

        read -p "Введите никнейм: " admin_username
        read -p "Введите фамилию: " admin_lastname
        read -p "Введите почту: " admin_email
        read -p "Введите пароль: " admin_password
        read -p "Введите домен для вингсов (wings.domain.com): " wings_domain
        read -p "Введите домен панели (domain.com): " panel_domain

        sudo apt-get update
        sudo apt-get install -y ufw apache2 php libapache2-mod-php php-mysql mongodb npm

        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
        sudo ufw allow http
        sudo ufw allow https
        sudo ufw enable

        sudo systemctl start apache2
        sudo systemctl enable apache2

        git clone https://github.com/famenodes/Aquadactyl.git /var/www/html/aquadactyl
        cd /var/www/html/aquadactyl/server
        npm install

        sudo chown -R www-data:www-data /var/www/html/aquadactyl
        sudo chmod -R 755 /var/www/html/aquadactyl

        sudo bash -c "cat > /etc/apache2/sites-available/$panel_domain.conf <<EOF
<VirtualHost *:80>
    ServerName $panel_domain
    DocumentRoot /var/www/html/aquadactyl/client
    <Directory /var/www/html/aquadactyl/client>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

        sudo a2ensite $panel_domain.conf
        sudo systemctl reload apache2

        sudo bash -c "cat > /etc/apache2/sites-available/$wings_domain.conf <<EOF
<VirtualHost *:80>
    ServerName $wings_domain
    DocumentRoot /var/www/html/aquadactyl/client
    <Directory /var/www/html/aquadactyl/client>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

        sudo a2ensite $wings_domain.conf
        sudo systemctl reload apache2

        echo "Установка завершена! Ваша панель доступна по адресу http://$panel_domain, а вингсы по адресу http://$wings_domain"
        ;;

    2)
        read -p "На каком языке выполнить удаление? (RU/EN): " lang
        case $lang in
            "RU")
                echo "Вы выбрали удаление на русском языке."
                ;;
            "EN")
                echo "You chose to uninstall in English."
                ;;
            *)
                echo "Выбран неверный язык, удаление отменено."
                exit 1
                ;;
        esac

        sudo rm -rf /var/www/html/aquadactyl
        sudo a2dissite $panel_domain.conf
        sudo a2dissite $wings_domain.conf
        sudo systemctl reload apache2

        echo "Панель удалена."
        ;;
    *)
        echo "Неверный выбор, завершение работы."
        exit 1
        ;;
esac
