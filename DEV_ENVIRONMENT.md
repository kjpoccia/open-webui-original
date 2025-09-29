# Open WebUI Development Environment

This guide helps you set up a development environment with hot reload for SvelteKit frontend files without requiring Docker rebuilds.

## Quick Start

### Option 1: Full Local Development (Recommended for Frontend Development)

Run both frontend and backend locally with hot reload:

```bash
# One-time setup
npm run dev:setup

# Start both frontend and backend with hot reload
npm run dev:local
```

This will:
- Start the backend on `http://localhost:8080` with Python hot reload
- Start the frontend on `http://localhost:5173` with SvelteKit hot reload
- Automatically proxy API calls from frontend to backend

### Option 2: Hybrid Development (Docker Backend + Local Frontend)

Keep your existing Docker backend and run only the frontend locally:

```bash
# Terminal 1: Start Docker backend
npm run dev:backend

# Terminal 2: Start frontend with hot reload
npm run dev:frontend
```

### Option 3: Docker-based Development (Current Setup)

Use your existing Docker setup (requires rebuilds for frontend changes):

```bash
npm run dev:full
```

## Development URLs

- **Frontend**: http://localhost:5173 (SvelteKit dev server)
- **Backend API**: http://localhost:8080 (FastAPI/uvicorn)
- **Health Check**: http://localhost:8080/health

## Hot Reload Features

### ✅ What's Hot Reloaded

**Frontend (SvelteKit)**:
- `.svelte` components
- `.ts` and `.js` files
- `.css` and styling changes
- Page routes in `src/routes/`
- Library files in `src/lib/`

**Backend (Python)**:
- All `.py` files in `backend/`
- Configuration changes
- API route modifications

### ⚡ Performance Optimizations

- **Fast Refresh**: SvelteKit HMR preserves component state
- **CSS Injection**: Styles update without page reload
- **Efficient Watching**: Ignores unnecessary files (`node_modules`, build artifacts)
- **Memory Management**: Optimized for large codebases

## File Structure

```
open-webui/
├── src/                    # SvelteKit frontend source
│   ├── routes/            # Page routes (hot reload)
│   ├── lib/               # Shared components (hot reload)
│   └── app.html           # HTML template
├── backend/               # Python backend source
│   ├── open_webui/        # Main backend package (hot reload)
│   └── requirements.txt   # Python dependencies
├── scripts/               # Development scripts
│   ├── dev-local.sh       # Local development
│   ├── dev-frontend.sh    # Frontend only
│   └── dev-backend.sh     # Backend only (Docker)
├── vite.config.ts         # Vite configuration
├── svelte.config.js       # SvelteKit configuration
└── package.json           # Node.js dependencies
```

## Environment Configuration

The development environment uses these key configurations:

### Frontend (Vite)
- **Port**: 5173
- **Host**: 0.0.0.0 (accessible externally)
- **HMR**: Enabled with overlay
- **Proxy**: API calls forwarded to backend

### Backend (uvicorn)
- **Port**: 8080
- **Host**: 0.0.0.0
- **Reload**: Enabled for `.py` files
- **CORS**: Configured for frontend origin

## Troubleshooting

### Frontend Not Connecting to Backend

1. Ensure backend is running on port 8080
2. Check CORS configuration in `.env`:
   ```
   CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
   ```

### Hot Reload Not Working

1. **SvelteKit files**: Check if Vite dev server is running
2. **Python files**: Ensure uvicorn is started with `--reload`
3. **File permissions**: Ensure `.venv` is activated

### Virtual Environment Issues

Always ensure `.venv` is activated (user requirement):

```bash
source .venv/bin/activate
```

The development scripts automatically handle this, but manual commands require activation.

### Port Conflicts

- Frontend default: 5173
- Backend default: 8080
- Change ports in `vite.config.ts` and backend startup scripts if needed

## Development Commands

```bash
# Setup (one-time)
npm run dev:setup          # Full environment setup

# Development modes
npm run dev:local           # Local frontend + backend
npm run dev:frontend        # Frontend only (requires backend)
npm run dev:backend         # Docker backend only
npm run dev:full            # Docker backend + frontend

# Building
npm run build              # Production build
npm run build:watch        # Watch mode build

# Code quality
npm run check              # Type checking
npm run lint               # Linting
npm run format             # Code formatting
```

## Performance Tips

1. **Use Local Development**: `npm run dev:local` is fastest for frontend changes
2. **File Watching**: Vite efficiently watches only relevant files
3. **Memory Usage**: Node.js memory limit set to 6GB for large builds
4. **CSS Hot Reload**: Styles update instantly without losing state

## Virtual Environment Requirement

As per user requirements, always ensure `.venv` is activated:

```bash
# Check if virtual environment is active
echo $VIRTUAL_ENV

# Activate if not active
source .venv/bin/activate
```

All development scripts handle this automatically.
