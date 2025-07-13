FROM node:20-slim AS base

# Set working directory
WORKDIR /app

# Copy package.json and yarn files for dependency installation
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Install dependencies
RUN yarn install --immutable

# Copy the entire project
COPY . .

# Generate Prisma client
RUN cd packages/backend/server && npx prisma generate

# Build backend server using direct approach
RUN cd tools/cli && yarn build && cd ../..
RUN cd packages/backend/server && node ../../tools/cli/dist/cli.js bundle -p @affine/server

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
