#!/bin/bash

# Get the absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Correctly resolve project root assuming script is in tools/
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utility functions if available
if [ -f "$PROJECT_ROOT/lib/utils.sh" ]; then
    source "$PROJECT_ROOT/lib/utils.sh"
else
    # Fallback if utils not found (for standalone execution outside project structure)
    log_info() { echo "[INFO] $1"; }
    log_success() { echo "[SUCCESS] $1"; }
    log_warning() { echo "[WARNING] $1"; }
    log_error() { echo "[ERROR] $1"; }
    install_apt_packages() {
        sudo apt update && sudo apt install -y "$@"
    }
fi

# Define NVM directory
export NVM_DIR="$HOME/.nvm"

pre_install() {
    log_info "Checking for existing dependencies..."
    if ! command -v curl &> /dev/null; then
        log_info "Installing curl..."
        install_apt_packages curl
    fi

    if [ -d "$NVM_DIR" ]; then
        log_info "nvm directory already exists at $NVM_DIR"
    fi
}

install() {
    log_info "Installing/Updating nvm..."
    
    # Install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    # Load nvm for the current session
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if ! command -v nvm &> /dev/null; then
        log_error "nvm could not be loaded. Please restart your terminal or source your profile."
        return 1
    fi

    log_success "nvm installed/loaded successfully."

    # Install Node.js LTS
    log_info "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    
    # Enable Corepack and pnpm
    log_info "Enabling Corepack and pnpm..."
    corepack enable
    corepack prepare pnpm@latest --activate
}

post_install() {
    # Re-load nvm to ensure it's available in this function scope as well
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    log_info "Verifying installation..."
    
    if command -v node &> /dev/null; then
        log_success "Node.js installed: $(node -v)"
    else
        log_error "Node.js installation failed"
    fi

    if command -v npm &> /dev/null; then
        log_success "npm installed: $(npm -v)"
    else
        log_error "npm installation failed"
    fi

    if command -v pnpm &> /dev/null; then
        log_success "pnpm installed: $(pnpm -v)"
    else
        log_error "pnpm installation failed"
    fi
}

# Main execution logic
# This allows the script to be run standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log_info "Starting standalone execution of nvm setup..."
    
    pre_install
    install
    post_install
    
    log_success "nvm and Node.js setup finished."
fi
