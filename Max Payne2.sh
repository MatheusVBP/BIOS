#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/maxpayne
cd $GAMEDIR

# ==============================================================================
# 🛡️ CORREÇÃO DE PERMISSÃO (SD CARD + ÁUDIO)
# ==============================================================================
export XDG_RUNTIME_DIR="$GAMEDIR/runtime"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 777 "$XDG_RUNTIME_DIR"

export SDL_AUDIODRIVER=alsa
export PULSE_SERVER=null
# ==============================================================================

# >>>> MODO DEBUG (DEDO-DURO) <<<<
# Tudo o que acontecer vai ser escrito no arquivo erro.txt
exec > "$GAMEDIR/erro.txt" 2>&1

echo "--- INICIO DO LOG ---"
echo "Data: $(date)"

# 1. Verifica se os arquivos existem
echo "Checando arquivos..."
if [ -f "./libMaxPayne.so" ]; then
    echo "libMaxPayne.so ENCONTRADO."
else
    echo "ERRO: libMaxPayne.so NAO ENCONTRADO."
fi

if [ -d "./gamedata" ]; then
    echo "Pasta gamedata ENCONTRADA."
else
    echo "ERRO: Pasta gamedata NAO ENCONTRADA."
fi

# 2. Garante permissão de execução
chmod +x ./maxpayne_arm64
chmod 777 ./libMaxPayne.so

# 3. Inicia o jogo direto (sem launcher, para testar)
echo "Iniciando binario..."

$GPTOKEYB "maxpayne_arm64" & 
pm_platform_helper "$GAMEDIR/maxpayne_arm64"

./maxpayne_arm64

echo "--- FIM DO LOG (Codigo de saida: $?) ---"
pm_finish