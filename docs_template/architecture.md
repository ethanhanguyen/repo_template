# Architecture — `{PROJECT_NAME}`

## Overview

<!-- One paragraph: what does the system do, at a high level -->

{system_overview}

## Data flow

<!-- Describe the primary data flow through the system -->
<!-- Text or diagram: input → processing → output -->

```
{data_flow_diagram}
```

## Module boundaries

| Module | Responsibility | Inputs | Outputs | Dependencies |
|--------|---------------|--------|---------|--------------|
| `{module_1}` | {description} | {inputs} | {outputs} | {deps} |
| `{module_2}` | {description} | {inputs} | {outputs} | {deps} |

## Key design decisions

| Decision | Rationale | Alternatives considered |
|----------|-----------|------------------------|
| {decision_1} | {why} | {alternatives} |
| {decision_2} | {why} | {alternatives} |

See [decisions/](./decisions/) for full ADRs.

## Tech stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Backend | {backend_framework} | {purpose} |
| Frontend | {frontend_framework} | {purpose} |
| Database | {database} | {purpose} |
| Cache | {cache} | {purpose} |
| Storage | {storage} | {purpose} |
| Queue/Worker | {queue} | {purpose} |
| Monitoring | {monitoring} | {purpose} |
| CI/CD | {cicd} | {purpose} |
| Hosting | {hosting} | {purpose} |

## Scaling model

<!-- Describe scaling strategy: vertical, horizontal, sharding, etc. -->

{scaling_description}
