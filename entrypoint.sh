#!/usr/bin/env bash

# 1. Ajouter la règle iptables pour bloquer les connexions sortantes
# iptables -I OUTPUT -o eth0 -j DROP

# 2. Lancer ComfyUI
pushd /app/comfyui
source venv/bin/activate
python3 main.py "$@"
popd

# 2. Démarrer supervisord pour gérer Xvfb, x11vnc, noVNC, et Fluxbox
/usr/bin/supervisord -c /app/supervisor/supervisord.conf &

# 4. Garder le conteneur en cours d'exécution
 wait
