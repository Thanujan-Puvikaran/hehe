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
3. Choose "Start in test mode" (we'll secure it later)
4. Click "Next" and "Done"

## Step 3: Enable Realtime Database

1. Click "Realtime Database" in the left menu
2. Click "Create Database"
3. Choose your location (closest to your users)
4. Start in "Test mode"
5. Click "Enable"

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

## Step 6: Configure Security Rules

### Storage Rules
Go to Storage → Rules and replace with:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /memories/{imageId} {
      allow read: if true;
      allow write: if true; // Change this to add authentication later
    }
  }
}
```

### Database Rules
Go to Realtime Database → Rules and replace with:

```json
{
  "rules": {
    "photos": {
      ".read": true,
      ".write": true
    }
  }
}
```

## Step 7: Deploy to GitHub Pages

1. Update both files with your Firebase config
2. Commit and push:
```bash
git add index.html view.html
git commit -m "Add Firebase integration"
git push
```

3. Enable GitHub Pages (Settings → Pages → Deploy from main branch)

## How It Works

- Upload photos on `index.html` → Photos stored in Firebase Storage
- Photo URLs saved in Firebase Realtime Database
- `view.html` loads photos from Firebase
- Works from any device, anywhere!

## Free Tier Limits

Firebase free tier includes:
- 5GB Storage
- 1GB/day download bandwidth
- 10GB/month Realtime Database storage

This is more than enough for a personal memory page!

## Optional: Add Password Protection

To restrict uploads to `index.html`, you can add Firebase Authentication later.
