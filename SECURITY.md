# Security

Leaf Reader is local-first. Its helper listens only on `127.0.0.1`, uses a random per-process token for state-changing requests, and serves only bundled assets plus files already identified by the library scanner.

Please report a vulnerability through GitHub's private security-advisory form for this repository. Do not include private ebook files, API keys, or reading-history data in a public issue.
