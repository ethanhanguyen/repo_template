# Quickstart — `{PROJECT_NAME}`

## Prerequisites

<!-- List required tools with versions -->
- {language} `{version}+`
- {package_manager} (`{install_command}`)
- {database} (`{install_command}`)
- {additional_tools}

## Install

```bash
git clone {repo_url}
cd {project_dir}
{install_command}
```

## Environment

```bash
cp .env.example .env
# Fill in required values:
#   {ENV_VAR_1} — {description}
#   {ENV_VAR_2} — {description}
```

```bash
# Verify setup
{verify_command}
```

## First run

```bash
# Start services
{start_command}
```

Expected output:
```
{expected_output}
```

## Walkthrough

<!-- Step-by-step walkthrough of core user flow -->

1. **{Step 1}**: {description and command}
2. **{Step 2}**: {description and command}
3. **{Step 3}**: {description}

## Common operations

| Task | Command |
|------|---------|
| Run tests | `{test_command}` |
| Lint | `{lint_command}` |
| Typecheck | `{typecheck_command}` |
| Build | `{build_command}` |
| Deploy | `{deploy_command}` |

## Docker (if applicable)

```bash
docker compose up -d
```

## Cloud deploy (if applicable)

```bash
{cloud_deploy_command}
```

## Next steps

- Read [architecture.md](./architecture.md) for system overview
- Read [contributing.md](./contributing.md) for development workflow
- Check [plans/progress.md](./plans/progress.md) for current status
