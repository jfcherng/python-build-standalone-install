import ssl

try:
    import sitecustomize2  # noqa: F401
except ImportError:
    pass


def __use_certifi_cert_by_default() -> None:
    try:
        import certifi

        # define a function that returns a default SSL context with certifi's CA bundle
        def create_certifi_context(*args, cafile=None, **kwargs):
            return ssl_create_default_context_bak(*args, cafile=cafile or certifi.where(), **kwargs)

        # backup the original ssl.create_default_context
        ssl_create_default_context_bak = ssl.create_default_context
        # set the default SSL context creation function to use certifi's CA bundle
        ssl._create_default_https_context = ssl.create_default_context = create_certifi_context
    except Exception as e:
        print(f"certifi package is not installed: {e}")


__use_certifi_cert_by_default()
