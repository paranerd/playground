/**
 * Get 1-based index of element in parent
 *
 * @param {HTMLElement} elem
 * @returns {number}
 */
function getChildIndex(elem) {
	let i = 1;
	while ((elem = elem.previousSibling) != null) ++i;

	return i;
}
