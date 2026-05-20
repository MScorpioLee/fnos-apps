// fnOS framework field guard for mihomo external-controller / external-ui
// Intercepts PUT /configs requests and rewrites the payload so that
// loading a user's upstream config (which typically has external-controller: 127.0.0.1:9090)
// does NOT cause mihomo to switch ports and break the dashboard connection.
(function () {
    var P = "__FNOS_PORT__";
    var origFetch = window.fetch;
    window.fetch = function (input, init) {
        try {
            var url = typeof input === "string" ? input : (input && input.url) || "";
            if (init && init.method === "PUT" && url.indexOf("/configs") >= 0 && init.body) {
                var body = JSON.parse(init.body);
                if (body && body.payload && typeof body.payload === "string") {
                    var p = body.payload;
                    // Force external-controller to fnOS-managed port
                    p = p.match(/^external-controller:/m)
                        ? p.replace(/^external-controller:.*$/m, "external-controller: 0.0.0.0:" + P)
                        : "external-controller: 0.0.0.0:" + P + "\n" + p;
                    // Force external-ui to relative path so mihomo SAFE_PATHS check passes
                    p = p.match(/^external-ui:/m)
                        ? p.replace(/^external-ui:.*$/m, "external-ui: metacubexd")
                        : p.replace(/(^external-controller:.*$)/m, "$1\nexternal-ui: metacubexd");
                    body.payload = p;
                    init = Object.assign({}, init, { body: JSON.stringify(body) });
                    console.log("[fnOS patch] payload external-controller/external-ui rewritten to fnOS values");
                }
            }
        } catch (e) {
            console.warn("[fnOS patch] failed to rewrite payload:", e);
        }
        return origFetch.call(this, input, init);
    };
    console.log("[fnOS patch] external-controller guard installed (port " + P + ")");
})();
