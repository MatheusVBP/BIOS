# --- BLOCO DE INICIALIZAÇÃO ---
APP_DIR=$(dirname "$0")
cd "$APP_DIR"
# --- FIM DO BLOCO DE INICIALIZAÇÃO ---

# Ativa o modo de depuração para gravar tudo no log.txt
exec > "log.txt" 2>&1

echo "--- Log de Teste do 'Dialog' ---"
echo "Data e Hora: $(date)"
echo ""

# Define o caminho para a ferramenta 'dialog'
FERRAMENTA_DIALOG="/mnt/SDCARD/System/bin/dialog"
echo "Tentando executar: $FERRAMENTA_DIALOG"
echo ""

# Adiciona caminhos de bibliotecas comuns ao sistema, uma boa prática.
export LD_LIBRARY_PATH=/mnt/SDCARD/System/lib/:/usr/lib/:$LD_LIBRARY_PATH
echo "LD_LIBRARY_PATH definido para: $LD_LIBRARY_PATH"
echo ""

# Tenta executar um comando 'dialog' simples
$FERRAMENTA_DIALOG --title "Teste de Sucesso" --msgbox "Se você está a ver isto, o comando DIALOG funciona!" 10 50
CODIGO_SAIDA=$?

echo ""
echo "Comando 'dialog' executado com código de saída: $CODIGO_SAIDA"
echo "Se o código for 127, significa 'comando não encontrado' ou erro de biblioteca."
echo "--- Fim do Log ---"