#!/data/data/com.termux/files/usr/bin/bash
set -e

# Update and install dependencies
pkg update -y && pkg upgrade -y
pkg install -y git python rust tmux openssh

# Clone llama.cpp if not present
[ ! -d llama.cpp ] && git clone https://github.com/ggerganov/llama.cpp.git

# Build llama.cpp
cd llama.cpp
make -j$(nproc)

# Optional: download model
# curl -O https://huggingface.co/.../ggml-model.bin
