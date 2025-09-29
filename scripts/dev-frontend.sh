#!/bin/bash

# Frontend Development Script
# Starts the SvelteKit development server with hot reload

set -e

echo "🎨 Starting SvelteKit Frontend Development Server"
echo "================================================"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ package.json not found. Please run this script from the project root."
    exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install --legacy-peer-deps
fi

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

echo ""
echo "🔥 Starting development server with hot reload..."
echo "📁 Watching: src/**/*.{svelte,ts,js,css}"
echo "🌐 Frontend URL: http://localhost:5173"
echo "🔌 API Proxy: http://localhost:5173/api -> http://localhost:8080/api"
echo ""
echo "💡 Backend should be running on port 8080 for API calls to work"
echo "   Run 'npm run dev:backend' in another terminal if needed"
echo ""

# Start the development server
npm run dev:hybrid
