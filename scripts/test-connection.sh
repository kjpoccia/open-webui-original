#!/bin/bash

# Test Connection Script
# Helps diagnose frontend-backend connection issues

echo "🔍 Testing Frontend-Backend Connection"
echo "===================================="

# Test Docker backend
echo "🐳 Testing Docker backend..."
if curl -s http://localhost:8080/health >/dev/null 2>&1; then
    echo "✅ Docker backend is responding on http://localhost:8080"
    echo "📋 Health check response:"
    curl -s http://localhost:8080/health | jq . 2>/dev/null || curl -s http://localhost:8080/health
else
    echo "❌ Docker backend is not responding on http://localhost:8080"
    echo "🔍 Checking if Docker container is running..."
    docker ps | grep open-webui || echo "❌ No open-webui container found"
fi

echo ""

# Test frontend
echo "🎨 Testing frontend..."
if curl -s http://localhost:5173 >/dev/null 2>&1; then
    echo "✅ Frontend is responding on http://localhost:5173"
else
    echo "❌ Frontend is not responding on http://localhost:5173"
    echo "💡 Make sure to run 'npm run dev:hybrid' or similar"
fi

echo ""

# Test API proxy
echo "🔌 Testing API proxy (frontend → backend)..."
if curl -s http://localhost:5173/health >/dev/null 2>&1; then
    echo "✅ API proxy is working (frontend can reach backend)"
    echo "📋 Proxied health check response:"
    curl -s http://localhost:5173/health | jq . 2>/dev/null || curl -s http://localhost:5173/health
else
    echo "❌ API proxy is not working"
    echo "🔍 This usually indicates:"
    echo "   - Frontend is not running"
    echo "   - Backend is not running" 
    echo "   - Vite proxy configuration issue"
    echo "   - CORS configuration issue"
fi

echo ""

# Check CORS configuration
echo "🌐 Checking CORS configuration..."
if [ -f ".env" ]; then
    echo "📄 Current .env CORS settings:"
    grep -i cors .env || echo "❌ No CORS settings found in .env"
else
    echo "❌ No .env file found"
fi

echo ""

# Network diagnostics
echo "🔧 Network diagnostics..."
echo "📡 Checking if ports are in use:"
echo "   Port 5173 (frontend):"
lsof -i :5173 | grep LISTEN || echo "   ❌ Nothing listening on port 5173"

echo "   Port 8080 (backend):"
lsof -i :8080 | grep LISTEN || echo "   ❌ Nothing listening on port 8080"

echo ""
echo "🏁 Connection test completed"
echo ""
echo "💡 If you see issues:"
echo "   1. Make sure Docker backend is running: npm run dev:backend"
echo "   2. Make sure frontend is running: npm run dev:hybrid" 
echo "   3. Check CORS_ALLOW_ORIGIN includes http://localhost:5173"
echo "   4. Try the combined script: npm run dev:docker"
