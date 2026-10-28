:- encoding(utf8).
% ============================================================================
%  connaissances.pl — La base de connaissances du système expert
%
%  Les données sont INDICATIVES et simplifiées à des fins pédagogiques : elles
%  ne remplacent pas les conditions officielles d'admission (à vérifier auprès
%  des établissements).
%
%  Organisation :
%    1. Les filières (faits)
%    2. Les concepts intermédiaires (règles) : profil du bac, aptitudes…
%    3. Les exigences (éliminatoires) de chaque filière
%    4. Les critères pondérés de chaque filière (total = 100 points)
% ============================================================================

% ---------------------------------------------------------------------------
%  1. LES FILIÈRES
% ---------------------------------------------------------------------------
filiere(informatique_gestion).
filiere(medecine).
filiere(sante_courte).
filiere(agronomie).
filiere(gestion_finance).
filiere(economie_planification).
filiere(droit).
filiere(lettres_communication).
filiere(enseignement).
filiere(genie_civil).
filiere(genie_electrique).
filiere(commerce_entrepreneuriat).

libelle(informatique_gestion,    "Informatique de gestion").
libelle(medecine,                "Médecine").
libelle(sante_courte,            "Santé (infirmier, sage-femme, techniques médicales)").
libelle(agronomie,               "Agronomie et sciences agricoles").
libelle(gestion_finance,         "Gestion, comptabilité et finance").
libelle(economie_planification,  "Économie et planification").
libelle(droit,                   "Droit et sciences politiques").
libelle(lettres_communication,   "Lettres, langues et communication").
libelle(enseignement,            "Métiers de l'enseignement").
libelle(genie_civil,             "Génie civil et bâtiment").
libelle(genie_electrique,        "Génie électrique et énergies").
libelle(commerce_entrepreneuriat,"Commerce et entrepreneuriat").

description(informatique_gestion,
    "Concevoir des logiciels et des systèmes d'information pour les entreprises et les administrations.").
description(medecine,
    "Diagnostiquer, soigner et prévenir les maladies. Études très longues et admission sélective.").
description(sante_courte,
    "Formation courte et professionnalisante aux soins : infirmerie, maïeutique, laboratoire, imagerie.").
description(agronomie,
    "Améliorer la production agricole, l'élevage et la gestion des ressources naturelles.").
description(gestion_finance,
    "Piloter les finances, la comptabilité et l'organisation d'une entreprise ou d'une institution.").
description(economie_planification,
    "Analyser l'économie, élaborer des politiques publiques, planifier le développement.").
description(droit,
    "Maîtriser les textes de loi pour devenir magistrat, avocat, juriste ou cadre de l'administration.").
description(lettres_communication,
    "Analyser, écrire et communiquer : journalisme, édition, traduction, communication.").
description(enseignement,
    "Se former à transmettre une discipline dans l'enseignement secondaire ou technique.").
description(genie_civil,
    "Concevoir et suivre la construction de bâtiments, routes et ouvrages d'art.").
description(genie_electrique,
    "Concevoir et maintenir des installations électriques, des réseaux et des systèmes d'énergie.").
description(commerce_entrepreneuriat,
    "Vendre, négocier, gérer une activité commerciale ou lancer sa propre entreprise.").

exemples_etablissements(informatique_gestion,    "ENEAM, IFRI, écoles privées d'informatique").
exemples_etablissements(medecine,                "Faculté des Sciences de la Santé (FSS)").
exemples_etablissements(sante_courte,            "Instituts de formation en santé (ex. INMeS), écoles privées agréées").
exemples_etablissements(agronomie,               "Faculté des Sciences Agronomiques (FSA)").
exemples_etablissements(gestion_finance,         "ENEAM, FASEG, écoles privées de gestion").
exemples_etablissements(economie_planification,  "FASEG").
exemples_etablissements(droit,                   "FADESP").
exemples_etablissements(lettres_communication,   "FLASH").
exemples_etablissements(enseignement,            "Écoles Normales Supérieures (ENS)").
exemples_etablissements(genie_civil,             "EPAC").
exemples_etablissements(genie_electrique,        "EPAC").
exemples_etablissements(commerce_entrepreneuriat,"ENEAM, écoles de commerce privées").

debouches(informatique_gestion,    ["Développeur", "Analyste programmeur", "Administrateur de bases de données", "Chef de projet SI"]).
debouches(medecine,                ["Médecin généraliste", "Spécialiste", "Chercheur en santé"]).
debouches(sante_courte,            ["Infirmier", "Sage-femme", "Technicien de laboratoire"]).
debouches(agronomie,               ["Ingénieur agronome", "Conseiller agricole", "Entrepreneur agricole"]).
debouches(gestion_finance,         ["Comptable", "Contrôleur de gestion", "Auditeur", "Responsable financier"]).
debouches(economie_planification,  ["Économiste", "Statisticien", "Cadre de ministère ou d'ONG"]).
debouches(droit,                   ["Magistrat", "Avocat", "Juriste d'entreprise", "Cadre de l'administration"]).
debouches(lettres_communication,   ["Journaliste", "Chargé de communication", "Traducteur", "Éditeur"]).
debouches(enseignement,            ["Professeur de collège ou de lycée", "Conseiller pédagogique"]).
debouches(genie_civil,             ["Ingénieur du bâtiment", "Conducteur de travaux", "Bureau d'études"]).
debouches(genie_electrique,        ["Ingénieur électricien", "Responsable de maintenance", "Technicien en énergie solaire"]).
debouches(commerce_entrepreneuriat,["Responsable commercial", "Entrepreneur", "Chargé de marketing"]).

% duree_etudes(Filiere, Categorie, Texte)
duree_etudes(informatique_gestion,    courte, "3 ans (licence), 5 ans avec le master").
duree_etudes(medecine,                longue, "7 ans et plus").
duree_etudes(sante_courte,            courte, "3 ans").
duree_etudes(agronomie,               longue, "5 ans (ingénieur)").
duree_etudes(gestion_finance,         courte, "3 ans (licence), 5 ans avec le master").
duree_etudes(economie_planification,  courte, "3 ans (licence), 5 ans avec le master").
duree_etudes(droit,                   courte, "3 ans (licence), 4 à 5 ans avec le master").
duree_etudes(lettres_communication,   courte, "3 ans (licence)").
duree_etudes(enseignement,            longue, "3 à 5 ans selon le niveau d'enseignement").
duree_etudes(genie_civil,             longue, "5 ans (ingénieur)").
duree_etudes(genie_electrique,        longue, "5 ans (ingénieur)").
duree_etudes(commerce_entrepreneuriat,courte, "3 ans (licence)").

% cout(Filiere, bas | moyen | eleve) : coût global estimé
cout(informatique_gestion,    moyen).
cout(medecine,                eleve).
cout(sante_courte,            moyen).
cout(agronomie,               bas).
cout(gestion_finance,         bas).
cout(economie_planification,  bas).
cout(droit,                   bas).
cout(lettres_communication,   bas).
cout(enseignement,            bas).
cout(genie_civil,             moyen).
cout(genie_electrique,        moyen).
cout(commerce_entrepreneuriat,bas).

% series_admises(Filiere, ListeDeSeries)
series_admises(informatique_gestion,    [b, c, d, e, f, g]).
series_admises(medecine,                [c, d]).
series_admises(sante_courte,            [a, b, c, d, e]).
series_admises(agronomie,               [b, c, d, e]).
series_admises(gestion_finance,         [a, b, c, d, e, g]).
series_admises(economie_planification,  [b, c, d, e, g]).
series_admises(droit,                   [a, b, c, d, e, g]).
series_admises(lettres_communication,   [a, b, c, d, g]).
series_admises(enseignement,            [a, b, c, d, e, g]).
series_admises(genie_civil,             [c, e, f]).
series_admises(genie_electrique,        [c, e, f]).
series_admises(commerce_entrepreneuriat,[a, b, c, d, e, f, g]).

% ---------------------------------------------------------------------------
%  2. CONCEPTS INTERMÉDIAIRES (règles d'inférence)
% ---------------------------------------------------------------------------

% --- Profil du baccalauréat
bac_scientifique :- reponse(serie, S), member(S, [c, d, e]).
bac_math         :- reponse(serie, S), member(S, [c, e]).
bac_technique    :- reponse(serie, S), member(S, [e, f]).
bac_tertiaire    :- reponse(serie, S), member(S, [b, g]).
bac_litteraire   :- reponse(serie, a).

% --- Comparaison de niveaux : « fort » implique « au moins moyen »
au_moins(Q, moyen) :- reponse(Q, moyen).
au_moins(Q, moyen) :- reponse(Q, fort).
au_moins(Q, fort)  :- reponse(Q, fort).

% --- Aptitudes (combinent les notes et le profil du bac)
aptitude_calcul :- au_moins(maths, fort).
aptitude_calcul :- au_moins(maths, moyen), bac_math.

aptitude_sciences_exp :- au_moins(physique, fort).
aptitude_sciences_exp :- au_moins(physique, moyen), au_moins(maths, moyen).

aptitude_biologie :- au_moins(svt, fort).
aptitude_biologie :- au_moins(svt, moyen), reponse(serie, d).

aptitude_expression :- au_moins(langues, fort).
aptitude_expression :- au_moins(langues, moyen), bac_litteraire.

aptitude_gestion :- au_moins(eco_gestion, fort).
aptitude_gestion :- au_moins(eco_gestion, moyen), bac_tertiaire.

% --- Pour enseigner, il faut maîtriser au moins une discipline
competence_disciplinaire :- au_moins(maths, moyen).
competence_disciplinaire :- au_moins(physique, moyen).
competence_disciplinaire :- au_moins(svt, moyen).
competence_disciplinaire :- au_moins(langues, moyen).

% --- Contraintes pratiques
bac_admis(F) :-
    reponse(serie, S),
    series_admises(F, Series),
    member(S, Series).

budget_ok(limite,       bas).
budget_ok(moyen,        bas).
budget_ok(moyen,        moyen).
budget_ok(confortable,  bas).
budget_ok(confortable,  moyen).
budget_ok(confortable,  eleve).

budget_compatible(F) :-
    cout(F, Cout),
    reponse(budget, Budget),
    budget_ok(Budget, Cout).

duree_longue_acceptee :- reponse(duree, longue).

duree_compatible(_) :- duree_longue_acceptee.
duree_compatible(F) :- duree_etudes(F, courte, _), reponse(duree, courte).

% ---------------------------------------------------------------------------
%  3. EXIGENCES : si l'une d'elles n'est pas remplie, la filière est écartée
%     exigence(Filiere, Id, But)
% ---------------------------------------------------------------------------
exigence(F, bac, bac_admis(F)) :- filiere(F).

exigence(medecine,         svt,    au_moins(svt, moyen)).
exigence(medecine,         duree,  duree_longue_acceptee).
exigence(genie_civil,      maths,  au_moins(maths, moyen)).
exigence(genie_electrique, maths,  au_moins(maths, moyen)).

texte_exigence(_,                bac,   "Ta série de bac fait partie des séries admises").
texte_exigence(medecine,         svt,   "Un niveau au moins moyen en SVT est indispensable").
texte_exigence(medecine,         duree, "Tu acceptes de longues études (7 ans et plus)").
texte_exigence(genie_civil,      maths, "Un niveau au moins moyen en mathématiques est indispensable").
texte_exigence(genie_electrique, maths, "Un niveau au moins moyen en mathématiques est indispensable").

% ---------------------------------------------------------------------------
%  4. CRITÈRES PONDÉRÉS : critere(Filiere, Id, Poids, But, Texte)
%     Pour chaque filière : 80 points spécifiques + 20 points communs
%     (budget et durée) = 100. Un critère « _fort » vient compléter son
%     jumeau « _moyen » : un fort intérêt rapporte donc plus de points.
% ---------------------------------------------------------------------------

% --- Critères communs
critere(F, budget, 10, budget_compatible(F),
        "Le coût estimé des études est compatible avec ton budget") :- filiere(F).
critere(F, duree, 10, duree_compatible(F),
        "La durée des études correspond à ta préférence") :- filiere(F).

% --- Informatique de gestion
critere(informatique_gestion, calcul,           20, aptitude_calcul,
        "Bonne aptitude au calcul et à la logique").
critere(informatique_gestion, prog_moyen,       15, au_moins(int_programmation, moyen),
        "Un intérêt pour la programmation").
critere(informatique_gestion, prog_fort,        25, au_moins(int_programmation, fort),
        "Une vraie passion pour la programmation").
critere(informatique_gestion, entreprise_moyen, 10, au_moins(int_entreprise, moyen),
        "Un intérêt pour le monde de l'entreprise, que l'informatique de gestion sert").
critere(informatique_gestion, langues_moyen,    10, au_moins(langues, moyen),
        "Une aisance suffisante en langues (documentation, relation avec les clients)").

% --- Médecine
critere(medecine, biologie,     25, aptitude_biologie,
        "Bonne aptitude en biologie").
critere(medecine, sciences,     10, aptitude_sciences_exp,
        "Bonne aptitude en sciences expérimentales").
critere(medecine, sante_moyen,  15, au_moins(int_sante, moyen),
        "Un intérêt pour la santé").
critere(medecine, sante_fort,   25, au_moins(int_sante, fort),
        "Une vraie vocation pour le soin").
critere(medecine, calcul,        5, aptitude_calcul,
        "Bonne aptitude au calcul (posologies, statistiques)").

% --- Santé (cycle court)
critere(sante_courte, biologie,     20, aptitude_biologie,
        "Bonne aptitude en biologie").
critere(sante_courte, sante_moyen,  20, au_moins(int_sante, moyen),
        "Un intérêt pour la santé").
critere(sante_courte, sante_fort,   30, au_moins(int_sante, fort),
        "Une vraie vocation pour le soin").
critere(sante_courte, langues_moyen,10, au_moins(langues, moyen),
        "Une aisance de communication avec les patients").

% --- Agronomie
critere(agronomie, nature_moyen,     20, au_moins(int_nature, moyen),
        "Un intérêt pour l'agriculture et l'environnement").
critere(agronomie, nature_fort,      25, au_moins(int_nature, fort),
        "Une vraie passion pour la terre et le vivant").
critere(agronomie, biologie,         15, aptitude_biologie,
        "Bonne aptitude en biologie").
critere(agronomie, sciences,         10, aptitude_sciences_exp,
        "Bonne aptitude en sciences expérimentales").
critere(agronomie, entreprise_moyen, 10, au_moins(int_entreprise, moyen),
        "Un intérêt pour l'agrobusiness et l'entrepreneuriat agricole").

% --- Gestion, comptabilité, finance
critere(gestion_finance, gestion,          25, aptitude_gestion,
        "Bonne aptitude en économie et gestion").
critere(gestion_finance, calcul,           15, aptitude_calcul,
        "Bonne aptitude au calcul").
critere(gestion_finance, entreprise_moyen, 15, au_moins(int_entreprise, moyen),
        "Un intérêt pour l'entreprise").
critere(gestion_finance, entreprise_fort,  15, au_moins(int_entreprise, fort),
        "Une forte envie de gérer et d'entreprendre").
critere(gestion_finance, langues_moyen,    10, au_moins(langues, moyen),
        "Une aisance suffisante en langues (rapports, relations d'affaires)").

% --- Économie et planification
critere(economie_planification, calcul,           25, aptitude_calcul,
        "Bonne aptitude au calcul et à la modélisation").
critere(economie_planification, maths_fort,       15, au_moins(maths, fort),
        "Un excellent niveau en mathématiques").
critere(economie_planification, gestion,          15, aptitude_gestion,
        "Bonne aptitude en économie et gestion").
critere(economie_planification, entreprise_moyen, 10, au_moins(int_entreprise, moyen),
        "Un intérêt pour l'économie réelle et l'entreprise").
critere(economie_planification, droit_moyen,       5, au_moins(int_droit, moyen),
        "Un intérêt pour les politiques publiques").
critere(economie_planification, langues_moyen,    10, au_moins(langues, moyen),
        "Une aisance suffisante en langues (rédaction de rapports)").

% --- Droit
critere(droit, expression,   25, aptitude_expression,
        "Aisance en expression écrite et orale").
critere(droit, droit_moyen,  15, au_moins(int_droit, moyen),
        "Un intérêt pour le droit et l'administration").
critere(droit, droit_fort,   25, au_moins(int_droit, fort),
        "Une vraie passion pour la justice et les lois").
critere(droit, ecriture_moyen,15, au_moins(int_ecriture, moyen),
        "Un goût pour l'argumentation et la rédaction").

% --- Lettres, langues et communication
critere(lettres_communication, expression,      30, aptitude_expression,
        "Aisance en expression écrite et orale").
critere(lettres_communication, ecriture_moyen,  15, au_moins(int_ecriture, moyen),
        "Un goût pour l'écriture et la communication").
critere(lettres_communication, ecriture_fort,   25, au_moins(int_ecriture, fort),
        "Une vraie passion pour les mots").
critere(lettres_communication, langues_fort,    10, au_moins(langues, fort),
        "Un excellent niveau en langues").

% --- Enseignement
critere(enseignement, enseignement_moyen, 20, au_moins(int_enseignement, moyen),
        "Un intérêt pour la transmission du savoir").
critere(enseignement, enseignement_fort,  30, au_moins(int_enseignement, fort),
        "Une vraie vocation d'enseignant").
critere(enseignement, discipline,         20, competence_disciplinaire,
        "Une discipline maîtrisée que tu pourrais enseigner").
critere(enseignement, expression,         10, aptitude_expression,
        "Aisance en expression, indispensable devant une classe").

% --- Génie civil
critere(genie_civil, calcul,          20, aptitude_calcul,
        "Bonne aptitude au calcul (structures, dimensionnement)").
critere(genie_civil, sciences,        15, aptitude_sciences_exp,
        "Bonne aptitude en sciences physiques").
critere(genie_civil, technique_moyen, 15, au_moins(int_technique, moyen),
        "Un intérêt pour la construction et les métiers techniques").
critere(genie_civil, technique_fort,  20, au_moins(int_technique, fort),
        "Une vraie passion pour construire").
critere(genie_civil, bac_technique,   10, bac_technique,
        "Un bac à dominante technique (séries E ou F)").

% --- Génie électrique
critere(genie_electrique, sciences,        25, aptitude_sciences_exp,
        "Bonne aptitude en physique").
critere(genie_electrique, calcul,          15, aptitude_calcul,
        "Bonne aptitude au calcul").
critere(genie_electrique, technique_moyen, 15, au_moins(int_technique, moyen),
        "Un intérêt pour l'électricité et les systèmes techniques").
critere(genie_electrique, technique_fort,  15, au_moins(int_technique, fort),
        "Une vraie passion pour la technique").
critere(genie_electrique, bac_technique,   10, bac_technique,
        "Un bac à dominante technique (séries E ou F)").

% --- Commerce et entrepreneuriat
critere(commerce_entrepreneuriat, entreprise_moyen, 20, au_moins(int_entreprise, moyen),
        "Un intérêt pour le commerce et l'entreprise").
critere(commerce_entrepreneuriat, entreprise_fort,  30, au_moins(int_entreprise, fort),
        "Une vraie envie d'entreprendre").
critere(commerce_entrepreneuriat, expression,       15, aptitude_expression,
        "Aisance en expression (négociation, relation client)").
critere(commerce_entrepreneuriat, gestion,          15, aptitude_gestion,
        "Bonne aptitude en économie et gestion").

% ---------------------------------------------------------------------------
%  Niveau d'adéquation selon le score (0-100)
% ---------------------------------------------------------------------------
niveau_adequation(Score, "Très bonne adéquation") :- Score >= 70, !.
niveau_adequation(Score, "Bonne adéquation")      :- Score >= 50, !.
niveau_adequation(Score, "Adéquation partielle")  :- Score >= 30, !.
niveau_adequation(_,     "Adéquation faible").
