FROM node:20-slim AS base

# Set working directory
WORKDIR /app

# First copy the entire project so all workspace files are available
COPY . .

# Install dependencies
RUN yarn install

# Build all packages first to ensure cross-dependencies are available
RUN yarn build

# Generate Prisma client in backend server
WORKDIR /app/packages/backend/server
RUN npx prisma generate

# Ensure node_modules are available in the backend server directory
RUN mkdir -p /app/packages/backend/server/node_modules
RUN cp -R /app/node_modules/* /app/packages/backend/server/node_modules/

# Production image
FROM node:20-slim AS runner
WORKDIR /app

# Copy required files from builder - we'll copy more broadly to ensure all dependencies are available
COPY --from=base /app/packages/backend/server/dist ./dist
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/packages/backend/server/package.json ./package.json

# Create prisma directory if it doesn't exist in the base image
RUN mkdir -p ./prisma
COPY --from=base /app/packages/backend/server/prisma/* ./prisma/ || true

# Set environment variables
ENV NODE_ENV=production
# Skip native binaries check since we're running in a container
ENV AFFINE_SKIP_NATIVE=true

# Start the server
CMD ["node", "dist/index.js"]
