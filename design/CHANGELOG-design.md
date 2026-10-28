# CHANGELOG design

**Modifiés** : `web/index.html` (en-tête, bouton thème, rose, méta/préchargement polices), `web/style.css` (réécrit), `web/app.js` (thème, cadran, compteur, squelettes, raccourcis clavier, flèches onglets, icônes d'état via CSS).
**Ajoutés** : `web/fonts/` (Geist, Geist Mono — OFL ; Newsreader — OFL), `design/`.
**Non modifiés** : `api/`, `prolog/`, tests, Dockerfile.
**Dépendances** : aucune (polices locales). **Commandes** : `pip install -r requirements.txt` puis `uvicorn api.main:app --reload`.
**Vérifié** : rendu Chromium 1440 px et 390 px, clair/sombre, aucune erreur console, aucun défilement horizontal, avec un serveur d'API factice reproduisant les formats JSON.
**Vérifié ensuite** : intégration avec le vrai moteur SWI-Prolog 9.0, tests Prolog (plunit) et API (pytest, 9 tests) au vert, parcours complet du questionnaire jusqu'à l'arbre « pourquoi » en clair et en sombre, sans erreur console.
**Non vérifié** : mesure automatique des contrastes, 768 px, lecteur d'écran, build Docker.
