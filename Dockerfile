FROM node:18.17.0-alpine3.18

WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user and group
RUN addgroup --gid 1000 -S appgroup && \
    adduser --uid 1000 --gid appgroup --shell /bin/bash --create-home appuser

# Set proper ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PORT:-3000}/health || exit 1

EXPOSE 3000
CMD ["node", "server.js"]