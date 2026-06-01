# GCP CI/CD Pipeline for Python Web App

## Project Overview

This repository contains a lightweight Python Flask web application demonstrating a modern Continuous Integration and Continuous Deployment (CI/CD) pipeline on Google Cloud Platform (GCP). The project showcases automated container image builds, secure artifact storage, and serverless/compute-based deployment strategies using Cloud Build and Artifact Registry.


<img src="https://gcpicons.com/icons/cloud_build.svg" width="50" height="50" alt="Google Cloud Build"/>
<img src="https://svgmix.com/uploads/0f/7f/google-cloud-build.svg" width="50" height="50" alt="Google Cloud Build"/>

![Google Cloud Build](https://img.shields.io/badge/Google_Cloud-Build-4285F4?logo=googlecloud&logoColor=white)

<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/googlecloud/googlecloud-original.svg" width="50" height="50" alt="Google Cloud"/>


---

## Architecture & Tech Stack

* **Application Framework:** Python 3.13, Flask, Gunicorn
* **Source Control:** GitHub
* **Containerization:** Docker
* **CI/CD:** Google Cloud Build (via GitHub Triggers)
* **Artifact Storage:** Google Artifact Registry
* **Compute (Testing):** Google Compute Engine (GCE) Container VMs

---

## Repository Structure

```text
devops-repo/
├── Dockerfile               # Container build instructions
├── main.py                  # Flask application entry point
├── requirements.txt         # Python dependency definitions
└── templates/               # HTML UI templates
    ├── index.html           # Main landing page
    └── layout.html          # Base Bootstrap 4 layout

```

---

## CI/CD Workflow

1. **Code Commit:** A developer pushes code changes to the `main` branch on GitHub.
2. **Trigger:** Google Cloud Build detects the commit via the GitHub App integration.
3. **Build Phase:** Cloud Build executes the inline steps (or `cloudbuild.yaml`), building a new Docker image from the `Dockerfile`.
4. **Publish Phase:** The newly built container image is tagged with the `$COMMIT_SHA` and pushed securely to Google Artifact Registry.
5. **Deployment (Manual/Automated):** The resulting image URL can be deployed to Compute Engine, Cloud Run, or Google Kubernetes Engine (GKE).

---

## Setup & Deployment Instructions

### 1. Local Development Setup

Ensure you are authenticated with the GitHub CLI (`gh`) and have configured your local git environment:

```bash
# Authenticate GitHub CLI
gh auth login

# Set global git config
export GITHUB_USERNAME=$(gh api user -q ".login")
git config --global user.name "${GITHUB_USERNAME}"
git config --global user.email "your-email@example.com"

```

### 2. Infrastructure Setup (Artifact Registry)

Create a dedicated Docker repository in Artifact Registry to store the application images:

```bash
# Create the Artifact Registry repository
gcloud artifacts repositories create devops-repo \
    --repository-format=docker \
    --location="<YOUR_REGION>"

# Configure Docker authentication for Artifact Registry
gcloud auth configure-docker "<YOUR_REGION>-docker.pkg.dev"

```

### 3. Manual Build & Test

Before automating, verify the build process manually by submitting the build to Google Cloud Build and deploying it to a test Compute Engine instance.

```bash
# Submit a manual build
gcloud builds submit --tag "<YOUR_REGION>-docker.pkg.dev/$DEVSHELL_PROJECT_ID/devops-repo/devops-image:v0.1" .

```

*Note: Once built, this image can be deployed directly via the Google Cloud Console by creating a new VM Instance and specifying the container image path under the "Deploy Container" settings.*

### 4. Continuous Integration (Cloud Build Triggers)

To automate the build process on every push to the repository:

1. Navigate to **Cloud Build > Triggers** in the Google Cloud Console.
2. Connect your GitHub repository using the Cloud Build GitHub App.
3. Create a trigger for the `.*` (any) or `^main$` branch.
4. Configure the build with the following inline YAML structure:

```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', '<YOUR_REGION>-docker.pkg.dev/<YOUR_PROJECT_ID>/devops-repo/devops-image:$COMMIT_SHA', '.']
images:
  - '<YOUR_REGION>-docker.pkg.dev/<YOUR_PROJECT_ID>/devops-repo/devops-image:$COMMIT_SHA'
options:
  logging: CLOUD_LOGGING_ONLY

```

Once configured, any `git push origin main` will automatically trigger a new build and populate your Artifact Registry with the versioned image.
