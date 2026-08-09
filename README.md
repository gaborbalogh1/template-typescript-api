# template-typescript-api

Forge — Express + TypeScript REST API starter (strict tsconfig, Zod, Pino, Docker, GitHub Actions CI)

A real, working TypeScript API — strict compiler settings, a genuinely Zod-validated route
(not just an unused import), and a Docker/Terraform deploy path that actually runs.

## What's actually here

- `src/index.ts` — the Express app; `POST /echo` demonstrates real Zod request validation
- `src/lambda.ts` — wraps the same app for Lambda via `serverless-http`
- `infrastructure/lambda/` / `infrastructure/ecs-fargate/` — real Terraform, using Gabaltech's
  own `terraform-aws-serverless` / `terraform-aws-ecs` modules
- `.github/workflows/deploy.yml` — builds the real compiled output/image and deploys it

## Run locally

```bash
npm install
npm run build && npm start   # http://localhost:3000
npm test                     # builds, then node --test against the compiled output
```

## Deploy

Trigger the `Deploy` workflow (`workflow_dispatch`) with:

| Input | Required | Notes |
|-------|----------|-------|
| `service_name` | yes | Lowercase, hyphens only |
| `environment` | yes | `dev` / `test` / `prod` |
| `compute` | no | `lambda` (default) or `ecs-fargate` |
| `node_version` | no | `20` or `22`, default `22` |
| `region` | no | Defaults to `eu-west-2` |
| `cluster_arn`, `vpc_id`, `subnet_ids`, `security_group_ids`, `ecr_repository_url` | ECS Fargate only | An existing cluster/VPC to deploy into — this template doesn't provision networking itself. `subnet_ids`/`security_group_ids` are comma-separated. |

Requires `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` repo secrets.

### Lambda path

`tsc` compiles to `dist/`, `npm prune --omit=dev` strips dev dependencies, then the workflow
zips `dist/` + `node_modules` and pushes it via `aws lambda update-function-code`. Terraform
owns the function's existence/config (handler: `dist/lambda.handler`), not its code.

### ECS Fargate path

Builds the multi-stage Docker image, pushes it to the ECR repository you supply, applies
Terraform with that image tag. Needs an existing ECS cluster and VPC.
