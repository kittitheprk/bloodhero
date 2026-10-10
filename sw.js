/* Vampire Warrior · Blood Hero - Service Worker (Offline Web Support) */
const CACHE_NAME = 'bloodhero-v1';
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './vampire_warrior_blood_hero.html',
  './manifest.json',
  './hero_sprites.js',
  './sprite-animation-128x128-frames/frame-1.png',
  './sprite-animation-128x128-frames/frame-2.png',
  './sprite-animation-128x128-frames/frame-3.png',
  './sprite-animation-128x128-frames/frame-4.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS_TO_CACHE).catch(() => {});
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) return caches.delete(key);
        })
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      if (cachedResponse) return cachedResponse;
      return fetch(event.request).then((networkResponse) => {
        return networkResponse;
      }).catch(() => {
        if (event.request.mode === 'navigate') {
          return caches.match('./index.html');
        }
      });
    })
  );
});
