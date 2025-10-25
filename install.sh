#!/bin/bash
set -e

echo "========================================="
echo "vLLM Manager Installation Script"
echo "========================================="
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not found."
    echo "Please install Python 3.8 or higher and try again."
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "Found Python version: $PYTHON_VERSION"

# Create virtual environment if it doesn't exist
if [ ! -d "vllm_env" ]; then
    echo ""
    echo "Creating virtual environment..."
    python3 -m venv vllm_env
    echo "✓ Virtual environment created"
else
    echo ""
    echo "Virtual environment already exists"
fi

# Activate virtual environment and install dependencies
echo ""
echo "Installing dependencies..."
source vllm_env/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r vllm_manager_requirements.txt

echo "✓ Dependencies installed"

# Ask if user wants to install as a systemd service
echo ""
read -p "Do you want to install vLLM Manager as a systemd service? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Creating systemd service..."

    # Create service file
    SERVICE_FILE="/tmp/vllm-manager.service"
    cat > "$SERVICE_FILE" << EOF
[Unit]
Description=vLLM Manager - FastAPI middleware for managing vLLM servers
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$SCRIPT_DIR
Environment="PATH=$SCRIPT_DIR/vllm_env/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=$SCRIPT_DIR/vllm_env/bin/python $SCRIPT_DIR/vllm_manager.py
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    echo "Service file created at: $SERVICE_FILE"
    echo ""
    echo "To install the service, run these commands:"
    echo ""
    echo "  sudo cp $SERVICE_FILE /etc/systemd/system/"
    echo "  sudo systemctl daemon-reload"
    echo "  sudo systemctl enable vllm-manager"
    echo "  sudo systemctl start vllm-manager"
    echo ""
    echo "To check status:"
    echo "  sudo systemctl status vllm-manager"
    echo ""
    echo "To view logs:"
    echo "  sudo journalctl -u vllm-manager -f"
    echo ""

    read -p "Do you want to install and start the service now? (requires sudo) (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo cp "$SERVICE_FILE" /etc/systemd/system/
        sudo systemctl daemon-reload
        sudo systemctl enable vllm-manager
        sudo systemctl start vllm-manager
        echo ""
        echo "✓ Service installed and started"
        echo ""
        sudo systemctl status vllm-manager --no-pager
    fi
fi

echo ""
echo "========================================="
echo "Installation Complete!"
echo "========================================="
echo ""

if systemctl is-active --quiet vllm-manager 2>/dev/null; then
    echo "vLLM Manager is running as a service"
    echo "Access the web interface at: http://localhost:7999"
else
    echo "To start vLLM Manager manually, run:"
    echo "  ./start_vllm_manager.sh"
    echo ""
    echo "Or run directly:"
    echo "  ./vllm_env/bin/python vllm_manager.py"
fi

echo ""
echo "Access the web interface at: http://localhost:7999"
echo "API documentation at: http://localhost:7999/docs"
echo ""
