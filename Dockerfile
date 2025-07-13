FROM node:20-slim AS base

# Set working directory
WORKDIR /app

# First copy the entire project so all workspace files are available
COPY . .

# This is crucial for workspace resolution
RUN yarn install

# Set up the backend
WORKDIR /app/packages/backend/server

# Generate Prisma client
RUN npx prisma generate

# Build the server directly with its own build command
RUN yarn build

# Production image
FROM node:20-slim AS runner
WORKDIR /app

# Copy required files from builder
COPY --from=base /app/packages/backend/server/dist ./dist
COPY --from=base /app/packages/backend/server/node_modules ./node_modules
COPY --from=base /app/packages/backend/server/package.json ./package.json
COPY --from=base /app/packages/backend/server/prisma ./prisma

# Set environment variables
ENV NODE_ENV=production

# Start the server
CMD ["node", "dist/index.js"]
