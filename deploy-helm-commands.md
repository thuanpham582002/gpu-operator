# Installation Commands for thuanpham582002/gpu-operator

## Option 1: Install from GitHub Release
```bash
helm install gpu-operator \
  https://github.com/thuanpham582002/gpu-operator/releases/download/v25.3.4/gpu-operator-25.3.4.tgz \
  -n gpu-operator --create-namespace \
  --set sandboxWorkloads.enabled=true \
  --set devicePlugin.enabled=false \
  --set nvitopExporter.enabled=true
```

## Option 2: Install from GitHub Repository (if helm chart repo is set up)
```bash
helm repo add thuanpham582002 https://thuanpham582002.github.io/gpu-operator && \
helm repo update && \
helm install gpu-operator thuanpham582002/gpu-operator \
  -n gpu-operator --create-namespace \
  --version v25.3.4 \
  --set sandboxWorkloads.enabled=true \
  --set devicePlugin.enabled=false \
  --set nvitopExporter.enabled=true
```

## Option 3: Clone and Install
```bash
git clone https://github.com/thuanpham582002/gpu-operator.git
cd gpu-operator

helm install gpu-operator ./deployments/gpu-operator \
  -n gpu-operator --create-namespace \
  --set sandboxWorkloads.enabled=true \
  --set devicePlugin.enabled=false \
  --set nvitopExporter.enabled=true
```

## With Custom Operator Image
```bash
helm install gpu-operator \
  https://github.com/thuanpham582002/gpu-operator/releases/download/v25.3.4/gpu-operator-25.3.4.tgz \
  -n gpu-operator --create-namespace \
  --set sandboxWorkloads.enabled=true \
  --set devicePlugin.enabled=false \
  --set nvitopExporter.enabled=true \
  --set operator.repository=ghcr.io/thuanpham582002 \
  --set operator.image=gpu-operator \
  --set operator.version=main-latest
```