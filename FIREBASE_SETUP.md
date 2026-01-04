# Firebase Setup Guide

This guide will help you set up Firebase to host photos for your memory page without committing them to GitHub.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., "our-memories")
4. Disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Firebase Storage

1. In your Firebase project, click "Storage" in the left menu
2. Click "Get started"
3. Choose "Start in production mode" (we'll set secure rules)
4. Click "Next" and "Done"

## Step 3: Enable Realtime Database

1. Click "Realtime Database" in the left menu
2. Click "Create Database"
3. Choose your location (closest to your users)
4. Start in "locked mode" (we'll set secure rules)
5. Click "Enable"

## Step 4: Enable Authentication

1. Click "Authentication" in the left menu
2. Click "Get started"
3. Click "Sign-in method" tab
4. Enable "Anonymous" authentication
5. Click "Save"

## Step 4: Get Firebase Configuration

1. Click the gear icon ⚙️ next to "Project Overview"
2. Click "Project settings"
3. Scroll down to "Your apps"
4. Click the web icon `</>`
5. Register your app with a nickname (e.g., "memories-web")
6. Copy the `firebaseConfig` object

## Step 5: Update Your Code

Replace the placeholder configuration in both `index.html` and `view.html`:

```javascript
const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
    databaseURL: "https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
};
```

With your actual config values from Firebase.

## Step 6: Configure Security Rules (CRITICAL!)

### Storage Rules
Go to Storage → Rules and replace with these SECURE rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /memories/{imageId} {
      // Anyone can read
      allow read: if true;
      
      // Only authenticated users can write
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024  // Max 5MB
                   && request.resource.contentType.matches('image/.*');  // Images only
    }
  }
}
```

### Database Rules
Go to Realtime Database → Rules and replace with these SECURE rules:

```json
{
  "rules": {
    "photos": {
      ".read": true,
      ".write": "auth != null",
      "$photoId": {
        ".validate": "newData.hasChildren(['url', 'timestamp'])"
      }
    }
  }
}
```

**What these rules do:**
- ✅ Anyone can view photos (public gallery)
- ✅ Only authenticated users can upload
- ✅ Images limited to 5MB max
- ✅ Only image files accepted
- ✅ Data validation on uploads

## Step 7: Deploy to GitHub Pages

1. **IMPORTANT:** Change the password in upload.html:
   - Open `upload.html`
   - Find `const UPLOAD_PASSWORD = 'YourSecurePassword2026!';`
   - Change to a strong password
   - **DO NOT commit this password to a public repo!**

2. Update both files with your Firebase config
3. Commit and push:
```bash
git add index.html upload.html
git commit -m "Add Firebase integration with authentication"
git push
```

4. Enable GitHub Pages (Settings → Pages → Deploy from main branch)

## How It Works

**Security Layers:**
1. 🔒 Password gate on upload.html (client-side)
2. 🔒 Firebase Anonymous Authentication (when password correct)
3. 🔒 Firebase Security Rules (server-side enforcement)
4. 🔒 File type validation (images only)
5. 🔒 File size limits (5MB max)

**Access:**
- Upload photos: `https://yourusername.github.io/hehe/upload.html` → Enter password → Authenticated upload
- View photos: `https://yourusername.github.io/hehe/` → No authentication needed

## Important Security Notes

⚠️ **Password Protection:**
- The password in `upload.html` is visible in source code
- This is basic protection - don't use for highly sensitive data
- Change the default password immediately
- Consider keeping upload.html link private

⚠️ **Best Practices:**
- Use a strong password (20+ characters)
- Don't share the upload.html URL publicly
- Monitor Firebase console for unusual activity
- Set up Firebase budget alerts

⚠️ **For Maximum Security:**
Consider using Firebase Email/Password authentication instead of Anonymous auth for production use.
