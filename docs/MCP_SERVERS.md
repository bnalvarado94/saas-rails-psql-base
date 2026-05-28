# MCP Servers — Referencia

El archivo `.mcp.json` en la raíz del proyecto define los MCP servers disponibles
para Claude Code en este proyecto. Es portable — cualquier dev que clone el repo
tiene el mismo setup.

**GitNexus ya está configurado por defecto.**

---

## Agregar servidores

Editar `.mcp.json` y agregar dentro de `mcpServers`:

### GitHub
```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
}
```

### PostgreSQL (acceso directo a la DB)
```json
"postgres": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-postgres", "${DATABASE_URL}"]
}
```

### Fetch (scraping de docs, APIs públicas)
```json
"fetch": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-fetch"]
}
```

### Filesystem (acceso a paths fuera del repo)
```json
"filesystem": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem", "/ruta/al/directorio"]
}
```

---

## Variables de entorno

Los valores sensibles como tokens nunca van hardcodeados en `.mcp.json`.
Usar la sintaxis `"${VARIABLE}"` — Claude Code los lee del entorno.

Definirlos en `.env.local` (gitignored):
```bash
GITHUB_TOKEN=ghp_...
DATABASE_URL=postgresql://...
```

---

## settings.local.json

Para overrides personales (no commiteados):
- Permisos adicionales para tu máquina específica
- MCP servers que solo vos usás localmente

Ver `.claude/settings.local.json` como punto de partida.
