const CACHE_NAME = 'our-memories-shell-v2';
const APP_SHELL = [
  '/',
  '/index.html',
  '/upload.html',
  '/styles.min.css',
  '/music-player.min.js',
  '/login_public.html',
  '/login_admin.html',
  '/error.html'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') {
    return;
  }

  // Keep Firebase and external requests network-first to avoid stale auth/data.
  const requestUrl = new URL(event.request.url);
  const isExternal = requestUrl.origin !== self.location.origin;
  const isFirebase = /firebase|gstatic|googleapis/.test(requestUrl.hostname);
  if (isExternal || isFirebase) {
    return;
  }

  // Always prefer fresh HTML so clients get latest script references.
  const isDocumentRequest = event.request.mode === 'navigate' ||
    event.request.destination === 'document' ||
    (event.request.headers.get('accept') || '').includes('text/html');

  if (isDocumentRequest) {
    event.respondWith(
      fetch(event.request)
        .then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const responseClone = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(event.request, responseClone);
            });
          }
          return networkResponse;
        })
        .catch(() => caches.match(event.request))
    );
    return;
  }

  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      if (cachedResponse) {
        return cachedResponse;
      }

      return fetch(event.request).then((networkResponse) => {
        if (networkResponse && networkResponse.status === 200) {
          const responseClone = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseClone);
          });
        }
        return networkResponse;
      });
    })
  );
});
