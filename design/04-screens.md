# 04 — Écrans

### Intro — web/index.html `#intro`
- Action primaire : « Commencer le questionnaire » (`#commencer`).
- Hiérarchie : titre serif + italique laiton → chapeau → CTA → carte d'exemple d'explication.
- États : hover/focus/active du bouton ; rose des vents (décor, `aria-hidden`) ; erreur API → bloc `.erreur` avec « Réessayer ».
- Responsive : 1 colonne ≤ 900 px, rose atténuée. Motion : rose se stabilise 1,8 s une fois.

### Questionnaire — `#questionnaire`
- Action : choisir une réponse. Options pleine largeur 56 px, chip clavier 1–9 (raccourcis), option déjà choisie surlignée au retour.
- Progression mono « Question n sur N » + barre (aria-progressbar). Squelette si réponse > 300 ms ; erreur avec Réessayer.

### Résultats — `#resultats`
- Action : ouvrir « Pourquoi cette réponse ? ». N°1 = carte « Cap recommandé » avec cadran + compteur ; autres = jauge. Listes forts/faibles avec icônes SVG (masques), filières écartées en `details`, avertissement.
- « Et si ? » : panneau sticky (statique ≤ 900 px), selects stylés 42 px.
- Preuve : arbre « itinéraire », interrupteur « termes Prolog ». États : squelette, vide (message existant), erreur.

### Règles Prolog — `#vue-regles`
Onglets fichiers (ARIA tabs, flèches/Home/End, tabindex itinérant), code sombre dans les deux thèmes.

### Comment ça marche — `#vue-principe`
Schéma SVG thématisé par tokens, deux colonnes → une colonne mobile, bloc « limites » en accent doux.

### Global
En-tête sticky flouté, bascule de thème (mémorisée en localStorage avec try/catch), lien d'évitement, `prefers-reduced-motion` désactive animations et transitions.
