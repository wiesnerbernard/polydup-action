# Deployment Guide for PolyDup GitHub Action

## Prerequisites

- GitHub account with repository creation permissions
- Docker Hub account (optional, for pre-built images)
- Git installed locally

## Step 1: Create GitHub Repository

```bash
# Create new repository on GitHub
# Name: polydup-action
# Description: Detect duplicate code across multiple languages in your Pull Requests
# Public repository (required for GitHub Marketplace)
```

Or use GitHub CLI:

```bash
gh repo create wiesnerbernard/polydup-action --public --description "Detect duplicate code across multiple languages in your Pull Requests"
```

## Step 2: Push Action Files

```bash
cd /Users/bernardwiesner/Documents/dev/personal/polydup/polydup-action

# Initialize git repository
git init
git add .
git commit -m "feat: initial commit - PolyDup GitHub Action v1.0.0

- Dockerfile with polydup-cli v0.5.0
- Action metadata with inputs/outputs
- Entrypoint script with git-diff integration
- PR comment support
- Comprehensive README with examples"

# Add remote and push
git remote add origin https://github.com/wiesnerbernard/polydup-action.git
git branch -M main
git push -u origin main
```

## Step 3: Create Release Tags

```bash
# Tag for Marketplace
git tag -a v1 -m "Release v1.0.0: Initial release

Features:
- Git-Diff Mode integration (10-100x faster)
- Multi-language support (JS/TS/Python/Rust)
- PR comment support
- Configurable thresholds
- Exit code integration"

git tag -a v1.0.0 -m "Release v1.0.0"

# Push tags
git push origin v1 v1.0.0
```

## Step 4: Publish to GitHub Marketplace

1. Go to: https://github.com/wiesnerbernard/polydup-action
2. Click "Draft a release"
3. Select tag: `v1.0.0`
4. Release title: "v1.0.0 - Initial Release"
5. Description: (copy from tag message)
6. Check: **"Publish this Action to the GitHub Marketplace"**
7. Choose categories:
   - Code Quality
   - Testing
   - Continuous Integration
8. Click "Publish release"

## Step 5: Test the Action

Create a test workflow in any repository:

```yaml
# .github/workflows/test-polydup.yml
name: Test PolyDup

on:
  pull_request:
    branches: [ main ]

jobs:
  duplicate-detection:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - uses: wiesnerbernard/polydup-action@v1
        with:
          threshold: 50
          similarity: 0.85
```

## Step 6: Update Main Polydup README

Add GitHub Action section to main repository README:

```markdown
## GitHub Action

Use PolyDup in your CI/CD pipeline:

```yaml
- uses: wiesnerbernard/polydup-action@v1
  with:
    threshold: 50
    similarity: 0.85
    fail-on-duplicates: true
```

See [polydup-action](https://github.com/wiesnerbernard/polydup-action) for details.
```

## Step 7: Promote

1. Add badge to main README:
```markdown
[![GitHub Action](https://img.shields.io/badge/Action-PolyDup-blue.svg?logo=github)](https://github.com/marketplace/actions/polydup-code-duplicate-detector)
```

2. Tweet/post announcement
3. Add to awesome-actions lists
4. Submit to GitHub Marketplace newsletter

## Maintenance

### Update to New Version

```bash
# Make changes to action files
git add .
git commit -m "feat: update to polydup-cli v0.6.0"

# Create new tags
git tag -a v1.1.0 -m "Release v1.1.0"
git tag -f v1  # Move v1 to latest
git push origin v1.1.0
git push origin v1 --force
```

### Monitor Usage

- Check GitHub Action insights
- Monitor issues/discussions
- Track Marketplace stats

## Troubleshooting

### Docker Build Fails

- Check Dockerfile syntax
- Verify cargo install works with specified version
- Test locally: `docker build -t polydup-action .`

### Action Not Appearing in Marketplace

- Ensure repository is public
- Verify action.yml syntax
- Check that release is published to Marketplace

### PR Comments Not Posting

- Verify token has `pull-requests: write` permission
- Check GITHUB_TOKEN is passed correctly
- Review action logs for API errors

## Cost Considerations

- **Free**: For public repositories
- **Included**: GitHub Actions minutes for private repos (2000 min/month on free plan)
- **Docker Hub**: Optional - can use GitHub Container Registry instead

## Next Steps

After successful deployment:

1. Create example repositories showcasing the action
2. Write blog post about the release
3. Submit to newsletters/aggregators
4. Gather user feedback
5. Iterate based on usage patterns
