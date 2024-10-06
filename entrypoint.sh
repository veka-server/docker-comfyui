#!/usr/bin/env bash

# Ajouter la règle iptables pour bloquer les connexions sortantes
iptables -I OUTPUT -o eth0 -j DROP

pushd /app/comfyui
source venv/bin/activate
python3 main.py "$@"
popd
