:- encoding(utf8).
% ============================================================================
%  tests.pl — Tests unitaires (plunit)
%
%      swipl -q -g run_tests -t halt prolog/tests.pl
% ============================================================================
:- use_module(library(plunit)).
:- ensure_loaded(moteur).

charge(Profil) :-
    retractall(reponse(_, _)),
    forall(member(Q-V, Profil), assertz(reponse(Q, V))).

profil_informaticien([
    serie-c, maths-fort, physique-moyen, svt-moyen, langues-moyen,
    int_programmation-fort, int_sante-faible, int_nature-faible,
    int_entreprise-moyen, int_droit-faible, int_ecriture-faible,
    int_enseignement-faible, int_technique-moyen,
    budget-moyen, duree-courte ]).

profil_litteraire([
    serie-a, maths-faible, langues-fort, eco_gestion-faible,
    int_programmation-faible, int_sante-faible, int_nature-faible,
    int_entreprise-faible, int_droit-fort, int_ecriture-fort,
    int_enseignement-moyen, int_technique-faible,
    budget-limite, duree-courte ]).

premier(Reponse, Id) :-
    get_dict(filieres, Reponse, [Premier|_]),
    get_dict(id, Premier, Id).

elimine(Reponse, Id) :-
    get_dict(eliminees, Reponse, Elim),
    member(E, Elim),
    get_dict(id, E, Id).

:- begin_tests(base_de_connaissances).

test(chaque_filiere_totalise_100_points) :-
    forall(filiere(F),
           ( findall(P, critere(F, _, P, _, _), Ps),
             sum_list(Ps, Total),
             assertion(Total =:= 100) )).

test(chaque_filiere_a_toutes_ses_informations) :-
    forall(filiere(F),
           ( libelle(F, _), description(F, _), exemples_etablissements(F, _),
             debouches(F, _), duree_etudes(F, _, _), cout(F, _),
             series_admises(F, _) )).

test(chaque_exigence_a_un_texte) :-
    forall(exigence(F, Id, _), assertion(texte_exigence(F, Id, _))).

test(chaque_question_a_une_etiquette) :-
    ordre_questions(L),
    forall(member(Q, L), ( question(Q, _, _, _, _), etiquette(Q, _) )).

:- end_tests(base_de_connaissances).

:- begin_tests(inference).

test(informaticien_arrive_en_tete) :-
    profil_informaticien(P), charge(P),
    recommander(R),
    premier(R, informatique_gestion).

test(litteraire_arrive_en_tete_dans_le_droit_ou_les_lettres) :-
    profil_litteraire(P), charge(P),
    recommander(R),
    premier(R, Id),
    memberchk(Id, [droit, lettres_communication]).

test(medecine_ecartee_pour_un_bac_g, [nondet]) :-
    charge([serie-g, maths-moyen, langues-moyen, eco_gestion-fort,
            int_sante-fort, budget-confortable, duree-longue]),
    recommander(R),
    elimine(R, medecine).

test(medecine_ecartee_si_etudes_courtes) :-
    profil_informaticien(P), charge(P),
    recommander(R),
    elimine(R, medecine).

test(score_entre_0_et_100) :-
    profil_informaticien(P), charge(P),
    recommander(R),
    get_dict(filieres, R, Fs),
    forall(member(F, Fs),
           ( get_dict(score, F, S), assertion(between(0, 100, S)) )).

test(un_fort_interet_rapporte_plus_qu_un_interet_moyen) :-
    charge([serie-c, maths-moyen, int_programmation-moyen, budget-moyen, duree-courte]),
    recommander(R1),
    charge([serie-c, maths-moyen, int_programmation-fort, budget-moyen, duree-courte]),
    recommander(R2),
    score_de(R1, informatique_gestion, S1),
    score_de(R2, informatique_gestion, S2),
    S2 > S1.

test(serie_obligatoire) :-
    charge([maths-fort]),
    catch(recommander(_), erreur(serie_manquante), true).

score_de(R, Id, S) :-
    get_dict(filieres, R, Fs),
    member(F, Fs), get_dict(id, F, Id), !,
    get_dict(score, F, S).

:- end_tests(inference).

:- begin_tests(explication).

test(arbre_de_preuve_d_une_regle, [nondet]) :-
    charge([serie-c, maths-moyen]),
    prouve(aptitude_calcul, Arbre),
    Arbre = noeud(regle, aptitude_calcul, Enfants),
    Enfants \== [].

test(la_preuve_choisit_la_bonne_clause, [nondet]) :-
    % maths « moyen » : seule la 2e clause d'aptitude_calcul (avec bac_math) convient
    charge([serie-c, maths-moyen]),
    prouve(aptitude_calcul, noeud(regle, _, Enfants)),
    memberchk(noeud(regle, bac_math, _), Enfants).

test(pas_de_preuve_si_la_condition_echoue) :-
    charge([serie-g, maths-moyen]),
    \+ prouve(aptitude_calcul, _).

test(les_faits_utilisateur_sont_des_feuilles) :-
    charge([maths-fort]),
    prouve(au_moins(maths, fort), noeud(regle, _, [noeud(fait, reponse(maths, fort), [])])).

test(arbre_json_contient_des_phrases, [nondet]) :-
    charge([serie-c, maths-fort]),
    prouve(aptitude_calcul, Arbre),
    arbre_json(Arbre, J),
    get_dict(texte, J, T),
    T == "Aptitude au calcul et à la logique".

:- end_tests(explication).

:- begin_tests(questionnaire).

test(bac_g_ne_pose_pas_physique_ni_svt) :-
    charge([serie-g]),
    \+ pertinente(physique),
    \+ pertinente(svt),
    pertinente(eco_gestion).

test(bac_d_pose_svt_mais_pas_eco_gestion) :-
    charge([serie-d]),
    pertinente(svt),
    \+ pertinente(eco_gestion).

test(la_serie_est_la_premiere_question) :-
    charge([]),
    suivante(R),
    get_dict(question, R, Q),
    get_dict(id, Q, serie).

test(questionnaire_termine) :-
    profil_informaticien(P), charge(P),
    suivante(R),
    get_dict(terminee, R, true).

test(reponse_invalide_refusee) :-
    catch(enregistre(maths, "enorme"), erreur(reponse_invalide(maths, _)), true).

test(question_inconnue_refusee) :-
    catch(enregistre(foo, "bar"), erreur(reponse_invalide(foo, _)), true).

:- end_tests(questionnaire).
