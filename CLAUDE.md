# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Trinomio is a creative workshop space landing page for artisanal and craft workshops. The project focuses on creating a welcoming digital presence that reflects the brand's values of wellbeing, creativity, pause, and community.

## Project Structure

This is a static website project with multiple landing page versions:
- `index.html` - Original version with custom CSS
- `index-tailwind.html` - Modern version using Tailwind CSS CDN and Alpine.js
- `index-modern.html` - Premium version with advanced animations (GSAP, glassmorphism, neumorphism)
- `styles.css` - Custom styles for the original version
- `script.js` - Vanilla JavaScript for the original version
- `imagenes/` - Workshop space photographs and brand assets

## Brand Guidelines

The project must strictly follow the Trinomio brand manual:

### Typography
- **Primary**: Gotham (for logos and main headings)
- **Secondary**: Lato (for body text and subtitles)

### Color Palette
```css
--color-coral: #E86D5A      /* Primary accent */
--color-gray: #474747       /* Main text */
--color-blue: #2E5266       /* Secondary accent */
--color-light: #F3E8DC      /* Background */
--color-mint: #A7B7A1       /* Tertiary */
--color-yellow: #D9A441     /* Highlight */
```

### Logo
- SVG format with human figure symbol
- Located in `favicon.svg` and should be used consistently
- Sub-brands for different workshop dimensions (Madera, Herrería, Cerámica, Textil)

## Development Commands

### Local Development
```bash
# No build process needed - open HTML files directly in browser
# For live reload during development, use VS Code Live Server extension or:
python -m http.server 8000
# Then navigate to http://localhost:8000
```

### Git Operations
```bash
# Stage and commit changes
git add -A
git commit -m "Description of changes"
git push

# GitHub CLI is available at: "C:\Program Files\GitHub CLI\gh.exe"
```

### Deployment
The site is deployed via GitHub Pages:
- Repository: https://github.com/sefeguz/trinomio-landing
- Live URL: https://sefeguz.github.io/trinomio-landing
- Any push to main branch automatically deploys

## Key Implementation Notes

### When Creating New Versions
1. Always use the official Trinomio logo SVG, not placeholder icons
2. Maintain the brand's philosophical messaging:
   - "¿Te equivocaste? Bien. Estás haciendo."
   - Focus on process over results
   - Emphasize community without obligation

### Image Assets
Workshop photos are available in `imagenes/`:
- `logo-pared-trinomio.jpg` - Wall logo
- `mesa-trabajo-madera.jpg` - Woodworking bench
- `taladro-banco-herramientas.jpg` - Drill press and tools
- `espacio-taller-general.jpg` - General workshop space

### Technology Choices
- For modern implementations, use CDN versions:
  - Tailwind CSS (latest stable)
  - Alpine.js for interactivity
  - GSAP for advanced animations (optional)
- Avoid heavy frameworks (React, Vue) for this static site
- Prioritize performance and accessibility

## Target Audience Personas

The site serves four main client personas and one instructor persona:
- **Carlos (68)**: Retiree seeking meaningful activities
- **Martín (42)**: Professional needing active disconnection
- **María José (54)**: Seeking personal identity recovery
- **Sofía (33)**: Young professional wanting pressure-free creativity
- **Marcelo (48)**: Instructor seeking stable teaching space

Design decisions should accommodate all age groups with clear navigation and readable typography.

## Important Context

- This is a workshop space in La Plata, Buenos Aires, Argentina
- The brand emphasizes "hacer con sentido" (meaningful making)
- Avoid overly technical or competitive language
- Maintain a warm, welcoming tone throughout