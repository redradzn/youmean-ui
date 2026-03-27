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
  background: #040810;
  color: #b8d4e3;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 4rem 2rem;
  position: relative;
  transition: background 0.4s, color 0.4s;
}


/* Cuneiform bands */
.cuneiform {
  position: fixed;
  left: 0;
  width: 100%;
  font-size: 1.4rem;
  letter-spacing: 0.3em;
  color: #0d2035;
  text-align: center;
  pointer-events: none;
  z-index: 0;
  overflow: hidden;
  white-space: nowrap;
  padding: 0 0.5rem;
}
.cuneiform-top { top: 0.8rem; }
.cuneiform-bottom { bottom: 0.8rem; }

@keyframes dragonFade {
  to { opacity: 1; }
}
@keyframes dragonBreath {
  0%, 100% { opacity: 0.85; }
  50% { opacity: 1; }
}
@keyframes breathe {
  0%, 100% { filter: drop-shadow(0 0 12px rgba(212, 166, 70, 0.3)); }
  50% { filter: drop-shadow(0 0 24px rgba(212, 166, 70, 0.6)); }
}
@keyframes glowPulse {
  0%, 100% { text-shadow: 0 0 10px rgba(212, 166, 70, 0.4); }
  50% { text-shadow: 0 0 20px rgba(212, 166, 70, 0.7), 0 0 40px rgba(212, 166, 70, 0.2); }
}
@keyframes scribeFloat {
  0%, 100% { opacity: 0.4; }
  50% { opacity: 0.7; }
}

body > *:not(.dragon-top):not(.dragon-bottom):not(.cuneiform) {
  position: relative;
  z-index: 1;
}

h1 {
  font-size: 1.8rem;
  letter-spacing: 0.4em;
  margin-bottom: 0.5rem;
  font-weight: 700;
  text-transform: lowercase;
  background: linear-gradient(135deg, #c49a3c, #f0d78c, #d4a646, #f5e6b8, #c49a3c);
  background-size: 200% 200%;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  filter: drop-shadow(0 0 12px rgba(212, 166, 70, 0.3));
  animation: breathe 6s ease-in-out infinite;
}

.subtitle {
  font-size: 0.5rem;
  letter-spacing: 0.7em;
  color: #1e3a50;
  margin-bottom: 1.6rem;
  text-transform: uppercase;
}

.separator {
  margin-bottom: 1.8rem;
  font-size: 1.3rem;
  color: #d4a646;
  text-shadow: 0 0 10px rgba(212, 166, 70, 0.4);
  animation: glowPulse 8s ease-in-out infinite;
}

.rule {
  width: 65vw;
  max-width: 420px;
  height: 1px;
  background: linear-gradient(90deg, transparent, #1a3048, #2a5070, #1a3048, transparent);
  transition: background 0.4s;
}
.rule-top { margin-bottom: 2rem; }
.rule-bottom { margin-top: 2rem; margin-bottom: 2rem; }

#words {
  font-size: 1.25rem;
  font-weight: 400;
  letter-spacing: 0.05em;
  max-width: 70vw;
  text-align: center;
  line-height: 2.4;
  overflow-wrap: break-word;
  min-height: 2rem;
  color: #e8d5a3;
  text-shadow: 0 0 24px rgba(232, 213, 163, 0.12);
  transition: color 0.4s, text-shadow 0.4s;
}

.buttons {
  display: flex;
  gap: 1.2rem;
}

button {
  font-family: 'Space Mono', monospace;
  font-size: 0.8rem;
  letter-spacing: 0.12em;
  text-transform: lowercase;
  padding: 0.5rem 1.2rem;
  border: 1px solid #1e3a4f;
  border-radius: 4px;
  cursor: pointer;
  background: transparent;
  color: #4a8fa8;
  transition: all 0.25s;
}
button:hover {
  background: rgba(15, 29, 42, 0.6);
  color: #2dd4bf;
  border-color: rgba(45, 212, 191, 0.3);
  box-shadow: 0 0 14px rgba(45, 212, 191, 0.1);
}

#copy.copied {
  color: #d4a646;
  border-color: rgba(212, 166, 70, 0.4);
}

#clear {
  color: #2a4a5a;
  border-color: #142a3a;
}
#clear:hover {
  color: #e07a5f;
  border-color: rgba(224, 122, 95, 0.3);
  box-shadow: 0 0 14px rgba(224, 122, 95, 0.1);
}

#hint {
  margin-top: 2.5rem;
  font-size: 0.6rem;
  color: #1e3a4f;
  letter-spacing: 0.15em;
  text-transform: lowercase;
  transition: color 0.4s;
}

#theme-toggle {
  position: fixed;
  top: 1rem;
  right: 1.2rem;
  font-size: 1.6rem;
  background: none;
  border: none;
  cursor: pointer;
  color: #1e3a4f;
  padding: 0.4rem;
  line-height: 1;
  letter-spacing: 0.1em;
  opacity: 0.5;
  transition: opacity 0.3s, color 0.3s;
}
#theme-toggle:hover {
  opacity: 1;
  box-shadow: none;
  border: none;
  color: #d4a646;
}

/* E-ink overrides */
body.eink {
  background: #fefefe;
  background-image: none;
  color: #111;
}
body.eink .cuneiform { display: none; }
body.eink h1 {
  background: none;
  -webkit-background-clip: unset;
  -webkit-text-fill-color: #111;
  background-clip: unset;
  filter: none;
  animation: none;
  color: #111;
}
body.eink .subtitle { color: #999; }
body.eink .separator { color: #999; text-shadow: none; animation: none; }
body.eink .rule { background: #ccc; }
body.eink #words { color: #000; text-shadow: none; }
body.eink button {
  color: #555;
  border: none;
  border-bottom: 1px solid transparent;
  border-radius: 0;
  padding: 0.4rem 0;
}
body.eink button:hover {
  color: #111;
  background: none;
  border-bottom-color: #111;
  box-shadow: none;
}
body.eink #copy.copied { color: #111; border-bottom-color: #111; }
body.eink #clear { color: #aaa; border-color: transparent; }
body.eink #clear:hover { color: #111; border-bottom-color: #111; box-shadow: none; }
body.eink #hint { color: #bbb; }
body.eink #theme-toggle { color: #aaa; }
body.eink #theme-toggle:hover { color: #111; }
</style>
</head>
<body>


<!-- Cuneiform band top -->
<div class="cuneiform cuneiform-top">\u{12000} \u{12038} \u{1202D} \u{12049} \u{1204E} \u{120FB} \u{12197} \u{121B8} \u{121A5} \u{12229} \u{1223E} \u{12263} \u{122E3} \u{12038} \u{1202D} \u{12000} \u{12049} \u{1204E} \u{120FB} \u{12197} \u{121B8} \u{121A5} \u{12229}</div>

<h1>naemu</h1>
<div class="subtitle">oracle of the deep</div>
<div class="separator">\u{13080}</div>
<div class="rule rule-top"></div>
<div id="words"></div>
<div class="rule rule-bottom"></div>
<div class="buttons">
  <button id="copy">copy</button>
  <button id="refresh">refresh</button>
  <button id="clear">clear</button>
</div>

<!-- Cuneiform band bottom -->
<div class="cuneiform cuneiform-bottom">\u{12263} \u{122E3} \u{12229} \u{1223E} \u{121A5} \u{121B8} \u{12197} \u{120FB} \u{1204E} \u{12049} \u{1202D} \u{12038} \u{12000} \u{12263} \u{122E3} \u{12229} \u{1223E} \u{121A5} \u{121B8} \u{12197} \u{120FB} \u{1204E}</div>


<button id="theme-toggle">\u{13079}</button>
<script>
(function() {
  if (localStorage.getItem('naemu_eink') === 'true') {
    document.body.classList.add('eink');
  }

  document.getElementById('theme-toggle').addEventListener('click', function() {
    document.body.classList.toggle('eink');
    localStorage.setItem('naemu_eink', document.body.classList.contains('eink'));
  });

  var newWord = ${JSON.stringify(word)};
  var words = JSON.parse(sessionStorage.getItem('naemu_words') || '[]');

  words.push(newWord);
  sessionStorage.setItem('naemu_words', JSON.stringify(words));

  document.getElementById('words').textContent = words.join('  ').toLowerCase();

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
