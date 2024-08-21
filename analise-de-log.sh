#!/bin/bash

# ------------------------------------------------------------
# Script de Análise de Logs
# Autor: Lucas Rangel
# Descrição: Este script automatiza a análise de arquivos de log.
# ------------------------------------------------------------

print_header() {
    echo ""
    echo "                       _ _              _       _              "
    echo "        /_\  _ _  __ _| (_)___ ___   __| |___  | |   ___  __ _ "
    echo "       / _ \| ' \/ _\` | | (_-</ -_) / _\` / -_) | |__/ _ \/ _\` |"
    echo "      /_/ \_\_||_\__,_|_|_/__/\___| \__,_\___| |____\___/\__, |"
    echo "                                                          |___/ "
    echo "                                                          by Lucas R."
    echo ""
}

#p/ verificar se o arquivo existe
check_file_exists() {
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "Erro: O arquivo '$LOG_FILE' não foi encontrado."
        exit 1
    fi
}

#p/ exibir as 5 primeiras linhas do arquivo de log
show_first_line() {
    echo "📝 Primeiras 5 linhas do arquivo '$LOG_FILE':"
    head -n 5 "$LOG_FILE"
    echo ""
}

#p/ listar IPs ordenados por quantidade de requisições
list_ips_by_requests() {
    echo "📊 Lista de IPs ordenados por quantidade de requisições:"
    awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr
    echo ""
}

#p/ exibir a data e hora da primeira e última requisição de um IP específico
show_request_times() {
    read -p "🔍 Insira o IP que deseja analisar: " TARGET_IP
    echo "⏰ Data e hora da PRIMEIRA requisição do IP '$TARGET_IP':"
    FIRST_REQUEST=$(grep "$TARGET_IP" "$LOG_FILE" | head -n 1)
    echo "$FIRST_REQUEST" | awk '{print $4" "$5}' | sed 's/\[//;s/\]//'
    echo ""
    echo "⏰ Data e hora da ÚLTIMA requisição do IP '$TARGET_IP':"
    LAST_REQUEST=$(grep "$TARGET_IP" "$LOG_FILE" | tail -n 1)
    echo "$LAST_REQUEST" | awk '{print $4" "$5}' | sed 's/\[//;s/\]//'
    echo ""
}

#p/ filtrar logs por código de status HTTP
filter_by_status() {
    read -p "Digite o código de status HTTP para filtrar (ex: 404): " STATUS_CODE
    echo "📄 Logs filtrados pelo código de status $STATUS_CODE:"
    grep " $STATUS_CODE " "$LOG_FILE"
    echo ""
}

#p/ listar User-Agents únicos
list_user_agents() {
    echo "📋 Lista de User-Agents únicos:"
    awk -F\" '{print $6}' "$LOG_FILE" | sort | uniq -c | sort -nr
    echo ""
}

#p/ exibir a primeira e última ocorrência de uma ferramenta usada por um IP específico
show_tool_usage() {
    read -p "🔍 Insira o IP que deseja analisar: " TARGET_IP
    read -p "🔧 Insira o nome da ferramenta que deseja procurar (ex: Nmap): " TOOL_NAME
    
    # Primeira ocorrência
    echo "🔍 Primeira ocorrência do uso da ferramenta '$TOOL_NAME' pelo IP '$TARGET_IP':"
    FIRST_OCCURRENCE=$(grep "$TARGET_IP" "$LOG_FILE" | grep "$TOOL_NAME" | head -n 1)
    echo "$FIRST_OCCURRENCE"
    if [[ -n "$FIRST_OCCURRENCE" ]]; then
        FIRST_DATE=$(echo "$FIRST_OCCURRENCE" | awk '{print $4" "$5}' | sed 's/\[//;s/\]//')
        echo "⏰ Data e hora da PRIMEIRA requisição: $FIRST_DATE"
    fi
    echo ""
    
    # Última ocorrência
    echo "🔍 Última ocorrência do uso da ferramenta '$TOOL_NAME' pelo IP '$TARGET_IP':"
    LAST_OCCURRENCE=$(grep "$TARGET_IP" "$LOG_FILE" | grep "$TOOL_NAME" | tail -n 1)
    echo "$LAST_OCCURRENCE"
    if [[ -n "$LAST_OCCURRENCE" ]]; then
        LAST_DATE=$(echo "$LAST_OCCURRENCE" | awk '{print $4" "$5}' | sed 's/\[//;s/\]//')
        echo "⏰ Data e hora da ÚLTIMA requisição: $LAST_DATE"
    fi
    echo ""
}

#p/ exibir o menu interativo
show_menu() {
    echo "Selecione uma opção:"
    echo "1) Ver primeiras 5 linhas do log"
    echo "2) Listar IPs por quantidade de requisições"
    echo "3) Ver data e hora da primeira e última requisição de um IP"
    echo "4) Filtrar logs por código de status HTTP"
    echo "5) Listar User-Agents únicos"
    echo "6) Ver ocorrências de uma ferramenta usada por um IP (ex:data e hora do primeiro e ultimo log c/ Nmap) "
    echo "7) Sair"
    read -p "Opção: " OPTION
    case $OPTION in
        1) show_first_line ;;
        2) list_ips_by_requests ;;
        3) show_request_times ;;
        4) filter_by_status ;;
        5) list_user_agents ;;
        6) show_tool_usage ;;
        7) exit 0 ;;
        *) echo "Opção inválida" ;;
    esac
}

# Função principal
main() {
    print_header

    # Solicita o caminho do arquivo de log ao usuário
    read -p "📁 Por favor, insira o caminho para o arquivo de log: " LOG_FILE
    check_file_exists

    while true; do
        show_menu
        echo ""
    done
}

# Executa a função principal
main
