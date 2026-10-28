:- encoding(utf8).
% ============================================================================
%  textes.pl — Phrases en français associées aux buts de la base de règles
%
%  texte(+But, -Phrase) transforme un nœud de l'arbre de preuve en une phrase
%  lisible par l'utilisateur. Si aucun texte n'existe, l'interface affiche le
%  but Prolog brut.
% ============================================================================

% --- Faits issus des réponses de l'utilisateur
texte(reponse(Q, V), T) :-
    etiquette(Q, E),
    libelle_valeur(Q, V, L),
    format(string(T), "~w : ~w", [E, L]).

% --- Comparaison de niveaux
texte(au_moins(Q, N), T) :-
    etiquette(Q, E),
    libelle_valeur(Q, N, L0),
    string_lower(L0, L),
    format(string(T), "~w : au moins « ~w »", [E, L]).

% --- Profil du bac
texte(bac_scientifique, "Bac scientifique (séries C, D ou E)").
texte(bac_math,         "Bac à dominante mathématiques (séries C ou E)").
texte(bac_technique,    "Bac à dominante technique (séries E ou F)").
texte(bac_tertiaire,    "Bac tertiaire (séries B ou G)").
texte(bac_litteraire,   "Bac littéraire (série A)").

% --- Aptitudes
texte(aptitude_calcul,         "Aptitude au calcul et à la logique").
texte(aptitude_sciences_exp,   "Aptitude aux sciences expérimentales").
texte(aptitude_biologie,       "Aptitude en biologie").
texte(aptitude_expression,     "Aisance en expression (langues, rédaction)").
texte(aptitude_gestion,        "Aptitude en économie et gestion").
texte(competence_disciplinaire,"Maîtrise d'au moins une discipline enseignable").

% --- Contraintes pratiques
texte(bac_admis(F), T) :-
    libelle(F, Nom),
    format(string(T), "Ta série de bac est admise en « ~w »", [Nom]).
texte(series_admises(F, L), T) :-
    libelle(F, Nom),
    fmt_liste(L, LS),
    format(string(T), "Séries admises en « ~w » : ~w", [Nom, LS]).
texte(budget_compatible(_),  "Le coût des études est compatible avec ton budget").
texte(cout(_, C), T) :-
    format(string(T), "Coût global estimé de la filière : ~w", [C]).
texte(budget_ok(B, C), T) :-
    format(string(T), "Un budget « ~w » permet de couvrir un coût « ~w »", [B, C]).
texte(duree_longue_acceptee, "Tu acceptes de longues études").
texte(duree_compatible(_),   "La durée des études correspond à ta préférence").
texte(duree_etudes(_, _, Txt), T) :-
    format(string(T), "Durée de la filière : ~w", [Txt]).

% --- Tests élémentaires
texte(member(X, L), T) :-
    fmt_val(X, XV),
    fmt_liste(L, LS),
    format(string(T), "« ~w » fait partie de : ~w", [XV, LS]).

% --- Utilitaires de mise en forme
fmt_val(X, V) :-
    (   atom(X), atom_length(X, 1)
    ->  upcase_atom(X, V)
    ;   V = X
    ).

fmt_liste(L, S) :-
    maplist(fmt_val, L, LV),
    atomic_list_concat(LV, ', ', S).
