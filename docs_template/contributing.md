# Contributing — `{PROJECT_NAME}`

## Local setup

```bash
git clone {repo_url}
cd {project_dir}
{install_command}
cp .env.example .env
# Fill in required env vars
{verify_command}
```

## Directory structure

```
├── src/                  # Source code
│   ├── {module_1}/       # {description}
│   ├── {module_2}/       # {description}
│   └── ...
├── tests/                # Test suite
├── docs/                 # Documentation (you are here)
├── scripts/              # Utility scripts
├── {config_file}         # {description}
└── ...
```

## Testing

```bash
# Run all tests with coverage
{test_cmd}

# Run specific test file
{test_cmd_single} tests/{path}

# Coverage targets
#   Unit:   >=90%
#   Integration: >=80%
#   E2E:    smoke tests pass
```

## Commit conventions

This project uses [Conventional Commits](https://www.conventionalcommits.org/).

```
<type>: <description>

[optional body]
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `ci`, `chore`, `perf`

## Branch naming

```
pr<N>-<description>
```

Example: `pr1-config-logging`, `pr2-user-auth`

## PR workflow

1. Create branch from `main`
2. Write tests first (TDD)
3. Implement changes
4. Run full test suite + lint + typecheck locally
5. Run code review checklist (`docs/code-review.md`) — all 4 phases, zero rejection triggers
6. Commit with conventional commit message
7. Open PR with the `docs/PR-template.md` format
8. Auto merge when all gates passed and CI is green (`gh pr merge --auto --squash`)

## Environment variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `{ENV_1}` | Yes | — | {description} |
| `{ENV_2}` | No | `{default}` | {description} |

Secrets must never be committed. Use `.env` (gitignored) for local development.
