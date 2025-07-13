FROM node:20-slim AS base

# Set working directory for backend server only
WORKDIR /app/server

# Copy only the backend server package
COPY packages/backend/server/package.json .
COPY packages/backend/server/tsconfig.json .
COPY packages/backend/server/src ./src
COPY packages/backend/server/prisma ./prisma

# Install dependencies for this package only
RUN npm install

# Generate Prisma client
RUN npx prisma generate

# Build using TypeScript directly
RUN npx tsc

# Production image
FROM node:20-slim AS runner
WORKDIR /app

# Copy compiled files from build stage
COPY --from=base /app/server/dist ./dist
COPY --from=base /app/server/node_modules ./node_modules
COPY --from=base /app/server/package.json ./package.json
COPY --from=base /app/server/prisma ./prisma

# Set environment variables
ENV NODE_ENV=production
ENV AFFINE_SKIP_NATIVE=true

# Create required directories
RUN mkdir -p ./prisma/migrations
RUN mkdir -p ./dist/mails

# Start the server
CMD ["node", "dist/index.js"]
