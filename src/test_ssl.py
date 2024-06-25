import socket
import ssl

print(f"[INFO] OpenSSL version: {ssl.OPENSSL_VERSION}")

hostname = "www.python.org"
context = ssl.create_default_context()

with socket.create_connection((hostname, 443)) as sock:
    with context.wrap_socket(sock, server_hostname=hostname) as ssock:
        assert ssock.version(), "Failed getting SSL version"
