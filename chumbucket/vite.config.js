import {viteSingleFile} from 'vite-plugin-singlefile';
import {defineConfig} from 'vite';
// Vite.config.js
export default defineConfig({
	plugins: [viteSingleFile()],
});
