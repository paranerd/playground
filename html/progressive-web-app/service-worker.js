'use strict';

const CACHE_NAME = 'static-cache-v2';

const FILES_TO_CACHE = [
	'/',
	'/index.html',
	'/assets/icon.png'
];

self.addEventListener('install', function(event) {
	console.log('[ServiceWorker] Install');

	self.skipWaiting();

	event.waitUntil(
		caches.open(CACHE_NAME).then((cache) => {
			console.log('[ServiceWorker] Pre-caching offline page');
			return cache.addAll(FILES_TO_CACHE);
		})
	);
});

self.addEventListener("activate", event => {
	console.log('[ServiceWorker] Activate');

	event.waitUntil(
		caches.keys().then(function(keyList) {
			return Promise.all(keyList.map(function(key) {
				if (key !== CACHE_NAME) {
					console.log('[ServiceWorker] Removing old cache', key);
					return caches.delete(key);
				}
			}));
		})
	);

	self.clients.claim();
});

self.addEventListener('fetch', function(event) {
	console.log('Fetch!', event.request);

	event.respondWith(
		caches.match(event.request).then(function(response) {
			return response || fetch(event.request);
		})
	);
});
