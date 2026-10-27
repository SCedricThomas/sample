ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-bookworm-slim

WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1

# Install dependencies in a separate layer so source edits don't invalidate it.
COPY package.json ./
RUN node /usr/local/lib/node_modules/npm/bin/npm-cli.js install --no-audit --no-fund

COPY app/ ./app/
COPY public/ ./public/
COPY next.config.mjs copy-assets.js ./
RUN node /usr/local/lib/node_modules/npm/bin/npm-cli.js run build

ENV PORT=8080 HOSTNAME=0.0.0.0
EXPOSE 8080
CMD ["node", ".next/standalone/server.js"]
