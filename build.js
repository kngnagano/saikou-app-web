const fs = require('fs');
const path = require('path');

fs.mkdirSync('dist', { recursive: true });

const files = [
  'index.html',
  'sw.js',
  'manifest.json',
  'icon-192.png',
  'icon-512x512.png',
  'admin.html',
  'privacy.html',
  'terms.html',
  'reset-password.html'
];

files.forEach(f => {
  if (fs.existsSync(f)) {
    fs.copyFileSync(f, path.join('dist', f));
    console.log('copied:', f);
  }
});

console.log('Build complete → dist/');
