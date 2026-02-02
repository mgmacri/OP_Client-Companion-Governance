# Setup Node + pnpm Action

Composite action to set up Node.js and pnpm with proper caching for consistent CI environments.

## Usage

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

  - name: Setup Node + pnpm
    uses: ORG/owl-governance/.github/actions/setup-node-pnpm@main
    with:
      node-version: "20"
      pnpm-version: "9"
      working-directory: "app/client-companion"

  - name: Install dependencies
    run: pnpm install --frozen-lockfile
```

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `node-version` | No | `"20"` | Node.js version to install |
| `pnpm-version` | No | `"9"` | pnpm version to install |
| `working-directory` | No | `"."` | Directory containing package.json |
| `registry-url` | No | `""` | Optional npm registry URL |

## Outputs

| Output | Description |
|--------|-------------|
| `node-version` | Installed Node.js version |
| `pnpm-version` | Installed pnpm version |
| `cache-hit` | Whether the pnpm cache was hit |

## Features

- ✅ SHA-pinned actions for supply chain security
- ✅ pnpm store caching for faster installs
- ✅ Consistent tooling across all workflows
- ✅ Support for custom registries

## Example with Registry

```yaml
- name: Setup Node + pnpm
  uses: ORG/owl-governance/.github/actions/setup-node-pnpm@main
  with:
    node-version: "20"
    registry-url: "https://npm.pkg.github.com"
```
