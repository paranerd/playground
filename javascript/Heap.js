let Heap = function(max) {
	this.max = max;
	this.values = [null];

	this.add = function(value) {
		this.values.push(value);
		this.orderUpwards();
		return this.values;
	}

	this.remove = function() {
		// Remove the first value (actually second, because of null being the first)
		this.values.splice(1, 1);

		// Move the last element up front
		this.values.splice(1, 0, this.values.pop());
		this.orderDownwards();
		return this.values;
	}

	this.orderDownwards = function() {
		let p = 1;
		let l = this.getLeftChildIndex(p);
		let r = this.getRightChildIndex(p);

		// Check if any of the child nodes are bigger (max) or smaller (min) than their parent
		while ((l !== null && this.rightOrder(this.values[l], this.values[p])) ||
			(r !== null && this.rightOrder(this.values[r], this.values[p])))
		{
			if (r === null || this.rightOrder(this.values[l], this.values[r])) {
				let backup = this.values[p];
				this.values[p] = this.values[l];
				this.values[l] = backup;
				p = l;
			}
			else if (l === null || this.rightOrder(this.values[r], this.values[l])) {
				let backup = this.values[p];
				this.values[p] = this.values[r];
				this.values[r] = backup;
				p = r;
			}

			l = this.getLeftChildIndex(p);
			r = this.getRightChildIndex(p);
		}
	}

	// When max: val1 should be larger than val2
	// When min: val1 should be smaller than val2
	this.rightOrder = function(val1, val2) {
		return (this.max) ? val1 > val2 : val1 < val2;
	}

	this.orderUpwards = function() {
		let v = this.values.length - 1;
		let p = this.getParentIndex(v);

		while (p !== null && this.rightOrder(this.values[v], this.values[p])) {
			let backup = this.values[p];
			this.values[p] = this.values[v];
			this.values[v] = backup;
			v = p;
			p = this.getParentIndex(v);
		}
	}

	this.getParentIndex = function(childIndex) {
		if (childIndex === 1) {
			return null;
		}

		return Math.floor(childIndex / 2);
	}

	this.getLeftChildIndex = function(parentIndex) {
		let index = parentIndex * 2;
		return (index > this.values.length - 1) ? null : index;
	}

	this.getRightChildIndex = function(parentIndex) {
		let index = parentIndex * 2 + 1
		return (index > this.values.length - 1) ? null : index;
	}

	this.print = function() {
		document.write(this.values.slice(1) + "</br>");
	}
}
