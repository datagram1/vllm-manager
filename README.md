# vLLM Manager

A FastAPI-based middleware service for managing vLLM (virtual Large Language Model) servers with a beautiful, mobile-friendly web interface.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.8%2B-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-0.104%2B-009688)

## Features

### Core Functionality
- 🚀 **Start/Stop vLLM Server** - Control vLLM lifecycle with one click
- 📥 **Download Models** - Download from HuggingFace or direct URLs
- 🔄 **Switch Models** - Dynamically switch between models without manual restart
- 📊 **System Monitoring** - Real-time CPU, memory, and disk usage
- 🗑️ **Model Management** - Delete unused models to free up space
- 📏 **Context Window Display** - View model context window sizes
- 💾 **Disk Space Monitoring** - Check available storage before downloads

### User Interface
- 📱 **Mobile-Responsive** - Works perfectly on phones, tablets, and desktops
- 🎨 **Modern Design** - Beautiful gradient UI with smooth animations
- ⚡ **Real-time Updates** - Auto-refresh status every 5 seconds
- 📈 **Progress Indicators** - Visual feedback for long-running operations
- 🌐 **Single-Page App** - Everything accessible from one screen

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/datagram1/vllm-manager.git
cd vllm-manager

# Run the installation script
chmod +x install.sh
./install.sh
```

The installation script will:
1. Create a Python virtual environment
2. Install all required dependencies
3. Optionally set up vLLM Manager as a systemd service

### Manual Installation

```bash
# Create virtual environment
python3 -m venv vllm_env
source vllm_env/bin/activate

# Install dependencies
pip install -r vllm_manager_requirements.txt
```

### Starting the Manager

**Option 1: Using the startup script**
```bash
./start_vllm_manager.sh
```

**Option 2: Direct execution**
```bash
./vllm_env/bin/python vllm_manager.py
```

**Option 3: As a systemd service**
```bash
sudo systemctl start vllm-manager
sudo systemctl status vllm-manager
```

Access the web interface at: **http://localhost:7999**

## Usage

### Web Interface

The web interface provides a complete control panel for managing your vLLM instance:

1. **Status Dashboard** - View real-time status of both the Manager and vLLM inference service
2. **Control Panel** - Start, stop, and refresh with simple buttons
3. **Model Switcher** - Select and switch between downloaded models
4. **Model Download** - Enter HuggingFace model ID or direct URL to download
5. **System Metrics** - Monitor CPU usage, memory, disk space, and context windows

### API Endpoints

The manager provides a RESTful API for programmatic access:

#### Status
```bash
curl http://localhost:7999/status
```

#### Start vLLM
```bash
curl -X POST http://localhost:7999/start \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "meta-llama/Llama-2-7b-hf",
    "gpu_memory_utilization": 0.9,
    "max_model_len": 4096
  }'
```

#### Stop vLLM
```bash
curl -X POST http://localhost:7999/stop
```

#### Switch Models
```bash
curl -X POST http://localhost:7999/switch-model \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "mistralai/Mistral-7B-v0.1",
    "gpu_memory_utilization": 0.85
  }'
```

#### Download Model
```bash
curl -X POST http://localhost:7999/download-model \
  -H "Content-Type: application/json" \
  -d '{
    "model_url": "meta-llama/Llama-2-7b-hf"
  }'
```

#### List Models
```bash
curl http://localhost:7999/models
```

#### Delete Model
```bash
curl -X DELETE http://localhost:7999/delete-model \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "models--meta-llama--Llama-2-7b-hf"
  }'
```

#### Check Disk Space
```bash
curl http://localhost:7999/disk-space
```

## Python Client Example

```python
import requests

BASE_URL = "http://localhost:7999"

# Check status
status = requests.get(f"{BASE_URL}/status").json()
print(f"vLLM running: {status['vllm_running']}")
print(f"Current model: {status['current_model']}")
print(f"Context window: {status['context_window']}")

# Download a model
response = requests.post(
    f"{BASE_URL}/download-model",
    json={"model_url": "meta-llama/Llama-2-7b-hf"}
)
print(response.json())

# Start vLLM with the model
response = requests.post(
    f"{BASE_URL}/start",
    json={
        "model_name": "meta-llama/Llama-2-7b-hf",
        "gpu_memory_utilization": 0.9,
        "max_model_len": 4096
    }
)
print(response.json())

# Check disk space
space = requests.get(f"{BASE_URL}/disk-space").json()
print(f"Free space: {space['free_gb']} GB")

# List all models
models = requests.get(f"{BASE_URL}/models").json()
print(f"Total models: {models['count']}")
for model in models['models']:
    print(f"  - {model['name']} ({model['size_gb']} GB)")

# Stop vLLM when done
requests.post(f"{BASE_URL}/stop")
```

## Configuration

You can configure vLLM Manager using environment variables:

```bash
# Models directory (default: ~/.cache/huggingface/hub)
export VLLM_MODELS_DIR="/path/to/models"

# vLLM server port (default: 8000)
export VLLM_PORT="8000"

# vLLM server host (default: 0.0.0.0)
export VLLM_HOST="0.0.0.0"
```

## Architecture

```
┌─────────────────────────────────────┐
│   Client (Browser/API/Python)       │
└──────────────┬──────────────────────┘
               │ HTTP/REST
               ▼
┌─────────────────────────────────────┐
│   vLLM Manager (Port 7999)          │
│   ┌─────────────────────────────┐   │
│   │ FastAPI Web Server          │   │
│   ├─────────────────────────────┤   │
│   │ Process Management          │   │
│   ├─────────────────────────────┤   │
│   │ Model Downloads (HF Hub)    │   │
│   ├─────────────────────────────┤   │
│   │ System Monitoring (psutil)  │   │
│   └─────────────────────────────┘   │
└──────────────┬──────────────────────┘
               │ Subprocess Control
               ▼
┌─────────────────────────────────────┐
│   vLLM Server (Port 8000)           │
│   - OpenAI-compatible API           │
│   - Model Inference                 │
│   - GPU Management                  │
└─────────────────────────────────────┘
```

## API Documentation

Once running, access the interactive API documentation:
- **Swagger UI**: http://localhost:7999/docs
- **ReDoc**: http://localhost:7999/redoc

## System Requirements

- **Python**: 3.8 or higher
- **RAM**: Minimum 8GB (16GB+ recommended for larger models)
- **GPU**: NVIDIA GPU with CUDA support (for vLLM inference)
- **Disk**: Varies by model size (7B models ~14GB, 13B models ~26GB, etc.)

## Troubleshooting

### vLLM won't start
- Check if you have sufficient disk space: `curl http://localhost:7999/disk-space`
- Verify the model exists: `curl http://localhost:7999/models`
- Check the vLLM Manager logs for error messages
- Ensure your GPU has enough memory for the selected model

### Model download fails
- Ensure you have internet connectivity
- For HuggingFace models, you may need to authenticate:
  ```bash
  pip install huggingface-cli
  huggingface-cli login
  ```
- Check available disk space before downloading large models

### Port already in use
- Change the manager port when starting:
  ```bash
  # In the Python file, or set environment variable
  export MANAGER_PORT=8999
  ```
- Change vLLM port:
  ```bash
  export VLLM_PORT=8001
  ```

### Service won't start
```bash
# Check service status
sudo systemctl status vllm-manager

# View logs
sudo journalctl -u vllm-manager -f

# Restart service
sudo systemctl restart vllm-manager
```

## Security Notes

⚠️ **Important Security Considerations:**

- This service is intended for **local/internal use**
- No authentication is enabled by default
- For production deployments, consider:
  - Adding authentication (API keys, OAuth, etc.)
  - Using a reverse proxy (nginx, Caddy)
  - Enabling HTTPS/TLS
  - Implementing rate limiting
  - Restricting network access with firewall rules
- Be cautious with model download URLs from untrusted sources
- Monitor disk usage when downloading large models

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to modify and use as needed.

## Acknowledgments

- Built with [FastAPI](https://fastapi.tiangolo.com/)
- Powered by [vLLM](https://github.com/vllm-project/vllm)
- Uses [psutil](https://github.com/giampaolo/psutil) for system monitoring
- Models from [HuggingFace](https://huggingface.co/)

## Support

If you encounter any issues or have questions:
- Open an issue on [GitHub](https://github.com/datagram1/vllm-manager/issues)
- Check the [API Documentation](http://localhost:7999/docs) when the server is running

---

**Made with ❤️ for the AI/ML community**
