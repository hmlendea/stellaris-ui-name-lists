# Contributing to Universum Infinitum: Name Lists

Thank you for your interest in contributing to **Universum Infinitum: Name Lists**! This document outlines the process for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Development Workflow](#development-workflow)
  - [Branching Strategy](#branching-strategy)
  - [Commit Messages](#commit-messages)
  - [Testing](#testing)
  - [Code Style](#code-style)
- [License](#license)

## Code of Conduct

This project does not currently have a `CODE_OF_CONDUCT.md` file. Please be respectful and constructive in all interactions.

## Getting Started

### Prerequisites

- bash
- curl
- wget
- unzip
- Internet access (to download the StellarisNameListGenerator tool)

### Development Setup

```bash
# Clone the repository
git clone https://github.com/hmlendea/stellaris-ui-name-lists.git
cd stellaris-ui-name-lists

# Download the StellarisNameListGenerator build tool
bash scripts/update-builder.sh
```

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check the [existing issues](https://github.com/hmlendea/stellaris-ui-name-lists/issues) to avoid duplicates.

When creating a bug report, include:

- A clear, descriptive title
- Steps to reproduce the issue
- Expected vs. actual behaviour
- Your environment (OS, Stellaris version, mod version)
- Relevant log output or screenshots

### Suggesting Enhancements

Enhancement suggestions are welcome. Please open an issue with:

- A clear, descriptive title
- Detailed description of the proposed enhancement
- Rationale for why this would benefit the project
- Any implementation ideas you have

### Pull Requests

1. Fork the repository
2. Create a feature branch from `master`
3. Make your changes
4. Run tests and validation (see [Testing](#testing))
5. Ensure code style compliance (see [Code Style](#code-style))
6. Submit a pull request to `master`

Pull requests should:

- Address a single concern
- Include tests for new functionality
- Update documentation as needed
- Pass all CI checks

## Development Workflow

### Branching Strategy

- `master` — Stable, release-ready code
- Feature branches — `feature/<short-description>`
- Bug fix branches — `fix/<short-description>`
- Documentation branches — `docs/<short-description>`

### Commit Messages

Follow conventional commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat(name-lists): add new elven name list from Divinity

- Add elven.xml to media/divinity/
- Update build script to include new source
```

### Testing

Run the validation script before committing:

```bash
bash scripts/validate-data.sh
```

This validates:
- XML well-formedness and schema compliance
- URL accessibility for external sources
- Duplicate name entries
- Required localisation keys

### Code Style

Shell scripts follow these conventions:

- 4-space indentation (no tabs)
- `set -euo pipefail` at the top of each script
- `[[ ]]` for conditionals (not `[ ]`)
- Descriptive variable names (lower_snake_case)
- Functions for reusable logic
- Comments for non-obvious logic

Validate style with:

```bash
bash scripts/validate-data.sh
```

## License

By contributing to **Universum Infinitum: Name Lists**, you agree that your contributions will be licensed under the **GNU General Public License v3.0** (same as the project).

See [LICENSE](LICENSE) for the full license text.