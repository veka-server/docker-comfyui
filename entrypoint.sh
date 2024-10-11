#!/usr/bin/env bash

# 1. Ajouter la règle iptables pour bloquer les connexions sortantes
# iptables -I OUTPUT -o eth0 -j DROP

# 2. Démarrer supervisord pour gérer Xvfb, x11vnc, noVNC, et Fluxbox
/usr/bin/supervisord -c /app/supervisor/supervisord.conf &

# 3. Lancer ComfyUI
pushd /app/comfyui
source venv/bin/activate
python3 main.py --listen 0.0.0.0 --port 8188 --preview-method auto
popd

# 4. Garder le conteneur en cours d'exécution
 wait
