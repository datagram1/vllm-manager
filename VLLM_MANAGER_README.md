# vLLM Manager

A FastAPI-based middleware service for managing vLLM (virtual Large Language Model) servers. This service runs on port 7999 and provides a RESTful API to control vLLM lifecycle, manage models, and monitor system resources.

## Features

- Start/Stop vLLM server
- Download models from URLs or HuggingFace
- Switch between models dynamically
- Check system disk space
- Monitor vLLM process status
- List available models

## Installation

1. Install dependencies:
```bash
pip install -r vllm_manager_requirements.txt
```

2. (Optional) Set environment variables:
```bash
export VLLM_MODELS_DIR="$HOME/.cache/huggingface/hub"  # Default models directory
export VLLM_PORT="8000"  # Port where vLLM server will run
export VLLM_HOST="0.0.0.0"  # Host for vLLM server
```

## Usage

### Start the Manager

```bash
python vllm_manager.py
```

The manager will start on `http://0.0.0.0:7999`

### API Endpoints

#### 1. Check Status
```bash
curl http://localhost:7999/status
```

Response:
```json
{
  "vllm_running": true,
  "current_model": "meta-llama/Llama-2-7b-hf",
  "process_info": {
    "pid": 12345,
    "status": "running",
    "cpu_percent": 45.2,
    "memory_mb": 8192.5
  },
  "disk_space": {
    "total_gb": 500,
    "used_gb": 250,
    "free_gb": 250,
    "percent_used": 50.0
  }
}
```

#### 2. Start vLLM
```bash
curl -X POST http://localhost:7999/start \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "meta-llama/Llama-2-7b-hf",
    "gpu_memory_utilization": 0.9,
    "max_model_len": 4096,
    "tensor_parallel_size": 1
  }'
```

#### 3. Stop vLLM
```bash
curl -X POST http://localhost:7999/stop
```

#### 4. Switch Models
```bash
curl -X POST http://localhost:7999/switch-model \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "mistralai/Mistral-7B-v0.1",
    "gpu_memory_utilization": 0.85
  }'
```

#### 5. Download Model (HuggingFace)
```bash
curl -X POST http://localhost:7999/download-model \
  -H "Content-Type: application/json" \
  -d '{
    "model_url": "meta-llama/Llama-2-7b-hf"
  }'
```

#### 6. Download Model (Direct URL)
```bash
curl -X POST http://localhost:7999/download-model \
  -H "Content-Type: application/json" \
  -d '{
    "model_url": "https://example.com/model.bin",
    "model_name": "custom-model"
  }'
```

#### 7. Check Disk Space
```bash
curl http://localhost:7999/disk-space
```

Response:
```json
{
  "total_gb": 500,
  "used_gb": 250,
  "free_gb": 250,
  "percent_used": 50.0,
  "models_dir": "/home/user/.cache/huggingface/hub"
}
```

#### 8. List Available Models
```bash
curl http://localhost:7999/models
```

#### 9. Health Check
```bash
curl http://localhost:7999/health
```

## Python Client Example

```python
import requests

BASE_URL = "http://localhost:7999"

# Start vLLM
response = requests.post(f"{BASE_URL}/start", json={
    "model_name": "meta-llama/Llama-2-7b-hf",
    "gpu_memory_utilization": 0.9
})
print(response.json())

# Check status
status = requests.get(f"{BASE_URL}/status").json()
print(f"vLLM running: {status['vllm_running']}")
print(f"Current model: {status['current_model']}")

# Check disk space
space = requests.get(f"{BASE_URL}/disk-space").json()
print(f"Free space: {space['free_gb']} GB")

# Switch model
requests.post(f"{BASE_URL}/switch-model", json={
    "model_name": "mistralai/Mistral-7B-v0.1"
})

# Stop vLLM
requests.post(f"{BASE_URL}/stop")
```

## Advanced Configuration

### Custom vLLM Arguments

You can pass additional vLLM arguments when starting:

```bash
curl -X POST http://localhost:7999/start \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "meta-llama/Llama-2-7b-hf",
    "gpu_memory_utilization": 0.9,
    "additional_args": {
      "trust_remote_code": true,
      "dtype": "float16",
      "quantization": "awq"
    }
  }'
```

### Restart with New Settings

```bash
curl -X POST http://localhost:7999/restart \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "meta-llama/Llama-2-7b-hf",
    "gpu_memory_utilization": 0.8,
    "max_model_len": 2048
  }'
```

## API Documentation

Once running, access the interactive API documentation at:
- Swagger UI: `http://localhost:7999/docs`
- ReDoc: `http://localhost:7999/redoc`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VLLM_MODELS_DIR` | `~/.cache/huggingface/hub` | Directory where models are stored |
| `VLLM_PORT` | `8000` | Port where vLLM server runs |
| `VLLM_HOST` | `0.0.0.0` | Host address for vLLM server |

## Architecture

```
┌─────────────────────────────────────┐
│   Client (curl/Python/etc)          │
└──────────────┬──────────────────────┘
               │ HTTP REST API
               ▼
┌─────────────────────────────────────┐
│   vLLM Manager (Port 7999)          │
│   - FastAPI Application             │
│   - Process Management              │
│   - Model Downloads                 │
│   - System Monitoring               │
└──────────────┬──────────────────────┘
               │ Subprocess Control
               ▼
┌─────────────────────────────────────┐
│   vLLM Server (Port 8000)           │
│   - OpenAI-compatible API           │
│   - Model Inference                 │
└─────────────────────────────────────┘
```

## Troubleshooting

### vLLM won't start
- Check disk space: `curl http://localhost:7999/disk-space`
- Verify model exists: `curl http://localhost:7999/models`
- Check vLLM logs in the manager output

### Model download fails
- Ensure internet connectivity
- For HuggingFace models, you may need to login: `huggingface-cli login`
- Check available disk space

### Port already in use
- Change the manager port: `uvicorn vllm_manager:app --port 8999`
- Change vLLM port: `export VLLM_PORT=8001`

## Security Notes

- This service is intended for local/internal use
- Consider adding authentication for production deployments
- Be cautious with model download URLs from untrusted sources
- Monitor disk usage when downloading large models

## License

MIT License - feel free to modify and use as needed.
