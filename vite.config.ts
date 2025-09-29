import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

import { viteStaticCopy } from 'vite-plugin-static-copy';

export default defineConfig({
	plugins: [
		sveltekit(),
		viteStaticCopy({
			targets: [
				{
					src: 'node_modules/onnxruntime-web/dist/*.jsep.*',

					dest: 'wasm'
				}
			]
		})
	],
	define: {
		APP_VERSION: JSON.stringify(process.env.npm_package_version),
		APP_BUILD_HASH: JSON.stringify(process.env.APP_BUILD_HASH || 'dev-build')
	},
	build: {
		sourcemap: true
	},
	worker: {
		format: 'es'
	},
	esbuild: {
		pure: process.env.ENV === 'dev' ? [] : ['console.log', 'console.debug', 'console.error']
	},
	server: {
		host: true,
		port: 5173,
		watch: {
			// Enable hot reload for all relevant file types
			ignored: ['!**/node_modules/**', '**/backend/**'],
			usePolling: false
		},
		hmr: {
			// Enable hot module replacement
			overlay: true
		},
		proxy: {
			// Proxy API calls to the Docker backend
			'/api': {
				target: 'http://localhost:8080',
				changeOrigin: true,
				secure: false,
				timeout: 10000,
				configure: (proxy, options) => {
					proxy.on('error', (err, req, res) => {
						console.log('🔴 API Proxy Error:', err.message);
						console.log('📡 Target URL:', req.url);
					});
					proxy.on('proxyReq', (proxyReq, req, res) => {
						console.log('📤 API Request:', req.method, req.url);
					});
				}
			},
			'/health': {
				target: 'http://localhost:8080',
				changeOrigin: true,
				secure: false
			},
			'/ollama': {
				target: 'http://localhost:8080',
				changeOrigin: true,
				secure: false,
				timeout: 30000,
				configure: (proxy, options) => {
					proxy.on('error', (err, req, res) => {
						console.log('🔴 Ollama Proxy Error:', err.message);
					});
				}
			},
			'/ws': {
				target: 'ws://localhost:8080',
				ws: true,
				changeOrigin: true,
				configure: (proxy, options) => {
					proxy.on('error', (err, req, res) => {
						console.log('🔴 WebSocket Proxy Error:', err.message);
					});
				}
			},
			// Additional backend routes that might need proxying
			'/oauth': {
				target: 'http://localhost:8080',
				changeOrigin: true,
				secure: false
			},
			'/static': {
				target: 'http://localhost:8080',
				changeOrigin: true,
				secure: false
			}
		}
	}
});
