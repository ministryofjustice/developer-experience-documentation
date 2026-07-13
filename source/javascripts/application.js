//= require govuk_tech_docs

(function () {
	function loadMermaid() {
		return new Promise(function (resolve, reject) {
			if (window.mermaid) {
				resolve(window.mermaid);
				return;
			}

			var existing = document.querySelector('script[data-mermaid-loader="true"]');
			if (existing) {
				existing.addEventListener('load', function () {
					resolve(window.mermaid);
				});
				existing.addEventListener('error', reject);
				return;
			}

			var script = document.createElement('script');
			script.src = 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js';
			script.async = true;
			script.setAttribute('data-mermaid-loader', 'true');
			script.onload = function () {
				resolve(window.mermaid);
			};
			script.onerror = reject;
			document.head.appendChild(script);
		});
	}

	function normalizeFenceLikeBlocks() {
		var selector = 'pre.highlight.plaintext > code, pre > code.language-mermaid';
		var codeBlocks = document.querySelectorAll(selector);

		codeBlocks.forEach(function (code) {
			var text = (code.textContent || '').trim();
			if (!text) {
				return;
			}

			var looksLikeMermaid = /^(graph|flowchart|sequenceDiagram|classDiagram|stateDiagram|erDiagram|journey|gantt|pie|mindmap|timeline)\b/m.test(text);
			if (!looksLikeMermaid) {
				return;
			}

			var pre = code.closest('pre');
			if (!pre || pre.previousElementSibling && pre.previousElementSibling.classList && pre.previousElementSibling.classList.contains('mermaid')) {
				return;
			}

			var container = document.createElement('div');
			container.className = 'mermaid';
			container.textContent = text;
			pre.parentNode.insertBefore(container, pre);
			pre.remove();
		});
	}

	function initMermaid() {
		normalizeFenceLikeBlocks();

		var mermaidNodes = document.querySelectorAll('.mermaid');
		if (!mermaidNodes.length) {
			return;
		}

		loadMermaid()
			.then(function (mermaid) {
				mermaid.initialize({
					startOnLoad: false,
					securityLevel: 'loose',
					theme: 'default'
				});
				mermaid.run({ querySelector: '.mermaid' });
			})
			.catch(function (error) {
				console.error('Mermaid failed to load:', error);
			});
	}

	document.addEventListener('DOMContentLoaded', initMermaid);
})();
