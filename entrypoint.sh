#!/usr/bin/env bash

# Lancer ComfyUI
pushd /app/comfyui
# source venv/bin/activate
python3 main.py --listen 0.0.0.0 --port 8188 --lowvram --disable-smart-memory
popd

# 5. Garder le conteneur en cours d'exécution
wait
