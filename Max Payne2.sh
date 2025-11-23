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

# >>>> LÓGICA DE EXTRAÇÃO (CORRIGIDA: SEM SUDO) <<<<
if [ ! -d "$GAMEDIR/gamedata" ]; then
    if ls "$GAMEDIR"/*.obb 1> /dev/null 2>&1; then
        pm_message "Extraindo arquivos... Aguarde!"
        
        # Cria a pasta
        mkdir -p "$GAMEDIR/gamedata"
        
        # Cria um log para vermos se der erro
        echo "Iniciando extração..." > "$GAMEDIR/log_install.txt"
        
        # Tenta extrair OBB e APK sem usar SUDO (pois é no SD Card)
        # Redireciona erros para o arquivo de log
        unzip -o "$GAMEDIR"/*.obb -d "$GAMEDIR/gamedata" >> "$GAMEDIR/log_install.txt" 2>&1
        unzip -o "$GAMEDIR"/*.apk -d "$GAMEDIR/gamedata" >> "$GAMEDIR/log_install.txt" 2>&1
        
        # Move arquivos se estiverem dentro de subpastas comuns (assets)
        if [ -d "$GAMEDIR/gamedata/assets" ]; then
            mv "$GAMEDIR/gamedata/assets/"* "$GAMEDIR/gamedata/" >> "$GAMEDIR/log_install.txt" 2>&1
        fi
        
        pm_message "Extração concluída!"
    else
        pm_message "ERRO: APK/OBB não encontrados!"
        sleep 5
        exit 1
    fi
fi

# Configurações do Joystick para o Launcher
$GPTOKEYB "love" &
launcherGPTOKEYBPid=$!

# >>>> FUNÇÃO PARA INICIAR O JOGO <<<<
function start_maxpayne {
  # Mata o controle do launcher
  $ESUDO kill -9 $launcherGPTOKEYBPid
  
  # Inicia o controle do Jogo
  $GPTOKEYB "maxpayne_arm64" & 
  pm_platform_helper "$GAMEDIR/maxpayne_arm64"

  # Limpa a tela
  printf "\033c"
  
  # Roda o jogo (Silencioso)
  ./maxpayne_arm64 > /dev/null 2>&1
}

# >>>> INICIA O LAUNCHER DO LOVE <<<<
source $controlfolder/runtimes/"love_11.5"/love.txt
$LOVE_RUN "$GAMEDIR/launcher.love" && start_maxpayne

pm_finish