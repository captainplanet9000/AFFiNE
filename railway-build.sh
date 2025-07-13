#!/bin/bash
set -e

echo "Running AFFiNE Railway build script..."

# Install required node packages
echo "Installing dependencies..."
yarn install

# Build the application directly using the CLI tool
echo "Building AFFiNE using direct CLI invocation..."
node --import=./tools/cli/register.js ./tools/cli/src/affine.ts build

echo "Build completed successfully!"
