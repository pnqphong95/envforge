---
sidebar_position: 2
---

# Custom Bundles

Advanced techniques for creating sophisticated bundle configurations.

## Advanced Bundle Patterns

### Pattern 1: Layered Architecture

Organize bundles in layers:

**bundles/base.yaml**:
```yaml
name: "Base System"
description: "Essential system tools"
tools:
  - build-essential:
  - git:
  - curl:
  - wget:
```

**bundles/development.yaml**:
```yaml
name: "Development Environment"
description: "Base + development tools"
tools:
  # Include base tools
  - build-essential:
  - git:
  - curl:
  - wget:
  
  # Add development tools
  - nodejs:
      depends_on:
        - build-essential
  - python3:
      depends_on:
        - build-essential
  - docker:
      depends_on:
        - build-essential
```

### Pattern 2: Role-Based Bundles

Create bundles for different roles:

**bundles/backend-developer.yaml**:
```yaml
name: "Backend Developer"
tools:
  - git:
  - nodejs:
  - postgresql:
  - redis:
  - docker:
```

**bundles/frontend-developer.yaml**:
```yaml
name: "Frontend Developer"
tools:
  - git:
  - nodejs:
  - vscode:
  - chrome:
```

**bundles/devops-engineer.yaml**:
```yaml
name: "DevOps Engineer"
tools:
  - git:
  - docker:
  - kubectl:
  - terraform:
  - ansible:
```

### Pattern 3: Environment-Specific

**bundles/development.yaml**:
```yaml
name: "Development"
tools:
  - git:
  - nodejs:
  - docker:
  - vscode:
  - dev-certificates:
```

**bundles/staging.yaml**:
```yaml
name: "Staging"
tools:
  - git:
  - nodejs:
  - docker:
  - monitoring-agent:
```

**bundles/production.yaml**:
```yaml
name: "Production"
tools:
  - git:
  - nodejs:
  - docker:
  - monitoring-agent:
  - security-hardening:
```

## Complex Dependency Graphs

### Multi-Level Dependencies

```yaml
name: "Complex Application Stack"
tools:
  # Level 1: Base
  - build-essential:
  
  # Level 2: Languages
  - nodejs:
      depends_on:
        - build-essential
  - python3:
      depends_on:
        - build-essential
  
  # Level 3: Databases
  - postgresql:
      depends_on:
        - build-essential
  - redis:
      depends_on:
        - build-essential
  
  # Level 4: Application tools
  - backend-app:
      depends_on:
        - nodejs
        - postgresql
        - redis
  - data-processor:
      depends_on:
        - python3
        - postgresql
  
  # Level 5: Monitoring
  - monitoring:
      depends_on:
        - backend-app
        - data-processor
```

### Diamond Dependencies

```yaml
name: "Diamond Pattern"
tools:
  - base:
  
  - tool-a:
      depends_on:
        - base
  
  - tool-b:
      depends_on:
        - base
  
  - final-tool:
      depends_on:
        - tool-a
        - tool-b
```

Execution order:
1. `base`
2. `tool-a`, `tool-b` (parallel)
3. `final-tool`

## Dynamic Bundle Generation

### Using Environment Variables

Create a script to generate bundles:

**scripts/generate-bundle.sh**:
```bash
#!/bin/bash

ENV_TYPE="${1:-development}"

cat > "bundles/generated-${ENV_TYPE}.yaml" <<EOF
name: "Generated ${ENV_TYPE} Bundle"
description: "Auto-generated for ${ENV_TYPE}"
tools:
  - git:
  - nodejs:
EOF

if [[ "$ENV_TYPE" == "development" ]]; then
    cat >> "bundles/generated-${ENV_TYPE}.yaml" <<EOF
  - vscode:
  - docker:
EOF
fi

if [[ "$ENV_TYPE" == "production" ]]; then
    cat >> "bundles/generated-${ENV_TYPE}.yaml" <<EOF
  - monitoring:
  - security:
EOF
fi
```

Usage:
```bash
./scripts/generate-bundle.sh development
envforge up --env bundles/generated-development.yaml
```

## Bundle Composition

### Modular Bundles

Break large bundles into smaller, reusable pieces:

**bundles/modules/base.yaml**:
```yaml
name: "Base Module"
tools:
  - build-essential:
  - git:
```

**bundles/modules/nodejs.yaml**:
```yaml
name: "Node.js Module"
tools:
  - nodejs:
      depends_on:
        - build-essential
  - yarn:
      depends_on:
        - nodejs
```

**bundles/full-stack.yaml**:
```yaml
name: "Full Stack"
tools:
  # Include base
  - build-essential:
  - git:
  
  # Include nodejs module
  - nodejs:
      depends_on:
        - build-essential
  - yarn:
      depends_on:
        - nodejs
  
  # Add more
  - docker:
  - postgresql:
```

## Conditional Tools

### OS-Specific Tools

While EnvForge doesn't natively support conditionals in YAML, you can create OS-specific bundles:

**bundles/ubuntu.yaml**:
```yaml
name: "Ubuntu Setup"
tools:
  - apt-tools:
  - ubuntu-specific:
```

**bundles/debian.yaml**:
```yaml
name: "Debian Setup"
tools:
  - apt-tools:
  - debian-specific:
```

Or handle in tool scripts:

```bash
install() {
    if [[ -f /etc/lsb-release ]]; then
        # Ubuntu-specific
        install_apt_packages "ubuntu-package"
    elif [[ -f /etc/debian_version ]]; then
        # Debian-specific
        install_apt_packages "debian-package"
    fi
}
```

## Bundle Metadata

### Rich Descriptions

```yaml
name: "Full-Stack Web Development"
description: |
  Complete environment for full-stack web development including:
  - Node.js and npm for JavaScript development
  - PostgreSQL for database
  - Docker for containerization
  - VS Code for editing
  - Git for version control
  
  Suitable for React, Vue, and Node.js projects.
tools:
  - git:
  - nodejs:
  - postgresql:
  - docker:
  - vscode:
```

## Testing Bundles

### Validation Script

Create a script to validate bundles:

**scripts/validate-bundle.sh**:
```bash
#!/bin/bash

BUNDLE_FILE="$1"

# Check YAML syntax
if ! python3 -c "import yaml; yaml.safe_load(open('$BUNDLE_FILE'))" 2>/dev/null; then
    echo "Invalid YAML syntax"
    exit 1
fi

# Check for circular dependencies
envforge up --env "$BUNDLE_FILE" --dry-run

echo "Bundle validation passed"
```

### Test Suite

```bash
#!/bin/bash

# Test all bundles
for bundle in bundles/*.yaml; do
    echo "Testing $bundle..."
    envforge up --env "$bundle" --dry-run
done
```

## Bundle Documentation

### Inline Comments

YAML supports comments:

```yaml
name: "Web Development"
description: "Full-stack web development"
tools:
  # Core tools - required for everything
  - build-essential:
  - git:
  
  # JavaScript ecosystem
  - nodejs:
      depends_on:
        - build-essential
  
  # Database - PostgreSQL chosen for JSON support
  - postgresql:
      depends_on:
        - build-essential
  
  # Containerization - required for deployment
  - docker:
      depends_on:
        - build-essential
```

### README for Bundles

Create documentation:

**bundles/README.md**:
```markdown
# Custom Bundles

## Available Bundles

### development.yaml
Full development environment with all tools.

**Includes**:
- Git, Node.js, Docker, VS Code
- PostgreSQL, Redis
- Development certificates

**Use case**: Local development

### production.yaml
Minimal production environment.

**Includes**:
- Git, Node.js, Docker
- Monitoring agent
- Security hardening

**Use case**: Production servers
```

## Performance Optimization

### Parallel Installation

Structure bundles to maximize parallelism:

```yaml
name: "Optimized Bundle"
tools:
  # Single base dependency
  - build-essential:
  
  # All these can install in parallel
  - nodejs:
      depends_on: [build-essential]
  - python3:
      depends_on: [build-essential]
  - golang:
      depends_on: [build-essential]
  - rust:
      depends_on: [build-essential]
```

### Minimal Dependencies

Only declare necessary dependencies:

❌ **Over-specified**:
```yaml
tools:
  - tool-a:
      depends_on: [base]
  - tool-b:
      depends_on: [base, tool-a]  # tool-a already depends on base
```

✅ **Optimal**:
```yaml
tools:
  - tool-a:
      depends_on: [base]
  - tool-b:
      depends_on: [tool-a]  # Implicit dependency on base
```

## Next Steps

- [**Custom Tools**](custom-tools.md) - Advanced tool techniques
- [**Overview**](overview.md) - Customization principles
- [**Creating Bundles**](../scripting/creating-bundles.md) - Basic bundle creation
