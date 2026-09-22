FROM nvidia/cuda:13.0.2-cudnn-runtime-ubuntu24.04

COPY entrypoint.sh /app/entrypoint.sh

# Configuration pour éviter les interactions durant l'installation des paquets
ENV DEBIAN_FRONTEND=noninteractive

# Python 3.12 (natif Ubuntu 24.04) + toolchain de build pour les paquets qui compilent (triton, etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git wget build-essential \
        python3.12 python3.12-venv python3.12-dev python3-pip \
        libgl1-mesa-dev libglib2.0-0 libsm6 libxrender1 libxext6 \
        libgoogle-perftools4 libtcmalloc-minimal4 && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /app && \
    if getent passwd 1000 >/dev/null; then \
        OLDUSER=$(getent passwd 1000 | cut -d: -f1); \
        OLDGROUP=$(getent group 1000 | cut -d: -f1); \
        usermod -l comfyui -d /app "$OLDUSER"; \
        groupmod -n comfyui "$OLDGROUP"; \
        usermod -s /bin/bash comfyui; \
    else \
        groupadd -g 1000 comfyui && \
        useradd -m -s /bin/bash -u 1000 -g 1000 --home /app comfyui; \
    fi && \
    ln -sf /app /home/comfyui && \
    chown -R comfyui:comfyui /app && \
    chmod +x /app/entrypoint.sh

# Ubuntu 24.04 a un python "externally managed" (PEP 668) : on isole dans un venv
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# install comfyui stock
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git comfyui

# PyTorch cu130 - remplace le pip install -r requirements.txt classique pour torch,
# car requirements.txt de ComfyUI ne fixe pas de variante CUDA précise
RUN pip install --upgrade pip && \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130 && \
    pip install -r /app/comfyui/requirements.txt

WORKDIR /app/comfyui/custom_nodes

# Add support for GGUF
RUN git clone https://github.com/molbal/ComfyUI-GGUF ComfyUI-GGUF ;
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-GGUF/requirements.txt ;

# add support multi GPU
RUN git clone https://github.com/pollockjj/ComfyUI-MultiGPU.git ComfyUI-MultiGPU ;

# node for llm api
RUN git clone https://github.com/veka-server/ComfyUI-OpenAI-Compat-LLM-Node;
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-OpenAI-Compat-LLM-Node/requirements.txt ;

# install des noeud pour qwen3-tts
RUN git clone https://github.com/starsFriday/ComfyUI-Qwen3-TTS;
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-Qwen3-TTS/requirements.txt ;

RUN git clone https://github.com/kijai/ComfyUI-KJNodes;
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-KJNodes/requirements.txt ;

# noeud pour bypass filtre censure Krea 2
RUN git clone https://github.com/capitan01R/ComfyUI-Krea2T-Enhancer

# install des noeud pour ltx director
RUN git clone https://github.com/WhatDreamscost/WhatDreamsCost-ComfyUI;

WORKDIR /app/comfyui

# Copier le dossier workflow dans le conteneur
COPY workflow /app/workflow

# Copier la config comfyui
COPY comfyui/user/default/comfy.settings.json /app/comfyui/user/default/comfy.settings.json

# Ports exposés pour ComfyUI et VNC/NoVNC
EXPOSE 6080 8188

VOLUME /app/comfyui/output
VOLUME /app/comfyui/input
VOLUME /app/comfyui/models/checkpoints
VOLUME /app/comfyui/models/clip
VOLUME /app/comfyui/models/clip_vision
VOLUME /app/comfyui/models/controlnet
VOLUME /app/comfyui/models/diffusers
VOLUME /app/comfyui/models/diffusion_models
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
