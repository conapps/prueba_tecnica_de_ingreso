# Parche global: IOSv (router) negocia KEX legacy; IOL/XE (switches) SSH moderno.
# Ansible network_cli usa Paramiko — ofrecer ambos conjuntos de algoritmos.
try:
    import paramiko

    paramiko.Transport._preferred_kex = (
        "diffie-hellman-group-exchange-sha256",
        "diffie-hellman-group14-sha256",
        "ecdh-sha2-nistp256",
        "ecdh-sha2-nistp384",
        "ecdh-sha2-nistp521",
        "diffie-hellman-group14-sha1",
        "diffie-hellman-group-exchange-sha1",
        "diffie-hellman-group1-sha1",
    )
    paramiko.Transport._preferred_keys = (
        "rsa-sha2-512",
        "rsa-sha2-256",
        "ssh-rsa",
    )
except ImportError:
    pass
