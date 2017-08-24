var Guts = {
	types: {
		element: 1,
		array: 2,
		arrayofarrays: 3,
		object: 4,
		json: 5,
		string: 6,
		selector: 7
	},
	isElement: function(obj) {
		try {
			return obj instanceof HTMLElement;
		} catch (e) {
			return typeof obj === 'object' && obj.nodeType === 1 && typeof obj.style === 'object' && typeof obj.ownerDocument === 'object';
		}
	},
	isArray: function(a) {
		return (!!a) && (a.constructor === Array);
	},
	isArrayOfArrays: function(a) {
		return (!!a) && (a.constructor === Array) && this.isArray(a[0]);
	},
	isObject: function(a) {
		return typeof a === 'object' && !this.isArray(a);
	},
	isJSON: function(a) {
		return this.isObject(a) || (this.isArray(a) && !this.isArrayOfArrays(a));
	},
	isString: function(a) {
		return typeof a === 'string';
	},
	isFunction: function(functionToCheck) {
		var getType;
		getType = {};
		return functionToCheck && getType.toString.call(functionToCheck) === '[object Function]';
	},
	getDataType: function(a) {
		if (this.isString(a)) {
			return Guts.types.selector;
		} else if (this.isArrayOfArrays(a)) {
			return Guts.types.arrayofarrays;
		} else if (this.isJSON(a)) {
			return Guts.types.json;
		} else {
			return null;
		}
	}
};