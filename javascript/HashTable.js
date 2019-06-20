let HashTable = function(size) {
	this.size = size;
	this.buckets = [];

	this.hash = function(key) {
		let sum = 0;

		for (let i = 0; i < key.length; i++) {
			sum += i * key.charCodeAt(i);
		}

		return sum % this.size;
	}

	this.insert = function(key, value) {
		let hash = this.hash(key);

		// Create bucket if not exists
		// Array for simplicity
		// For performance reasons you would actually use a Linked List
		if (typeof this.buckets[hash] === 'undefined') {
			this.buckets[hash] = []
		}

		this.buckets[hash].push({key: key, value: value});
	}

	this.retrieve = function(key) {
		let bucket = this.buckets[this.hash(key)];

		for (let i = 0; i < bucket.length; i++) {
			if (bucket[i].key == key) {
				return bucket[i].value;
			}
		}
	}
}
