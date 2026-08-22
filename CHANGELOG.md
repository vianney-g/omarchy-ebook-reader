# Changelog

## 1.1.0 — 2026-08-21

- Four reviewed public-domain starter books for an immediately useful offline shelf
- Fresh installs prefer an existing `~/Books` library, then fall back to the bundled starter shelf
- Crisper Noto Serif/Noto Sans rendering across the reader and library panel
- Page turns no longer wake the top and bottom reader controls
- Controls now respond deliberately to pointer movement, click/tap, and Escape
- Current Omarchy panel-switching contract and single-instance manifest declaration
- Conflict-free ephemeral loopback port passed explicitly to the native reader
- Off-the-record WebEngine profile with outbound networking disabled for book content
- Defensive ebook ignores and provenance records to prevent private libraries from entering releases

## 1.0.0 — 2026-08-21

- Native Omarchy library panel with cover grid, search, sorting, and folder selection
- Exact EPUB CFI resume, reading percentage, chapter state, and bookmarks
- Direct offline EPUB and PDF reading
- Optional local conversion and caching for AZW3, MOBI, AZW, PRC, FB2, FBZ, HTMLZ, RTF, TXT, and TXTZ
- Paper, Sepia, Slate, and Night reading themes
- Font, text size, line spacing, reading width, and paginated/scrolled layout controls
- Meditations-inspired 3D page turns with reduced-motion support
- Table of contents, in-book search, progress scrubbing, and keyboard navigation
- Crash-isolated Qt 6 reader process with deterministic Hyprland fullscreen activation
