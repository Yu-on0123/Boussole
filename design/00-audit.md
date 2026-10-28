# 00 — Audit

**Stack** : front statique vanilla (HTML/CSS/JS, sans build) servi par FastAPI (`app.mount("/", StaticFiles)`), moteur SWI-Prolog appelé par JSON/stdin. Pas de Tailwind/React : le projet reste en vanilla, sans build ni framework, pour rester simple à lancer et à lire.

**Écrans** (3 vues dans `web/index.html`, bascule par `data-vue`) :
| Vue | Fichier | Endpoints |
|---|---|---|
| Orientation (intro → questionnaire → résultats « et si ? ») | index.html + app.js | GET `/api/questions`, POST `/api/question-suivante`, POST `/api/recommander` |
| Règles Prolog | idem | GET `/api/regles` |
| Comment ça marche | idem (statique) | — |

**Points faibles constatés** : pas de dark mode ; hiérarchie plate des résultats (la meilleure filière ne se distingue que par un dégradé) ; glyphes ✔/✘ texte au lieu d'icônes ; aucun état de chargement ; focus jaune sur fond clair peu contrasté ; police système sans caractère ; pas d'ARIA tabs au clavier.

**Contrats préservés** : tous les `id` (`contenu`, `vue-*`, `intro`, `questionnaire`, `resultats`, `commencer`, `exemple-arbre`, `regles-*`, `titre-question`, `pq-*`, `si-*`), `data-vue`, classes lues par le JS, appels `fetch`, structure JSON consommée, clés des réponses, logique `etat`/`elaguer`/`retour`/`recommencer`. `api/` et `prolog/` non modifiés.
