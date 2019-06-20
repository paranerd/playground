let BinaryTree = function() {
	let root = null;

	let Node = function(value) {
		this.value = value;
		this.left = null;
		this.right = null;
	}

	this.add = function(value, node = null) {
		node = node || root;

		if (!root) {
			root = new Node(value);
			return;
		}

		if (value < node.value) {
			if (node.left) {
				this.add(value, node.left);
			}
			else {
				node.left = new Node(value);
			}
		}
		else {
			if (node.right) {
				this.add(value, node.right);
			}
			else {
				node.right = new Node(value);
			}
		}
	}

	this.add_iterative = function(value) {
		let current = root;
		let node = new Node(value);

		while (current) {
			if (value < current.value) {
				if (current.left) {
					current = current.left;
				}
				else {
					current.left = node;
					break;
				}
			}
			else {
				if (current.right) {
					current = current.right;
				}
				else {
					current.right = node;
					break;
				}
			}
		}
	}

	this.height = function(node = null, recursed = false) {
		node = (recursed) ? node : root;

		if (!node) {
			// If you want to include the root node in height, return 0!
			return -1;
		}

		return Math.max(this.height(node.left, true), this.height(node.right, true)) + 1;
	}

	this.heightIterative = function() {
		let queue = [root];
		let height = 0;

		while (queue.length > 0) {
			let size = queue.length;

			while (size > 0) {
				let node = queue.shift();

				if (node.left) {
					queue.push(node.left);
				}
				if (node.right) {
					queue.push(node.right);
				}

				size--;
			}

			height++
		}

		return height - 1;
	}

	this.depthFirstSearch = function(order = 'in', node = null) {
		node = node || root;

		let values = []

		// NLR
		if (order == 'pre') {
			values.push(node.value);
		}

		if (node.left) {
			values = values.concat(this.depthFirstSearch(order, node.left));
		}

		// LNR
		if (order == 'in') {
			values.push(node.value);
		}

		if (node.right) {
			values = values.concat(this.depthFirstSearch(order, node.right));
		}

		// LRN
		if (order == 'post') {
			values.push(node.value);
		}

		return values;
	}

	this.dfsPreOrder = function() {
		let stack = [root];
		let result = [];

		while (stack.length > 0) {
			let node = stack.shift();
			result.push(node.value);

			if (node.right) {
				stack.unshift(node.right);
			}
			if (node.left) {
				stack.unshift(node.left);
			}
		}

		return result;
	}

	this.breadthFirstSearch = function() {
		let queue = [root];
		let result = [];

		while (queue.length > 0) {
			let node = queue.shift();

			result.push(node.value);

			if (node.left) {
				queue.push(node.left);
			}
			if (node.right) {
				queue.push(node.right);
			}
		}

		return result;
	}
}

let bt = new BinaryTree();
bt.add(10);
bt.add(5);
bt.add(15);
bt.add(7);
bt.add(4);

console.log(bt.breadthFirstSearch());
