# Testing Guide — `{PROJECT_NAME}`

## Layer boundaries

| Layer | Scope | Mocks | Speed | Count |
|-------|-------|-------|-------|-------|
| Unit | Single function/class | All dependencies | Fast | Many |
| Integration | Multiple modules together | External services only | Medium | Moderate |
| E2E | Full system | Nothing | Slow | Few |
| Benchmark | Performance-critical paths | Varies | Medium | Selective |

## Positive patterns

### Test behavior, not structure

```python
# Good: test what the function DOES
def test_returns_zero_for_empty_input():
    assert calculate_total([]) == 0

# Bad: test how the function IS BUILT
def test_calculate_total_calls_sum():
    ...
```

### One behavior per test

Each test verifies exactly one thing. Use parametrization for variants.

```python
@pytest.mark.parametrize("input,expected", [
    ([], 0),
    ([1], 1),
    ([1, 2, 3], 6),
])
def test_calculate_total(input, expected):
    assert calculate_total(input) == expected
```

### Test failure modes

```python
def test_raises_on_negative_input():
    with pytest.raises(ValueError, match="must be non-negative"):
        calculate(-1)
```

### Shared fixtures

```python
@pytest.fixture
def sample_data():
    return {"key": "value"}
```

## Assertion quality

| Avoid | Prefer |
|-------|--------|
| `assert True` | Assert the actual value |
| `assert len(x) == 3` | `assert x == expected_list` |
| `assert response.status_code == 200` ONLY | Also assert response body shape |
| Multiple unrelated asserts in one test | Split into separate tests |

## Anti-pattern catalog

| Anti-pattern | Why it's bad | Fix |
|-------------|-------------|-----|
| Testing private methods | Tests coupled to implementation | Test through public API only |
| Mocking what you don't own | Mock diverges from real behavior | Wrap in adapter, mock adapter |
| Testing the mock | No system under test exercised | Verify SUT behavior, not mock calls |
| Time-dependent tests | Flaky results | Inject clock/use freezegun |
| Order-dependent tests | Hidden coupling | Each test sets up its own state |
| `sleep()` in tests | Slow + flaky | Await conditions, mock time |
| Testing config values | Testing framework, not code | Test behavior that uses config |
| Snapshot testing everything | Brittle on any change | Snapshot only stable output |
| Over-mocking | Code that never runs real | Mock at boundaries, not internals |
| Missing assertions | Test can't fail | Always assert something meaningful |

## Test structure template

```python
# Arrange — set up test data and state
# Act — call the system under test
# Assert — verify the outcome
# (Optional) Cleanup — if needed

def test_{function}_{scenario}():
    # Arrange
    input_data = ...

    # Act
    result = some_function(input_data)

    # Assert
    assert result == expected
```

## Rejection triggers (grep-based)

Before submitting code, grep for these anti-patterns:

| Grep pattern | Problem |
|-------------|---------|
| `{sleep_pattern}` | Hardcoded sleep in tests |
| `{mock_not_called}` | Possibly testing the mock, not the behavior |
| `{bare_assert_true}` | Assert without verification |
| `{missing_assert_in_test}` | Test with no assertions |
| `{test_specific_impl}` | Testing private/internal methods |
| `{env_read_in_test}` | Tests reading environment directly |

## Coverage targets

| Layer | Target |
|-------|--------|
| New code (all layers) | >=90% |
| Integration modules | >=80% |
| Overall project | >=85% |
