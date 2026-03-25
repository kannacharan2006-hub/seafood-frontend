# Hosting Legal Pages for OceanSync

This folder contains the legal pages required for Google Play Store publication.

## Files

- `privacy-policy.html` - Privacy Policy page
- `terms-of-service.html` - Terms of Service page

## How to Host for Free

### Option 1: GitHub Pages (Recommended)

1. **Create a new GitHub repository** (e.g., `oceansync-legal`)

2. **Clone the repo:**
   ```bash
   git clone https://github.com/yourusername/oceansync-legal.git
   ```

3. **Copy the HTML files:**
   ```bash
   cp privacy-policy.html terms-of-service.html ~/oceansync-legal/
   cd ~/oceansync-legal/
   ```

4. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Add legal pages"
   git push
   ```

5. **Enable GitHub Pages:**
   - Go to Settings → Pages
   - Source: Deploy from a branch
   - Branch: main, / (root)
   - Click Save

6. **Your pages will be live at:**
   - `https://yourusername.github.io/oceansync-legal/privacy-policy.html`
   - `https://yourusername.github.io/oceansync-legal/terms-of-service.html`

### Option 2: Netlify

1. Go to [netlify.com](https://netlify.com)
2. Sign up/Login
3. Click "Add new site" → "Deploy manually"
4. Drag and drop this `docs` folder
5. Your site will be deployed instantly
6. Get the URL (e.g., `random-name.netlify.app`)
7. Your URLs will be:
   - `https://random-name.netlify.app/privacy-policy.html`
   - `https://random-name.netlify.app/terms-of-service.html`

### Option 3: Vercel

1. Go to [vercel.com](https://vercel.com)
2. Sign up/Login
3. Click "Add New" → "Project"
4. Upload this folder or connect GitHub
5. Deploy
6. Get your URL

## For Custom Domain

If you buy a domain (e.g., `oceansync.app`):

### Netlify:
1. Go to Site Settings → Domain Management
2. Click "Add custom domain"
3. Enter your domain
4. Configure DNS as instructed

### GitHub Pages:
1. Go to repository Settings → Pages
2. Add your custom domain
3. Configure DNS to point to GitHub

## Play Store Setup

In your Play Store Console, add these URLs:
- **Privacy Policy:** `https://your-domain.com/privacy-policy.html`
- **Terms of Service:** `https://your-domain.com/terms-of-service.html`

## Notes

- These pages are static HTML - no server needed
- HTTPS is required for Play Store
- Both GitHub Pages and Netlify provide HTTPS automatically
