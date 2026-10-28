# 03 — Tokens (`web/style.css`)

| Rôle | Light | Dark |
|---|---|---|
| bg / subtle / surface | #f6f3ec / #efebe1 / #fdfcf9 | #0a111e / #0e1727 / #111b2d |
| border / strong | #e2ddd0 / #cbc4b2 | #223049 / #33445f |
| text / muted / subtle | #182131 / #4f5a6e / #5f697b | #e8ecf4 / #a3aec3 / #8795ad |
| primary / fg | #0f1b2d / #fff | #eef1f7 / #0a111e |
| accent / accent-ink / soft | #d99a2b / #7f5000 / #f7ecd2 | #f0b13c / #f0b13c / #2a2314 |
| success / danger | #17724f / #ab3329 | #4cc38a / #ff8a7c |

Typo : 12/13/14/16/18/20/24/30/36/48+ ; `--font-display` Newsreader, `--font-sans` Geist, `--font-mono` Geist Mono (woff2 variables locaux, `font-display: swap`).
Rayons 6/10/16 ; ombres sm/md ; durées 150/220/420 ms ; `--ease-out` cubic-bezier(.22,1,.36,1) ; `--ease-settle` pour l'aiguille ; z-sticky 60.
Contrastes visés AA (texte muted ≥ 5:1 sur bg ; accent-ink #7f5000 ≈ 6:1) — calculés à la main, non mesurés par outil.
