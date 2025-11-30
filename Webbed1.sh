#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

get_controls

GAMEDIR="/$directory/ports/webbed"
cd "$GAMEDIR"

# Log para debug
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# --- OPERAÇÃO ROBIN HOOD ---
# O script roda como ADMIN, então ele consegue copiar o que você não conseguiu.

# 1. Garante que a pasta libs existe
mkdir -p "$GAMEDIR/libs"

# 2. Copia o arquivo do sistema (usr/lib) para a sua pasta
# Usamos o comando 'cp' que funciona em qualquer cartão SD
if [ -f /usr/lib/libopenal.so.1 ]; then
    echo "Roubando libopenal do sistema..."
    cp /usr/lib/libopenal.so.1 "$GAMEDIR/libs/libopenal.so"
elif [ -f /usr/lib/libopenal.so ]; then
    cp /usr/lib/libopenal.so "$GAMEDIR/libs/libopenal.so"
fi

# 3. Dá permissão total para o arquivo copiado (pra garantir)
$ESUDO chmod 777 "$GAMEDIR/libs/libopenal.so"

# Aponta as bibliotecas
export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/lib:/usr/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Inicia o motor (Pizza Tower)
$GPTOKEYB "gmloader" &
./gmloader -c gmloader.json

$ESUDO kill -9 $(pidof gptokeyb)