# YouMean Deployment Guide

This guide explains how to deploy the YouMean Flutter web UI to Railway.app or other hosting platforms.

---

## 🚀 Quick Deploy to Railway

### Prerequisites:
- Railway account (free tier available)
- GitHub repository with YouMean UI code
- Your backend API URL (if deployed separately)

### Step 1: Prepare Your Repository

1. Make sure all files are committed:
```bash
git status
git add .
git commit -m "Prepare for Railway deployment"
git push
```

2. Verify `.gitignore` is protecting your backend:
```bash
git check-ignore rust/
# Should output: rust/
```

### Step 2: Deploy to Railway

1. Go to [Railway.app](https://railway.app/)
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your `youmean` repository
4. Railway will automatically detect the `Dockerfile`

### Step 3: Configure Environment Variables

In Railway dashboard, add environment variable:

- **Variable**: `API_URL`
- **Value**: Your backend API URL (e.g., `https://youmean-api.railway.app`)

**Or** use build arguments:
- Go to Settings → Build Args
- Add: `API_URL=https://your-backend-url.com`

### Step 4: Deploy

Railway will automatically:
1. Build using the Dockerfile with Flutter 3.38.5 (Dart 3.10.4+)
2. Apply the `--dart-define=API_URL` during build
3. Deploy and assign a public URL

---

## 🏗️ Manual Build (Local Testing)

### Build with Default Localhost API:
```bash
# Build for development (connects to localhost:3000)
flutter build web --release
```

### Build with Custom API URL:
```bash
# Build for production with your backend URL
flutter build web --release --dart-define=API_URL=https://your-backend.railway.app
```

### Test Locally:
```bash
# Serve the built app
python3 -m http.server 8080 --directory build/web

# Open browser to: http://localhost:8080
```

---

## 🐳 Docker Build & Run

### Build Docker Image:
```bash
# Build with default (localhost)
docker build -t youmean-ui .

# Build with custom API URL
docker build --build-arg API_URL=https://your-backend.com -t youmean-ui .
```

### Run Docker Container:
```bash
docker run -p 8080:8080 youmean-ui

# Open browser to: http://localhost:8080
```

---

## 📋 Deployment Checklist

Before deploying, ensure:

- [ ] `.gitignore` excludes `rust/` folder
- [ ] `.dockerignore` excludes unnecessary files
- [ ] `Dockerfile` uses Flutter 3.38.5 (Dart 3.10.4+)
- [ ] `API_URL` environment variable or build arg is set
- [ ] Backend API is deployed and accessible
- [ ] CORS is enabled on backend for your frontend domain

---

## 🔧 Troubleshooting

### "Dart SDK version mismatch" Error:
**Solution**: The Dockerfile now uses `ghcr.io/cirruslabs/flutter:3.38.5` which includes Dart 3.10.4+

### UI Can't Connect to Backend:
**Check**:
1. Is `API_URL` set correctly during build?
2. Is your backend deployed and running?
3. Does backend allow CORS from your frontend domain?

### Build Takes Too Long:
**Check**: 
- `.dockerignore` is excluding large folders like `rust/`, `android/`, `ios/`
- Railway has enough resources allocated

---

## 🌐 Architecture (Reminder)

```
┌─────────────────────────────────────┐
│   FLUTTER UI (Railway Deployed)     │  ← This Repository
│   - User interface                  │
│   - Connects to backend API         │
└─────────────────────────────────────┘
              ⬇️ HTTP Requests
┌─────────────────────────────────────┐
│   BACKEND API (Separate Deploy)     │  ← NOT in this repo
│   - Queue system only               │
│   - Stores requests in DB           │
└─────────────────────────────────────┘
              ⬇️ Manual Processing
┌─────────────────────────────────────┐
│   OFFLINE ALGORITHMS (Your PC)      │  ← NEVER deployed
│   - Proprietary calculations        │
│   - Process requests manually       │
└─────────────────────────────────────┘
```

---

## 📞 Support

If you encounter deployment issues:
1. Check Railway build logs
2. Verify Flutter version in Dockerfile
3. Confirm API_URL is set correctly
4. Test locally with Docker first

---

**Happy Deploying! 🚀**
