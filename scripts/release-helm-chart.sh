#!/bin/bash

# Release Helm Chart Script
# Usage: ./scripts/release-helm-chart.sh [version]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 GPU Operator Helm Chart Release Script${NC}"
echo "=================================================="

# Get version from argument or git tag
VERSION=${1:-$(git describe --tags --exact-match 2>/dev/null || echo "v1.0.0")}

if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ Error: Version must be in format v1.0.0${NC}"
    echo "Usage: $0 [v1.0.0]"
    exit 1
fi

echo -e "${YELLOW}📦 Releasing Helm Chart version: $VERSION${NC}"

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Error: Helm is not installed${NC}"
    echo "Please install Helm: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Check if we're in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Check if working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Warning: Working directory is not clean${NC}"
    echo "Please commit or stash changes before releasing"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Set VERSION for Makefile
export VERSION=${VERSION#v}

echo -e "${YELLOW}🔍 Validating Helm chart...${NC}"
make helm-lint
make helm-test

echo -e "${YELLOW}📦 Packaging Helm chart...${NC}"
make helm-package

CHART_FILE="deployments/gpu-operator/gpu-operator-$VERSION.tgz"

if [[ ! -f "$CHART_FILE" ]]; then
    echo -e "${RED}❌ Error: Chart file not found: $CHART_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Helm chart packaged successfully!${NC}"
echo -e "${GREEN}📄 Chart file: $CHART_FILE${NC}"

# Show file info
echo -e "${YELLOW}📊 Chart file info:${NC}"
ls -lh "$CHART_FILE"

echo ""
echo -e "${GREEN}🎯 Installation commands:${NC}"
echo -e "${YELLOW}# Install from GitHub releases (after push):${NC}"
echo "helm install gpu-operator \\"
echo "  https://github.com/thuanpham582002/gpu-operator/releases/download/v$VERSION/gpu-operator-$VERSION.tgz \\"
echo "  --namespace gpu-operator --create-namespace \\"
echo "  --set nvitopExporter.enabled=true"
echo ""
echo -e "${YELLOW}# Install from local file:${NC}"
echo "helm install gpu-operator $CHART_FILE --namespace gpu-operator --create-namespace"

echo ""
echo -e "${GREEN}🚀 Next steps:${NC}"
echo "1. Tag the release: git tag v$VERSION"
echo "2. Push to GitHub: git push origin v$VERSION"
echo "3. GitHub Actions will automatically create the release"

# Ask if user wants to tag and push
read -p "Create git tag and push to GitHub? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🏷️  Creating git tag...${NC}"
    git tag v$VERSION

    echo -e "${YELLOW}📤 Pushing tag to GitHub...${NC}"
    git push origin v$VERSION

    echo -e "${GREEN}✅ Tag pushed! GitHub Actions will create the release automatically.${NC}"
    echo "Check: https://github.com/thuanpham582002/gpu-operator/actions"
else
    echo -e "${YELLOW}💡 Don't forget to tag and push when ready:${NC}"
    echo "git tag v$VERSION && git push origin v$VERSION"
fi

echo -e "${GREEN}🎉 Helm chart release complete!${NC}"