---
sidebar_position: 3
---

# Custom Tools

Advanced techniques for creating sophisticated tool scripts.

## Advanced Tool Patterns

### Pattern 1: Multi-Source Installation

Install from multiple sources:

```bash
#!/bin/bash
source "$PROJECT_ROOT/lib/utils.sh"

TOOL_VERSION="1.2.3"
DEB_URL="https://example.com/tool_${TOOL_VERSION}_amd64.deb"
FALLBACK_URL="https://example.com/tool-${TOOL_VERSION}.tar.gz"

pre_install() {
    log_info "Installing Tool v${TOOL_VERSION}..."
}

install() {
    # Try DEB package first
    if curl -fsSL "$DEB_URL" -o /tmp/tool.deb 2>/dev/null; then
        log_info "Installing from DEB package..."
        sudo dpkg -i /tmp/tool.deb
        sudo apt-get install -f -y
    else
        # Fallback to tarball
        log_info "DEB not available, using tarball..."
        curl -fsSL "$FALLBACK_URL" -o /tmp/tool.tar.gz
        tar -xzf /tmp/tool.tar.gz -C "$HOME/.local"
        add_to_path "$HOME/.local/bin"
    fi
}

post_install() {
    rm -f /tmp/tool.deb /tmp/tool.tar.gz
    
    if command -v tool &> /dev/null; then
        log_success "Tool installed: $(tool --version)"
    else
        log_error "Installation failed"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pre_install
    install
    post_install
fi
```

### Pattern 2: Version Management

Support multiple versions:

```bash
#!/bin/bash
source "$PROJECT_ROOT/lib/utils.sh"

# Allow version override via environment variable
NODEJS_VERSION="${NODEJS_VERSION:-18}"

pre_install() {
    log_info "Installing Node.js v${NODEJS_VERSION}..."
}

install() {
    # Add NodeSource repository
    curl -fsSL "https://deb.nodesource.com/setup_${NODEJS_VERSION}.x" | sudo -E bash -
    
    # Install specific version
    install_apt_packages "nodejs"
}

post_install() {
    if command -v node &> /dev/null; then
        log_success "Node.js installed: $(node --version)"
        log_success "npm installed: $(npm --version)"
    else
        log_error "Installation failed"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pre_install
    install
    post_install
fi
```

Usage:
```bash
# Default version
./tools/nodejs.sh

# Specific version
NODEJS_VERSION=20 ./tools/nodejs.sh
```

### Pattern 3: Configuration Management

Install and configure:

```bash
#!/bin/bash
source "$PROJECT_ROOT/lib/utils.sh"

CONFIG_DIR="$HOME/.config/mytool"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

pre_install() {
    log_info "Installing and configuring MyTool..."
    mkdir -p "$CONFIG_DIR"
}

install() {
    install_apt_packages "mytool"
}

post_install() {
    # Create default configuration
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" <<EOF
# MyTool Configuration
setting1: value1
setting2: value2
EOF
        log_info "Created default configuration at $CONFIG_FILE"
    fi
    
    # Verify installation
    if command -v mytool &> /dev/null; then
        log_success "MyTool installed and configured"
    else
        log_error "Installation failed"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pre_install
    install
    post_install
fi
```

## Advanced Techniques

### Idempotent Installations

Ensure tools can run multiple times safely:

```bash
pre_install() {
    # Check if already installed
    if command -v mytool &> /dev/null; then
        CURRENT_VERSION=$(mytool --version | grep -oP '\d+\.\d+\.\d+')
        
        if [[ "$CURRENT_VERSION" == "$DESIRED_VERSION" ]]; then
            log_info "MyTool v${DESIRED_VERSION} already installed"
            exit 0
        else
            log_info "Upgrading from v${CURRENT_VERSION} to v${DESIRED_VERSION}"
        fi
    fi
}
```

### Cleanup and Rollback

Handle failures gracefully:

```bash
install() {
    # Create backup
    if [[ -f "$CONFIG_FILE" ]]; then
        cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
    fi
    
    # Try installation
    if ! install_apt_packages "mytool"; then
        log_error "Installation failed, rolling back..."
        
        # Restore backup
        if [[ -f "${CONFIG_FILE}.backup" ]]; then
            mv "${CONFIG_FILE}.backup" "$CONFIG_FILE"
        fi
        
        exit 1
    fi
    
    # Remove backup on success
    rm -f "${CONFIG_FILE}.backup"
}
```

### Progress Indication

Show progress for long operations:

```bash
install() {
    log_info "Downloading large file..."
    
    # Download with progress
    curl -fsSL --progress-bar "$URL" -o /tmp/file.tar.gz
    
    log_info "Extracting (this may take a while)..."
    tar -xzf /tmp/file.tar.gz -C "$INSTALL_DIR"
    
    log_info "Compiling from source..."
    cd "$INSTALL_DIR/source"
    ./configure > /dev/null 2>&1
    make -j$(nproc) > /dev/null 2>&1
    sudo make install > /dev/null 2>&1
}
```

### Dependency Checking

Verify prerequisites:

```bash
pre_install() {
    log_info "Checking prerequisites..."
    
    # Check for required commands
    local required_commands=("curl" "git" "make")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command not found: $cmd"
            log_error "Please install $cmd first"
            exit 1
        fi
    done
    
    # Check for required files
    if [[ ! -f "/usr/include/openssl/ssl.h" ]]; then
        log_error "OpenSSL development headers not found"
        log_error "Please install libssl-dev"
        exit 1
    fi
    
    log_success "All prerequisites satisfied"
}
```

## Platform-Specific Logic

### OS Detection

```bash
install() {
    # Detect OS
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    fi
    
    case "$OS" in
        ubuntu)
            log_info "Installing for Ubuntu ${VERSION}..."
            install_apt_packages "ubuntu-package"
            ;;
        debian)
            log_info "Installing for Debian ${VERSION}..."
            install_apt_packages "debian-package"
            ;;
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}
```

### Architecture Detection

```bash
install() {
    ARCH=$(uname -m)
    
    case "$ARCH" in
        x86_64)
            DOWNLOAD_URL="${BASE_URL}/tool-linux-amd64.tar.gz"
            ;;
        aarch64)
            DOWNLOAD_URL="${BASE_URL}/tool-linux-arm64.tar.gz"
            ;;
        *)
            log_error "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    
    curl -fsSL "$DOWNLOAD_URL" -o /tmp/tool.tar.gz
    tar -xzf /tmp/tool.tar.gz -C "$HOME/.local/bin"
}
```

## Complex Installation Scenarios

### Compile from Source

```bash
#!/bin/bash
source "$PROJECT_ROOT/lib/utils.sh"

TOOL_VERSION="2.1.0"
SOURCE_URL="https://github.com/user/tool/archive/v${TOOL_VERSION}.tar.gz"
BUILD_DIR="/tmp/tool-build"

apt_packages=("build-essential" "cmake" "libssl-dev")

pre_install() {
    log_info "Preparing to build Tool v${TOOL_VERSION} from source..."
    install_apt_packages "${apt_packages[@]}"
    mkdir -p "$BUILD_DIR"
}

install() {
    log_info "Downloading source..."
    curl -fsSL "$SOURCE_URL" -o "${BUILD_DIR}/source.tar.gz"
    
    log_info "Extracting source..."
    tar -xzf "${BUILD_DIR}/source.tar.gz" -C "$BUILD_DIR"
    
    log_info "Configuring..."
    cd "${BUILD_DIR}/tool-${TOOL_VERSION}"
    cmake -DCMAKE_BUILD_TYPE=Release .
    
    log_info "Building (this may take several minutes)..."
    make -j$(nproc)
    
    log_info "Installing..."
    sudo make install
}

post_install() {
    # Cleanup
    rm -rf "$BUILD_DIR"
    
    # Verify
    if command -v tool &> /dev/null; then
        log_success "Tool built and installed: $(tool --version)"
    else
        log_error "Build failed"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pre_install
    install
    post_install
fi
```

### Docker Image Installation

```bash
#!/bin/bash
source "$PROJECT_ROOT/lib/utils.sh"

IMAGE_NAME="myapp/tool"
IMAGE_TAG="latest"
CONTAINER_NAME="mytool"

pre_install() {
    log_info "Installing Tool via Docker..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is required but not installed"
        exit 1
    fi
}

install() {
    log_info "Pulling Docker image..."
    docker pull "${IMAGE_NAME}:${IMAGE_TAG}"
    
    log_info "Creating wrapper script..."
    sudo tee /usr/local/bin/mytool > /dev/null <<EOF
#!/bin/bash
docker run --rm -it \\
    -v "\$PWD:/workspace" \\
    -w /workspace \\
    ${IMAGE_NAME}:${IMAGE_TAG} "\$@"
EOF
    
    sudo chmod +x /usr/local/bin/mytool
}

post_install() {
    if command -v mytool &> /dev/null; then
        log_success "Tool installed via Docker"
        mytool --version
    else
        log_error "Installation failed"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pre_install
    install
    post_install
fi
```

## Testing Tools

### Unit Testing

Create a test script:

**tests/test-mytool.sh**:
```bash
#!/bin/bash

source "$(dirname "$0")/../lib/utils.sh"

test_installation() {
    if command -v mytool &> /dev/null; then
        log_success "✓ Tool is installed"
        return 0
    else
        log_error "✗ Tool is not installed"
        return 1
    fi
}

test_version() {
    local version=$(mytool --version 2>&1)
    if [[ -n "$version" ]]; then
        log_success "✓ Version check passed: $version"
        return 0
    else
        log_error "✗ Version check failed"
        return 1
    fi
}

test_functionality() {
    if mytool --help &> /dev/null; then
        log_success "✓ Basic functionality works"
        return 0
    else
        log_error "✗ Basic functionality failed"
        return 1
    fi
}

# Run tests
log_info "Running tests for mytool..."
test_installation
test_version
test_functionality
```

## Best Practices

### 1. Comprehensive Logging

```bash
pre_install() {
    log_info "=== MyTool Installation ==="
    log_info "Version: ${TOOL_VERSION}"
    log_info "Install directory: ${INSTALL_DIR}"
}

install() {
    log_info "Step 1/3: Downloading..."
    # download
    
    log_info "Step 2/3: Extracting..."
    # extract
    
    log_info "Step 3/3: Installing..."
    # install
}
```

### 2. Error Messages

```bash
post_install() {
    if ! command -v mytool &> /dev/null; then
        log_error "Installation failed"
        log_error "Possible causes:"
        log_error "  - Network connectivity issues"
        log_error "  - Insufficient permissions"
        log_error "  - Missing dependencies"
        log_error "Check the logs above for details"
        exit 1
    fi
}
```

### 3. User Feedback

```bash
post_install() {
    log_success "MyTool installed successfully!"
    log_info ""
    log_info "Next steps:"
    log_info "  1. Run 'mytool init' to initialize"
    log_info "  2. Edit ~/.mytool/config.yaml"
    log_info "  3. Run 'mytool start'"
    log_info ""
    log_info "Documentation: https://mytool.example.com/docs"
}
```

## Next Steps

- [**Custom Bundles**](custom-bundles.md) - Use your tools in bundles
- [**Overview**](overview.md) - Customization principles
- [**Creating Tools**](../scripting/creating-tools.md) - Basic tool creation
