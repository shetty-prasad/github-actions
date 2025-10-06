What is GitHub Actions and how does it differ from other CI/CD tools like Jenkins, CircleCI, or GitLab CI?

Answer:
GitHub Actions is tightly integrated with GitHub, allowing native automation workflows triggered by GitHub events without needing external CI/CD systems. Unlike Jenkins, which requires server setup and plugin management, GitHub Actions is cloud-native and maintained by GitHub, with scalable hosted runners. CircleCI and GitLab CI offer similar features, but GitHub Actions excels in ease of use within the GitHub ecosystem and support for community-contributed actions.

2. How would you design a GitHub Actions workflow for a microservices architecture?

Answer:

Each microservice lives in its own folder or repo.

Use matrix builds for parallel testing across services.

Use path: filter to trigger builds only for changed services.

Use reusable workflows to avoid duplication.

Secrets management for deploying each service to its respective environment.

Use needs: to manage job dependencies if some services rely on others.

3. How can you optimize workflow performance and cost in GitHub Actions?

Answer:

Use job caching (e.g., actions/cache) to avoid re-installing dependencies.

Use matrix builds efficiently to parallelize tests.

Use self-hosted runners for high-load or licensed builds.

Run tests only when specific files are changed using paths filter.

Avoid unnecessary triggers like pushes to docs.

4. How do you handle secrets securely in GitHub Actions?

Answer:

Use GitHub's encrypted secrets in repository or organization settings.

Never hardcode secrets in workflows.

Access secrets using ${{ secrets.MY_SECRET }}.

For enhanced security, use OIDC integration with AWS/GCP instead of long-lived credentials.

Can you write a GitHub Actions workflow to deploy a Docker container to AWS ECS?
```
name: Deploy to ECS

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v3
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Build and push Docker image
        run: |
          docker build -t my-image .
          docker tag my-image:latest ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/my-repo:latest
          docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/my-repo:latest

      - name: Deploy to ECS
        run: |
          aws ecs update-service --cluster my-cluster --service my-service --force-new-deployment
```

What are composite and reusable workflows in GitHub Actions?

Answer:

Composite Actions: Group multiple steps into a single custom action (.yml), reusable across workflows.

Reusable Workflows: Call an entire workflow from another workflow using workflow_call. Ideal for standardizing CI pipelines across services.

7. How do you test GitHub Actions workflows before pushing to main?

Answer:

Use feature branches with pull requests.

Use workflow_dispatch to test manually.

Add conditions using if: to run only on specific branches or users.

Use act (a local runner for GitHub Actions) to test workflows locally.

8. What are common pitfalls or anti-patterns in GitHub Actions?

Answer:

Hardcoding secrets or sensitive data.

Not caching dependencies, causing slow builds.

Long workflows with repetitive steps (instead of reusable workflows).

Using single monolithic workflows for all jobs.

Not leveraging matrix builds for parallelism.

बहुत अच्छा सवाल 👏 — ये repository_dispatch और reusable workflow दोनों ही GitHub Actions में “एक workflow को दूसरे से चलाने” के तरीके हैं,
लेकिन इनका purpose, use-case और execution model काफ़ी अलग है।
आओ step-by-step समझते हैं 👇

⚙️ 1️⃣ repository_dispatch क्या है?
🔸 Concept:

repository_dispatch एक event trigger है — यानी आप किसी workflow को manually या दूसरे repo से trigger कर सकते हैं
GitHub API या GitHub CLI का उपयोग करके।

इसका मतलब:

आप किसी external system या repo से GitHub Actions workflow चालू कर सकते हैं।

🔹 Typical Use:

Cross-repo automation: एक repo में build complete होते ही, दूसरा repo में deploy workflow चलाना।

External system से trigger (जैसे Jenkins, Terraform Cloud, या custom script)।

🧱 Example:

Repo B में ये workflow है (.github/workflows/deploy.yml):
```
name: Deploy via Dispatch

on:
  repository_dispatch:
    types: [deploy-trigger]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Application
        run: echo "Deploying version ${{ github.event.client_payload.version }}"
```

अब Repo A से आप GitHub API call करके इसे चला सकते हैं 👇
```
curl -X POST \
  -H "Authorization: token <YOUR_GITHUB_TOKEN>" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/<org>/<repoB>/dispatches \
  -d '{"event_type": "deploy-trigger", "client_payload": {"version": "v1.2.3"}}'
```
🔹 Key Features:

External trigger possible ✅

Cross-repo communication ✅

Custom payloads (data pass कर सकते हैं) ✅

Needs API token 🔐

🔸 Limitation:

कोई built-in input/output handling नहीं (आप payload manually parse करते हैं)

Not type-safe; payload schema आप खुद maintain करते हैं

Jobs chaining manually manage करनी पड़ती है

⚙️ 2️⃣ Reusable Workflow क्या है?
🔸 Concept:

Reusable workflow का मतलब है कि आप एक पूरे workflow (multi-job pipeline) को किसी दूसरे workflow से uses: syntax से call कर सकते हैं —
जैसे function call programming में।

🔹 Typical Use:

एक ही organization या repo में standard CI/CD pipeline reuse करना

DRY principle — repeat ना करना

Inputs/Outputs clearly defined होते हैं

🧱 Example:

Reusable Workflow (.github/workflows/build.yml):
```
on:
  workflow_call:
    inputs:
      env:
        required: true
        type: string

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building for environment ${{ inputs.env }}"
```

Caller Workflow:
```
name: Call reusable workflow

on:
  push:
    branches: [main]

jobs:
  call-build:
    uses: my-org/my-repo/.github/workflows/build.yml@main
    with:
      env: "production"
```
🔹 Key Features:

Built-in input/output system ✅

No API token needed 🚫

Type-safe & versioned (via branch/tag) ✅

Automatic dependency handling between jobs ✅

🔸 Limitation:

Cannot trigger across unrelated repos (unless both public or you use a PAT with permissions)

Works only when workflow is defined with on: workflow_call

Cannot be triggered externally by an API

* how to increase the performance of github actions ?

Cache dependencies (npm, pip, Maven, Gradle, cargo). Restoring cached deps is often the single biggest win.

Use self-hosted runners (or autoscaled pools): more CPU/RAM, pre-warmed caches, persistent Docker images — huge for heavy builds.

Reuse workflows / composite actions to reduce YAML duplication and repeated setup steps.

Avoid expensive steps every run (lint/build/test only on changed packages, run fast linters early and fail fast).


