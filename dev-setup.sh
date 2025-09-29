#!/bin/bash

# Open WebUI Development Environment Setup Script
# This script sets up hot reload for both frontend and backend

set -e

echo "🚀 Setting up Open WebUI Development Environment"
echo "==============================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if Docker is running
check_docker() {
    if ! command_exists docker; then
        echo "❌ Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker first."
        exit 1
    fi
    
    echo "✅ Docker is running"
}

# Function to check if Node.js and npm are available
check_node() {
    if ! command_exists node; then
        echo "❌ Node.js is not installed. Please install Node.js first."
        exit 1
    fi
    
    if ! command_exists npm; then
        echo "❌ npm is not installed. Please install npm first."
        exit 1
    fi
    
    echo "✅ Node.js and npm are available"
}

# Function to activate virtual environment
setup_venv() {
    echo "🐍 Setting up Python virtual environment..."
    
    if [ ! -d ".venv" ]; then
        echo "📦 Creating virtual environment..."
        python3 -m venv .venv
    fi
    
    echo "🔄 Activating virtual environment..."
    source .venv/bin/activate
    
    echo "✅ Virtual environment activated"
}

# Function to install dependencies
install_dependencies() {
    echo "📦 Installing frontend dependencies..."
    npm install --legacy-peer-deps
    
    echo "📦 Installing backend dependencies..."
    source .venv/bin/activate
    pip install -r backend/requirements.txt
    
    echo "✅ Dependencies installed"
}

# Function to create development network
create_network() {
    echo "🌐 Creating Docker network..."
    
    if ! docker network ls | grep -q "expnet"; then
        docker network create expnet
        echo "✅ Created expnet Docker network"
    else
        echo "✅ expnet Docker network already exists"
    fi
}

# Function to create environment file
create_env_file() {
    if [ ! -f ".env" ]; then
        echo "⚙️ Creating .env file..."
        cat > .env << EOF
# Open WebUI Development Environment Configuration

# Backend Configuration
OLLAMA_BASE_URL=
WEBUI_SECRET_KEY=your-secret-key-for-oauth-sessions

# Custom Branding
WEBUI_NAME=Expedient AI
WEBUI_BANNERS=[{"id":"expedient-welcome","type":"info","title":"Welcome to Expedient AI CTRL","content":"Your enterprise AI toolbox powered by Expedient AI CTRL","dismissible":true,"timestamp":1693276800}]

# Development Configuration
ENV=dev
CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
PORT=8080

# Disable analytics
SCARF_NO_ANALYTICS=true
DO_NOT_TRACK=true
ANONYMIZED_TELEMETRY=false

# Model Configuration
WHISPER_MODEL=base
RAG_EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
TIKTOKEN_ENCODING_NAME=cl100k_base
EOF
        echo "✅ Created .env file"
    else
        echo "✅ .env file already exists"
    fi
}

# Main setup function
main() {
    echo "🔍 Checking prerequisites..."
    check_docker
    check_node
    
    echo ""
    echo "⚙️ Setting up development environment..."
    setup_venv
    create_network
    create_env_file
    install_dependencies
    
    echo ""
    echo "🎉 Development environment setup complete!"
    echo ""
    echo "📖 Next steps:"
    echo "1. Run 'npm run dev:full' to start both frontend and backend with hot reload"
    echo "2. Or run 'npm run dev:backend' and 'npm run dev' in separate terminals"
    echo "3. Frontend will be available at: http://localhost:5173"
    echo "4. Backend API will be available at: http://localhost:8080"
    echo ""
    echo "🔥 Hot reload is enabled for:"
    echo "   - SvelteKit frontend files (src/**/*)"
    echo "   - Python backend files (backend/**/*.py)"
    echo ""
}

# Run main function
main
