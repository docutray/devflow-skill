# Development Workflow - TypeScript/Node.js

This file configures the `/devflow:dev` command workflow for TypeScript/Node.js projects.

## Environment Setup

### Dependency Installation
```bash
npm ci
# or for pnpm: pnpm install --frozen-lockfile
# or for yarn: yarn install --frozen-lockfile
```

### Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Generate types (if using Prisma, GraphQL, etc.)
npx prisma generate
# or
npm run codegen
```

### Database Setup (if applicable)
```bash
# Run migrations
npx prisma migrate dev
# or
npm run db:migrate

# Seed database (optional)
npm run db:seed
```

## Development Commands

### Run Development Server
```bash
npm run dev
# or for specific package in monorepo:
npm run dev --filter=web
```

### Run Tests
```bash
# All tests
npm run test
# or directly with vitest
npx vitest run

# Watch mode (auto-reruns on file changes)
npm run test:watch
# or
npx vitest

# Specific test file
npm run test -- path/to/test.spec.ts
# or
npx vitest run path/to/test.spec.ts

# With coverage
npm run test:coverage
# or
npx vitest run --coverage

# UI mode (browser-based test UI)
npx vitest --ui
```

### Code Generation
```bash
# Prisma
npx prisma generate

# GraphQL
npm run codegen

# Other generators
npm run generate
```

## Project Structure

### Code Organization
```
src/
├── components/     # React components (if applicable)
├── lib/           # Shared utilities
├── services/      # Business logic
├── types/         # TypeScript types
└── utils/         # Helper functions
```

### Naming Conventions
- Files: `kebab-case.ts`
- Components: `PascalCase.tsx`
- Utilities: `camelCase.ts`
- Types: `PascalCase.ts` or `camelCase.types.ts`

### Import/Module Structure
```typescript
// External imports
import { useState } from 'react';
import express from 'express';

// Internal imports (absolute)
import { Button } from '@/components/Button';
import { formatDate } from '@/utils/date';

// Relative imports (same directory)
import { localHelper } from './helper';
```

## Best Practices

### Commit Message Format
Follow Conventional Commits:
```
feat: add user authentication
fix: resolve login redirect issue
docs: update API documentation
refactor: simplify data fetching logic
test: add unit tests for user service
chore: update dependencies
```

### Branch Naming
```
feat/issue-123-user-authentication
fix/issue-456-login-bug
refactor/issue-789-data-layer
docs/issue-012-api-docs
```

### Code Style
- Use ESLint and Prettier for consistent formatting
- Follow project's TypeScript strict mode settings
- Use async/await over raw promises
- Prefer named exports over default exports
- Add JSDoc comments for public APIs

## Testing Requirements

### Unit Tests
- Test business logic and utilities
- Mock external dependencies with `vi.mock()` or `vi.fn()`
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)

Example:
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { userService } from './user-service';

describe('UserService', () => {
  beforeEach(() => {
    // Clear mocks before each test
    vi.clearAllMocks();
  });

  it('should create a new user with valid data', async () => {
    // Arrange
    const userData = { email: 'test@example.com', name: 'Test' };

    // Act
    const user = await userService.create(userData);

    // Assert
    expect(user.email).toBe(userData.email);
    expect(user.id).toBeDefined();
  });
});
```

### Integration Tests
- Test API endpoints
- Test database interactions
- Use test database/containers
- Consider using `@vitest/ui` for visual debugging

### Test Coverage

**Minimum coverage: 80%**
- Statements: > 80%
- Branches: > 75%
- Functions: > 80%
- Lines: > 80%

**Generate Coverage Report**:
```bash
# Run tests with coverage
npx vitest run --coverage

# Coverage providers (choose one)
# - @vitest/coverage-v8 (default, faster)
# - @vitest/coverage-istanbul (more accurate)

# View HTML report
open coverage/index.html
```

**Coverage Configuration** (vitest.config.ts):
```typescript
export default {
  test: {
    coverage: {
      provider: 'v8', // or 'istanbul'
      reporter: ['text', 'json', 'html', 'lcov'],
      exclude: [
        'node_modules/',
        'test/',
        '**/*.spec.ts',
        '**/*.test.ts',
        '**/types/',
      ],
      thresholds: {
        statements: 80,
        branches: 75,
        functions: 80,
        lines: 80,
      },
    },
  },
};
```

## Common Tasks

### Adding Dependencies
```bash
npm install <package>
npm install -D <dev-package>

# Update package-lock.json
npm install
```

### Updating Dependencies
```bash
# Check outdated
npm outdated

# Update specific package
npm update <package>

# Update all
npm update
```

### Debugging

**Using Vitest Debugging**:
```bash
# Debug mode with Node inspector
npx vitest --inspect-brk --single-thread

# Run single test file in debug mode
npx vitest run path/to/test.spec.ts --inspect-brk
```

**VS Code Debugging**:

Add to `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Vitest Tests",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "test"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Current Test File",
      "runtimeExecutable": "npx",
      "runtimeArgs": [
        "vitest",
        "run",
        "${file}",
        "--inspect-brk"
      ],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    }
  ]
}
```

**Browser Debugging with Vitest UI**:
```bash
# Launch interactive test UI in browser
npx vitest --ui

# UI with coverage
npx vitest --ui --coverage
```

## Troubleshooting

### Type Errors
- Run `npm run type-check` to see all type errors
- Ensure `@types/*` packages are installed
- Check tsconfig.json configuration

### Test Failures
- Run single test: `npx vitest run path/to/test.spec.ts`
- Run with verbose output: `npx vitest run --reporter=verbose`
- Clear Vitest cache: `rm -rf node_modules/.vitest`
- Check test environment setup in `vitest.config.ts`
- Use UI mode for debugging: `npx vitest --ui`
- Check for TypeScript errors in test files: `npx tsc --noEmit`

### Build Errors
- Clear cache/build artifacts: `rm -rf .next dist build`
- Reinstall dependencies: `rm -rf node_modules && npm ci`
- Check for TypeScript errors: `npm run type-check`
