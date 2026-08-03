#!/usr/bin/env python3
"""Clustert die Eingaben eines Export-JSON thematisch (für Phase 3, >20 Einträge).

Aufruf:  python3 scripts/synthesize.py export.json
         cat export.json | python3 scripts/synthesize.py

Gibt JSON mit Clustern (nach Wortüberlappung) und Solitären aus. Das ist
bewusst nur eine Vorsortierung — die inhaltliche Benennung und Bewertung
der Cluster bleibt Aufgabe des Skills, nicht dieses Scripts.
"""
import json
import re
import sys
from itertools import combinations

STOPWORDS = {
    "der", "die", "das", "und", "oder", "ein", "eine", "einen", "einem", "einer",
    "ist", "sind", "war", "mit", "für", "von", "auf", "aus", "bei", "als", "auch",
    "nicht", "kein", "keine", "wir", "ihr", "sie", "ich", "man", "sich", "dass",
    "wie", "was", "wenn", "dann", "noch", "nur", "aber", "mehr", "sehr", "kann",
    "the", "and", "for", "with", "that", "this", "not", "are", "was", "can",
}
MIN_OVERLAP = 2  # gemeinsame signifikante Wörter, ab denen zwei Einträge verbunden gelten


def tokens(text):
    words = re.findall(r"[a-zA-ZäöüÄÖÜß]{3,}", text.lower())
    return {w for w in words if w not in STOPWORDS}


def cluster(entries):
    toks = [tokens(e["text"]) for e in entries]
    # Union-Find über Paare mit ausreichender Wortüberlappung
    parent = list(range(len(entries)))

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    for i, j in combinations(range(len(entries)), 2):
        if len(toks[i] & toks[j]) >= MIN_OVERLAP:
            parent[find(i)] = find(j)

    groups = {}
    for i in range(len(entries)):
        groups.setdefault(find(i), []).append(i)

    clusters, solitaere = [], []
    for members in groups.values():
        if len(members) == 1:
            solitaere.append(entries[members[0]])
            continue
        shared = set.intersection(*(toks[m] for m in members)) or set.union(
            *(toks[m] for m in members)
        )
        clusters.append({
            "schluesselwoerter": sorted(shared)[:5],
            "eintraege": [entries[m] for m in members],
        })
    clusters.sort(key=lambda c: -len(c["eintraege"]))
    return clusters, solitaere


def main():
    raw = open(sys.argv[1]).read() if len(sys.argv) > 1 else sys.stdin.read()
    export = json.loads(raw)
    entries = export.get("eingaben", [])
    if not entries:
        sys.exit("Keine eingaben[] im Export gefunden.")
    clusters, solitaere = cluster(entries)
    json.dump(
        {
            "method_id": export.get("method_id"),
            "anzahl_eintraege": len(entries),
            "cluster": clusters,
            "solitaere": solitaere,
        },
        sys.stdout,
        ensure_ascii=False,
        indent=2,
    )
    print()


if __name__ == "__main__":
    main()
