:- encoding(utf8).
% ============================================================================
%  moteur.pl — Point d'entrée du système expert
%
%  Protocole : une requête JSON sur l'entrée standard, une réponse JSON sur la
%  sortie standard.
%
%      echo '{"action":"questions"}' | swipl -q -g main -t halt moteur.pl
%
%  Actions :
%      questions     — liste de toutes les questions
%      suivante      — prochaine question pertinente selon les réponses
%      recommander   — classement des filières + explications
% ============================================================================

:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).

:- ensure_loaded(questions).
:- ensure_loaded(connaissances).
:- ensure_loaded(textes).
:- ensure_loaded(explication).

% ---------------------------------------------------------------------------
%  Boucle principale : lire une requête JSON, répondre en JSON
% ---------------------------------------------------------------------------
main :-
    set_stream(user_input,  encoding(utf8)),
    set_stream(user_output, encoding(utf8)),
    (   catch(( json_read_dict(user_input, Requete),
                repondre(Requete, Reponse) ),
              Erreur,
              erreur_vers_dict(Erreur, Reponse))
    ->  true
    ;   Reponse = _{erreur: "Échec interne du moteur", code: "echec_interne"}
    ),
    json_write_dict(user_output, Reponse, [width(0)]),
    nl.

repondre(Requete, Reponse) :-
    get_dict(action, Requete, A0),
    atom_string(Action, A0),
    action(Action, Requete, Reponse).

action(questions, _, _{questions: Qs}) :-
    findall(D, ( ordre_questions(L), member(Q, L), question_dict(Q, D) ), Qs).

action(suivante, Requete, Reponse) :-
    avec_reponses(Requete, suivante(Reponse)).

action(recommander, Requete, Reponse) :-
    avec_reponses(Requete, recommander(Reponse)).

% ---------------------------------------------------------------------------
%  Gestion des réponses (faits dynamiques reponse/2)
% ---------------------------------------------------------------------------
avec_reponses(Requete, But) :-
    setup_call_cleanup(
        charger_reponses(Requete),
        once(But),
        retractall(reponse(_, _))).

charger_reponses(Requete) :-
    retractall(reponse(_, _)),
    (   get_dict(reponses, Requete, Rs), is_dict(Rs)
    ->  dict_pairs(Rs, _, Paires),
        forall(member(Q-V, Paires), enregistre(Q, V))
    ;   true
    ).

% Seules les valeurs prévues par une question sont acceptées : aucune donnée
% saisie par l'utilisateur n'est jamais exécutée comme du code.
enregistre(Q, V0) :-
    (   atom_string(V, V0),
        atom(Q),
        question(Q, _, _, _, Options),
        memberchk(V-_, Options)
    ->  assertz(reponse(Q, V))
    ;   throw(erreur(reponse_invalide(Q, V0)))
    ).

% ---------------------------------------------------------------------------
%  Questionnaire dynamique
% ---------------------------------------------------------------------------
questions_pertinentes(Ids) :-
    ordre_questions(L),
    include(pertinente, L, Ids).

repondue(Q) :- reponse(Q, _).

suivante(Reponse) :-
    questions_pertinentes(Ids),
    include(repondue, Ids, Faites),
    length(Faites, NbFaites),
    length(Ids, Total),
    (   member(Q, Ids), \+ repondue(Q)
    ->  question_dict(Q, D),
        Reponse = _{question: D, repondues: NbFaites, total: Total, terminee: false,
                    pertinentes: Ids}
    ;   Reponse = _{question: null, repondues: NbFaites, total: Total, terminee: true,
                    pertinentes: Ids}
    ).

question_dict(Q, _{id: Q, groupe: G, texte: T, aide: A, etiquette: E, options: Os}) :-
    question(Q, G, T, A, Options),
    etiquette(Q, E),
    findall(_{valeur: V, libelle: L}, member(V-L, Options), Os).

% ---------------------------------------------------------------------------
%  Recommandation
% ---------------------------------------------------------------------------
recommander(Reponse) :-
    (   reponse(serie, _)
    ->  true
    ;   throw(erreur(serie_manquante))
    ),
    findall(F, filiere(F), Filieres),
    maplist(evalue_filiere, Filieres, Evaluations),
    partition(est_eligible, Evaluations, Eligibles, Eliminees),
    sort(nom,   @=<, Eligibles, ParNom),
    sort(score, @>=, ParNom,    Classees),
    numerote(Classees, 1, Rangees),
    sort(nom, @=<, Eliminees, ElimTriees),
    profil(Profil),
    Reponse = _{filieres: Rangees, eliminees: ElimTriees, profil: Profil}.

est_eligible(E) :- get_dict(statut, E, eligible).

numerote([], _, []).
numerote([D|Ds], N, [D2|Ds2]) :-
    put_dict(rang, D, N, D2),
    N1 is N + 1,
    numerote(Ds, N1, Ds2).

% Les réponses de l'utilisateur, dans l'ordre du questionnaire
profil(Profil) :-
    ordre_questions(L),
    findall(_{id: Q, etiquette: E, valeur: V, libelle: Lib},
            ( member(Q, L), reponse(Q, V), etiquette(Q, E), libelle_valeur(Q, V, Lib) ),
            Profil).

% ---------------------------------------------------------------------------
%  Évaluation d'une filière
% ---------------------------------------------------------------------------
evalue_filiere(F, Resultat) :-
    libelle(F, Nom),
    description(F, Desc),
    exemples_etablissements(F, Ex),
    debouches(F, Deb),
    duree_etudes(F, _, DureeTxt),
    cout(F, Cout),
    findall(E, ( exigence(F, Id, But), evalue_exigence(F, Id, But, E) ), Exigences),
    Base = _{id: F, nom: Nom, description: Desc, etablissements: Ex,
             debouches: Deb, duree: DureeTxt, cout: Cout, exigences: Exigences},
    (   forall(member(E, Exigences), get_dict(ok, E, true))
    ->  evalue_criteres(F, Criteres),
        score(Criteres, Score),
        niveau_adequation(Score, Niveau),
        points(Criteres, true,  3, Forts),
        points(Criteres, false, 3, Faibles),
        put_dict(_{statut: eligible, score: Score, niveau: Niveau, criteres: Criteres,
                   points_forts: Forts, points_a_renforcer: Faibles}, Base, Resultat)
    ;   findall(Raison,
                ( member(E, Exigences), get_dict(ok, E, false), raison(E, Raison) ),
                Raisons),
        put_dict(_{statut: elimine, score: 0, raisons: Raisons}, Base, Resultat)
    ).

raison(E, Raison) :-
    get_dict(texte, E, T),
    get_dict(detail, E, D),
    format(string(Raison), "~w. ~w", [T, D]).

evalue_exigence(F, Id, But, Dict) :-
    texte_exigence(F, Id, T),
    (   once(prouve(But, Arbre))
    ->  arbre_json(Arbre, AJ),
        Dict = _{id: Id, ok: true, texte: T, arbre: AJ}
    ;   detail_echec(But, Detail),
        Dict = _{id: Id, ok: false, texte: T, detail: Detail, arbre: null}
    ).

evalue_criteres(F, Criteres) :-
    findall(C, ( critere(F, Id, Poids, But, Texte),
                 evalue_critere(Id, Poids, But, Texte, C) ),
            Criteres).

evalue_critere(Id, Poids, But, Texte, Dict) :-
    (   once(prouve(But, Arbre))
    ->  arbre_json(Arbre, AJ),
        Dict = _{id: Id, ok: true, poids: Poids, points: Poids, texte: Texte, arbre: AJ}
    ;   detail_echec(But, Detail),
        Dict = _{id: Id, ok: false, poids: Poids, points: 0, texte: Texte,
                 detail: Detail, arbre: null}
    ).

score(Criteres, Score) :-
    findall(P, ( member(C, Criteres), get_dict(poids,  C, P) ),         Poids),
    findall(P, ( member(C, Criteres), get_dict(points, C, P) ),         Points),
    sum_list(Poids,  Total),
    sum_list(Points, Gagnes),
    (   Total > 0
    ->  Score is round(100 * Gagnes / Total)
    ;   Score = 0
    ).

% Les critères les plus lourds, satisfaits (Ok = true) ou non (Ok = false).
% Un critère « X_moyen » est masqué si son jumeau « X_fort » est satisfait.
points(Criteres, Ok, N, Textes) :-
    findall(P-T,
            ( member(C, Criteres),
              get_dict(ok, C, Ok),
              \+ redondant(C, Criteres),
              get_dict(poids, C, P),
              get_dict(texte, C, T) ),
            Paires),
    keysort(Paires, Croissant),
    reverse(Croissant, Decroissant),
    pairs_values(Decroissant, Tous),
    prefixe(N, Tous, Textes).

redondant(C, Criteres) :-
    get_dict(id, C, Id),
    atom_concat(Base, '_moyen', Id),
    atom_concat(Base, '_fort', IdFort),
    member(C2, Criteres),
    get_dict(id, C2, IdFort),
    get_dict(ok, C2, true).

prefixe(N, L, P) :- length(P, N), append(P, _, L), !.
prefixe(_, L, L).

% ---------------------------------------------------------------------------
%  Pourquoi un but a échoué ?
% ---------------------------------------------------------------------------
detail_echec(bac_admis(F), D) :-
    reponse(serie, S),
    series_admises(F, L), !,
    fmt_val(S, SV),
    fmt_liste(L, LS),
    format(string(D), "Ta série (~w) ne fait pas partie des séries admises : ~w.", [SV, LS]).
detail_echec(au_moins(Q, _), D) :- !,
    (   reponse(Q, V)
    ->  libelle_valeur(Q, V, L),
        format(string(D), "Ta réponse : ~w.", [L])
    ;   D = "Aucune réponse : cette question ne t'a pas été posée pour ton profil."
    ).
detail_echec(budget_compatible(F), D) :-
    cout(F, C),
    reponse(budget, B), !,
    format(string(D), "Coût estimé de la filière : ~w ; ton budget : ~w.", [C, B]).
detail_echec(duree_compatible(F), D) :-
    duree_etudes(F, _, Txt), !,
    format(string(D), "Durée de la filière : ~w ; tu préfères des études courtes.", [Txt]).
detail_echec(duree_longue_acceptee, "Tu as indiqué préférer des études courtes.") :- !.
detail_echec(_, "Cette condition n'est pas remplie avec tes réponses.").

% ---------------------------------------------------------------------------
%  Arbre de preuve -> JSON
% ---------------------------------------------------------------------------
arbre_json(noeud(Type, But, Enfants),
           _{type: Type, texte: Texte, but: Brut, enfants: EnfantsJson}) :-
    (   once(texte(But, T0)) -> Texte = T0 ; format(string(Texte), "~q", [But]) ),
    format(string(Brut), "~q", [But]),
    maplist(arbre_json, Enfants, EnfantsJson).

% ---------------------------------------------------------------------------
%  Erreurs -> JSON
% ---------------------------------------------------------------------------
erreur_vers_dict(erreur(reponse_invalide(Q, V)), _{erreur: Msg, code: "reponse_invalide"}) :- !,
    format(string(Msg), "Réponse invalide pour « ~w » : ~w", [Q, V]).
erreur_vers_dict(erreur(serie_manquante), _{erreur: "La série du bac est obligatoire.", code: "serie_manquante"}) :- !.
erreur_vers_dict(error(syntax_error(_), _), _{erreur: "Requête JSON invalide.", code: "json_invalide"}) :- !.
erreur_vers_dict(E, _{erreur: Msg, code: "erreur_interne"}) :-
    format(string(Msg), "~q", [E]).
