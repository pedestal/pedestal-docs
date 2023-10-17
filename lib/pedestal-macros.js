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
// - api_doc_root - URL for the root for API links, e.g., "http://pedestal.io/api"
// - default_api_ns - Default namespace (ns attribute), eg., "io.pedestal.http"

module.exports = function (registry) {

    registry.inlineMacro("api", function () {
        const self = this; // Could we use arrow funcs here instead?

        self.process(function (parent, target, attributes) {
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

            // if (target == "execute") { console.debug({ target, attributes, text, docAttributes }) }

            return self.createInlinePass(parent,
                text,
                attributes,
                { subs: "normal" });
        });
    });
};
