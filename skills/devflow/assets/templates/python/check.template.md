# DevFlow Validation Configuration - Python

This file configures the DevFlow validation workflow for Python projects. It applies in any client, whether DevFlow is invoked in natural language or through the optional `/devflow:check` command.

## Validation Configuration

```json
{
  "validations": {
    "tests": {
      "command": "pytest -v",
      "description": "Pytest test suite",
      "enabled": true
    },
    "lint": {
      "command": "flake8 . && black --check . && isort --check .",
      "description": "Code quality (flake8, black, isort)",
      "enabled": true
    },
    "typecheck": {
      "command": "mypy .",
      "description": "Type checking with mypy",
      "enabled": true
    }
  }
}
```

## Customization Guide

### Test Command
- Default: `pytest -v`
- With coverage: `pytest --cov=. --cov-report=html`
- Specific module: `pytest tests/test_module.py`
- Parallel execution: `pytest -n auto` (requires pytest-xdist)
- With markers: `pytest -m "not slow"`

### Lint Command
Multiple tools for comprehensive code quality:

**flake8** (PEP 8 compliance):
```bash
flake8 .
# or with config:
flake8 --config=.flake8 .
```

**black** (code formatting):
```bash
black --check .
# or to fix:
black .
```

**isort** (import sorting):
```bash
isort --check .
# or to fix:
isort .
```

**Combined**:
```bash
flake8 . && black --check . && isort --check .
```

**Alternative with ruff** (faster all-in-one):
```bash
ruff check .
```

### Type Check Command
- Default: `mypy .`
- Specific package: `mypy src/`
- Strict mode: `mypy --strict .`
- With config: `mypy --config-file=mypy.ini .`

## Additional Validations

You can add custom validations:

```json
{
  "validations": {
    "...": "...",
    "opsx_status": {
      "command": "CHANGE=${DEVFLOW_OPENSPEC_CHANGE:-$(git branch --show-current | sed 's|.*/||')}; if openspec status --change \"$CHANGE\" --json >/dev/null 2>&1; then openspec status --change \"$CHANGE\"; else echo \"No active OpenSpec change named $CHANGE\"; fi",
      "description": "OPSX: check current change status",
      "enabled": false
    },
    "opsx_validate": {
      "command": "CHANGE=${DEVFLOW_OPENSPEC_CHANGE:-$(git branch --show-current | sed 's|.*/||')}; if ! command -v openspec >/dev/null 2>&1; then echo \"opsx_validate: openspec CLI not found on PATH\" >&2; (exit 2); elif [ -n \"$CHANGE\" ] && openspec status --change \"$CHANGE\" --json >/dev/null 2>&1; then openspec validate \"$CHANGE\" --strict; elif [ -n \"$CHANGE\" ] && openspec list --archived --json 2>/dev/null | sed -n 's/^ *\"name\": *\"[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}-\\(.*\\)\",*$/\\1/p' | grep -Fqx -- \"$CHANGE\"; then echo \"opsx_validate: change '$CHANGE' is archived; validating the main specs\" >&2; openspec validate --specs --strict; elif ! ACTIVE=$(openspec list --json 2>/dev/null); then echo \"opsx_validate: openspec list failed\" >&2; (exit 2); elif ! printf '%s\\n' \"$ACTIVE\" | grep -q '\"name\":'; then echo \"opsx_validate: no active OpenSpec change; validating the main specs\" >&2; openspec validate --specs --strict; else echo \"opsx_validate: no active or archived OpenSpec change named '${CHANGE:-<none: detached HEAD>}' while other changes are active; name the branch after its change or set DEVFLOW_OPENSPEC_CHANGE\" >&2; (exit 2); fi",
      "description": "OPSX: validate the branch's change, or the main specs when it is archived or no change is active; exits 2 on broken configuration (pre-PR gate)",
      "enabled": false
    },
    "security": {
      "command": "bandit -r . -ll",
      "description": "Security vulnerability scan",
      "enabled": false
    },
    "complexity": {
      "command": "radon cc . -a",
      "description": "Code complexity analysis",
      "enabled": false
    },
    "dependencies": {
      "command": "safety check",
      "description": "Dependency security check",
      "enabled": false
    }
  }
}
```

## Virtual Environment

Ensure commands run in virtual environment:

```json
{
  "validations": {
    "tests": {
      "command": "source venv/bin/activate && pytest -v",
      "description": "Pytest test suite",
      "enabled": true
    }
  }
}
```

Or use poetry:

```json
{
  "validations": {
    "tests": {
      "command": "poetry run pytest -v",
      "description": "Pytest test suite",
      "enabled": true
    },
    "lint": {
      "command": "poetry run flake8 . && poetry run black --check . && poetry run isort --check .",
      "description": "Code quality validation",
      "enabled": true
    }
  }
}
```

## Django Projects

For Django projects:

```json
{
  "validations": {
    "tests": {
      "command": "python manage.py test",
      "description": "Django test suite",
      "enabled": true
    },
    "lint": {
      "command": "flake8 . && black --check . && isort --check .",
      "description": "Code quality",
      "enabled": true
    },
    "typecheck": {
      "command": "mypy .",
      "description": "Type checking",
      "enabled": true
    },
    "migrations": {
      "command": "python manage.py makemigrations --check --dry-run",
      "description": "Check for missing migrations",
      "enabled": true
    }
  }
}
```

## FastAPI Projects

For FastAPI projects:

```json
{
  "validations": {
    "tests": {
      "command": "pytest -v --cov=app",
      "description": "API test suite with coverage",
      "enabled": true
    },
    "lint": {
      "command": "ruff check . && black --check .",
      "description": "Code quality",
      "enabled": true
    },
    "typecheck": {
      "command": "mypy app/",
      "description": "Type checking",
      "enabled": true
    }
  }
}
```
