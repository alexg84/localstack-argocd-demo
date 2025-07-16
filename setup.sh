#!/bin/bash

# Setup script for ArgoCD and Crossplane on Minikube

set -e

echo "🚀 Setting up ArgoCD and Crossplane on Minikube..."

# Check if minikube is running
if ! minikube status > /dev/null 2>&1; then
    echo "❌ Minikube is not running. Please start minikube first."
    exit 1
fi

echo "✅ Minikube is running"

# Step 1: Install ArgoCD
echo "📦 Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Step 2: Install Crossplane
echo "📦 Installing Crossplane..."
kubectl create namespace crossplane-system --dry-run=client -o yaml | kubectl apply -f -
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace --wait

# Wait for Crossplane to be ready
echo "⏳ Waiting for Crossplane to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/crossplane -n crossplane-system

# Step 3: Build and load Docker image for the hello world app
echo "🐳 Building Docker image for hello world app..."
eval $(minikube docker-env)
docker build -t idp-demo:latest ./app/

# Step 4: Apply ArgoCD configurations
echo "⚙️ Applying ArgoCD configurations..."
kubectl apply -f argocd/configs.yaml
kubectl apply -f argocd/rbac.yaml
kubectl apply -f argocd/services.yaml

# Step 5: Apply Crossplane configurations
echo "⚙️ Applying Crossplane configurations..."
kubectl apply -f crossplane/provider.yaml

# Wait for provider to be ready
echo "⏳ Waiting for Crossplane provider to be ready..."
kubectl wait --for=condition=Healthy --timeout=300s provider/provider-aws

# Apply AWS resources
kubectl apply -f crossplane/s3.yaml
kubectl apply -f crossplane/sns.yaml
kubectl apply -f crossplane/sqs.yaml
kubectl apply -f crossplane/rds.yaml

# Step 6: Deploy the ArgoCD application
echo "🚀 Deploying ArgoCD application..."
kubectl apply -f argocd/deployments.yaml

# Get ArgoCD admin password
echo "🔑 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

echo "✅ Setup completed successfully!"
echo ""
echo "📝 Access Information:"
echo "---------------------"
echo "ArgoCD UI: http://${MINIKUBE_IP}:30080"
echo "Username: admin"
echo "Password: ${ARGOCD_PASSWORD}"
echo ""
echo "To access the hello world app:"
echo "kubectl port-forward svc/idp-demo 8080:80"
echo "Then visit: http://localhost:8080"
echo ""
echo "To start LocalStack (run in another terminal):"
echo "docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack"
