# Contributing to Universum Infinitum: Name Lists

This document covers the guidelines and processes for contributing to this project, including how to report issues, suggest enhancements, submit code changes, and follow project standards.

## 📑 Table of Contents

- [How to Contribute](#how-to-contribute)
  - [Reporting Issues](#reporting-issues)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Code Contributions](#code-contributions)
    - [Prerequisites](#prerequisites)
    - [Development Setup](#development-setup)
    - [Making Changes](#making-changes)
    - [Pull Request Guidelines](#pull-request-guidelines)
  - [Testing](#testing)
  - [Documentation](#documentation)
- [Code of Conduct](#code-of-conduct)
- [Security](#security)
- [License](#license)
- [Getting Assistance](#getting-assistance)

## 🤝 How to Contribute

### Reporting Issues

- Search existing issues first.
- Use the issue templates if available.
- Provide clear reproduction steps.
- Include environment details.

### Suggesting Enhancements

- Check the roadmap and existing discussions.
- Explain the use case and expected behaviour.
- Consider implementation complexity.

### Code Contributions

#### Prerequisites

- `bash`, `curl`, `wget`, and `unzip`
- Internet access to download the StellarisNameListGenerator build tool

#### Development Setup

```bash
# Clone the repository
git clone https://github.com/hmlendea/stellaris-ui-name-lists.git
cd stellaris-ui-name-lists

# Install dependencies
bash scripts/update-builder.sh
```

#### Making Changes

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes.
4. Run tests: `bash scripts/validate-data.sh`
5. Commit with clear and descriptive messages.
6. Push to your fork.
7. Open a Pull Request.

#### Pull Request Guidelines

- Target the `master` branch.
- Keep PRs focused and atomic.
- Revise documentation if applicable.
- Include tests for any new functionality.
- Ensure the CI checks pass.

### Testing

```bash
# Run all tests
bash scripts/validate-data.sh

# Run specific test suite
bash scripts/validate-data.sh
```

### Documentation

- Revise relevant docs for changes.
- Follow the documentation style guide.
- Preview changes locally if possible.

## 📋 Code of Conduct

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).

## 🔒 Security

Report security vulnerabilities per the [Security Policy](SECURITY.md).

## 📄 License

By contributing, you agree that your contributions will be licensed under the GNU General Public License v3.0.

## ❓ Getting Assistance

- [GitHub Issues](https://github.com/hmlendea/stellaris-ui-name-lists/issues)
- Check existing discussions and documentation first.