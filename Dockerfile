#FROM ghcr.io/veka-server/docker-ubuntu-cuda-pytorch:12.1.1
FROM pytorch/pytorch:2.8.0-cuda12.9-cudnn9-runtime

COPY entrypoint.sh /app/entrypoint.sh

# Configuration pour éviter les interactions durant l'installation des paquets
ENV DEBIAN_FRONTEND=noninteractive

# Installer uniquement les paquets nécessaires et nettoyer le cache APT
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git wget \
        libgl1-mesa-dev libglib2.0-0 libsm6 libxrender1 libxext6 \
        libgoogle-perftools4 libtcmalloc-minimal4 libcusparse11 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -g 1000 comfyui && \
    useradd -m -s /bin/bash -u 1000 -g 1000 --home /app comfyui && \
    ln -s /app /home/comfyui && \
    chown -R comfyui:comfyui /app && \
    chmod +x /app/entrypoint.sh

WORKDIR /app
    
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git comfyui

RUN pip install -r /app/comfyui/requirements.txt ; 
    
WORKDIR /app/comfyui/custom_nodes

RUN git clone https://github.com/city96/ComfyUI-GGUF ComfyUI-GGUF ; 
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-GGUF/requirements.txt ;

#RUN git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper ComfyUI-HunyuanVideoWrapper ; 
#RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-HunyuanVideoWrapper/requirements.txt ;

RUN git clone https://github.com/stavsap/comfyui-ollama.git comfyui-ollama ;
RUN pip install -r /app/comfyui/custom_nodes/comfyui-ollama/requirements.txt ;   

#RUN git clone https://github.com/welltop-cn/ComfyUI-TeaCache.git ComfyUI-TeaCache ; 

RUN git clone https://github.com/pollockjj/ComfyUI-MultiGPU.git ComfyUI-MultiGPU ; 

#RUN git clone https://github.com/fairy-root/ComfyUI-Show-Text.git ComfyUI-Show-Text ;

#RUN git clone https://github.com/larsupb/comfyui-joycaption.git comfyui-joycaption ;
#RUN pip install -r /app/comfyui/custom_nodes/comfyui-joycaption/requirements.txt ;   

RUN git clone https://github.com/veka-server/ComfyUI_SLK_joy_caption_two.git ComfyUI_SLK_joy_caption_two ;
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI_SLK_joy_caption_two/requirements.txt ;   

#RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git comfyui_controlnet_aux ;
#RUN pip install -r /app/comfyui/custom_nodes/comfyui_controlnet_aux/requirements.txt ;   

# RUN git clone https://github.com/neverbiasu/ComfyUI-BAGEL.git ComfyUI-BAGEL ;
# RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-BAGEL/requirements.txt ;   

#RUN git clone https://github.com/wildminder/ComfyUI-VibeVoice.git;
#RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-VibeVoice/requirements.txt ;   

RUN git clone https://github.com/Enemyx-net/VibeVoice-ComfyUI;
RUN pip install -r /app/comfyui/custom_nodes/VibeVoice-ComfyUI/requirements.txt ;   

RUN git clone https://github.com/veka-server/ComfyUI-OpenAI-Compat-LLM-Node;
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-nunchaku/requirements.txt ;   

# install de nunchaku
RUN git clone https://github.com/mit-han-lab/ComfyUI-nunchaku;
RUN pip install -r /app/comfyui/custom_nodes/ComfyUI-OpenAI-Compat-LLM-Node/requirements.txt ;   
RUN pip install https://github.com/nunchaku-tech/nunchaku/releases/download/v1.0.2/nunchaku-1.0.2+torch2.7-cp310-cp310-linux_x86_64.whl

WORKDIR /app/comfyui

# Copier le dossier workflow dans le conteneur
COPY workflow /app/workflow

# Copier la config comfyui
COPY comfyui/user/default/comfy.settings.json /app/comfyui/user/default/comfy.settings.json

# Ports exposés pour ComfyUI et VNC/NoVNC
EXPOSE 6080 8188

RUN mkdir -p /app/comfyui/models/Joy_caption_two
RUN mkdir -p /app/comfyui/models/LLM

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
