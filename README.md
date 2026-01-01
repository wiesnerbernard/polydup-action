# PolyDup GitHub Action

Automatically detect duplicate code across multiple languages in your Pull Requests.

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-PolyDup-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=github)](https://github.com/marketplace/actions/polydup-code-duplicate-detector)
[![Test Action](https://github.com/wiesnerbernard/polydup-action/actions/workflows/test-action.yml/badge.svg)](https://github.com/wiesnerbernard/polydup-action/actions/workflows/test-action.yml)
[![License](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](../LICENSE)

## Features

- **10-100x faster** than traditional approaches using Git-Diff Mode
- **Multi-language support**: JavaScript, TypeScript, Python, Rust, and more
- **Smart detection**: Finds Type-1 (exact), Type-2 (renamed), and Type-3 (near-miss) clones
- **PR comments**: Automatic feedback on pull requests
- **Configurable**: Adjust thresholds and similarity levels
- **Secure**: No data leaves your repository
- **Cross-platform**: Works on Ubuntu, macOS, and Windows

## Quick Start

Add this to your `.github/workflows/code-quality.yml`:

```yaml
name: Code Quality

on:
  pull_request:
    branches: [ main, master ]

permissions:
  contents: read
  pull-requests: write  # Required for PR comments

jobs:
  duplicate-detection:
    runs-on: ubuntu-latest
    name: Detect Duplicate Code

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Required for git-diff comparison

      - name: Run PolyDup
        uses: wiesnerbernard/polydup-action@v1
        with:
          threshold: 50
          similarity: 0.85
          fail-on-duplicates: true
```

## Required Permissions

For PR comments to work, your workflow needs these permissions:

```yaml
permissions:
  contents: read       # Required to read repository content
  pull-requests: write # Required to post PR comments
```

## Inputs

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `threshold` | Minimum code block size in tokens | `50` | No |
| `similarity` | Similarity threshold (0.0-1.0) | `0.85` | No |
| `fail-on-duplicates` | Fail the check if duplicates are found | `true` | No |
| `format` | Output format: `text` or `json` | `text` | No |
| `base-ref` | Base git reference for comparison | Auto-detect | No |
| `github-token` | GitHub token for PR comments | `${{ github.token }}` | No |
| `comment-on-pr` | Post results as PR comment | `true` | No |
| `polydup-version` | Version of polydup to install | `latest` | No |
| `working-directory` | Working directory for scanning | `.` | No |
| `scan-mode` | Scan mode: `git-diff` (only changed files) or `full` (all files) | `git-diff` | No |

## Outputs

| Output | Description |
|--------|-------------|
| `duplicates-found` | Number of duplicate code blocks found |
| `files-scanned` | Number of files scanned |
| `exit-code` | Exit code from polydup (see Exit Codes below) |

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success - no duplicates found (or duplicates found but `fail-on-duplicates: false`) |
| `1` | Duplicates found with `fail-on-duplicates: true` |
| `2` | Error occurred (git failure, invalid configuration, etc.) |

## Usage Examples

### Basic Usage

Detect duplicates with default settings:

```yaml
- name: Detect Duplicates
  uses: wiesnerbernard/polydup-action@v1
```

### Strict Mode

Lower threshold for stricter duplicate detection:

```yaml
- name: Strict Duplicate Detection
  uses: wiesnerbernard/polydup-action@v1
  with:
    threshold: 30
    similarity: 0.90
    fail-on-duplicates: true
```

### Warning Mode

Report duplicates but don't fail the build:

```yaml
- name: Duplicate Code Report
  uses: wiesnerbernard/polydup-action@v1
  with:
    fail-on-duplicates: false
    comment-on-pr: true
```

### Custom Base Branch

Compare against a specific branch:

```yaml
- name: Compare Against Develop
  uses: wiesnerbernard/polydup-action@v1
  with:
    base-ref: origin/develop
```

### Pin Polydup Version

Use a specific version of polydup for reproducibility:

```yaml
- name: Detect Duplicates
  uses: wiesnerbernard/polydup-action@v1
  with:
    polydup-version: '0.8.1'
```

### Monorepo Support

Scan a specific subdirectory:

```yaml
- name: Detect Duplicates in Backend
  uses: wiesnerbernard/polydup-action@v1
  with:
    working-directory: packages/backend
```

### Without PR Comments

Disable automatic PR commenting:

```yaml
- name: Detect Duplicates (No Comments)
  uses: wiesnerbernard/polydup-action@v1
  with:
    comment-on-pr: false
```

### Use Outputs in Subsequent Steps

```yaml
- name: Detect Duplicates
  id: polydup
  uses: wiesnerbernard/polydup-action@v1
  with:
    fail-on-duplicates: false

- name: Check Results
  run: |
    echo "Duplicates found: ${{ steps.polydup.outputs.duplicates-found }}"
    echo "Files scanned: ${{ steps.polydup.outputs.files-scanned }}"

    if [ "${{ steps.polydup.outputs.duplicates-found }}" -gt 10 ]; then
      echo "Too many duplicates detected!"
      exit 1
    fi
```

## Complete Workflow Example

```yaml
name: Code Quality Checks

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

permissions:
  contents: read
  pull-requests: write

jobs:
  code-quality:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run Tests
        run: npm test

      - name: Run Linter
        run: npm run lint

      - name: Detect Duplicate Code
        uses: wiesnerbernard/polydup-action@v1
        with:
          threshold: 50
          similarity: 0.85
          fail-on-duplicates: true
          comment-on-pr: true
```

## How It Works

1. **Git-Diff Mode**: Only scans files changed in your PR (10-100x faster than full scans)
2. **Multi-Language Parsing**: Uses Tree-sitter for accurate syntax-aware detection
3. **Smart Normalization**: Detects duplicates even when variable/function names differ
4. **PR Integration**: Automatically posts results as PR comments

## Supported Languages

- JavaScript / TypeScript
- Python
- Rust
- JSX / TSX
- Vue (JavaScript/TypeScript sections)
- Svelte (JavaScript/TypeScript sections)

More languages coming soon!

## Configuration Tips

### Threshold

- **Small projects** (< 10K LOC): Use `30-40` tokens
- **Medium projects** (10K-100K LOC): Use `50-60` tokens (default)
- **Large projects** (> 100K LOC): Use `70-100` tokens

### Similarity

- **Strict** (minimize false positives): `0.90-1.0`
- **Balanced** (recommended): `0.85` (default)
- **Lenient** (catch more candidates): `0.75-0.85`

## Performance

**Real-world benchmarks:**

| Project Size | Files Changed | Scan Time | Speedup |
|--------------|---------------|-----------|---------|
| 10K LOC | 5 files | 0.05s | 50x faster |
| 50K LOC | 15 files | 0.3s | 80x faster |
| 200K LOC | 30 files | 1.2s | 100x faster |

*Compared to full codebase scans*

## Troubleshooting

### Action fails with "fatal: Invalid revision range"

**Solution**: Ensure `fetch-depth: 0` in checkout step:

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0
```

### No duplicates detected in PR

**Possible causes**:
- The action only scans changed files. If no files changed, no duplicates will be found.
- Files don't contain functions (polydup detects duplicate functions, not arbitrary text)
- Threshold is too high for the code blocks in question

### PR comment not posting

**Solution**: Ensure the workflow has proper permissions:

```yaml
permissions:
  contents: read
  pull-requests: write
```

Also verify `comment-on-pr: true` (the default).

### "Resource not accessible by integration" error

**Solution**: This happens when the workflow lacks `pull-requests: write` permission. Add it to your workflow:

```yaml
permissions:
  contents: read
  pull-requests: write
```

### Action exits with code 2

**Cause**: An error occurred (not related to finding duplicates). Common causes:
- Invalid git reference in `base-ref`
- Missing `fetch-depth: 0` in checkout
- Invalid threshold or similarity values

Check the action logs for specific error messages.

### Slow first run

**Cause**: On first run, the action installs polydup via `cargo install`. Subsequent runs use a cached binary and are much faster.

## Local Testing

Test the action locally using [act](https://github.com/nektos/act):

```bash
# Install act
brew install act

# Run action locally
act pull_request -j duplicate-detection
```

## CLI Usage

Want to use PolyDup outside GitHub Actions? Install the CLI:

```bash
cargo install polydup

# Scan your code
polydup scan . --git-diff origin/main..HEAD
```

See the [main repository](https://github.com/wiesnerbernard/polydup) for more details.

## Contributing

We welcome contributions! See our [Contributing Guide](https://github.com/wiesnerbernard/polydup/blob/master/CONTRIBUTING.md).

## License

Licensed under either of:

- Apache License, Version 2.0 ([LICENSE-APACHE](../LICENSE-APACHE))
- MIT license ([LICENSE-MIT](../LICENSE-MIT))

at your option.

## Support

- [Documentation](https://github.com/wiesnerbernard/polydup)
- [Report Issues](https://github.com/wiesnerbernard/polydup-action/issues)
- [Discussions](https://github.com/wiesnerbernard/polydup/discussions)

---

Made with ❤️ by the PolyDup Contributors
