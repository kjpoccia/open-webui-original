# Quick Start - Hot Reload Development

Get SvelteKit hot reload working in 3 simple steps:

## 🚀 Option 1: Quick Start (Recommended)

If you already have `node_modules` installed:

```bash
# Start both frontend and backend with hot reload
npm run dev:simple
```

This will start:
- Backend on http://localhost:8080 (Python hot reload)
- Frontend on http://localhost:5173 (SvelteKit hot reload)

## 🚀 Option 2: Docker Backend + Local Frontend (Your Preferred Setup)

Keep your backend in Docker, run frontend locally with hot reload:

```bash
# One command that handles everything
npm run dev:docker
```

Or manually:

```bash
# Terminal 1: Start your Docker backend
npm run dev:backend

# Terminal 2: Start frontend with hot reload
npm run dev:frontend
```

### 🔧 Connection Issues?

If frontend can't connect to Docker backend:

```bash
# Test the connection
npm run test:connection

# This checks:
# - Docker backend health
# - Frontend accessibility
# - API proxy functionality
# - CORS configuration
```

## 🔥 What You Get

### ✅ Hot Reload Features
- **SvelteKit files**: Instant updates for `.svelte`, `.ts`, `.js`, `.css`
- **Python files**: Auto-restart for backend changes
- **State preservation**: Component state maintained during updates
- **Error overlay**: Helpful error messages in browser

### 📁 Files to Edit
- `src/routes/` - Page components
- `src/lib/` - Shared components  
- `src/app.css` - Global styles
- `backend/` - Python API code

## 🔧 Virtual Environment

The scripts automatically handle your `.venv` requirement:

```bash
# Check if .venv is active
echo $VIRTUAL_ENV

# Manually activate if needed
source .venv/bin/activate
```

## 🚨 Troubleshooting

### Node.js Dependencies Issue
If you get dependency conflicts during `npm install`:

```bash
npm install --legacy-peer-deps
```

### Backend Connection Issues
Ensure CORS is configured in your `.env`:

```env
CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
```

### Port Conflicts
- Frontend: http://localhost:5173
- Backend: http://localhost:8080

Change ports in `vite.config.ts` if needed.

## 💡 Development Tips

1. **Edit a .svelte file** - See instant changes
2. **Modify backend code** - Server auto-restarts
3. **Update styles** - CSS updates without page reload
4. **Use browser DevTools** - Source maps enabled

## 📋 Available Commands

```bash
npm run dev:simple     # Quick start (recommended)
npm run dev:frontend   # Frontend only
npm run dev:backend    # Docker backend only
npm run dev:full       # Full Docker setup
npm run dev:hybrid     # Frontend dev server only
```

---

**Next**: Edit any file in `src/` and watch the magic happen! 🪄
