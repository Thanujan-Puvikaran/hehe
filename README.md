
# 🎯 MVP (Produit Minimum Viable)

Créer une page web d’anniversaire simple et fun, accessible uniquement à une personne à la fois, permettant :
- de dessiner un troll sur un canvas interactif
- d’ajouter et d’afficher des photos souvenirs
- d’assurer la sécurité par un accès protégé (mot de passe/session unique)
- d’être hébergée localement sur la machine de l’organisateur

---

## 📋 Cahier des charges fonctionnel

### 1. Accès & Sécurité
- Authentification par mot de passe
- Une seule session active à la fois (une personne connectée)
- Session liée à l’adresse IP et expiration automatique

### 2. Page principale
- Canvas de dessin (troll, messages, etc.)
- Outils : choix de couleur, taille du pinceau, gomme, effacer, sauvegarder le dessin
- Galerie de photos (ajout et affichage)
- Interface responsive (PC/tablette/mobile)

### 3. Hébergement
- Serveur local Python sécurisé (non accessible depuis Internet)
- Accès via navigateur web sur la machine locale

### 4. Expérience utilisateur
- Design fun, festif et simple
- Instructions claires pour l’utilisation

---

# 💫 Our Memories Together

A beautiful, elegant web page for sharing memories through photos. Features a sophisticated dark design with scroll-based photo gallery and Firebase cloud storage.

## ✨ Features

- 📸 **Photo Gallery**: Upload photos that appear beautifully as you scroll
  - Scroll-based reveal animations
  - Firebase cloud storage (photos accessible from any device)
  - Elegant fade-in transitions
  - Mobile-friendly responsive design
  
- ✍️ **Drawing Canvas** (upload page only): Express yourself with drawings or handwritten messages
  - Color picker for custom colors
  - Adjustable brush size
  - Eraser tool
  - Save your creation as PNG

- 🎨 **Beautiful Design**:
  - Sophisticated dark theme (#0b0c0f)
  - Modern typography (DM Sans headings, Inter body)
  - Subtle film grain texture
  - Smooth animations and transitions
  - No neon effects - clean and professional

## 📱 Two Pages

- **index.html**: View-only page (for sharing)
- **upload.html**: Admin page with photo upload and drawing tools (keep private)

## 🌐 Deployment Options

### Option 1: GitHub Pages + Firebase (Recommended)

**Step 1: Setup Firebase** (see FIREBASE_SETUP.md)

**Step 2: Deploy to GitHub Pages:**

1. **Push to GitHub:**
   ```bash
   cd /Users/thanujanpuvikaran/Documents/repositories/hehe
   git add .
   git commit -m "Deploy memory page"
   git push origin main
   ```

2. **Enable GitHub Pages:**
   - Go to your repo on GitHub
   - Settings → Pages
   - Source: Deploy from branch → `main` → `/root`
   - Save

3. **Access your sites:**
   - View page: `https://yourusername.github.io/hehe/` (share this)
   - Upload page: `https://yourusername.github.io/hehe/upload.html` (keep private)

### Option 2: Local Testing

1. **Navigate to directory:**
   ```bash
   cd /Users/thanujanpuvikaran/Documents/repositories/hehe
   ```

2. **Start simple server:**
   ```bash
   python3 -m http.server 8000
   ```

3. **Access locally:**
   - View page: `http://localhost:8000/`
   - Upload page: `http://localhost:8000/upload.html`

## 🔒 Security Notes

- ⚠️ Upload page has no password protection - keep the URL private
- Photos stored in Firebase (free tier: 5GB storage)
- For production, consider adding Firebase Authentication

## 🎨 How to Use

### Uploading Photos (upload.html)

1. Click the floating "📸 Upload Photos" button (bottom right)
2. Select one or multiple photos
3. Photos automatically upload to Firebase
4. Photos will appear on both pages

### Drawing (upload.html only)

1. **Choose a color**: Click the color picker
2. **Adjust brush size**: Use the slider (1-50px)
3. **Start drawing**: Click and drag on the canvas
4. **Eraser mode**: Click "Eraser" button
5. **Clear canvas**: Click "Clear Canvas"
6. **Save your work**: Click "Save Drawing" to download as PNG

### Viewing Photos (index.html)

1. Simply scroll down to see photos appear with beautiful animations
2. No upload capability - perfect for sharing

## 🛠️ Customization

### Change Fonts

Edit `styles.css`:
```css
h1 {
  font-family: 'DM Sans', sans-serif;
  font-weight: 300; /* or 400, 600 for bolder */
}
```

### Change Colors

Edit CSS variables in `styles.css`:
```css
:root {
  --bg: #0b0c0f;        /* background color */
  --text: rgba(255,255,255,.92);  /* text color */
  --muted: rgba(255,255,255,.62); /* muted text */
}
```

### Adjust Photo Spacing

Edit `styles.css`:
```css
.photos-gallery {
  gap: 70px; /* space between photos */
}
```

## 📁 Project Structure

```
hehe/
├── index.html         # View-only page (for sharing)
├── upload.html        # Admin page with upload & drawing
├── styles.css         # Shared styles for both pages
├── FIREBASE_SETUP.md  # Firebase configuration guide
├── server.py          # Local development server
└── README.md          # This file
```

## 🔧 Troubleshooting

### Photos not appearing
- Check Firebase configuration in both HTML files
- Ensure Firebase rules allow read/write access
- Check browser console for errors

### Styles not loading
- Ensure `styles.css` is in the same directory as HTML files
- Check browser developer tools for 404 errors

### Firebase errors
- Verify your Firebase config values are correct
- Check that Storage and Realtime Database are enabled
- Review Firebase security rules

## 💡 Tips

- Keep `upload.html` URL private - only share `index.html`
- Firebase free tier is generous (5GB storage, plenty for photos)
- Photos are compressed as base64 in Firebase - consider optimizing large images
- Test locally before deploying to ensure everything works
- Ensure both devices are on the same WiFi network

### Photos not uploading
- Make sure you're selecting image files (jpg, png, gif, etc.)
- Check browser console for errors (F12 → Console tab)

## 💡 Tips

- **Best Experience**: Use a mouse or stylus for detailed drawings
- **Photo Formats**: Supports JPG, PNG, GIF, WebP
- **Canvas Size**: 800x600 pixels - perfect for detailed troll art!
- **Save Often**: Click "Save Drawing" periodically to backup your work
- **Mobile Drawing**: Works on tablets with finger or stylus input

## 🎉 Have Fun!

Draw the most epic birthday troll ever and make some unforgettable memories! 🎂✨

---

**Created with ❤️ for a special birthday celebration**
