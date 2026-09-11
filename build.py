# -*- coding: utf-8 -*-
"""
Construieste index.html (document complet, pentru GitHub Pages) din
pentru-sara.html (fragmentul folosit de Claude Artifacts).

    python build.py
"""
import io, os, re, sys

AICI = os.path.dirname(os.path.abspath(__file__))
SURSA = os.path.join(AICI, "pentru-sara.html")
IESIRE = os.path.join(AICI, "index.html")

TITLU = "Pentru Sara"
DESCRIERE = ("La multi ani, Sara. O scrisoare trimisa din Bucuresti la Rouen, "
             "peste 1968 de kilometri.")

src = io.open(SURSA, encoding="utf-8").read()

taietura = src.find("</style>")
if taietura == -1:
    sys.exit("Nu gasesc </style> in sursa.")
taietura += len("</style>")

cap = src[:taietura]
corp = src[taietura:]

# titlul propriu al fragmentului ramane in <head>, il scot ca sa nu fie dublat
cap = re.sub(r"<title>.*?</title>\s*", "", cap, count=1, flags=re.S)

doc = u"""<!doctype html>
<html lang="ro">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>{titlu}</title>
<meta name="description" content="{desc}">

<!-- pagina e privata: are link public, dar nu vrem sa apara in cautari -->
<meta name="robots" content="noindex, nofollow, noarchive, noimageindex">
<meta name="googlebot" content="noindex, nofollow">

<meta property="og:type" content="website">
<meta property="og:title" content="{titlu}">
<meta property="og:description" content="{desc}">
<meta property="og:locale" content="ro_RO">
<meta name="twitter:card" content="summary">
<meta name="theme-color" content="#030711">
<meta name="color-scheme" content="dark">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E%F0%9F%8C%99%3C/text%3E%3C/svg%3E">

<style>
  html{{color-scheme:dark}}
  img{{max-width:100%}}
  [hidden]{{display:none!important}}
</style>
{cap}
</head>
<body>
{corp}
</body>
</html>
"""

doc = doc.format(titlu=TITLU, desc=DESCRIERE, cap=cap.strip(), corp=corp.strip())

io.open(IESIRE, "w", encoding="utf-8", newline="\n").write(doc)

marime = os.path.getsize(IESIRE)
print("index.html scris: %d KB" % round(marime / 1024.0))
