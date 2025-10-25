#!/bin/bash
# Start the vLLM Manager with Web Interface
# Access at http://localhost:7999

cd /home/richardbrown
echo "Starting vLLM Manager..."
echo "Web Interface: http://localhost:7999"
echo "API Docs: http://localhost:7999/docs"
echo ""
./vllm_env/bin/python vllm_manager.py
