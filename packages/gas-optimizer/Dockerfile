# Multi-stage build for gas-optimizer service
FROM node:20-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy root package files for workspace setup
COPY package.json pnpm-workspace.yaml ./
COPY pnpm-lock.yaml* ./

# Copy shared-types package
COPY packages/shared-types ./packages/shared-types

# Copy gas-optimizer package
COPY packages/gas-optimizer ./packages/gas-optimizer

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build shared-types first
RUN pnpm --filter @orbitflash/shared-types build

# Build gas-optimizer
RUN pnpm --filter gas-optimizer build

# Production stage
FROM node:20-alpine AS production

# Install pnpm
RUN npm install -g pnpm

# Create app directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-workspace.yaml ./
COPY pnpm-lock.yaml* ./

# Copy shared-types package
COPY packages/shared-types/package.json ./packages/shared-types/
COPY --from=builder /app/packages/shared-types/dist ./packages/shared-types/dist

# Copy gas-optimizer package
COPY packages/gas-optimizer/package.json ./packages/gas-optimizer/
COPY --from=builder /app/packages/gas-optimizer/dist ./packages/gas-optimizer/dist

# Install only production dependencies
RUN pnpm install --frozen-lockfile --prod

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S gasopt -u 1001

# Change ownership of the app directory
RUN chown -R gasopt:nodejs /app
USER gasopt

# Expose port
EXPOSE 3003

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3003/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the application
CMD ["node", "packages/gas-optimizer/dist/index.js"]
