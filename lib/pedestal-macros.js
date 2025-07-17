'use strict'

// Registers the api: macro, which creates a link to Codox-generated Clojure API documentation.
//
// Usage:
//
// api:var[ns=a.namespace.name]
//
// Example:
//    ... this implements the api:Router[io.pedestal.http.route.router] protocol ...
//
// var is the name of a var, such as `service`, or `router`.
// ns is the namespace containing the var; it can be omitted if it is `io.pedestal.http`.
// var can also be `*` which links the the namespace documentation, rather than a var within the namespace.
//
// Configuration: 
// Page attribute:
// - api_doc_root - URL for the root for API links, e.g., "http://pedestal.io/api/7.0"
// - default_api_ns - Default namespace (ns attribute), eg., "io.pedestal.http"
//
// A second macro, `clj:`, links to Clojure core documentation.  The URL is fixed, and the default namespace is `clojure.core`.

module.exports = function (registry) {

    // Fortunately, this is already a dependency:
    const he = require('html-entities');
    const quote = "`"

    registry.inlineMacro("api", function () {
        const self = this;

        self.process(function (parent, target, attributes) {
            // May also have to unescape target here
            const docAttributes = parent.getDocument().getAttributes();
            const api_root = docAttributes.api_doc_root;
            if (!api_root) {
                throw new Error("api macro: api_doc_root is not defined (in antora.yml or as page attribute)");
            }

            const namespace = attributes.ns || docAttributes.default_api_ns;

            if (!namespace) {
                console.error({ in: "api macro", target, attributes, docAttributes })
                throw new Error("api macro: must specify ns attribute, or default_api_ns page attribute")
            }

            var text = `link:${api_root}/${namespace}.html`;

            if (target != "*") {
                text += `#var-${target}[${target}]`;
            } else {
                text += `[${namespace}]`
            }

            return self.createInlinePass(parent,
                quote + text + quote,
                { attributes: { subs: "normal" } });
        });
    });

    registry.inlineMacro("clj", function () {
        const self = this;

        self.process(function (parent, target, attributes) {
            // Asciidoctor always converts HTML entities, have to back that down here:
            // (See https://docs.asciidoctor.org/asciidoc/latest/syntax-quick-reference/#text-replacements)
            // Because of some text replacements, you may need to escape things. For instance,
            // use `clj:cond\->[]`.

            const name = he.decode(target)
            const namespace = attributes.ns || "clojure.core";

            var text = `link:https://clojure.github.io/clojure/${namespace}-api.html`;

            if (target != "*") {
                text += `#${namespace}/${target}[${target}]`;
            } else {
                text += `[${namespace}]`;
            }

            // console.debug({ target, name, label, text });

            return self.createInlinePass(parent,
                text,
                { attributes: { subs: "normal" } });
        });
    });
};
