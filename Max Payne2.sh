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
# 🛡️ A CORREÇÃO DE OURO (SD CARD + ÁUDIO)
# Aplicamos isso AQUI para valer tanto para o Launcher quanto para o Jogo
# ==============================================================================
export XDG_RUNTIME_DIR="$GAMEDIR/runtime"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 777 "$XDG_RUNTIME_DIR"

export SDL_AUDIODRIVER=alsa
export PULSE_SERVER=null
# ==============================================================================

# >>>> Lógica de Instalação (Recuperada do original) <<<<
# Se não tiver gamedata, ele vai tentar extrair do seu APK/OBB dublado
if [ ! -d "$GAMEDIR/gamedata" ]; then
    if ls "$GAMEDIR"/*.obb 1> /dev/null 2>&1; then
        pm_message "Instalando dados (pode demorar)..."
        # Se houver um script de patch, use-o, senão apenas extraia
        if [ -f "$GAMEDIR/tools/patchscript" ]; then
             source "$GAMEDIR/tools/patchscript"
        else
             # Fallback simples se não houver script de patch
             $ESUDO unzip -o "$GAMEDIR"/*.obb -d "$GAMEDIR/gamedata"
             $ESUDO unzip -o "$GAMEDIR"/*.apk -d "$GAMEDIR/gamedata"
        fi
        pm_message "Instalação concluída!"
    else
        pm_message "ERRO: APK/OBB não encontrados!"
        sleep 5
        exit 1
    fi
fi

# Configurações do Joystick
$GPTOKEYB "love" &
launcherGPTOKEYBPid=$!

# >>>> FUNÇÃO PARA INICIAR O JOGO REAL <<<<
function start_maxpayne {
  # Mata o controle do launcher anterior
  $ESUDO kill -9 $launcherGPTOKEYBPid
  
  # Inicia o controle do Max Payne
  $GPTOKEYB "maxpayne_arm64" & 
  pm_platform_helper "$GAMEDIR/maxpayne_arm64"

  # Limpa a tela
  printf "\033c"
  
  # Roda o jogo (com o fix já aplicado lá no topo)
  ./maxpayne_arm64 > /dev/null 2>&1
}

# >>>> INICIA O LAUNCHER DO LOVE <<<<
# O Launcher vai abrir. Se você clicar em "Start Game" nele, 
# ele fecha com sucesso e roda o comando 'start_maxpayne'
source $controlfolder/runtimes/"love_11.5"/love.txt

# Executa o Launcher
$LOVE_RUN "$GAMEDIR/launcher.love" && start_maxpayne

pm_finish