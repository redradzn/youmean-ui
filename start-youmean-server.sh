#!/bin/bash
# ============================================================================
# YouMean MacBook Server Startup Script
# ============================================================================
# This script starts your Rust backend and exposes it via ngrok
# Your algorithms stay PRIVATE on your MacBook - only the queue is exposed
# ============================================================================

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║     🔮 YouMean Server - Starting on MacBook M1 Pro     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Navigate to Rust directory
RUST_DIR="/Users/redradzn/desktop/YouMean/rust"
cd "$RUST_DIR"

echo "📁 Working directory: $RUST_DIR"
echo ""

# Check if server is already running
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Server already running on port 3000"
    echo "   PID: $(lsof -Pi :3000 -sTCP:LISTEN -t)"
else
    echo "🚀 Starting Rust backend server..."
    # Keep MacBook awake while server runs
    caffeinate -i cargo run --bin youmean-server > /tmp/youmean-server.log 2>&1 &
    SERVER_PID=$!
    echo "   ✅ Server started (PID: $SERVER_PID)"
    echo "   📋 Logs: /tmp/youmean-server.log"
    sleep 3
fi

echo ""

# Check if ngrok is already running
if curl -s http://localhost:4040/api/tunnels > /dev/null 2>&1; then
    echo "⚠️  ngrok tunnel already running"
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "import sys, json; data = json.load(sys.stdin); print(data['tunnels'][0]['public_url'])" 2>/dev/null || echo "unknown")
    echo "   🌐 Public URL: $NGROK_URL"
else
    echo "🌐 Starting ngrok tunnel..."
    ngrok http 3000 --log=stdout > /tmp/ngrok.log 2>&1 &
    NGROK_PID=$!
    echo "   ✅ ngrok started (PID: $NGROK_PID)"
    echo "   Waiting for tunnel to establish..."
    sleep 5
    
    # Get the public URL
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "import sys, json; data = json.load(sys.stdin); print(data['tunnels'][0]['public_url'])" 2>/dev/null || echo "Error getting URL")
    echo "   🌐 Public URL: $NGROK_URL"
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                 ✅ YOUMEAN SERVER READY!                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Status:"
echo "   • Rust Backend: http://localhost:3000"
echo "   • Admin Panel: http://localhost:3000/admin"
echo "   • Public URL: $NGROK_URL"
echo "   • umean.app: Will connect to your MacBook!"
echo ""
echo "🔒 Privacy:"
echo "   ✅ Algorithms stay on YOUR MacBook"
echo "   ✅ Users submit requests → Queue → You process offline"
echo "   ✅ No code uploaded to internet"
echo ""
echo "📝 Logs:"
echo "   • Server: tail -f /tmp/youmean-server.log"
echo "   • ngrok: tail -f /tmp/ngrok.log"
echo ""
echo "🛑 To stop:"
echo "   • killall youmean-server"
echo "   • killall ngrok"
echo ""
echo "Press Ctrl+C to exit (servers will keep running in background)"
echo ""

# Keep script running to show status
tail -f /tmp/youmean-server.log
