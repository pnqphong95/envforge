# EnvForge Documentation

This directory contains the Docusaurus documentation site for EnvForge.

## Local Development

### Prerequisites

- Node.js 18+ and npm

### Installation

```bash
cd docs
npm install
```

### Start Development Server

```bash
npm start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

### Build

```bash
npm run build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.

### Deployment

The documentation is automatically deployed to GitHub Pages when changes are pushed to the master branch.

To deploy manually:

```bash
npm run deploy
```

## Documentation Structure

```
docs/
├── content/                 # Documentation pages
│   ├── intro.md            # Introduction
│   ├── installation.md     # Installation guide
│   ├── quick-start.md      # Quick start guide
│   ├── architecture/       # Architecture documentation
│   ├── scripting/          # Scripting system guides
│   └── customization/      # Customization guides
├── src/                    # React components and pages
│   ├── css/               # Custom CSS
│   └── pages/             # Custom pages (homepage)
├── static/                # Static assets
│   └── img/              # Images
├── docusaurus.config.js   # Docusaurus configuration
└── sidebars.js           # Sidebar configuration
```

## Theme

The documentation uses a minimalist design with mint as the primary color:

- **Primary Color**: `#3dd68c` (mint green)
- **Design Philosophy**: Content-focused, clean, minimal
- **Dark Mode**: Supported with adjusted mint color palette

## Contributing

To add or update documentation:

1. Edit markdown files in `content/`
2. Update `sidebars.js` if adding new pages
3. Test locally with `npm start`
4. Commit and push changes

## License

Same as the main EnvForge project.
