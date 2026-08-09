// GoalsFORGold – Offline-Cache, Netzwerk zuerst (immer frisch, wenn online)
const CACHE = "goalsforgold-v2";
const ASSETS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./icon-192.png",
  "./icon-512.png",
  "./apple-touch-icon.png",
  "./favicon.png",
];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

// Netzwerk zuerst und dabei den HTTP-Cache umgehen (cache:"no-cache" = beim Server
// revalidieren), damit neue Versionen sofort ankommen. Cache nur als Offline-Fallback.
self.addEventListener("fetch", e => {
  if (e.request.method !== "GET" || !e.request.url.startsWith(self.location.origin)) return;
  e.respondWith(
    fetch(e.request.url, { cache: "no-cache" })
      .then(res => {
        if (res.ok) {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(e.request.url, copy));
        }
        return res;
      })
      .catch(() => caches.match(e.request.url, { ignoreSearch: true })
        .then(hit => hit || caches.match("./index.html")))
  );
});
