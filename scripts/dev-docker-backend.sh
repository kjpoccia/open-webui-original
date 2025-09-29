#!/bin/bash

# Docker Backend + Local Frontend Development Script
# Perfect for when you want backend in Docker but frontend running locally with hot reload

set -e

echo "🐳 Starting Docker Backend + Local Frontend Development"
echo "====================================================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ package.json not found. Please run this script from the project root."
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
if ! command_exists docker; then
    echo "❌ Docker is not installed"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"

# Check if .venv is activated (as requested by user)
if [ -z "$VIRTUAL_ENV" ]; then
    echo "🐍 Activating virtual environment..."
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
        echo "✅ Virtual environment activated"
    else
        echo "⚠️  No virtual environment found. Creating one..."
        python3 -m venv .venv
        source .venv/bin/activate
        echo "✅ Virtual environment created and activated"
    fi
else
    echo "✅ Virtual environment already active: $VIRTUAL_ENV"
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "❌ node_modules not found. Installing frontend dependencies..."
    npm install --legacy-peer-deps
fi

# Create/update .env to ensure proper CORS configuration
echo "⚙️ Configuring environment for Docker backend + local frontend..."

# Backup existing .env if it exists
if [ -f ".env" ]; then
    cp .env .env.backup
    echo "✅ Backed up existing .env to .env.backup"
fi

# Create or update .env with proper CORS settings
cat > .env << 'EOF'
# Docker Backend + Local Frontend Configuration
ENV=dev

# CORS Configuration - Critical for local frontend to connect to Docker backend
CORS_ALLOW_ORIGIN=http://localhost:5173;http://127.0.0.1:5173;http://0.0.0.0:5173

# Backend Configuration
PORT=8080
WEBUI_SECRET_KEY=your-secret-key-for-oauth-sessions

# Custom Branding
WEBUI_NAME=Expedient AI
WEBUI_BANNERS=[{"id":"expedient-welcome","type":"info","title":"Welcome to Expedient AI CTRL","content":"Your enterprise AI toolbox powered by Expedient AI CTRL","dismissible":true,"timestamp":1693276800}]

# Disable analytics
SCARF_NO_ANALYTICS=true
DO_NOT_TRACK=true
ANONYMIZED_TELEMETRY=false

# Model Configuration
WHISPER_MODEL=base
RAG_EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
TIKTOKEN_ENCODING_NAME=cl100k_base

# Optional: Ollama configuration
OLLAMA_BASE_URL=
EOF

echo "✅ Environment configured for Docker backend + local frontend"

# Ensure Docker network exists
echo "🌐 Ensuring Docker network exists..."
if ! docker network ls | grep -q "expnet"; then
    docker network create expnet
    echo "✅ Created expnet Docker network"
else
    echo "✅ expnet Docker network already exists"
fi

# Function to start Docker backend
start_docker_backend() {
    echo "🐳 Starting Docker backend..."
    
    # Stop any existing containers
    docker-compose -f docker-compose.dev.yaml down 2>/dev/null || true
    
    # Start the Docker backend
    docker-compose -f docker-compose.dev.yaml up --build -d
    
    echo "✅ Docker backend started"
    echo "⏳ Waiting for backend to be ready..."
    
    # Wait for backend to be healthy
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:8080/health >/dev/null 2>&1; then
            echo "✅ Backend is ready!"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            echo "❌ Backend failed to start within 30 seconds"
            echo "🔍 Checking Docker logs..."
            docker-compose -f docker-compose.dev.yaml logs --tail=20
            exit 1
        fi
        
        echo "⏳ Attempt $attempt/$max_attempts - waiting for backend..."
        sleep 1
        ((attempt++))
    done
}

# Function to start frontend
start_frontend() {
    echo "🎨 Starting local frontend with hot reload..."
    
    # Start frontend in background
    npm run dev:hybrid &
    FRONTEND_PID=$!
    
    echo "✅ Frontend started (PID: $FRONTEND_PID)"
    
    # Wait a moment for frontend to start
    sleep 3
    
    # Test if frontend is responding
    if curl -s http://localhost:5173 >/dev/null 2>&1; then
        echo "✅ Frontend is ready!"
    else
        echo "⚠️  Frontend might still be starting up..."
    fi
}

# Function to cleanup
cleanup() {
    echo ""
    echo "🛑 Shutting down development environment..."
    
    # Stop frontend
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
        echo "✅ Frontend stopped"
    fi
    
    # Stop Docker backend
    echo "🐳 Stopping Docker backend..."
    docker-compose -f docker-compose.dev.yaml down
    echo "✅ Docker backend stopped"
    
    echo "👋 Development environment stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

echo ""
echo "🚀 Starting development environment..."
echo ""

# Start Docker backend
start_docker_backend

# Start local frontend
start_frontend

echo ""
echo "🎉 Development environment is ready!"
echo ""
echo "📖 URLs:"
echo "   Frontend (Hot Reload): http://localhost:5173"
echo "   Backend API (Docker): http://localhost:8080"
echo "   Backend Health: http://localhost:8080/health"
echo ""
echo "🔥 Hot reload enabled for:"
echo "   - SvelteKit files: src/**/*.{svelte,ts,js,css}"
echo "   - Python files: backend/**/*.py (Docker auto-restart)"
echo ""
echo "🐳 Backend runs in Docker container"
echo "🎨 Frontend runs locally with Vite hot reload"
echo ""
echo "💡 Connection Details:"
echo "   - Frontend proxies API calls to http://localhost:8080"
echo "   - CORS configured for local frontend origin"
echo "   - All changes to src/ files will hot reload instantly"
echo ""
echo "🔍 Troubleshooting:"
echo "   - Check Docker logs: docker-compose -f docker-compose.dev.yaml logs"
echo "   - Check frontend logs in this terminal"
echo "   - Backend logs: docker-compose -f docker-compose.dev.yaml logs open-webui"
echo ""
echo "Press Ctrl+C to stop both frontend and backend"
echo ""

# Follow frontend logs
echo "📋 Following frontend logs (Ctrl+C to stop):"
echo ""
wait $FRONTEND_PID
