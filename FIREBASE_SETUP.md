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

### 6.1 Storage Rules
1. Go to **Storage** → **Rules** in Firebase Console
2. Replace all content with the rules from `firebase-storage-rules.txt` in your project:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Photos directory - readable by everyone, writable only by authenticated users
    match /photos/{imageId} {
      // Anyone can read (public gallery)
      allow read: if true;
      
      // Only authenticated users can write
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024  // Max 5MB
                   && request.resource.contentType.matches('image/.*');  // Images only
      
      // Delete allowed only for authenticated users
      allow delete: if request.auth != null;
    }
    
    // Drawings directory - authenticated users only
    match /drawings/{drawingId} {
      allow read: if true;
      allow write: if request.auth != null
                   && request.resource.size < 10 * 1024 * 1024;  // Max 10MB for canvas
      allow delete: if request.auth != null;
    }
    
    // Deny all other access
    match /{allPaths=**} {
      allow read: if false;
      allow write: if false;
    }
  }
}
```

3. Click **Publish** to deploy the rules

### 6.2 Database Rules
1. Go to **Realtime Database** → **Rules** in Firebase Console
2. Replace all content with the rules from `firebase-database-rules.json`:

```json
{
  "rules": {
    "photos": {
      // Anyone can read the photo metadata
      ".read": true,
      
      // Only authenticated users can write
      ".write": "auth != null",
      
      "$photoId": {
        // Metadata structure validation
        ".validate": "newData.hasChildren(['url', 'timestamp']) && newData.child('timestamp').isNumber() && newData.child('url').isString()",
        
        "url": {
          ".validate": "newData.isString() && newData.val().length > 0"
        },
        "timestamp": {
          ".validate": "newData.isNumber() && newData.val() > 0"
        },
        "size": {
          ".validate": "newData.isNumber() && newData.val() < 5242880"
        },
        "type": {
          ".validate": "newData.isString() && newData.val().matches(/image\\/.+/)"
        },
        "name": {
          ".validate": "newData.isString()"
        },
        "uploadedBy": {
          ".validate": "newData.isString()"
        },
        "caption": {
          ".validate": "newData.isString() && newData.val().length <= 500"
        }
      }
    },
    
    "drawings": {
      ".read": true,
      ".write": "auth != null",
      
      "$drawingId": {
        ".validate": "newData.hasChildren(['url', 'timestamp']) && newData.child('timestamp').isNumber()",
        
        "url": {
          ".validate": "newData.isString() && newData.val().length > 0"
        },
        "timestamp": {
          ".validate": "newData.isNumber()"
        },
        "title": {
          ".validate": "newData.isString() && newData.val().length <= 100"
        },
        "uploadedBy": {
          ".validate": "newData.isString()"
        }
      }
    },
    
    ".read": false,
    ".write": false
  }
}
```

3. Click **Publish** to deploy the rules

### 6.3 What These Rules Do:
- ✅ Anyone can view photos (public gallery)
- ✅ Only authenticated users can upload photos
- ✅ Only authenticated users can upload drawings
- ✅ Images limited to 5MB, drawings to 10MB
- ✅ Only image files accepted
- ✅ Strict data validation - prevents invalid entries
- ✅ Metadata validation - enforces required fields
- ✅ Only authenticated users can delete
- ✅ Prevents accidental data corruption

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
