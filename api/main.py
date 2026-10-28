"""API FastAPI du système expert d'orientation « Boussole ».

Lancement (depuis la racine du projet) :
    uvicorn api.main:app --reload
puis ouvrir http://127.0.0.1:8000
"""
from __future__ import annotations

import os
import time
from collections import defaultdict, deque
from pathlib import Path

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field, field_validator

from . import moteur

DOSSIER_WEB = Path(__file__).resolve().parent.parent / "web"

app = FastAPI(
    title="Boussole — système expert d'orientation",
    description="Une API Python qui interroge une base de règles Prolog et "
    "renvoie, avec chaque recommandation, l'arbre de preuve qui l'explique.",
    version="1.0.0",
)


class Reponses(BaseModel):
    """Les réponses déjà données : identifiant de question -> valeur choisie."""

    reponses: dict[str, str] = Field(default_factory=dict, max_length=40)

    @field_validator("reponses")
    @classmethod
    def _limiter_longueurs(cls, valeur: dict[str, str]) -> dict[str, str]:
        # Chaque clé et chaque valeur reste courte : le moteur n'a pas besoin de plus.
        for cle, val in valeur.items():
            if len(cle) > 40 or len(val) > 40:
                raise ValueError("clé ou valeur trop longue (40 caractères maximum)")
        return valeur


# Limiteur de débit simple, en mémoire, par adresse IP. Chaque appel lance un
# processus Prolog : sans limite, une démo publique est facile à saturer.
LIMITE_PAR_MINUTE = int(os.environ.get("BOUSSOLE_LIMITE_PAR_MINUTE", "60"))
_appels: dict[str, deque[float]] = defaultdict(deque)


@app.middleware("http")
async def limiter_debit(request: Request, call_next):
    if LIMITE_PAR_MINUTE > 0 and request.url.path.startswith("/api/") \
            and request.url.path != "/api/sante":
        # Derrière un proxy (Render, Railway...), l'IP réelle est dans X-Forwarded-For.
        ip = request.headers.get("x-forwarded-for", "").split(",")[0].strip() or (
            request.client.host if request.client else "inconnu"
        )
        maintenant = time.monotonic()
        file = _appels[ip]
        while file and maintenant - file[0] > 60:
            file.popleft()
        if len(file) >= LIMITE_PAR_MINUTE:
            return JSONResponse({"detail": "Trop de requêtes, réessaie dans une minute."},
                                status_code=429, headers={"Retry-After": "60"})
        file.append(maintenant)
    return await call_next(request)


def _appeler(action: str, reponses: dict[str, str] | None = None) -> dict:
    try:
        return moteur.appeler(action, reponses)
    except moteur.MoteurIndisponible as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    except moteur.MoteurErreur as exc:
        statut = 422 if exc.code in {"reponse_invalide", "serie_manquante"} else 500
        raise HTTPException(status_code=statut, detail=str(exc)) from exc


@app.get("/api/sante")
def sante() -> dict:
    """Vérifie que le moteur Prolog répond."""
    _appeler("questions")
    return {"statut": "ok"}


@app.get("/api/questions")
def questions() -> dict:
    """Toutes les questions du questionnaire."""
    return _appeler("questions")


@app.post("/api/question-suivante")
def question_suivante(corps: Reponses) -> dict:
    """La prochaine question à poser, selon les réponses déjà données."""
    return _appeler("suivante", corps.reponses)


@app.post("/api/recommander")
def recommander(corps: Reponses) -> dict:
    """Le classement des filières, avec l'arbre « pourquoi » de chaque décision."""
    return _appeler("recommander", corps.reponses)


@app.get("/api/regles")
def regles() -> dict:
    """Le code source Prolog de la base de règles."""
    return {"fichiers": moteur.lire_regles()}


# L'interface web est servie par la même application : un seul processus à lancer.
app.mount("/", StaticFiles(directory=DOSSIER_WEB, html=True), name="web")
