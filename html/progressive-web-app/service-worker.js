'use strict';

const CACHE_NAME = 'static-cache-v1';

const FILES_TO_CACHE = [
	'/',
	'/index.html',
	'/assets/icon.png'
];

self.addEventListener('install', function() {
	console.log('[ServiceWorker] Install');

	self.skipWaiting();
});

self.addEventListener("activate", event => {
	console.log('[ServiceWorker] Activate');

	self.clients.claim();
});
self.addEventListener('fetch', function(event) {
	console.log('Fetch!', event.request);

	event.waitUntil(
		caches.open(CACHE_NAME).then((cache) => {
			console.log('[ServiceWorker] Pre-caching offline page');
			return cache.addAll(FILES_TO_CACHE);
		})
	);
});
