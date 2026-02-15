const crypto = require('crypto');
const WORDS = require('./words');

function getHTML(word) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex, nofollow">
<title>Naemu</title>
<link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: 'Space Mono', monospace;
  background: #0a0f14;
  color: #b8d4e3;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 2rem;
}
h1 {
  font-size: 1.8rem;
  letter-spacing: 0.3em;
  margin-bottom: 2.5rem;
  font-weight: 300;
  text-transform: lowercase;
  background: linear-gradient(135deg, #2dd4bf, #3b82f6, #d4a646);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
#words {
  font-size: 1.25rem;
  letter-spacing: 0.05em;
  max-width: 80vw;
  text-align: center;
  margin-bottom: 2.5rem;
  line-height: 2;
  overflow-wrap: break-word;
  min-height: 2rem;
  color: #e0dcd0;
}
.buttons {
  display: flex;
  gap: 1rem;
}
button {
  font-family: inherit;
  font-size: 0.9rem;
  padding: 0.6rem 1.4rem;
  border: 1px solid #1e3a4f;
  border-radius: 6px;
  cursor: pointer;
  background: transparent;
  color: #4a8fa8;
  transition: all 0.2s;
}
button:hover {
  background: #0f1d2a;
  color: #2dd4bf;
  border-color: #2dd4bf40;
}
#copy.copied {
  color: #d4a646;
  border-color: #d4a64660;
}
#clear {
  color: #5a6a7a;
  border-color: #1a2a3a;
}
#clear:hover {
  color: #e07a5f;
  border-color: #e07a5f40;
}
#hint {
  margin-top: 2rem;
  font-size: 0.7rem;
  color: #1e3a4f;
  letter-spacing: 0.1em;
}
</style>
</head>
<body>
<h1>naemu</h1>
<div id="words"></div>
<div class="buttons">
  <button id="copy">Copy</button>
  <button id="refresh">Refresh</button>
  <button id="clear">Clear</button>
</div>
<div id="hint">refresh for next word</div>
<script>
(function() {
  var newWord = ${JSON.stringify(word)};
  var words = JSON.parse(sessionStorage.getItem('naemu_words') || '[]');

  words.push(newWord);
  sessionStorage.setItem('naemu_words', JSON.stringify(words));

  document.getElementById('words').textContent = words.join('  ');

  document.getElementById('copy').addEventListener('click', function() {
    var text = words.join(' ');
    var btn = this;
    navigator.clipboard.writeText(text).then(function() {
      btn.classList.add('copied');
      btn.textContent = 'Copied';
      setTimeout(function() {
        btn.classList.remove('copied');
        btn.textContent = 'Copy';
      }, 1500);
    });
  });

  document.getElementById('refresh').addEventListener('click', function() {
    location.reload();
  });

  document.getElementById('clear').addEventListener('click', function() {
    sessionStorage.removeItem('naemu_words');
    location.reload();
  });
})();
</script>
</body>
</html>`;
}

exports.handler = async function() {
  const rand = crypto.randomBytes(4).readUInt32BE(0);
  const word = WORDS[rand % WORDS.length];

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
      'Cache-Control': 'no-store, no-cache, must-revalidate',
      'Pragma': 'no-cache',
    },
    body: getHTML(word),
  };
};
