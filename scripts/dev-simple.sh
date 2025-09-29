#!/bin/bash

# Simple Development Script for Hot Reload
# Works with existing node_modules and focuses on starting dev servers

set -e

echo "🚀 Starting Open WebUI Development with Hot Reload"
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ package.json not found. Please run this script from the project root."
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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
        
        # Install backend dependencies
        echo "📦 Installing backend dependencies..."
        pip install -r backend/requirements.txt
    fi
else
    echo "✅ Virtual environment already active: $VIRTUAL_ENV"
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "❌ node_modules not found. Please run 'npm install' first."
    echo "💡 If you have dependency conflicts, try: npm install --legacy-peer-deps"
    exit 1
fi

# Function to start backend
start_backend() {
    echo "🖥️  Starting backend server with hot reload..."
    cd backend
    export CORS_ORIGINS="http://localhost:5173,http://127.0.0.1:5173"
    export PORT=8080
    export ENV=dev
    python -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8080 --reload --reload-dir . &
    BACKEND_PID=$!
    cd ..
    echo "✅ Backend started (PID: $BACKEND_PID)"
}

# Function to start frontend  
start_frontend() {
    echo "🎨 Starting frontend server with hot reload..."
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
echo "💡 Edit any .svelte file in src/ to see hot reload in action!"
echo "Press Ctrl+C to stop all servers"
echo ""

# Wait for processes
wait
