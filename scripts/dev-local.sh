#!/bin/bash

# Local Development Script (No Docker)
# Starts both frontend and backend locally with hot reload

set -e

echo "🚀 Starting Open WebUI Local Development Environment"
echo "===================================================="

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
echo "🔍 Checking prerequisites..."

if ! command_exists python3; then
    echo "❌ Python 3 is not installed"
    exit 1
fi

if ! command_exists node; then
    echo "❌ Node.js is not installed"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Setup virtual environment
echo "🐍 Setting up Python virtual environment..."
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    echo "✅ Created virtual environment"
fi

source .venv/bin/activate
echo "✅ Activated virtual environment"

# Install backend dependencies
echo "📦 Installing backend dependencies..."
if [ ! -f "backend/.venv" ]; then
    pip install -r backend/requirements.txt
    echo "✅ Backend dependencies installed"
else
    echo "✅ Backend dependencies already installed"
fi

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
if [ ! -d "node_modules" ]; then
    npm install --legacy-peer-deps
    echo "✅ Frontend dependencies installed"
else
    echo "✅ Frontend dependencies already installed"
fi

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo "⚙️ Creating .env file..."
    cat > .env << 'EOF'
# Open WebUI Local Development Configuration
ENV=dev
PORT=8080
CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
WEBUI_SECRET_KEY=your-secret-key-for-oauth-sessions
WEBUI_NAME=Expedient AI
SCARF_NO_ANALYTICS=true
DO_NOT_TRACK=true
ANONYMIZED_TELEMETRY=false
WHISPER_MODEL=base
RAG_EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
TIKTOKEN_ENCODING_NAME=cl100k_base
EOF
    echo "✅ Created .env file"
fi

# Function to start backend
start_backend() {
    echo "🖥️  Starting backend server..."
    cd backend
    export CORS_ORIGINS="http://localhost:5173,http://127.0.0.1:5173"
    export PORT=8080
    python -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8080 --reload --reload-dir . &
    BACKEND_PID=$!
    cd ..
    echo "✅ Backend started (PID: $BACKEND_PID)"
}

# Function to start frontend  
start_frontend() {
    echo "🎨 Starting frontend server..."
    sleep 2  # Give backend a moment to start
    npm run dev:hybrid &
    FRONTEND_PID=$!
    echo "✅ Frontend started (PID: $FRONTEND_PID)"
}

# Function to cleanup processes
cleanup() {
    echo ""
    echo "🛑 Shutting down development servers..."
    
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
        echo "✅ Backend stopped"
    fi
    
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
        echo "✅ Frontend stopped"
    fi
    
    echo "👋 Development environment stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

echo ""
echo "🚀 Starting development servers..."
echo ""

# Start backend
start_backend

# Start frontend
start_frontend

echo ""
echo "🎉 Development environment is ready!"
echo ""
echo "📖 URLs:"
echo "   Frontend: http://localhost:5173"
echo "   Backend API: http://localhost:8080"
echo "   Health Check: http://localhost:8080/health"
echo ""
echo "🔥 Hot reload enabled for:"
echo "   - SvelteKit files: src/**/*.{svelte,ts,js,css}"
echo "   - Python files: backend/**/*.py"
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

# Wait for processes
wait
