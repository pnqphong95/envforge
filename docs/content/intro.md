---
sidebar_position: 1
---

# Introduction

**EnvForge** is a modular, dependency-aware installation framework designed to scaffold and bootstrap development environments. Built for Linux distributions (Debian/Ubuntu/Mint), its flexible architecture allows easy customization for various setup needs.

## Vision

This project provides a flexible scaffolding framework for multiple purposes:

- **Generic Linux Setup**: Essential tools for fresh OS installations
- **Developer Workstations**: Robust environments for backend, web, and systems programming
- **Mobile Development**: Provisioning toolchains for Android, iOS, and cross-platform frameworks
- **Custom Environments**: Easily extensible to support any specific tooling requirements

## Key Features

### 🎯 Bundle System
Define tool collections with dependency management in YAML format. Group related tools together for easy installation.

### ⚡ Dependency Resolution
Automatic topological sorting ensures correct installation order. No more manual dependency tracking.

### 🔧 Standalone Tools
Each tool script can run independently or as part of a bundle. Maximum flexibility for your workflow.

### 💾 State Management
Per-bundle state tracking prevents redundant installations. Resume interrupted installations seamlessly.

### 🎨 Flexible Execution
Install complete bundles or individual tools. Choose what you need, when you need it.

### 🪝 3-Phase Hooks
`pre_install`, `install`, and `post_install` phases for granular control over installation process.

### ⏭️ Skip Parameter
Conditionally enable/disable tools in bundles based on your requirements.

### 🌍 Global Command
Install once, use `envforge` from anywhere in your system.

## Why EnvForge?

Setting up a new development environment can be time-consuming and error-prone. EnvForge solves this by:

1. **Automating repetitive tasks** - No more copy-pasting installation commands
2. **Ensuring consistency** - Same environment across multiple machines
3. **Managing dependencies** - Automatic resolution of tool dependencies
4. **Providing flexibility** - Easy to customize and extend
5. **Tracking state** - Resume installations without starting over

## What's Next?

- [**Installation**](installation.md) - Get EnvForge up and running
- [**Quick Start**](quick-start.md) - Your first bundle installation
- [**Architecture**](architecture/overview.md) - Understand how it works
- [**Customization**](customization/overview.md) - Make it your own
