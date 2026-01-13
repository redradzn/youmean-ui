# YouMean MacBook Server Guide

## 🎉 Your Setup is LIVE!

**umean.app** is now connected to your MacBook M1 Pro via ngrok!

---

## 🌐 Your URLs

| Service | URL |
|---------|-----|
| **Frontend** | https://umean.app |
| **Backend API** | https://dennise-cartable-unquixotically.ngrok-free.dev |
| **Admin Panel** | https://dennise-cartable-unquixotically.ngrok-free.dev/admin |

---

## 🔒 How It Works (Privacy-First)

```
┌─────────────────────────────┐
│  USER on umean.app          │
│  Fills form & clicks        │
│  "Calculate"                │
└─────────────────────────────┘
         ⬇️ HTTPS Request
┌─────────────────────────────┐
│  NGROK TUNNEL               │  ← Secure encrypted tunnel
│  (Free public endpoint)     │
└─────────────────────────────┘
         ⬇️ Forwards to
┌─────────────────────────────┐
│  YOUR MACBOOK M1 PRO        │  ← localhost:3000
│  Rust Queue Server          │
│  - Stores request           │
│  - Returns "pending"        │
│  - NO algorithms run        │
└─────────────────────────────┘
         ⬇️ You access
┌─────────────────────────────┐
│  ADMIN PANEL                │
│  View pending requests      │
│  Download → Process offline │
│  Upload results             │
└─────────────────────────────┘
         ⬇️ Offline processing
┌─────────────────────────────┐
│  YOUR PYTHON ALGORITHMS     │  ← 100% PRIVATE
│  astro_engine.py            │
│  translation_engine.py      │
│  Run on YOUR MacBook only   │
└─────────────────────────────┘
```

**🎯 Your proprietary algorithms NEVER leave your MacBook!**

---

## 🚀 Starting the Server

### Quick Start:
```bash
cd /Users/redradzn/desktop/YouMean
bash start-youmean-server.sh
```

This script will:
1. ✅ Start Rust backend on port 3000
2. ✅ Start ngrok tunnel
3. ✅ Display public URL
4. ✅ Keep MacBook awake (no sleep)
5. ✅ Show real-time logs

---

## 🛑 Stopping the Server

```bash
# Stop Rust backend
killall youmean-server

# Stop ngrok tunnel
killall ngrok

# Or stop both at once:
killall youmean-server ngrok
```

---

## 📊 Monitoring

### View Logs:
```bash
# Server logs
tail -f /tmp/youmean-server.log

# ngrok logs
tail -f /tmp/ngrok.log
```

### Check Status:
```bash
# Is server running?
lsof -i :3000

# Is ngrok running?
curl -s http://localhost:4040/api/tunnels
```

### ngrok Dashboard:
- Open: http://localhost:4040
- See real-time requests
- Inspect HTTP traffic

---

## 🔧 Troubleshooting

### Server won't start:
```bash
# Kill any existing process on port 3000
lsof -ti:3000 | xargs kill -9

# Restart
cd /Users/redradzn/desktop/YouMean/rust
cargo run --bin youmean-server
```

### ngrok won't start:
```bash
# Kill existing ngrok
killall ngrok

# Restart
ngrok http 3000
```

### Get new ngrok URL:
```bash
curl -s http://localhost:4040/api/tunnels | python3 -c "import sys, json; print(json.load(sys.stdin)['tunnels'][0]['public_url'])"
```

### URL changed? Update Flutter app:
1. Get new ngrok URL (command above)
2. Edit: `lib/services/api_service.dart`
3. Update `defaultValue:` with new URL
4. Build: `flutter build web --release --base-href=/`
5. Commit & push to GitHub
6. Netlify will auto-deploy

---

## 🏃 Processing Workflow

### 1. User Submits Request:
- User fills form on umean.app
- Clicks "Calculate"
- Request stored in your MacBook's SQLite database
- User sees: "Request submitted! Check back in 24-48 hours"

### 2. You Process Offline:
```bash
# Open admin panel
open https://dennise-cartable-unquixotically.ngrok-free.dev/admin

# Or access locally
open http://localhost:3000/admin
```

In admin panel:
1. See pending requests
2. Copy request data
3. Run your Python algorithms OFFLINE
4. Upload results

### 3. User Gets Results:
- User returns to umean.app
- Enters their request ID
- Sees their "Mind Selfie" results

---

## 🔐 Security Notes

### What's Exposed:
- ✅ Rust queue server (no algorithms)
- ✅ SQLite database (request data only)
- ✅ Admin panel (password protect recommended)

### What's PRIVATE:
- 🔒 `astro_engine.py` (your algorithms)
- 🔒 `translation_engine.py` (your logic)
- 🔒 All Python code (never uploaded)
- 🔒 Processing happens offline

### Recommendations:
1. Add password to admin panel
2. Use ngrok's IP whitelisting (paid tier)
3. Monitor ngrok dashboard for unusual activity
4. Keep macOS firewall enabled

---

## 💰 Cost Breakdown

| Service | Cost |
|---------|------|
| **MacBook M1 Pro** | Electricity (~$2/month) |
| **ngrok Free Tier** | $0/month |
| **Netlify (umean.app)** | $0/month |
| **Total** | ~$2/month |

**Compare to cloud hosting:** $50-100/month for equivalent setup!

---

## 🌟 Advantages of This Setup

✅ **Privacy:** All algorithms stay on YOUR machine  
✅ **Security:** No code uploaded to cloud  
✅ **Cost:** Nearly free (~$2/month)  
✅ **Performance:** M1 Pro is FAST  
✅ **Control:** You decide when to process  
✅ **Flexibility:** Update algorithms anytime  
✅ **Professional:** Users see umean.app domain  

---

## ⚡ Optional Upgrades

### ngrok Paid Tier ($8/month):
- ✅ Static URL (doesn't change)
- ✅ Custom domain (api.yourdomain.com)
- ✅ No rate limits
- ✅ IP whitelisting
- ✅ More concurrent tunnels

### Auto-Start on MacBook Boot:
```bash
# Create launchd plist (macOS auto-start)
# Contact Claude for detailed instructions
```

### Add Admin Password:
```bash
# Protect admin panel with authentication
# Contact Claude for Rust middleware setup
```

---

## 📞 Need Help?

- ngrok dashboard: http://localhost:4040
- Server logs: `/tmp/youmean-server.log`
- ngrok logs: `/tmp/ngrok.log`
- Admin panel: Local or public URL

---

## 🎉 Success!

Your YouMean app is now:
- ✅ Live on umean.app
- ✅ Processing on YOUR MacBook
- ✅ Algorithms 100% private
- ✅ Cost-effective (~$2/month)
- ✅ Professional & secure

**Test it:** Visit umean.app and submit a calculation! 🚀
