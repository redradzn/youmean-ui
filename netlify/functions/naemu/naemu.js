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
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&display=swap" rel="stylesheet">
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: 'Cormorant Garamond', 'Georgia', serif;
  background: #fefefe;
  color: #111;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 2rem;
}
h1 {
  font-size: 1.6rem;
  letter-spacing: 0.4em;
  margin-bottom: 1rem;
  font-weight: 300;
  text-transform: lowercase;
  font-variant: small-caps;
  color: #111;
}
.separator {
  margin-bottom: 2rem;
  font-size: 0.8rem;
  letter-spacing: 0.6em;
  color: #999;
}
.rule {
  width: 60vw;
  max-width: 400px;
  height: 1px;
  background: #ccc;
}
.rule-top { margin-bottom: 2rem; }
.rule-bottom { margin-top: 2rem; margin-bottom: 2rem; }
#words {
  font-size: 1.5rem;
  font-weight: 400;
  font-style: italic;
  letter-spacing: 0.04em;
  max-width: 70vw;
  text-align: center;
  line-height: 2.2;
  overflow-wrap: break-word;
  min-height: 2rem;
  color: #000;
}
.buttons {
  display: flex;
  gap: 2rem;
}
button {
  font-family: 'Cormorant Garamond', 'Georgia', serif;
  font-size: 0.85rem;
  letter-spacing: 0.15em;
  text-transform: lowercase;
  padding: 0.4rem 0;
  border: none;
  border-bottom: 1px solid transparent;
  cursor: pointer;
  background: transparent;
  color: #888;
}
button:hover {
  color: #111;
  border-bottom-color: #111;
}
#copy.copied {
  color: #111;
  border-bottom-color: #111;
}
#clear {
  color: #aaa;
}
#clear:hover {
  color: #111;
  border-bottom-color: #111;
}
#hint {
  margin-top: 2.5rem;
  font-size: 0.65rem;
  color: #bbb;
  letter-spacing: 0.15em;
  text-transform: lowercase;
}
</style>
</head>
<body>
<h1>naemu</h1>
<div class="separator">✧</div>
<div class="rule rule-top"></div>
<div id="words"></div>
<div class="rule rule-bottom"></div>
<div class="buttons">
  <button id="copy">copy</button>
  <button id="refresh">refresh</button>
  <button id="clear">clear</button>
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
      btn.textContent = 'copied';
      setTimeout(function() {
        btn.classList.remove('copied');
        btn.textContent = 'copy';
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
