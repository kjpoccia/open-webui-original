#!/bin/bash

# Reset Backend Script
# Deletes all volumes and restarts the backend with a clean state

set -e

echo "🔄 Resetting Backend (Deleting Volumes & Restarting)"
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "docker-compose.dev.yaml" ]; then
    echo "❌ docker-compose.dev.yaml not found. Please run this script from the project root."
    exit 1
fi

echo "🛑 Stopping backend and removing volumes..."
docker compose -f docker-compose.dev.yaml down -v

echo "🧹 Cleaning up dangling images..."
docker image prune -f

echo "🔨 Rebuilding and starting backend..."
docker compose -f docker-compose.dev.yaml up --build -d

echo "⏳ Waiting for backend to be ready..."
max_attempts=30
attempt=1

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

echo ""
echo "🎉 Backend reset complete!"
echo ""
echo "📖 Backend status:"
echo "   URL: http://localhost:8080"
echo "   Health: http://localhost:8080/health"
echo ""
echo "🔍 To check logs: docker-compose -f docker-compose.dev.yaml logs -f"
