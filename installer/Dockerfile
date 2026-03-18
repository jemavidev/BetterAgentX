# BetterAgents Memory Dashboard
# Minimal Node.js server — no npm dependencies required

FROM node:20-alpine

WORKDIR /app

# Copy only the server script (no package.json needed — zero deps)
COPY .betteragents/scripts/serve-dashboard.js ./serve-dashboard.js

# Run as non-root node user (included in node:alpine images)
USER node

EXPOSE 3000

HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost:3000 || exit 1

CMD ["node", "serve-dashboard.js"]
