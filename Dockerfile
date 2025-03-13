FROM nvidia/cuda:12.1.1-base-ubuntu22.04

COPY entrypoint.sh /app/entrypoint.sh

# Configuration pour éviter les interactions durant l'installation des paquets
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y python3 python3-pip python3-venv git wget libgl1-mesa-dev \
    libglib2.0-0 libsm6 libxrender1 libxext6 libgoogle-perftools4 libtcmalloc-minimal4 libcusparse11 ; \
    groupadd -g 1000 comfyui && \
    useradd -m -s /bin/bash -u 1000 -g 1000 --home /app comfyui && \
    ln -s /app /home/comfyui && \
    chown -R comfyui:comfyui /app && \
    chmod +x /app/entrypoint.sh

#USER comfyui
WORKDIR /app

RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install torch torchvision torchaudio timm simpleeval accelerate --extra-index-url https://download.pytorch.org/whl/cu121 ;
    
RUN git clone --depth 1 --branch v0.3.26 https://github.com/comfyanonymous/ComfyUI.git comfyui

RUN pip install -r /app/comfyui/requirements.txt ; 
    
WORKDIR /app/comfyui/custom_nodes

RUN git clone https://github.com/city96/ComfyUI-GGUF ComfyUI-GGUF ; 
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-GGUF/requirements.txt ;

RUN git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper ComfyUI-HunyuanVideoWrapper ; 
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-HunyuanVideoWrapper/requirements.txt ;

RUN git clone https://github.com/stavsap/comfyui-ollama.git comfyui-ollama ;
RUN pip install -r /app/comfyui/custom_nodes/comfyui-ollama/requirements.txt ;   

RUN git clone https://github.com/welltop-cn/ComfyUI-TeaCache.git ComfyUI-TeaCache ; 

RUN git clone https://github.com/pollockjj/ComfyUI-MultiGPU.git ComfyUI-MultiGPU ; 

RUN git clone https://github.com/fairy-root/ComfyUI-Show-Text.git ComfyUI-Show-Text ;

RUN git clone https://github.com/larsupb/comfyui-joycaption.git comfyui-joycaption ;
RUN pip install -r /app/comfyui/custom_nodes/comfyui-joycaption/requirements.txt ;   

RUN git clone https://github.com/EvilBT/ComfyUI_SLK_joy_caption_two.git ComfyUI_SLK_joy_caption_two ;
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI_SLK_joy_caption_two/requirements.txt ;   

WORKDIR /app/comfyui

# Copier le dossier workflow dans le conteneur
COPY workflow /app/workflow

# Copier la config comfyui
COPY comfyui/user/default/comfy.settings.json /app/comfyui/user/default/comfy.settings.json

#USER root
#RUN chown -R comfyui:comfyui /app

#USER comfyui

# Ports exposés pour ComfyUI et VNC/NoVNC
EXPOSE 6080 8188

RUN mkdir -p /app/comfyui/models/Joy_caption_two

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
