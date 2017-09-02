#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    if (req.method != "GET" && req.method != "HEAD" && req.method != "OPTIONS") {
	    return (pass);
	}
    if (req.http.cookie ~ "wordpress_logged_in|resetpass") {
        return (pass);
    }
    if (req.method == "GET" || req.method == "HEAD" || req.method == "OPTIONS") {
        set req.http.X-Method = req.method;
    }
    return(hash);
}

sub vcl_backend_fetch {

    if (bereq.http.X-Method) {
        set bereq.method = bereq.http.X-Method;
    }
    return (fetch);
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.

    if (beresp.status >= 400) {
        set beresp.ttl = 15s;
        set beresp.grace = 30s;
        return(deliver);
    }
    set beresp.grace = 1h;
    return(deliver);
}

sub vcl_hash {

    hash_data(req.method);
    hash_data(req.url);
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }
    return(lookup);
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.

    if (obj.hits > 0) {
                set resp.http.X-Cache = "HIT";
        } else {
                set resp.http.X-Cache = "MISS";
    }
    return (deliver);
}