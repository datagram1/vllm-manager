#!/bin/bash

# Installation script for vLLM
# Choose one of the methods below:

echo "vLLM Installation Options:"
echo "=========================="
echo ""
echo "Option 1: Create new conda environment (recommended)"
echo "  conda create -n vllm_env python=3.10 -y"
echo "  conda activate vllm_env"
echo "  pip install vllm"
echo ""
echo "Option 2: Install in current environment (bypass pip restrictions)"
echo "  # Edit ~/.config/pip/pip.conf and remove require-virtualenv=true"
echo "  # OR use: pip install --user vllm"
echo ""
echo "Option 3: Use existing vLLM installation"
echo "  # Modify vllm_manager.py to use specific Python path"
echo "  # Change line: 'python', '-m', 'vllm.entrypoints.openai.api_server'"
echo "  # To: '/path/to/your/vllm/python', '-m', 'vllm.entrypoints.openai.api_server'"
echo ""

# Uncomment the method you want to use:

# Method 1: New conda environment
# conda create -n vllm_env python=3.10 -y
# source $(conda info --base)/etc/profile.d/conda.sh
# conda activate vllm_env
# pip install vllm fastapi uvicorn[standard] pydantic aiohttp psutil huggingface-hub

# Method 2: Bypass virtualenv requirement (be cautious)
# PIP_REQUIRE_VIRTUALENV=false pip install vllm
