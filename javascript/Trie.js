let Trie = function() {
	let root = null;

	let Node = function() {
		this.children = {};
		this.size = 0;
		this.end = false;

		this.getChild = function(s) {
			return this.children[s];
		}

		this.addChild = function(s) {
			let child = new Node();
			this.children[s] = child;
			return child;
		}

		this.add = function(word) {
			let child = this.getChild(word[0]);

			if (!child) {
				child = this.addChild(word[0]);
				this.size++;
			}

			if (word.length === 1) {
				this.end = true;
				return;
			}

			child.add(word.slice(1));
		}

		this.contains = function(word, prefix) {
			if (word[0] in this.children) {
				if (word.length === 1) {
					if (this.end || prefix) {
						return true;
					}
				}
				else {
					let child = this.getChild(word[0]);
					return child.contains(word.slice(1), prefix);
				}
			}

			return false;
		}
	}

	this.add = function(word) {
		if (!root) {
			root = new Node();
		}

		root.add(word);
	}

	this.contains = function(word, prefix = false) {
		if (!root) {
			return false;
		}

		return root.contains(word, prefix);
	}
}
