/**
 * jQuery plugin to convert a given $.ajax response xml object to json.
 *
 * @example var json = $.xml2json(response);
 */
(function() {

	// default options based on https://github.com/Leonidas-from-XIV/node-xml2js
	var defaultOptions = {
		attrkey: '$',
		charkey: '_',
		normalize: false
	};

	// extracted from jquery
	function parseXML(data) {
		var xml, tmp;
		if (!data || typeof data !== "string") {
			return null;
		}
		try {
			if (window.DOMParser) { // Standard
				tmp = new DOMParser();
				xml = tmp.parseFromString(data, "text/xml");
			} else { // IE
				xml = new ActiveXObject("Microsoft.XMLDOM");
				xml.async = "false";
				xml.loadXML(data);
			}
		} catch (e) {
			xml = undefined;
		}
		if (!xml || !xml.documentElement || xml.getElementsByTagName("parsererror").length) {
			throw new Error("Invalid XML: " + data);
		}
		return xml;
	}

	function normalize(value, options){
		if (!!options.normalize){
			return (value || '').trim();
		}
		return value;
	}

	function xml2jsonImpl(xml, options) {

		var i, result = {}, attrs = {}, node, child, name;
		result[options.attrkey] = attrs;

		if (xml.attributes && xml.attributes.length > 0) {
			for (i = 0; i < xml.attributes.length; i++){
				var item = xml.attributes.item(i);
				attrs[item.nodeName] = item.value;
			}
		}

		// element content
		if (xml.childElementCount === 0) {
			result[options.charkey] = normalize(xml.textContent, options);
		}

		for (i = 0; i < xml.childNodes.length; i++) {
			node = xml.childNodes[i];
			if (node.nodeType === 1) {

				if (node.attributes.length === 0 && node.childElementCount === 0){
					child = normalize(node.textContent, options);
				} else {
					child = xml2jsonImpl(node, options);
				}

				name = node.nodeName;
				if (result.hasOwnProperty(name)) {
					// For repeating elements, cast/promote the node to array
					var val = result[name];
					if (!Array.isArray(val)) {
						val = [val];
						result[name] = val;
					}
					val.push(child);
				} else {
					result[name] = child;
				}
			}
		}

		return result;
	}

	/**w
	 * Converts an xml document or string to a JSON object.
	 *
	 * @param xml
	 */
	function xml2json(xml, options) {
		if (!xml) {
			return xml;
		}

		options = options || defaultOptions;

		if (typeof xml === 'string') {
			xml = parseXML(xml).documentElement;
		}

		var root = {};

		if (xml.attributes.length === 0 && xml.childElementCount === 0){
			root[xml.nodeName] = normalize(xml.textContent, options);
		} else {
			root[xml.nodeName] = xml2jsonImpl(xml, options);
		}

		return root;
	}

	if (typeof jQuery !== 'undefined') {
		jQuery.extend({xml2json: xml2json});
	} else if (typeof module !== 'undefined') {
		module.exports = xml2json;
	} else if (typeof window !== 'undefined') {
		window.xml2json = xml2json;
	}
})();
