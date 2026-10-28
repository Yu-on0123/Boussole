"""Pont Python <-> Prolog.

Chaque appel lance SWI-Prolog (`swipl`) avec `prolog/moteur.pl`, lui envoie une
requête JSON sur l'entrée standard et lit la réponse JSON sur la sortie
standard. Aucune bibliothèque de liaison (pyswip, janus) n'est nécessaire :
cela fonctionne de la même façon sous Windows, Linux, macOS et Docker.

Variable d'environnement facultative :
    SWIPL  chemin complet vers l'exécutable SWI-Prolog
           (ex. C:\\Program Files\\swipl\\bin\\swipl.exe)
"""
from __future__ import annotations

import json
import os
import shutil
import subprocess
from pathlib import Path

RACINE = Path(__file__).resolve().parent.parent
DOSSIER_PROLOG = RACINE / "prolog"
FICHIER_MOTEUR = DOSSIER_PROLOG / "moteur.pl"
DELAI_SECONDES = 15


class MoteurIndisponible(RuntimeError):
    """SWI-Prolog est introuvable ou n'a pas répondu."""


class MoteurErreur(RuntimeError):
    """Le moteur Prolog a refusé la requête (réponse invalide, etc.)."""

    def __init__(self, message: str, code: str) -> None:
        super().__init__(message)
        self.code = code


def trouver_swipl() -> str:
    candidat = os.environ.get("SWIPL", "swipl")
    chemin = shutil.which(candidat)
    if chemin is None:
        raise MoteurIndisponible(
            "SWI-Prolog est introuvable. Installe-le (https://www.swi-prolog.org) "
            "et ajoute-le au PATH, ou renseigne la variable d'environnement SWIPL."
        )
    return chemin


def appeler(action: str, reponses: dict[str, str] | None = None) -> dict:
    """Envoie une requête au moteur Prolog et renvoie sa réponse décodée."""
    requete = {"action": action, "reponses": reponses or {}}
    commande = [trouver_swipl(), "-q", "-g", "main", "-t", "halt", str(FICHIER_MOTEUR)]
    try:
        processus = subprocess.run(
            commande,
            input=json.dumps(requete).encode("utf-8"),
            capture_output=True,
            timeout=DELAI_SECONDES,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        raise MoteurIndisponible("Le moteur Prolog n'a pas répondu à temps.") from exc

    sortie = processus.stdout.decode("utf-8", errors="replace").strip()
    if not sortie:
        details = processus.stderr.decode("utf-8", errors="replace").strip()
        raise MoteurIndisponible(f"Le moteur Prolog n'a rien renvoyé. {details}")

    try:
        donnees = json.loads(sortie)
    except json.JSONDecodeError as exc:
        raise MoteurIndisponible(f"Réponse illisible du moteur Prolog : {sortie[:200]}") from exc

    if "erreur" in donnees:
        raise MoteurErreur(donnees["erreur"], donnees.get("code", "erreur_interne"))
    return donnees


def lire_regles() -> list[dict[str, str]]:
    """Le code source de la base de règles (affiché dans l'interface)."""
    fichiers = [
        ("connaissances.pl", "Base de connaissances : filières, règles, critères"),
        ("explication.pl", "Méta-interpréteur : construit l'arbre « pourquoi »"),
        ("questions.pl", "Questionnaire dynamique"),
        ("textes.pl", "Phrases d'explication en français"),
        ("moteur.pl", "Point d'entrée JSON"),
    ]
    resultat = []
    for nom, description in fichiers:
        contenu = (DOSSIER_PROLOG / nom).read_text(encoding="utf-8")
        resultat.append({"nom": nom, "description": description, "contenu": contenu})
    return resultat
