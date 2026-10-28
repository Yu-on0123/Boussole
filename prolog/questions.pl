:- encoding(utf8).
% ============================================================================
%  questions.pl — Les questions posées à l'utilisateur
%
%  Les réponses sont stockées comme des faits dynamiques : reponse(Question, Valeur).
%  Le questionnaire est DYNAMIQUE : une question n'est posée que si elle est
%  pertinente compte tenu des réponses déjà données (voir pertinente/1).
% ============================================================================

:- dynamic reponse/2.

% ---------------------------------------------------------------------------
%  Ordre dans lequel les questions sont envisagées
% ---------------------------------------------------------------------------
ordre_questions([
    serie, maths, physique, svt, langues, eco_gestion,
    int_programmation, int_sante, int_nature, int_entreprise,
    int_droit, int_ecriture, int_enseignement, int_technique,
    budget, duree
]).

% ---------------------------------------------------------------------------
%  Pertinence : quand faut-il poser la question ?
% ---------------------------------------------------------------------------
pertinente(serie).
pertinente(maths).
pertinente(physique)    :- reponse(serie, S), member(S, [c, d, e, f]).
pertinente(svt)         :- reponse(serie, S), member(S, [c, d]).
pertinente(langues).
pertinente(eco_gestion) :- reponse(serie, S), member(S, [a, b, g]).
pertinente(int_programmation).
pertinente(int_sante).
pertinente(int_nature).
pertinente(int_entreprise).
pertinente(int_droit).
pertinente(int_ecriture).
pertinente(int_enseignement).
pertinente(int_technique).
pertinente(budget).
pertinente(duree).

% ---------------------------------------------------------------------------
%  Échelles de réponses
% ---------------------------------------------------------------------------
options_niveau([fort-"Fort", moyen-"Moyen", faible-"Faible"]).
options_interet([fort-"Beaucoup", moyen-"Un peu", faible-"Pas du tout"]).

% ---------------------------------------------------------------------------
%  question(Id, Groupe, Texte, Aide, Options)
% ---------------------------------------------------------------------------
question(serie, profil,
    "Quelle est ta série de baccalauréat ?",
    "Si tu es encore en terminale, choisis la série que tu prépares.",
    [ a-"A — Littéraire",
      b-"B — Économie",
      c-"C — Mathématiques et physique",
      d-"D — Sciences de la vie et de la terre",
      e-"E — Mathématiques et technique",
      f-"F — Techniques industrielles",
      g-"G — Gestion, comptabilité, commerce" ]).

question(maths, matieres,
    "Comment te situes-tu en mathématiques ?",
    "Pense à tes moyennes des deux dernières années.",
    O) :- options_niveau(O).
question(physique, matieres,
    "Comment te situes-tu en physique-chimie ?",
    "Pense à tes moyennes des deux dernières années.",
    O) :- options_niveau(O).
question(svt, matieres,
    "Comment te situes-tu en SVT (biologie, géologie) ?",
    "Pense à tes moyennes des deux dernières années.",
    O) :- options_niveau(O).
question(langues, matieres,
    "Comment te situes-tu en français et en anglais (expression, rédaction) ?",
    "Pense à l'aisance à l'écrit comme à l'oral.",
    O) :- options_niveau(O).
question(eco_gestion, matieres,
    "Comment te situes-tu en économie, gestion et comptabilité ?",
    "Si tu n'as pas eu ces matières, choisis « Faible ».",
    O) :- options_niveau(O).

question(int_programmation, interets,
    "Est-ce que programmer, créer des logiciels ou des sites web t'attire ?",
    "Même sans expérience : c'est l'envie qui compte ici.",
    O) :- options_interet(O).
question(int_sante, interets,
    "Est-ce que soigner, accompagner des malades ou travailler dans la santé t'attire ?",
    "Pense aussi aux contraintes : horaires, contact avec la souffrance.",
    O) :- options_interet(O).
question(int_nature, interets,
    "Est-ce que travailler dans l'agriculture, l'élevage ou l'environnement t'attire ?",
    "Cela inclut le travail de terrain et l'agrobusiness.",
    O) :- options_interet(O).
question(int_entreprise, interets,
    "Est-ce que gérer une entreprise, vendre, négocier ou entreprendre t'attire ?",
    "Pense à créer ta propre activité ou à diriger une équipe.",
    O) :- options_interet(O).
question(int_droit, interets,
    "Les lois, la justice et l'administration publique t'intéressent-elles ?",
    "Débats, textes juridiques, fonctionnement de l'État…",
    O) :- options_interet(O).
question(int_ecriture, interets,
    "Aimes-tu écrire, parler en public, communiquer ou analyser des textes ?",
    "Journalisme, communication, littérature, langues…",
    O) :- options_interet(O).
question(int_enseignement, interets,
    "Est-ce que transmettre des connaissances et enseigner t'attire ?",
    "Pense à expliquer, accompagner des élèves, préparer des cours.",
    O) :- options_interet(O).
question(int_technique, interets,
    "Est-ce que construire, réparer ou travailler sur l'électricité et les machines t'attire ?",
    "Bâtiment, installations électriques, mécanique, énergie…",
    O) :- options_interet(O).

question(budget, contraintes,
    "Quel budget peux-tu consacrer aux études ?",
    "Frais d'inscription, logement, transport, matériel.",
    [ limite-"Limité (université publique, bourses)",
      moyen-"Moyen",
      confortable-"Confortable (écoles privées possibles)" ]).
question(duree, contraintes,
    "Quelle durée d'études envisages-tu ?",
    "Choisis « Longue » si tu es prêt(e) à aller jusqu'à 5 ans ou plus.",
    [ courte-"Courte : environ 3 ans (licence)",
      longue-"Longue : 5 ans ou plus (ingénieur, master, médecine)" ]).

% ---------------------------------------------------------------------------
%  Étiquettes courtes (utilisées dans les explications)
% ---------------------------------------------------------------------------
etiquette(serie,            "Série du bac").
etiquette(maths,            "Niveau en mathématiques").
etiquette(physique,         "Niveau en physique-chimie").
etiquette(svt,              "Niveau en SVT").
etiquette(langues,          "Niveau en français/anglais").
etiquette(eco_gestion,      "Niveau en économie/gestion").
etiquette(int_programmation,"Intérêt pour la programmation").
etiquette(int_sante,        "Intérêt pour la santé").
etiquette(int_nature,       "Intérêt pour l'agriculture et l'environnement").
etiquette(int_entreprise,   "Intérêt pour l'entreprise et le commerce").
etiquette(int_droit,        "Intérêt pour le droit et l'administration").
etiquette(int_ecriture,     "Intérêt pour l'écriture et la communication").
etiquette(int_enseignement, "Intérêt pour l'enseignement").
etiquette(int_technique,    "Intérêt pour les métiers techniques").
etiquette(budget,           "Budget disponible").
etiquette(duree,            "Durée d'études souhaitée").

% libelle_valeur(+Question, +Valeur, -Libelle)
libelle_valeur(Q, V, L) :-
    question(Q, _, _, _, Opts),
    member(V-L, Opts), !.
