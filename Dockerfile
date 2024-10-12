FROM nvidia/cuda:12.1.1-base-ubuntu22.04 

COPY entrypoint.sh /app/entrypoint.sh

# Configuration pour éviter les interactions durant l'installation des paquets
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata
    
RUN apt install -y python3 python3-pip python3-venv git wget libgl1-mesa-dev \
    libglib2.0-0 libsm6 libxrender1 libxext6 libgoogle-perftools4 libtcmalloc-minimal4 libcusparse11 iptables

RUN apt install -y fluxbox nano xterm supervisor x11vnc xvfb novnc websockify surf wmctrl
   
RUN groupadd -g 1000 comfyui && \
    useradd -m -s /bin/bash -u 1000 -g 1000 --home /app comfyui && \
    ln -s /app /home/comfyui && \
    chown -R comfyui:comfyui /app && \
    chmod +x /app/entrypoint.sh

USER comfyui
WORKDIR /app

RUN git clone https://github.com/comfyanonymous/ComfyUI.git comfyui

WORKDIR /app/comfyui/custom_nodes

RUN git clone https://github.com/city96/ComfyUI-GGUF ComfyUI-GGUF

WORKDIR /app/comfyui

RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install torch torchvision torchaudio timm simpleeval accelerate --extra-index-url https://download.pytorch.org/whl/cu121 && \
    pip install -r /app/comfyui/custom_nodes/ComfyUI-GGUF/requirements.txt && \
    pip install -r requirements.txt
  
# Configuration de supervisord pour gérer Xvfb, x11vnc, et noVNC
RUN mkdir -p /app/supervisor /app/.vnc /app/.config/openbox && \
    echo "[supervisord]\nnodaemon=true\n" > /app/supervisor/supervisord.conf && \
    echo "[program:xvfb]\ncommand=/usr/bin/Xvfb :1 -screen 0 1920x1080x24\n" >> /app/supervisor/supervisord.conf && \
    echo "[program:x11vnc]\ncommand=/usr/bin/x11vnc -display :1 -nopw -forever -shared -rfbport 5900\n" >> /app/supervisor/supervisord.conf && \
    echo "[program:novnc]\ncommand=/usr/bin/websockify --web=/usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5900\n" >> /app/supervisor/supervisord.conf && \
    echo "[program:fluxbox]\ncommand=/usr/bin/startfluxbox\nautostart=true\nautorestart=true\nenvironment=DISPLAY=:1\n" >> /app/supervisor/supervisord.conf

# Créer le fichier autostart pour surf dans Fluxbox
RUN mkdir -p /app/.fluxbox && \
    echo "surf http://localhost:8188 &" > /app/.fluxbox/startup && \
    echo "sleep 10 && wmctrl -r surf -b add,maximized_vert,maximized_horz &" >> /app/.fluxbox/startup && \
    echo "exec fluxbox" >> /app/.fluxbox/startup

# Créer le fichier autostart pour surf dans Fluxbox
RUN echo "[begin] (menu)" > /app/.fluxbox/menu && \
    echo "[exec] (comfyui) {surf http://localhost:8188}" >> /app/.fluxbox/menu && \
    echo "[end]" >> /app/.fluxbox/menu
    
# Ports exposés pour ComfyUI et VNC/NoVNC
EXPOSE 6080

VOLUME /app/comfyui/output
VOLUME /app/comfyui/input
VOLUME /app/comfyui/models/checkpoints
VOLUME /app/comfyui/models/clip
VOLUME /app/comfyui/models/clip_vision
VOLUME /app/comfyui/models/controlnet
VOLUME /app/comfyui/models/diffusers
VOLUME /app/comfyui/models/embeddings
VOLUME /app/comfyui/models/gligen
VOLUME /app/comfyui/models/hypernetworks
VOLUME /app/comfyui/models/loras
VOLUME /app/comfyui/models/photomaker
VOLUME /app/comfyui/models/style_models
VOLUME /app/comfyui/models/unet
VOLUME /app/comfyui/models/upscale_models
VOLUME /app/comfyui/models/vae
VOLUME /app/comfyui/models/vae_approx

ENTRYPOINT ["/app/entrypoint.sh"]
