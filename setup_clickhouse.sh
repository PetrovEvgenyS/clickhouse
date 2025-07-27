#!/bin/bash

# --- Переменные ---
CLICKHOUSE_IP="$1"                  # IP-адрес сервера, с которого будет принимать запросы.
CONFIG="/etc/clickhouse-server/config.d/my-config.xml"  # Конфиг с изменениями ClickHouse.

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

# --- Проверка наличия аргументов ---
if [ -z "$1" ]; then
  errorprint "Ошибка: не указан обязательный аргумент."
  echo "Пожалуйста, укажите IP-адрес сервера, с которого будет принимать запросы."
  echo "Использование: sudo $0 <CLICKHOUSE_IP>"
  echo "Пример: sudo $0 10.100.10.1"
  exit 1
fi

# --- Установка ClickHouse ---
magentaprint "Настройка репозитория RPM:"
dnf install -y yum-utils
yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo

magentaprint "Установка сервера и клиента ClickHouse:"
dnf install -y clickhouse-server clickhouse-client

magentaprint "Запуск сервера ClickHouse:"
systemctl enable --now clickhouse-server
systemctl status clickhouse-server --no-page

magentaprint "Версия ClickHouse:"
clickhouse-server --version

magentaprint "Логи ClickHouse:"
ls -lah /var/log/clickhouse-server/*

# --- Настройка прослушивания на $CLICKHOUSE_IP через config.d ---
magentaprint "Настройка ClickHouse на прослушивание на интерфейсе ($CLICKHOUSE_IP)"
magentaprint "через $CONFIG"
cat <<EOF > $CONFIG
<yandex>
    <!-- На каком интерфейсе будет слушать ClickHouse -->
    <listen_host>$CLICKHOUSE_IP</listen_host>
</yandex>
EOF

magentaprint "Чтобы запустить клиента ClickHouse, выполните:"
echo "clickhouse-client"

magentaprint "Если вы установили пароль для вашего сервера, вам нужно будет выполнить:"
echo "clickhouse-client --password"

magentaprint "Пример, подключеник к ClickHouse:"
echo "clickhouse-client -h <hostname> -u <username> --password"
