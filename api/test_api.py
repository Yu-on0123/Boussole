"""Tests de l'API (nécessitent SWI-Prolog installé).

    pytest -q
"""
import shutil

import pytest
from fastapi.testclient import TestClient

from api.main import app

pytestmark = pytest.mark.skipif(
    shutil.which("swipl") is None, reason="SWI-Prolog n'est pas installé"
)

client = TestClient(app)

PROFIL_INFORMATICIEN = {
    "serie": "c", "maths": "fort", "physique": "moyen", "svt": "moyen",
    "langues": "moyen", "int_programmation": "fort", "int_sante": "faible",
    "int_nature": "faible", "int_entreprise": "moyen", "int_droit": "faible",
    "int_ecriture": "faible", "int_enseignement": "faible",
    "int_technique": "moyen", "budget": "moyen", "duree": "courte",
}


def test_sante():
    assert client.get("/api/sante").json() == {"statut": "ok"}


def test_questions():
    donnees = client.get("/api/questions").json()
    ids = [q["id"] for q in donnees["questions"]]
    assert ids[0] == "serie"
    assert len(ids) == 16


def test_premiere_question_est_la_serie():
    donnees = client.post("/api/question-suivante", json={"reponses": {}}).json()
    assert donnees["question"]["id"] == "serie"
    assert donnees["terminee"] is False


def test_questionnaire_dynamique_saute_les_matieres_inutiles():
    donnees = client.post(
        "/api/question-suivante", json={"reponses": {"serie": "g", "maths": "moyen"}}
    ).json()
    # Pour un bac G on ne demande ni physique ni SVT : on passe aux langues.
    assert donnees["question"]["id"] == "langues"


def test_recommandation_et_explication():
    donnees = client.post("/api/recommander", json={"reponses": PROFIL_INFORMATICIEN}).json()
    premier = donnees["filieres"][0]
    assert premier["id"] == "informatique_gestion"
    assert premier["rang"] == 1
    assert 0 <= premier["score"] <= 100

    critere_satisfait = next(c for c in premier["criteres"] if c["ok"])
    arbre = critere_satisfait["arbre"]
    assert arbre["type"] in {"regle", "fait", "test"}
    assert arbre["texte"]

    ecartees = {f["id"] for f in donnees["eliminees"]}
    assert "medecine" in ecartees  # études courtes demandées


def test_reponse_invalide_refusee():
    r = client.post("/api/recommander", json={"reponses": {"serie": "c", "maths": "enorme"}})
    assert r.status_code == 422


def test_serie_obligatoire():
    r = client.post("/api/recommander", json={"reponses": {"maths": "fort"}})
    assert r.status_code == 422


def test_injection_prolog_sans_effet():
    r = client.post(
        "/api/recommander",
        json={"reponses": {"serie": "c", "maths": "fort), halt(1), (true"}},
    )
    assert r.status_code == 422


def test_regles_exposees():
    fichiers = client.get("/api/regles").json()["fichiers"]
    assert any(f["nom"] == "connaissances.pl" and "aptitude_calcul" in f["contenu"] for f in fichiers)


def test_valeur_trop_longue_refusee():
    r = client.post("/api/recommander", json={"reponses": {"serie": "x" * 100}})
    assert r.status_code == 422


def test_limiteur_de_debit(monkeypatch):
    from api import main

    main._appels.clear()
    monkeypatch.setattr(main, "LIMITE_PAR_MINUTE", 3)
    codes = [client.get("/api/questions").status_code for _ in range(5)]
    main._appels.clear()
    assert codes[:3] == [200, 200, 200] and codes[3] == 429
