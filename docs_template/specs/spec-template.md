# {Feature Name} — Specification v{version}

## Overview

<!-- One paragraph: what does this feature do? -->

{overview}

## Status

<!-- Draft / In Review / Approved / Implemented -->

{status}

## Requirements

### Functional

- [ ] FR1: {requirement}
- [ ] FR2: {requirement}
- [ ] FR3: {requirement}

### Non-functional

- [ ] NFR1: {performance requirement}
- [ ] NFR2: {security requirement}
- [ ] NFR3: {reliability requirement}

## API endpoints (if applicable)

| Method | Path | Description | Request | Response |
|--------|------|-------------|---------|----------|
| GET | `/api/{path}` | {desc} | — | `{response_schema}` |
| POST | `/api/{path}` | {desc} | `{request_schema}` | `{response_schema}` |

## Data model (if applicable)

```
{data_model_diagram_or_schema}
```

## Components (if applicable)

### {Component A}

- **Purpose**: {description}
- **Props/Inputs**: `{type_signature}`
- **State**: `{state_description}`
- **Edge cases**: {edge_case_handling}

## Error handling

| Scenario | Code | Response |
|----------|------|----------|
| {error_scenario_1} | {status_code} | `{error_body}` |
| {error_scenario_2} | {status_code} | `{error_body}` |

## Dependencies

- {dependency_1}
- {dependency_2}

## Open questions

- {question_1}
- {question_2}

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | {date} | Initial spec |
