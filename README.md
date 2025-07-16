# Hello World App with ArgoCD and Crossplane

This repository contains a complete setup for deploying a Hello World Flask application using ArgoCD and Crossplane on Minikube, with LocalStack for AWS services.

## Architecture

- **Application**: Simple Flask "Hello World" app
- **Container**: Docker image with Flask app
- **Orchestration**: Kubernetes with Helm charts
- **GitOps**: ArgoCD for application deployment
- **Infrastructure**: Crossplane for provisioning AWS resources on LocalStack

## Prerequisites

- Minikube
- kubectl
- Docker
- Helm
- LocalStack (optional, for AWS services)

## Quick Start

1. **Start Minikube**:
   ```bash
   minikube start
   ```

2. **Run the setup script**:
   ```bash
   ./setup.sh
   ```

3. **Start LocalStack** (in another terminal):
   ```bash
   docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
   ```

## Project Structure

```
├── app/                    # Flask application
│   ├── main.py            # Main application file
│   ├── Dockerfile         # Docker configuration
│   └── requirements.txt   # Python dependencies
├── argocd/                # ArgoCD configurations
│   ├── configs.yaml       # ArgoCD config map
│   ├── rbac.yaml          # RBAC configuration
│   ├── services.yaml      # ArgoCD services
│   └── deployments.yaml   # ArgoCD application
├── crossplane/            # Crossplane configurations
│   ├── provider.yaml      # AWS provider config
│   ├── s3.yaml           # S3 bucket
│   ├── sns.yaml          # SNS topic
│   ├── sqs.yaml          # SQS queue

│   └── rds.yaml          # RDS database
├── helm/                  # Helm chart
│   └── idp-demo/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
└── setup.sh              # Automated setup script
```

## Manual Steps

If you prefer to set up manually:

### 1. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Install Crossplane

```bash
kubectl create namespace crossplane-system
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace
```

### 3. Build and Deploy

```bash
# Build Docker image
eval $(minikube docker-env)
docker build -t idp-demo:latest ./app/

# Apply configurations
kubectl apply -f argocd/
kubectl apply -f crossplane/
```

## Access the Applications

### ArgoCD UI
```bash
# Get the password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Or use NodePort service
minikube service argocd-server -n argocd
```

### Hello World App
```bash
kubectl port-forward svc/idp-demo 8080:80
```

Visit: http://localhost:8080

## AWS Resources (via Crossplane + LocalStack)

The following AWS resources are provisioned:

- **S3 Bucket**: `idp-demo-bucket`
- **SNS Topic**: `idp-demo-notifications`
- **SQS Queue**: `idp-demo-queue`
- **RDS Database**: `idp-demo-db` (PostgreSQL)

## Troubleshooting

### Check ArgoCD Application Status
```bash
kubectl get applications -n argocd
```

### Check Crossplane Resources
```bash
kubectl get managed
```

### View Application Logs
```bash
kubectl logs -l app.kubernetes.io/name=idp-demo
```

### Reset Everything
```bash
minikube delete
minikube start
```

## Development

To make changes to the application:

1. Edit `app/main.py`
2. Rebuild the Docker image
3. ArgoCD will automatically sync and deploy changes (if auto-sync is enabled)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Test with the setup script
5. Submit a pull request
