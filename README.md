# IDP Demo App with ArgoCD and Crossplane

This repository contains a complete setup for deploying a Flask application using ArgoCD and Crossplane on Minikube, with LocalStack for AWS services.

## Architecture

- **Application**: Simple Flask demo app
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

3. **The setup script will**:
   - Install ArgoCD
   - Install Crossplane with AWS providers
   - Deploy LocalStack
   - Create ArgoCD applications
   - Set up the complete GitOps workflow

## GitOps Workflow

This project demonstrates a pure GitOps approach:

1. **Infrastructure as Code**: All AWS resources defined in Crossplane manifests
2. **Application as Code**: Kubernetes manifests in Helm charts
3. **GitOps**: ArgoCD monitors this repository and automatically deploys changes
4. **No Manual Steps**: Everything is managed through Git commits

### Applications in ArgoCD:
- `idp-demo`: Main application and AWS resources
- `localstack`: LocalStack deployment for AWS services

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
├── helm/                  # Helm charts
│   ├── idp-demo/          # Main application chart
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/     # Kubernetes manifests and Crossplane resources
│   └── localstack/        # LocalStack deployment chart
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
# Apply ArgoCD application
kubectl apply -f argocd/deployments.yaml

# The application will automatically sync and deploy via GitOps
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

### IDP Demo App
```bash
kubectl port-forward svc/idp-demo 8080:80
```

Visit: http://localhost:8080

## AWS Resources (via Crossplane + LocalStack)

The following AWS resources are provisioned via Crossplane:

- **S3 Bucket**: `idp-demo-bucket`
- **SNS Topic**: `idp-demo-notifications`
- **SQS Queue**: `idp-demo-queue`

All resources are managed declaratively through Helm charts and ArgoCD.

## Troubleshooting

### Check ArgoCD Application Status
```bash
kubectl get applications -n argocd
argocd app get idp-demo  # if using ArgoCD CLI
```

### Check Crossplane Resources
```bash
kubectl get managed
kubectl get providerconfig
kubectl get bucket,topic,queue
```

### View Application Logs
```bash
kubectl logs -l app=idp-demo
```

### Reset Everything
```bash
minikube delete
minikube start
```

## Development

To make changes to the application:

1. Edit the Helm chart in `helm/idp-demo/`
2. Commit and push changes to the repository
3. ArgoCD will automatically sync and deploy changes

This follows GitOps principles - all changes are managed through Git.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Test with the setup script
5. Submit a pull request
