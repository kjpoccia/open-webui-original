# Hybrid Development Setup

This setup provides hot reloading for both frontend and backend development without requiring Docker rebuilds.

## Quick Start

### Option 1: Run Everything Together
```bash
npm install
npm run dev:full
```

### Option 2: Run Separately (Recommended for debugging)

**Terminal 1 - Backend:**
```bash
docker-compose -f docker-compose.dev.yaml up --build
```

**Terminal 2 - Frontend:**
```bash
npm install
npm run dev:hybrid
```

### Important: Docker Ignore Setup
The development setup uses an optimized `.dockerignore.dev` file to reduce build context size. This file is automatically activated when you run the development commands.

## What This Setup Provides

### Frontend (SvelteKit)
- **Hot Reloading**: Instant updates when you change Svelte/TypeScript/CSS files
- **Port**: Runs on `http://localhost:5173`
- **Proxy**: API calls are automatically proxied to the Docker backend

### Backend (Python)
- **Auto-restart**: Backend automatically restarts when Python files change
- **Port**: Runs on `http://localhost:8080` (inside Docker)
- **Volume Mounting**: Your local backend code is mounted into the container

## File Structure

```
├── Dockerfile.dev              # Development Dockerfile with file watching
├── docker-compose.dev.yaml     # Development Docker Compose configuration
├── scripts/dev-backend.sh      # Backend startup script with auto-restart
├── .dockerignore.dev           # Development-specific dockerignore
├── vite.config.ts              # Updated with proxy configuration
└── package.json                # Updated with new dev scripts
```

## Available Scripts

- `npm run dev:hybrid` - Start frontend with hot reloading
- `npm run dev:backend` - Start backend with auto-restart
- `npm run dev:full` - Start both frontend and backend together

## Environment Variables

The development setup uses these key environment variables:

- `ENV=dev` - Enables development mode
- `CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173` - Allows frontend to connect
- `PORT=8080` - Backend port

## Troubleshooting

### Backend not starting
- Check if port 8080 is available: `lsof -i :8080`
- Ensure Docker is running: `docker ps`
- If you see GitPython errors, the setup now mounts the entire project to preserve the git repository

### Frontend not connecting to backend
- Verify backend is running: `curl http://localhost:8080/health`
- Check browser console for CORS errors
- Ensure proxy configuration in `vite.config.ts` is correct

### File changes not triggering reloads
- Backend: Check if the volume mount is working: `docker exec -it <container> ls -la /app/backend`
- Frontend: Check if the dev server is running and watching files

## Switching Back to Production

To switch back to the production Docker setup:
```bash
# Restore the original dockerignore file
cp .dockerignore.backup .dockerignore

# Start production setup
docker-compose -f docker-compose.override.yaml up --build
```

### Development Docker Ignore Management

The development setup automatically uses an optimized `.dockerignore.dev` file that:
- Excludes `node_modules/` and other large directories
- Preserves the `.git/` directory needed for GitPython
- Reduces build context from ~7GB to much smaller size

**Files:**
- `.dockerignore.dev` - Development-optimized ignore rules
- `.dockerignore.backup` - Backup of original production ignore rules

## Benefits

✅ **Fast Iteration**: No Docker rebuilds needed  
✅ **Hot Reloading**: Frontend changes appear instantly  
✅ **Auto-restart**: Backend restarts automatically on file changes  
✅ **Same Environment**: Backend runs in Docker with all dependencies  
✅ **Easy Debugging**: Frontend runs locally for easier debugging  
✅ **Optimized Build**: Development dockerignore reduces build context size  
