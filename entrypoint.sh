#!/usr/bin/env bash

# 1. Vérifier si la variable d'environnement VNC_PASSWORD est définie
if [ -z "$VNC_PASSWORD" ]; then
    echo "Aucun mot de passe VNC défini. Utilisation d'un mot de passe par défaut."
    VNC_PASSWORD="default_password"  # Mot de passe par défaut
fi

# Create .vnc directory if it doesn't exist
mkdir -p /app/.vnc

# Create a password file for x11vnc
x11vnc -storepasswd $VNC_PASSWORD /app/.vnc/passwd

# Set permissions to restrict access
chmod 600 /app/.vnc/passwd

# 3. Démarrer supervisord pour gérer Xvfb, x11vnc, noVNC, et Fluxbox
/usr/bin/supervisord -c /app/supervisor/supervisord.conf &

# 4. Lancer ComfyUI
pushd /app/comfyui
source venv/bin/activate
python3 main.py --listen 0.0.0.0 --port 8188 --lowvram --disable-smart-memory --reserve-vram 3
popd

# 5. Garder le conteneur en cours d'exécution
wait
