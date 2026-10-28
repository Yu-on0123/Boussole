:- encoding(utf8).
% ============================================================================
%  explication.pl — Méta-interpréteur qui construit l'arbre de preuve
%
%  prouve(+But, -Arbre) démontre But exactement comme Prolog le ferait, mais
%  garde la trace du raisonnement. Arbre est de la forme :
%
%      noeud(Type, But, Enfants)
%
%  avec Type :
%      regle  — un but démontré grâce à une règle (clause avec un corps)
%      fait   — un but démontré par un fait (réponse de l'utilisateur ou
%               connaissance de la base)
%      test   — un test élémentaire (appartenance à une liste, comparaison…)
%
%  C'est ce qui permet de répondre à « Pourquoi cette réponse ? ».
% ============================================================================

% Les prédicats de bibliothèque / de contrôle sont appelés directement,
% on ne peut pas les « ouvrir » avec clause/2.
test_direct(member(_, _)).
test_direct(_ \= _).
test_direct(_ == _).
test_direct(_ =< _).
test_direct(_ >= _).
test_direct(_ < _).
test_direct(_ > _).

prouve(But, noeud(test, But, [])) :-
    test_direct(But), !,
    call(But).
prouve(But, Arbre) :-
    clause(But, Corps),
    (   Corps == true
    ->  Arbre = noeud(fait, But, [])
    ;   prouve_corps(Corps, Enfants),
        Arbre = noeud(regle, But, Enfants)
    ).

prouve_corps(true, []) :- !.
prouve_corps((A, B), Enfants) :- !,
    prouve_corps(A, EA),
    prouve_corps(B, EB),
    append(EA, EB, Enfants).
prouve_corps(But, [Arbre]) :-
    prouve(But, Arbre).
