"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const electron_1 = require("electron");
electron_1.contextBridge.exposeInMainWorld('electron', {
    // Add any Electron APIs you want to expose to the renderer process
    platform: process.platform,
});
//# sourceMappingURL=preload.js.map