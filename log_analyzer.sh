#!/bin/bash

# ------------------------------------------------------------
# Log Analysis Script
# Author: Lucas Rangel
# Description: This script automates the analysis of log files.
# ------------------------------------------------------------

# Function to select language
select_language() {
    echo "Select a language:"
    echo "1) English"
    echo "2) Português"
    read -p "Option: " LANGUAGE_OPTION
    case $LANGUAGE_OPTION in
        1) LANGUAGE="en" ;;
        2) LANGUAGE="pt" ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
}

# Load the appropriate language strings based on the user's choice
load_language_strings() {
    if [[ "$LANGUAGE" == "en" ]]; then
        MSG_HEADER1="                       _ _              _       _              "
        MSG_HEADER2="        /_\  _ _  __ _| (_)___ ___   __| |___  | |   ___  __ _ "
        MSG_HEADER3="       / _ \| ' \/ _\` | | (_-</ -_) / _\` / -_) | |__/ _ \/ _\` |"
        MSG_HEADER4="      /_/ \_\_||_\__,_|_|_/__/\___| \__,_\___| |____\___/\__, |"
        MSG_HEADER5="                                                          |___/ "
        MSG_HEADER6="                                                          by Lucas R."
        
        MSG_FILE_NOT_FOUND="Error: File not found."
        MSG_FIRST_LINES="📝 First 5 lines of the file"
        MSG_IP_REQUESTS="📊 List of IPs sorted by number of requests:"
        MSG_ENTER_IP="🔍 Enter the IP you want to analyze:"
        MSG_FIRST_REQUEST="⏰ Date and time of the FIRST request from IP"
        MSG_LAST_REQUEST="⏰ Date and time of the LAST request from IP"
        MSG_ENTER_STATUS="Enter the HTTP status code to filter by (e.g., 404):"
        MSG_FILTERED_LOGS="📄 Logs filtered by status code"
        MSG_USER_AGENTS="📋 List of unique User-Agents:"
        MSG_ENTER_TOOL="🔧 Enter the name of the tool you want to search for (e.g., Nmap):"
        MSG_FIRST_TOOL_USE="🔍 First occurrence of tool used by IP"
        MSG_LAST_TOOL_USE="🔍 Last occurrence of tool used by IP"
        MSG_SELECT_OPTION="Select an option:"
        MSG_OPTION_1="1) View the first 5 lines of the log"
        MSG_OPTION_2="2) List IPs by number of requests"
        MSG_OPTION_3="3) View the date and time of the first and last request from an IP"
        MSG_OPTION_4="4) Filter logs by HTTP status code"
        MSG_OPTION_5="5) List unique User-Agents"
        MSG_OPTION_6="6) Identify the first and last occurrence of a specific tool used by an IP"
        MSG_OPTION_7="7) Exit"
        MSG_INVALID_OPTION="Invalid option"
        MSG_ENTER_LOG_FILE="📁 Please enter the path to the log file:"
    elif [[ "$LANGUAGE" == "pt" ]]; then
        MSG_HEADER1="                       _ _              _       _              "
        MSG_HEADER2="        /_\  _ _  __ _| (_)___ ___   __| |___  | |   ___  __ _ "
        MSG_HEADER3="       / _ \| ' \/ _\` | | (_-</ -_) / _\` / -_) | |__/ _ \/ _\` |"
        MSG_HEADER4="      /_/ \_\_||_\__,_|_|_/__/\___| \__,_\___| |____\___/\__, |"
        MSG_HEADER5="                                                          |___/ "
        MSG_HEADER6="                                                          by Lucas R."

        MSG_FILE_NOT_FOUND="Erro: O arquivo '$LOG_FILE' não foi encontrado."
        MSG_FIRST_LINES="📝 Primeiras 5 linhas do arquivo '$LOG_FILE':"
        MSG_IP_REQUESTS="📊 Lista de IPs ordenados por quantidade de requisições:"
        MSG_ENTER_IP="🔍 Insira o IP que deseja analisar:"
        MSG_FIRST_REQUEST="⏰ Data e hora da PRIMEIRA requisição do IP"
        MSG_LAST_REQUEST="⏰ Data e hora da ÚLTIMA requisição do IP"
        MSG_ENTER_STATUS="Digite o código de status HTTP para filtrar (ex: 404):"
        MSG_FILTERED_LOGS="📄 Logs filtrados pelo código de status"
        MSG_USER_AGENTS="📋 Lista de User-Agents únicos:"
        MSG_ENTER_TOOL="🔧 Insira o nome da ferramenta que deseja procurar (ex: Nmap):"
        MSG_FIRST_TOOL_USE="🔍 Primeira ocorrência do uso da ferramenta pelo IP"
        MSG_LAST_TOOL_USE="🔍 Última ocorrência do uso da ferramenta pelo IP"
        MSG_SELECT_OPTION="Selecione uma opção:"
        MSG_OPTION_1="1) Ver primeiras 5 linhas do log"
        MSG_OPTION_2="2) Listar IPs por quantidade de requisições"
        MSG_OPTION_3="3) Ver data e hora da primeira e última requisição de um IP"
        MSG_OPTION_4="4) Filtrar logs por código de status HTTP"
        MSG_OPTION_5="5) Listar User-Agents únicos"
        MSG_OPTION_6="6) Identifique a primeira e última vez que uma ferramenta específica foi usada por um IP"
        MSG_OPTION_7="7) Sair"
        MSG_INVALID_OPTION="Opção inválida"
        MSG_ENTER_LOG_FILE="📁 Por favor, insira o caminho para o arquivo de log:"
    fi
}

print_header() {
    echo ""
    echo "$MSG_HEADER1"
    echo "$MSG_HEADER2"
    echo "$MSG_HEADER3"
    echo "$MSG_HEADER4"
    echo "$MSG_HEADER5"
    echo "$MSG_HEADER6"
    echo ""
}

check_file_exists() {
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "$MSG_FILE_NOT_FOUND"
        exit 1
    fi
}

show_first_line() {
    echo "$MSG_FIRST_LINES '$LOG_FILE':"
    head -n 5 "$LOG_FILE"
    echo ""
}

list_ips_by_requests() {
    echo "$MSG_IP_REQUESTS"
    awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr
    echo ""
}

show_request_times() {
    read -p "$MSG_ENTER_IP " TARGET_IP
    echo "$MSG_FIRST_REQUEST '$TARGET_IP':"
    FIRST_REQUEST=$(grep "$TARGET_IP" "$LOG_FILE" | head -n 1)
    echo "$FIRST_REQUEST" | awk '{print $4" "$5}' | sed 's/\[//;s/\]//'
    echo ""
    echo "$MSG_LAST_REQUEST '$TARGET_IP':"
    LAST_REQUEST=$(grep "$TARGET_IP" "$LOG_FILE" | tail -n 1)
    echo "$LAST_REQUEST" | awk '{print $4" "$5}' | sed 's/\[//;s/\]//'
    echo ""
}

filter_by_status() {
    read -p "$MSG_ENTER_STATUS " STATUS_CODE
    echo "$MSG_FILTERED_LOGS $STATUS_CODE:"
    grep " $STATUS_CODE " "$LOG_FILE"
    echo ""
}

list_user_agents() {
    echo "$MSG_USER_AGENTS"
    awk -F\" '{print $6}' "$LOG_FILE" | sort | uniq -c | sort -nr
    echo ""
}

show_tool_usage() {
    read -p "$MSG_ENTER_IP " TARGET_IP
    read -p "$MSG_ENTER_TOOL " TOOL_NAME
    
    echo "$MSG_FIRST_TOOL_USE '$TARGET_IP':"
    FIRST_OCCURRENCE=$(grep "$TARGET_IP" "$LOG_FILE" | grep "$TOOL_NAME" | head -n 1)
    echo "$FIRST_OCCURRENCE"
    if [[ -n "$FIRST_OCCURRENCE" ]]; then
        FIRST_DATE=$(echo "$FIRST_OCCURRENCE" | awk '{print $4" "$5}' | sed 's/\[//;s/\]//')
        echo "$MSG_FIRST_REQUEST $FIRST_DATE"
    fi
    echo ""
    
    echo "$MSG_LAST_TOOL_USE '$TARGET_IP':"
    LAST_OCCURRENCE=$(grep "$TARGET_IP" "$LOG_FILE" | grep "$TOOL_NAME" | tail -n 1)
    echo "$LAST_OCCURRENCE"
    if [[ -n "$LAST_OCCURRENCE" ]]; then
        LAST_DATE=$(echo "$LAST_OCCURRENCE" | awk '{print $4" "$5}' | sed 's/\[//;s/\]//')
        echo "$MSG_LAST_REQUEST $LAST_DATE"
    fi
    echo ""
}

show_menu() {
    echo "$MSG_SELECT_OPTION"
    echo "$MSG_OPTION_1"
    echo "$MSG_OPTION_2"
    echo "$MSG_OPTION_3"
    echo "$MSG_OPTION_4"
    echo "$MSG_OPTION_5"
    echo "$MSG_OPTION_6"
    echo "$MSG_OPTION_7"
    read -p "Option: " OPTION
    case $OPTION in
        1) show_first_line ;;
        2) list_ips_by_requests ;;
        3) show_request_times ;;
        4) filter_by_status ;;
        5) list_user_agents ;;
        6) show_tool_usage ;;
        7) exit 0 ;;
        *) echo "$MSG_INVALID_OPTION" ;;
    esac
}

main() {
    select_language
    load_language_strings
    print_header

    read -p "$MSG_ENTER_LOG_FILE " LOG_FILE
    check_file_exists

    while true; do
        show_menu
        echo ""
    done
}

main
