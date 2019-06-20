let LinkedList = function() {
	let head = null;

	/**
	 * LinkedList-Node Helper class
	 */
	let Node = function(value) {
		this.value = value;
		this.next = null;
	}

	/**
	 * Add value to the end of the list
	 *
	 * @param int value
	 */
	this.add = function(value) {
		let current = head;
		let node = new Node(value);

		if (!head) {
			head = node;
			return;
		}

		while (current.next) {
			current = current.next;
		}

		current.next = node;
	}

	/**
	 * Insert value at specific position
	 *
	 * @param int value
	 * @param int position
	 */
	this.insertAt = function(value, position) {
		let node = new Node(value);
		let current = head;
		let index = 0;

		if (position == 0) {
			node.next = head;
			head = node;
			return;
		}

		while (current.next && index < position - 1) {
			index++;
			current = current.next;
		}

		if (current.next) {
			node.next = current.next;
		}

		current.next = node;
	}

	/**
	 * Remove first node with a specific value
	 *
	 * @param int value
	 * @return boolean
	 */
	this.remove = function(value) {
		let current = head;

		if (head.value == value) {
			head = head.next;
			return true;
		}

		while (current.next) {
			if (current.next.value == value) {
				current.next = current.next.next;
				return true;
			}

			current = current.next;
		}

		return false;
	}

	/**
	 * Remove element at specific position
	 *
	 * @param int position
	 * @return boolean
	 */
	this.removeAt = function(position) {
		let index = 0;
		let current = head;

		if (position == 0) {
			head = head.next;
			return true;
		}

		while (current.next && index < position) {
			if (index == position - 1) {
				current.next = current.next.next;
				return true;
			}

			index++;
			current = current.next;
		}

		return false;
	}

	/**
	 * Merge using a whole new LinkedList
	 *
	 * @param Node head2
	 */
	this.merge = function(head2) {
		let headNew = null;
		let currentNew = null;
		let current1 = head;
		let current2 = head2;

		if (!head) {
			head = head2;
			return;
		}

		if (!head2) {
			return;
		}

		while (current1 && current2) {
			let value = Math.min(current1.value, current2.value);
			let node = new Node(value);

			if (!headNew) {
				headNew = node;
				currentNew = headNew;
			}
			else {
				currentNew.next = node;
				currentNew = currentNew.next;
			}

			if (value == current1.value) {
				current1 = current1.next;
			}
			else {
				current2 = current2.next;
			}
		}

		while (current1) {
			currentNew.next = new Node(current1.value);
			currentNew = currentNew.next;
			current1 = current1.next;
		}

		while (current2) {
			currentNew.next = new Node(current2.value);;
			currentNew = currentNew.next;
			current2 = current2.next;
		}

		head = headNew;
	}

	/**
	 * Merge in place
	 *
	 * @param Node head2
	 */
	this.mergeInPlace = function(head2) {
		let current1 = head;
		let current2 = head2;

		if (!head) {
			head = head2;
			return;
		}

		if (!head2) {
			return;
		}

		// Update head for all elements smaller than the head
		while (current2 && current2.value < current1.value) {
			let node = new Node(current2.value);
			node.next = head;
			head = node;
			current1 = head;
			current2 = current2.next;
		}

		// Check for each element if the current element of list2 is smaller than the next element
		while (current1.next && current2) {
			// If current element of list 2 is smaller than the one following in list1, squeeze it in between
			if (current2.value < current1.next.value) {
				let node = new Node(current2.value);
				node.next = current1.next;
				current1.next = node;
				current2 = current2.next;
			}

			current1 = current1.next;
		}

		// Insert remaining elements (if any)
		while (current2) {
			current1.next = new Node(current2.value);
			current1 = current1.next;
			current2 = current2.next;
		}
	}

	/**
	 * Merge in place using a pointer to the previous element
	 *
	 * @param Node head2
	 */
	this.mergeInPlace2 = function(head2) {
		let current1 = head;
		let current2 = head2;
		let previous1 = null;

		if (!head) {
			head = head2;
			return;
		}

		if (!head2) {
			return;
		}

		while (current1 && current2) {
			if (current2.value < current1.value) {
				let node = new Node(current2.value);
				node.next = current1;

				if (previous1) {
					previous1.next = node;
				}
				else {
					head = node;
				}

				previous1 = node;
				current2 = current2.next;
			}
			else {
				previous1 = current1;
				current1 = current1.next;
			}
		}

		while (current2) {
			let node = new Node(current2.value);
			previous1.next = node;
			previous1 = node;
			current2 = current2.next;
		}
	}

	this.getAt = function(pos) {
		let current = head;
		let index = 0;

		if (pos < 0) {
			return null;
		}

		while (current && index < pos) {
			current = current.next;
			index++;
		}

		return (current) ? current.value : null;
	}

	/**
	 * Find the merge point of two Linked Lists
	 * Time complexity of O(n + m)
	 * Space complexity of O(n + m)
	 *
	 * @param Node head2
	 *
	 * @return boolean
	 */
	this.mergePoint = function(head2) {
		let current1 = head;
		let current2 = head2;

		let arr1 = [];
		let arr2 = [];

		while (current1) {
			arr1.push(current1.value);
			current1 = current1.next;
		}

		while (current2) {
			arr2.push(current2.value);
			current2 = current2.next;
		}

		let min = Math.min(arr1.length, arr2.length);
		let count = 1;
		let len1 = arr1.length;
		let len2 = arr2.length;
		let mergePoint = null;

		while (count <= min && arr1[len1 - count] == arr2[len2 - count]) {
			mergePoint = arr1[len1 - count];
			count++;
		}

		return mergePoint;
	}

	/**
	 * Find the merge point of two Linked Lists
	 * Time complexity of O(n + m)
	 * Space complexity of O(1)
	 *
	 * @param Node head2
	 *
	 * @return boolean
	 */
	this.mergePoint2 = function(head2) {
		let current1 = head;
		let current2 = head2;
		let len1 = 0;
		let len2 = 0;

		while (current1.next) {
			len1++;
			current1 = current1.next;
		}

		while (current2.next) {
			len2++;
			current2 = current2.next;
		}

		current1 = head;
		current2 = head2;

		if (len1 > len2) {
			for (let i = 0; i < len1 - len2; i++) {
				current1 = current1.next;
			}
		}
		else if (len2 > len1) {
			for (let i = 0; i < len2 - len1; i++) {
				current2 = current2.next;
			}
		}

		while (current1 && current2) {
			if (current1.value === current2.value) {
				return current1.value;
			}

			current1 = current1.next;
			current2 = current2.next;
		}

		return null;
	}

	this.partition = function(value) {
		let current = head;
		let head1 = null;
		let current1 = null;
		let head2 = null;
		let current2 = null;

		while (current) {
			let node = new Node(current.value);

			if (current.value < value) {
				if (!head1) {
					head1 = node;
					current1 = node;
				}
				else {
					current1.next = node;
					current1 = current1.next;
				}
			}
			else {
				if (!head2) {
					head2 = node;
					current2 = node;
				}
				else {
					current2.next = node;
					current2 = current2.next;
				}
			}

			current = current.next;
		}

		if (head1) {
			current1.next = head2;
		}
		else {
			head1 = head2;
		}

		let test1 = head1;
		while (test1) {
			console.log(test1.value);
			test1 = test1.next;
		}

		return head1;
	}

	/**
	 * Detect cycles using Floyd’s Cycle detection algorithm
	 *
	 * @return boolean
	 */
	this.hasCycle = function() {
		if (!head) {
			return false;
		}

		let fast = head.next;
		let slow = head;

		while (fast && fast.next && slow) {
			if (fast == slow) {
				return true;
			}
			fast = fast.next.next;
			slow = slow.next;
		}

		return false;
	}

	/**
	 * Print the LinkedList as an array
	 */
	this.print = function() {
		let elements = [];
		let current = head;

		while (current) {
			elements.push(current.value);
			current = current.next;
		}

		console.log(elements);
	}

	/**
	 * Return head
	 */
	this.getHead = function() {
		return head;
	}
}
