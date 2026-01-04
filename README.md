# 💫 Our Memories Together

A beautiful, elegant web page for sharing memories through photos and personal messages. Features a stunning glassmorphism design with dark theme and immersive photo slideshow.

## ✨ Features

- 📸 **Photo Slideshow**: Upload photos and watch them flow smoothly one by one
  - Drag & drop support from Apple Photos or Finder
  - Copy/paste images directly (Cmd+V)
  - Adjustable slideshow speed
  - Immersive fullscreen mode (UI disappears during slideshow)
  
- ✍️ **Drawing Canvas**: Express yourself with drawings or handwritten messages
  - White pen by default (perfect for dark background)
  - Color picker for custom colors
  - Adjustable brush size
  - Eraser tool
  - Save your creation as PNG

- 🎨 **Beautiful Design**:
  - Pure black background with glassmorphism effects
  - Elegant typography (Playfair Display, Cormorant Garamond, Raleway, Inter)
  - Smooth animations and transitions
  - Mobile-friendly responsive design

## 🌐 Deployment Options

### Option 1: GitHub Pages (Public, Free)
**Note:** GitHub Pages serves static files only - no password protection.

1. **Push to GitHub:**
   ```bash
   cd /Users/thanujanpuvikaran/Documents/repositories/hehe
   git add index.html
   git commit -m "Add memory page"
   git push origin main
   ```

2. **Enable GitHub Pages:**
   - Go to your repo on GitHub
   - Settings → Pages
   - Source: Deploy from branch → `main` → `/root`
   - Save

3. **Access your site:**
   - URL: `https://yourusername.github.io/hehe/`
   - Usually live within 1-2 minutes

### Option 2: Local Server (Private, Password Protected)

**Prerequisites:** Python 3.6+

1. **Navigate to directory:**
   ```bash
   cd /Users/thanujanpuvikaran/Documents/repositories/hehe
   ```

2. **Start server:**
   ```bash
   python3 server.py
   ```

3. **Access locally:**
   - URL: `http://localhost:8888`
   - Password is in `server.py` (keep this file private!)

## 🔒 Security Notes

- ⚠️ **server.py contains a hardcoded password** - added to `.gitignore` to prevent accidental commits
- GitHub Pages deployment = **no password protection** (static hosting only)
- For password protection, use local server or paid hosting with backend support

6. To stop the server, press `Ctrl+C` in the Terminal

## 🎨 How to Use

### Drawing Your Troll

1. **Choose a color**: Click the color picker to select your drawing color
2. **Adjust brush size**: Use the slider to change brush thickness (1-50px)
3. **Start drawing**: Click and drag on the canvas to draw
4. **Eraser mode**: Click "Eraser" button to erase parts of your drawing
5. **Clear canvas**: Click "Clear Canvas" to start over
6. **Save your work**: Click "Save Drawing" to download as PNG

### Adding Photos

1. Click "Choose Files" in the photo upload section
2. Select one or multiple photos from your computer
3. Photos will appear in a grid above the drawing canvas
4. Hover over photos for a zoom effect

## 🛠️ Customization

### Change the Password

Edit `server.py` and modify line 17:
```python
SECRET_PASSWORD = "YourNewPasswordHere"
```

### Change the Port

Edit `server.py` and modify line 16:
```python
PORT = 8888  # Change to any available port
```

### Change Session Timeout

Edit `server.py` and modify line 18:
```python
SESSION_TIMEOUT_MINUTES = 60  # Change to desired minutes
```

## 📁 Project Structure

```
hehe/
├── index.html       # Main birthday page with drawing canvas
├── server.py        # Secure Python web server
└── README.md        # This file
```

## 🌐 Accessing from Other Devices on Your Network

To access the page from other devices on your local network (like phones or tablets):

1. Find your computer's local IP address:
   ```bash
   ipconfig getifaddr en0
   ```

2. Start the server as usual

3. On other devices, use your computer's IP instead of localhost:
   ```
   http://YOUR_IP_ADDRESS:8888
   ```
   For example: `http://192.168.1.100:8888`

⚠️ **Important**: Only one person can access at a time, regardless of device!

## 🔧 Troubleshooting

### "Address already in use" error
- Another program is using port 8888
- Either stop that program or change the PORT in server.py

### Cannot access from other devices
- Make sure your computer's firewall allows incoming connections on port 8888
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
