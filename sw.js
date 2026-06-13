const CACHE = 'italiano-checkin-v13';
const URLS = [
  '/italiano-checkin/',
  '/italiano-checkin/index.html',
  '/italiano-checkin/manifest.json'
];

self.addEventListener('install', e => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(URLS)).catch(() => {}));
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(
    keys.filter(k => k !== CACHE).map(k => caches.delete(k))
  )));
  return self.clients.claim();
});

self.addEventListener('fetch', e => {
  // 主页和 HTML 优先走网络，确保始终加载最新版
  if (e.request.mode === 'navigate' || e.request.url.endsWith('.html')) {
    e.respondWith(fetch(e.request).then(resp => {
      const clone = resp.clone();
      caches.open(CACHE).then(c => c.put(e.request, clone));
      return resp;
    }).catch(() => caches.match(e.request)));
    return;
  }
  e.respondWith(
    caches.match(e.request).then(r => r || fetch(e.request).then(resp => {
      if (resp.ok) {
        const clone = resp.clone();
        caches.open(CACHE).then(c => c.put(e.request, clone));
      }
      return resp;
    }).catch(() => caches.match('/italiano-checkin/')))
  );
});


