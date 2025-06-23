## 0.1.1

- 🧠 Major performance enhancements:
    - All log read/write/purge now happens in isolates to prevent UI jank
    - Log overlay is now safe for high-frequency logging in production-grade apps
- 🎯 UI update:
    - Replaced log level text (DEBUG, INFO, ERROR) with intuitive icons
- 🧾 Log detail page now pretty-prints JSON request/response bodies
- 🛑 Auto-purge logs older than 2 days in background