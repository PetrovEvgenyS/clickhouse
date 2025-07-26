#!/bin/bash

# --- Переменные ---

### ЦВЕТА ###
ESC=$(printf '\033') RESET="${ESC}[0m" MAGENTA="${ESC}[35m" RED="${ESC}[31m" GREEN="${ESC}[32m"

### Функции цветного вывода ###
magentaprint() { echo; printf "${MAGENTA}%s${RESET}\n" "$1"; }
errorprint() { echo; printf "${RED}%s${RESET}\n" "$1"; }
greenprint() { echo; printf "${GREEN}%s${RESET}\n" "$1"; }


# ---------------------------------------------------------------------------------------


# --- Проверка запуска через sudo ---
if [ -z "$SUDO_USER" ]; then
    errorprint "Пожалуйста, запустите скрипт через sudo."
    exit 1
fi

magentaprint "Настройка репозитория RPM:"
dnf install -y yum-utils
yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo

magentaprint "Установка сервера и клиента ClickHouse:"
dnf install -y clickhouse-server clickhouse-client

magentaprint "Запуск сервера ClickHouse:"
systemctl enable --now clickhouse-server
systemctl status clickhouse-server --no-page

magentaprint "Чтобы запустить клиента ClickHouse, выполните:"
echo "clickhouse-client"

magentaprint "Если вы установили пароль для вашего сервера, вам нужно будет выполнить:"
echo "clickhouse-client --password"
