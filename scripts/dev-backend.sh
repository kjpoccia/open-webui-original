#!/bin/bash

# Development backend startup script with file watching
# This script monitors Python files and restarts the backend when changes are detected

set -e

echo "🚀 Starting Open WebUI Backend in Development Mode"
echo "📁 Watching for changes in: /app/project_root/backend"
echo "🔄 Backend will auto-restart when Python files change"
echo ""

# Function to start the backend
start_backend() {
    echo "🔄 Starting backend server..."
    
    # Set the working directory to the project root to preserve git repository
    cd /app/project_root
    
    # Set PYTHONPATH to include the backend directory
    export PYTHONPATH="/app/project_root/backend:$PYTHONPATH"
    
    # Start the backend with uvicorn
    python -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8080 --reload --reload-dir /app/project_root/backend
}

# Function to handle cleanup
cleanup() {
    echo ""
    echo "🛑 Shutting down development server..."
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Start the backend in the background
start_backend &

# Wait for the background process
wait
