# Leaf Reader for Omarchy

Leaf Reader turns the Omarchy bar into a calm, local-first ebook library. Click the book icon to browse your covers; right-click it to jump straight back into the last book and exact location you were reading.

The library panel is compact and native to the Omarchy shell. Reading opens in a spacious native Qt window designed to disappear around the page: quiet typography, restrained controls, no accounts, no cloud, and no library management ceremony.

## What it does

- Remembers the last book, exact EPUB location, percentage, chapter, and bookmarks
- Loads the last-read book first and keeps a prominent **Continue reading** card
- Recursively scans any folder you choose
- Groups multiple formats of the same book into one library entry
- Reads EPUB directly, with covers and metadata extracted locally
- Reads PDF through Qt WebEngine's built-in viewer
- Supports AZW3, MOBI, AZW, PRC, FB2, FBZ, HTMLZ, RTF, TXT, and TXTZ when the optional `ebook-convert` command is available
- Includes title/author search, table of contents, in-book search, bookmarks, progress scrubbing, and keyboard navigation
- Provides text size, serif/sans/publisher fonts, line spacing, reading width, page/scroll layouts, and paper/sepia/slate/night themes
- Stores state under XDG state/cache folders and never uploads book data

## Install

```bash
omarchy plugin add https://github.com/dlpwaters/omarchy-ebook-reader.git --enable
```

Leaf Reader needs `qt6-webengine`, `python`, and `zenity`. These are already present on a standard current Omarchy installation. EPUB and PDF work without Calibre.

For Kindle and other conversion-only formats, install Calibre only if you need it:

```bash
omarchy pkg add calibre
```

Then click the Leaf Reader bar icon, open the settings button, and choose your ebook folder. The scan includes subfolders automatically.

## Use

- Left-click the bar icon: open the library
- Right-click the bar icon: resume the last book
- Click a cover: read it
- `←` / `→`, `Page Up` / `Page Down`, or `Space`: turn pages
- `/`: search the current book
- `T`: table of contents
- `B`: add or remove a bookmark
- `A`: reading appearance
- `L`: library
- `Ctrl+Shift+Q`: close the reading window

Reader controls fade away while you read and return when the pointer approaches the top or bottom edge.

## Formats

| Format | How it opens |
| --- | --- |
| EPUB | Directly in the bundled offline EPUB engine |
| PDF | Directly in Qt WebEngine |
| AZW3, MOBI, AZW, PRC | Converted locally to a cached EPUB on first open |
| FB2, FBZ, HTMLZ, RTF, TXT, TXTZ | Converted locally to a cached EPUB on first open |

If a book folder contains EPUB plus another format, Leaf Reader always prefers the EPUB and does not convert anything. DRM-protected ebooks cannot be opened or converted.

## Privacy and storage

Nothing is sent over the network. The helper binds only to `127.0.0.1`, uses a per-process request token for writes, and serves only known books and bundled reader assets.

- Settings: `$XDG_STATE_HOME/omarchy-ebook-reader/settings.json`
- Reading progress and bookmarks: `$XDG_STATE_HOME/omarchy-ebook-reader/progress.json`
- Metadata, cover, and conversion cache: `$XDG_CACHE_HOME/omarchy-ebook-reader/`

Your original books are never modified.

## Verify a checkout

```bash
python3 -m unittest discover -s tests -v
python3 -m py_compile ebook-tool
node --check web/app.js
qmllint -I /usr/share/omarchy/shell BarWidget.qml Panel.qml Reader.qml
omarchy plugin validate .
./ebook-tool doctor
```

## Troubleshooting

Run `./ebook-tool doctor` inside the plugin folder. It reports the selected library, scanned book count, EPUB renderer, Qt WebEngine, and optional converter status.

If a folder was moved, choose it again in Reader settings. If covers or metadata changed, use the rescan button in the panel. A first open of a large AZW3/MOBI book may take a moment because the conversion is done locally and cached for later opens.

## License

Leaf Reader is MIT licensed. Bundled dependency licenses are documented in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
