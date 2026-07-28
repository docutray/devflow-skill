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
      "command": "CHANGE=$(git branch --show-current | sed 's|.*/||'); test -d openspec/changes/$CHANGE && openspec status --change $CHANGE",
      "description": "OPSX: check current change status",
      "enabled": false
    },
    "opsx_validate": {
      "command": "CHANGE=$(git branch --show-current | sed 's|.*/||'); test -d openspec/changes/$CHANGE && openspec validate $CHANGE --strict",
      "description": "OPSX: validate the change against its specs (pre-PR gate)",
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
