# ComfyUI
The most powerful and modular stable diffusion GUI and backend. This repository is for NVIDIA GPUs only.

For detailed command-line flags, see [Official instructions](https://github.com/comfyanonymous/ComfyUI).

![Docker Pulls](https://img.shields.io/github/v/release/veka-server/docker-comfyui?label=GHCR)

![Build Docker](https://github.com/veka-server/docker-comfyui/actions/workflows/docker-release.yml/badge.svg)

```bash
$ docker pull ghcr.io/veka-server/docker-comfyui:latest
```

Liste des images :
https://github.com/users/veka-server/packages/container/package/docker-comfyui


## Usage

Build image:
```
docker build -t comfyui https://github.com/veka-server/docker-comfyui.git#main
```

Basic example:
```
docker run --gpus all --restart unless-stopped -p 6080:6080 --name comfyui -d comfyui
```

Use SSL/TLS:
```
docker run --gpus all --restart unless-stopped -p 6080:6080 \
  -v /my/key.pem:/app/key.pem \
  -v /my/cert.pem:/app/cert.pem \
  --name comfyui -d comfyui --tls-keyfile /app/key.pem --tls-certfile /app/cert.pem
```

### Where to Store Data

It is recommended to create a data directory on the host system (outside the container) and mount this to a directory visible from inside the container. This places the data files (including: extensions, models, outputs, etc.) in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. The downside is that the user needs to make sure that the directory exists, and that e.g. directory permissions and other security mechanisms on the host system are set up correctly. 

We will simply show the basic procedure here:
1. Create a data directory on a suitable volume on your host system, e.g. `/my/own/datadir`.
2. Start your `comfyui` container like this:
```
docker run \
--restart unless-stopped \
--gpus all \
-p 6080:6080  \
-p 8188:8188  \
-v /home/veka/models/checkpoints:/app/comfyui/models/checkpoints \
-v /home/veka/models/clip:/app/comfyui/models/clip \
-v /home/veka/models/clip_vision:/app/comfyui/models/clip_vision \
-v /home/veka/models/unet:/app/comfyui/models/unet \
-v /home/veka/models/vae:/app/comfyui/models/vae \
-v /home/veka/models/loras:/app/comfyui/models/loras \
-v /home/veka/models/upscale_models:/app/comfyui/models/upscale_models \
-v /home/veka/models/controlnet:/app/comfyui/models/controlnet \
-v /home/veka/models/output:/app/comfyui/output \
--name comfyui \
-d comfyui 
```
3. Troubleshooting with the following command if you encountered problems:
```
docker logs -f comfyui
```
