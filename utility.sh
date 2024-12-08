#!/bin/bash

# Функции для выполнения задач
list_users() {
    cut -d: -f1,6 /etc/passwd | sort
}

list_processes() {
    ps -eo pid,cmd --sort=pid
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -u, --users         List users and their home directories"
    echo "  -p, --processes     List running processes"
    echo "  -h, --help          Show this help message"
    echo "  -l PATH, --log PATH Redirect output to file at PATH"
    echo "  -e PATH, --errors PATH Redirect error output to file at PATH"
}

# Обработка аргументов
TEMP=$(getopt -o uphl:e: --long users,processes,help,log:,errors: -n 'utility.sh' -- "$@")
if [ $? != 0 ]; then echo "Terminating..." >&2; exit 1; fi
eval set -- "$TEMP"

LOG_FILE=""
ERR_FILE=""
ACTION=""

while true; do
    case "$1" in
        -u|--users) ACTION="users"; shift ;;
        -p|--processes) ACTION="processes"; shift ;;
        -h|--help) ACTION="help"; shift ;;
        -l|--log) LOG_FILE="$2"; shift 2 ;;
        -e|--errors) ERR_FILE="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
done

# Перенаправление потоков, если указаны файлы
if [ -n "$LOG_FILE" ]; then
    if [ -w "$(dirname "$LOG_FILE")" ]; then
        exec >"$LOG_FILE"
    else
        echo "Cannot write to log file: $LOG_FILE" >&2
        exit 1
    fi
fi

if [ -n "$ERR_FILE" ]; then
    if [ -w "$(dirname "$ERR_FILE")" ]; then
        exec 2>"$ERR_FILE"
    else
        echo "Cannot write to error file: $ERR_FILE" >&2
        exit 1
    fi
fi

# Выполнение выбранного действия
case "$ACTION" in
    "users") list_users ;;
    "processes") list_processes ;;
    "help") show_help ;;
    *) echo "No valid action specified" >&2; exit 1 ;;
esac