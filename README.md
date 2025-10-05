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
