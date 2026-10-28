"use strict";

/* ==========================================================================
   Boussole — interface web
   Tout le texte provenant de l'API est inséré avec textContent (jamais en HTML).
   ========================================================================== */

const etat = {
  reponses: {},      // { idQuestion: valeur }
  ordre: [],         // ids des questions dans l'ordre où l'on y a répondu
  questions: {},     // { idQuestion: question } (options pour le panneau « et si ? »)
  resultat: null,    // dernière réponse de /api/recommander
  precedent: null,   // classement précédent, pour afficher les variations
  ouverts: new Set(),// filières dont l'explication est ouverte
  regles: null,
};

/* ---------- Utilitaires ---------- */

function h(tag, attrs, ...enfants) {
  const el = document.createElement(tag);
  for (const [cle, val] of Object.entries(attrs || {})) {
    if (val === false || val == null) continue;
    if (cle === "class") el.className = val;
    else if (cle.startsWith("on")) el.addEventListener(cle.slice(2), val);
    else el.setAttribute(cle, val === true ? "" : val);
  }
  for (const e of enfants.flat()) {
    if (e == null || e === false) continue;
    el.append(e.nodeType ? e : document.createTextNode(e));
  }
  return el;
}

const $ = (sel) => document.querySelector(sel);

const reduireMouvement = () => window.matchMedia("(prefers-reduced-motion: reduce)").matches;

/* Élément SVG (le helper h() ne sait créer que du HTML). */
function s(tag, attrs, ...enfants) {
  const el = document.createElementNS("http://www.w3.org/2000/svg", tag);
  for (const [cle, val] of Object.entries(attrs || {})) el.setAttribute(cle, val);
  el.append(...enfants.flat().filter(Boolean));
  return el;
}

/* Squelette affiché seulement si l'attente dépasse 300 ms (pas de flash sur réponse rapide). */
function squelette(zone, lignes = 4) {
  return setTimeout(() => {
    zone.replaceChildren(h("div", { class: "squelette", "aria-hidden": "true" },
      h("span", { class: "sq titre" }),
      Array.from({ length: lignes }, () => h("span", { class: "sq ligne" }))));
    zone.hidden = false;
  }, 300);
}

/* Compteur animé : 0 → cible en ~700 ms (instantané si mouvement réduit). */
function compter(el, cible) {
  if (reduireMouvement() || cible === 0) { el.textContent = String(cible); return; }
  const debut = performance.now();
  const duree = 700;
  const pas = (t) => {
    const p = Math.min(1, (t - debut) / duree);
    el.textContent = String(Math.round(cible * (1 - Math.pow(1 - p, 3))));
    if (p < 1) requestAnimationFrame(pas);
  };
  requestAnimationFrame(pas);
}

/* ---------- Thème ---------- */
function appliquerTheme(theme, memoriser) {
  document.documentElement.dataset.theme = theme;
  const bouton = $("#theme");
  bouton.setAttribute("aria-pressed", String(theme === "dark"));
  bouton.setAttribute("aria-label", theme === "dark" ? "Passer en thème clair" : "Passer en thème sombre");
  if (memoriser) { try { localStorage.setItem("boussole-theme", theme); } catch { /* ignoré */ } }
}

function initialiserTheme() {
  const fixe = document.documentElement.dataset.theme;
  const systemeSombre = window.matchMedia("(prefers-color-scheme: dark)").matches;
  appliquerTheme(fixe || (systemeSombre ? "dark" : "light"), false);
  $("#theme").addEventListener("click", () => {
    appliquerTheme(document.documentElement.dataset.theme === "dark" ? "light" : "dark", true);
  });
}

async function api(chemin, corps) {
  const options = corps
    ? { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(corps) }
    : undefined;
  let reponse;
  try {
    reponse = await fetch(chemin, options);
  } catch {
    throw new Error("Impossible de joindre le serveur. Vérifie qu'il est bien lancé.");
  }
  if (!reponse.ok) {
    let message = `Erreur ${reponse.status}`;
    try {
      const d = await reponse.json();
      if (typeof d.detail === "string") message = d.detail;
    } catch { /* corps non JSON */ }
    throw new Error(message);
  }
  return reponse.json();
}

function afficherErreur(conteneur, erreur, reessayer) {
  conteneur.replaceChildren(
    h("div", { class: "erreur", role: "alert" },
      h("p", {}, erreur.message),
      reessayer && h("button", { type: "button", class: "bouton secondaire", onclick: reessayer }, "Réessayer"))
  );
  conteneur.hidden = false;
}

/* ---------- Navigation entre les vues ---------- */

function voir(nom) {
  for (const section of document.querySelectorAll(".vue")) section.hidden = section.id !== `vue-${nom}`;
  for (const bouton of document.querySelectorAll(".navigation button")) {
    if (bouton.dataset.vue === nom) bouton.setAttribute("aria-current", "page");
    else bouton.removeAttribute("aria-current");
  }
  if (nom === "regles") chargerRegles();
  window.scrollTo({ top: 0 });
}

/* ---------- Arbre de preuve ---------- */

const LIBELLE_TYPE = { regle: "règle", fait: "fait", test: "test" };

let compteurNoeuds = 0;
function noeudArbre(n) {
  const li = h("li", { class: `noeud ${n.type}`, style: `--n:${Math.min(compteurNoeuds++, 14)}` },
    h("span", { class: "badge" }, LIBELLE_TYPE[n.type] || n.type),
    h("span", { class: "phrase" }, n.texte),
    h("code", { class: "but" }, n.but));
  if (n.enfants.length) li.append(h("ul", {}, n.enfants.map(noeudArbre)));
  return li;
}

function arbre(racine) {
  compteurNoeuds = 0;
  return h("ul", { class: "arbre" }, noeudArbre(racine));
}

/* Exemple affiché sur la page d'accueil (même format que celui renvoyé par l'API) */
const EXEMPLE = {
  type: "regle", texte: "Aptitude au calcul et à la logique", but: "aptitude_calcul",
  enfants: [{
    type: "regle", texte: "Niveau en mathématiques : au moins « fort »", but: "au_moins(maths,fort)",
    enfants: [{
      type: "fait", texte: "Niveau en mathématiques : Fort", but: "reponse(maths,fort)", enfants: [],
    }],
  }],
};

/* ---------- Questionnaire ---------- */

function montrer(zone) {
  for (const id of ["intro", "questionnaire", "resultats"]) $(`#${id}`).hidden = id !== zone;
}

async function avancer() {
  const zone = $("#questionnaire");
  const attente = zone.hidden ? null : squelette(zone, 3);
  try {
    const d = await api("/api/question-suivante", { reponses: etat.reponses });
    clearTimeout(attente);
    elaguer(d.pertinentes);
    if (d.terminee) return afficherResultats();
    rendreQuestion(d);
  } catch (e) {
    clearTimeout(attente);
    montrer("questionnaire");
    afficherErreur(zone, e, avancer);
  }
}

/* Retire les réponses à des questions devenues sans objet (ex. après un changement de série). */
function elaguer(pertinentes) {
  for (const id of Object.keys(etat.reponses)) {
    if (!pertinentes.includes(id)) delete etat.reponses[id];
  }
  etat.ordre = etat.ordre.filter((id) => id in etat.reponses);
}

function rendreQuestion(d) {
  const q = d.question;
  const pct = Math.round((d.repondues / d.total) * 100);
  montrer("questionnaire");
  $("#questionnaire").replaceChildren(
    h("div", { class: "question" },
      h("div", { class: "progression" },
        h("span", {}, `Question ${d.repondues + 1} sur ${d.total}`),
        h("div", { class: "barre", role: "progressbar", "aria-valuemin": "0", "aria-valuemax": "100", "aria-valuenow": String(pct), "aria-label": "Avancement" },
          h("span", { style: `width:${pct}%` }))),
      h("h2", { id: "titre-question", tabindex: "-1" }, q.texte),
      h("p", { class: "note" }, q.aide),
      h("div", { class: "options", role: "group", "aria-labelledby": "titre-question" },
        q.options.map((o, i) => h("button", {
          type: "button", class: `option${etat.reponses[q.id] === o.valeur ? " choisie" : ""}`,
          "aria-keyshortcuts": i < 9 ? String(i + 1) : false,
          onclick: () => choisir(q.id, o.valeur),
        }, h("kbd", { "aria-hidden": "true" }, String(i + 1)), h("span", {}, o.libelle)))),
      h("div", { class: "actions-question" },
        h("button", { type: "button", class: "lien", onclick: retour, disabled: etat.ordre.length === 0 }, "Question précédente"),
        h("p", { class: "astuce" }, "Astuce : les touches 1 à 9 choisissent une réponse."))));
  $("#titre-question").focus({ preventScroll: true });
}

function choisir(id, valeur) {
  etat.reponses[id] = valeur;
  if (!etat.ordre.includes(id)) etat.ordre.push(id);
  avancer();
}

function retour() {
  const id = etat.ordre.pop();
  if (id) delete etat.reponses[id];
  avancer();
}

function recommencer() {
  etat.reponses = {};
  etat.ordre = [];
  etat.resultat = null;
  etat.precedent = null;
  etat.ouverts.clear();
  avancer();
}

/* ---------- Résultats ---------- */

async function afficherResultats() {
  const zone = $("#resultats");
  const attente = zone.hidden ? squelette(zone, 4) : null;
  if (attente) { $("#intro").hidden = true; $("#questionnaire").hidden = true; }
  try {
    const res = await api("/api/recommander", { reponses: etat.reponses });
    clearTimeout(attente);
    if (etat.resultat) etat.precedent = classement(etat.resultat);
    etat.resultat = res;
    montrer("resultats");
    rendreResultats();
    window.scrollTo({ top: 0 });
  } catch (e) {
    clearTimeout(attente);
    montrer("resultats");
    afficherErreur(zone, e, afficherResultats);
  }
}

function classement(res) {
  const m = new Map();
  for (const f of res.filieres) m.set(f.id, { rang: f.rang, score: f.score });
  return m;
}

function variation(f) {
  if (!etat.precedent) return null;
  const avant = etat.precedent.get(f.id);
  if (!avant) return h("span", { class: "variation" }, "De nouveau possible");
  const dScore = f.score - avant.score;
  const dRang = avant.rang - f.rang;
  if (dScore === 0 && dRang === 0) return null;
  const morceaux = [];
  if (dRang > 0) morceaux.push(`monte de ${dRang} place${dRang > 1 ? "s" : ""}`);
  if (dRang < 0) morceaux.push(`descend de ${-dRang} place${dRang < -1 ? "s" : ""}`);
  if (dScore !== 0) morceaux.push(`${dScore > 0 ? "+" : "−"}${Math.abs(dScore)} points`);
  return h("span", { class: "variation" }, morceaux.join(", "));
}

function rendreResultats() {
  const res = etat.resultat;
  const premiere = res.filieres[0];
  const zone = $("#resultats");
  zone.classList.toggle("prolog-visible", document.body.classList.contains("prolog-visible"));

  const entete = h("div", { class: "resultats-entete" },
    h("h1", {}, "Tes pistes d'orientation"),
    h("label", { class: "interrupteur" },
      h("input", { type: "checkbox", checked: document.body.classList.contains("prolog-visible"), onchange: (e) => basculerProlog(e.target.checked) }),
      "Afficher les termes Prolog"));

  const intro = premiere
    ? h("p", { class: "chapeau" },
        `${premiere.nom} arrive en tête avec ${premiere.score} points sur 100. `,
        "Ouvre « Pourquoi cette réponse ? » sous chaque filière pour voir la démonstration du moteur.")
    : h("p", { class: "chapeau" }, "Aucune filière ne correspond à tes réponses. Change une réponse dans le panneau pour voir ce qui évolue.");

  const liste = h("ol", { class: "liste-filieres" }, res.filieres.map((f) => carteFiliere(f)));

  const ecartees = res.eliminees.length > 0 && h("details", { class: "ecartees" },
    h("summary", {}, `Filières écartées (${res.eliminees.length})`),
    h("ul", {}, res.eliminees.map((f) => h("li", {},
      h("strong", {}, f.nom),
      h("span", {}, f.raisons.join(" "))))));

  const avertissement = h("p", { class: "avertissement" },
    "Le score mesure l'adéquation de ton profil à une filière, pas tes chances d'être admis : les concours et les quotas décident. ",
    "Les conditions d'admission affichées sont indicatives, vérifie-les auprès des établissements.");

  zone.replaceChildren(
    entete, intro,
    h("div", { class: "resultats-grille" },
      h("div", {}, liste, ecartees, avertissement),
      panneauProfil(res.profil)));
}

/* Cadran : l'aiguille pointe le score (0 = gauche, 100 = droite). */
function cadran(score) {
  const v = Math.max(0, Math.min(100, Number(score) || 0));
  const graduations = Array.from({ length: 11 }, (_, i) => {
    const a = ((-90 + i * 18) * Math.PI) / 180;
    return s("line", { class: "graduation", x1: 60 + 37 * Math.sin(a), y1: 60 - 37 * Math.cos(a), x2: 60 + 41 * Math.sin(a), y2: 60 - 41 * Math.cos(a) });
  });
  const valeur = s("path", { class: "valeur", d: "M10 60 A50 50 0 0 1 110 60", pathLength: "100", "stroke-dasharray": "0 100" });
  const aiguille = s("g", { class: "aiguille-cadran", style: "transform:rotate(-90deg)" }, s("path", { d: "M57.6 60 L60 17 L62.4 60 Z" }));
  const svg = s("svg", { class: "cadran", viewBox: "0 0 120 68", role: "img", "aria-label": `Cadran : ${v} points sur 100` },
    s("path", { class: "piste", d: "M10 60 A50 50 0 0 1 110 60" }), valeur, graduations, aiguille,
    s("circle", { class: "pivot", cx: 60, cy: 60, r: 4 }));
  const demarrer = () => {
    valeur.setAttribute("stroke-dasharray", `${v} 100`);
    aiguille.style.transform = `rotate(${-90 + v * 1.8}deg)`;
  };
  if (reduireMouvement()) demarrer(); else requestAnimationFrame(() => requestAnimationFrame(demarrer));
  return svg;
}

function carteFiliere(f) {
  const ouvert = etat.ouverts.has(f.id);
  const panneau = h("div", { class: "pourquoi", id: `pq-${f.id}`, hidden: !ouvert }, ouvert ? contenuPourquoi(f) : null);
  const bouton = h("button", {
    type: "button", class: "lien", "aria-expanded": String(ouvert), "aria-controls": `pq-${f.id}`,
    onclick: () => {
      const ouvrir = panneau.hidden;
      panneau.hidden = !ouvrir;
      bouton.setAttribute("aria-expanded", String(ouvrir));
      if (ouvrir) {
        etat.ouverts.add(f.id);
        if (!panneau.firstChild) panneau.append(contenuPourquoi(f));
      } else {
        etat.ouverts.delete(f.id);
      }
    },
  }, "Pourquoi cette réponse ?");

  const liste = (textes, classe, vide) => h("ul", { class: classe },
    textes.length ? textes.map((t) => h("li", {}, t)) : h("li", { class: "vide" }, vide));

  let grand = null;
  const mesure = f.rang === 1
    ? h("div", { class: "cadran-bloc" },
        cadran(f.score),
        h("div", { class: "cadran-texte" },
          h("span", { class: "grand" }, (grand = h("span", {}, String(f.score))), h("small", {}, " / 100")),
          h("span", { class: "niveau" }, f.niveau),
          variation(f)))
    : h("div", { class: "score-ligne" },
        h("span", { class: "score" }, `${f.score} / 100`),
        h("div", { class: "jauge", "aria-hidden": "true" }, h("span", { style: `width:${f.score}%` })),
        h("span", { class: "niveau" }, f.niveau),
        variation(f));
  if (grand) compter(grand, Number(f.score) || 0);

  return h("li", { class: `filiere${f.rang === 1 ? " premiere" : ""}`, style: `--i:${Math.min(f.rang - 1, 8)}` },
    h("div", { class: "rang", "aria-hidden": "true" }, String(f.rang)),
    h("article", { "aria-label": f.nom },
      h("h3", {}, f.nom),
      mesure,
      h("p", {}, f.description),
      h("ul", { class: "puces" },
        h("li", {}, `Durée : ${f.duree}`),
        h("li", {}, `Coût : ${f.cout === "eleve" ? "élevé" : f.cout}`)),
      h("div", { class: "deux-listes" },
        h("div", { class: "forts" }, h("h4", {}, "Ce qui te correspond"), liste(f.points_forts, "", "Aucun point fort pour l'instant")),
        h("div", { class: "faibles" }, h("h4", {}, "À renforcer ou à vérifier"), liste(f.points_a_renforcer, "", "Rien à signaler"))),
      h("p", { class: "petit note" }, `Exemples d'établissements : ${f.etablissements}. Débouchés : ${f.debouches.join(", ")}.`),
      bouton,
      panneau));
}

function etatMarque(ok) {
  return h("span", { class: `marque-etat ${ok ? "ok" : "non"}`, role: "img", "aria-label": ok ? "satisfait" : "non satisfait" }, "");
}

function contenuPourquoi(f) {
  const frag = document.createDocumentFragment();
  frag.append(
    h("p", {}, `${f.nom} obtient ${f.score} points sur 100. Chaque critère satisfait rapporte ses points. `,
      "Ouvre une démonstration pour voir la chaîne de règles que le moteur Prolog a suivie."));

  frag.append(h("h4", {}, "Conditions requises"));
  frag.append(h("ul", { class: "criteres" }, f.exigences.map((e) =>
    h("li", { class: `critere ${e.ok ? "ok" : "non"}` },
      h("div", { class: "critere-ligne" }, etatMarque(e.ok), h("span", {}, e.texte), h("span")),
      h("div", { class: "critere-corps" },
        e.ok ? h("details", {}, h("summary", {}, "Voir la démonstration"), arbre(e.arbre)) : h("p", { class: "detail" }, e.detail))))));

  frag.append(h("h4", {}, "Critères"));
  const criteres = [...f.criteres].sort((a, b) => (b.ok - a.ok) || (b.poids - a.poids));
  frag.append(h("ul", { class: "criteres" }, criteres.map((c) =>
    h("li", { class: `critere ${c.ok ? "ok" : "non"}` },
      h("div", { class: "critere-ligne" },
        etatMarque(c.ok), h("span", {}, c.texte), h("span", { class: "points" }, `${c.points} / ${c.poids}`)),
      h("div", { class: "critere-corps" },
        c.ok ? h("details", {}, h("summary", {}, "Voir la démonstration"), arbre(c.arbre)) : h("p", { class: "detail" }, c.detail))))));
  return frag;
}

function basculerProlog(visible) {
  document.body.classList.toggle("prolog-visible", visible);
}

/* ---------- Panneau « et si ? » ---------- */

function panneauProfil(profil) {
  const champs = profil.map((p) => {
    const q = etat.questions[p.id];
    const id = `si-${p.id}`;
    return h("div", {},
      h("label", { for: id }, p.etiquette),
      h("select", { id, onchange: (e) => changerReponse(p.id, e.target.value) },
        q.options.map((o) => h("option", { value: o.valeur, selected: o.valeur === p.valeur }, o.libelle))));
  });
  return h("aside", { class: "profil", "aria-label": "Ton profil" },
    h("h2", {}, "Et si… ?"),
    h("p", {}, "Change une réponse : le classement se recalcule et indique ce qui bouge."),
    champs,
    h("button", { type: "button", class: "bouton secondaire", onclick: recommencer }, "Recommencer"));
}

function changerReponse(id, valeur) {
  etat.reponses[id] = valeur;
  avancer(); // si la série change, des questions peuvent devoir être reposées
}

/* ---------- Règles Prolog ---------- */

async function chargerRegles() {
  if (etat.regles) return;
  try {
    const d = await api("/api/regles");
    etat.regles = d.fichiers;
    const onglets = $("#regles-onglets");
    onglets.replaceChildren(...etat.regles.map((f, i) =>
      h("button", { type: "button", role: "tab", "aria-selected": String(i === 0), onclick: () => ouvrirFichier(i) }, f.nom)));
    ouvrirFichier(0);
  } catch (e) {
    $("#regles-description").textContent = e.message;
  }
}

function naviguerOnglets(e) {
  const onglets = [...$("#regles-onglets").children];
  const i = onglets.indexOf(document.activeElement);
  if (i < 0) return;
  let cible = null;
  if (e.key === "ArrowRight") cible = (i + 1) % onglets.length;
  else if (e.key === "ArrowLeft") cible = (i - 1 + onglets.length) % onglets.length;
  else if (e.key === "Home") cible = 0;
  else if (e.key === "End") cible = onglets.length - 1;
  if (cible === null) return;
  e.preventDefault();
  ouvrirFichier(cible);
  onglets[cible].focus();
}

function ouvrirFichier(i) {
  const f = etat.regles[i];
  [...$("#regles-onglets").children].forEach((b, j) => { b.setAttribute("aria-selected", String(i === j)); b.tabIndex = i === j ? 0 : -1; });
  $("#regles-description").textContent = f.description;
  const code = $("#regles-code");
  code.replaceChildren(...colorer(f.contenu));
  code.scrollTop = 0;
}

/* Coloration minimale de Prolog : commentaires, chaînes, variables, « :- » */
function colorer(source) {
  const motif = /(%.*$)|("(?:[^"\\]|\\.)*")|(\b[A-Z_][A-Za-z0-9_]*\b)|(:-|-->|->|\\\+)/gm;
  const noeuds = [];
  let dernier = 0;
  for (const m of source.matchAll(motif)) {
    if (m.index > dernier) noeuds.push(document.createTextNode(source.slice(dernier, m.index)));
    const classe = m[1] ? "c" : m[2] ? "s" : m[3] ? "v" : "o";
    noeuds.push(h("span", { class: classe }, m[0]));
    dernier = m.index + m[0].length;
  }
  noeuds.push(document.createTextNode(source.slice(dernier)));
  return noeuds;
}

/* ---------- Démarrage ---------- */

async function demarrer() {
  initialiserTheme();
  for (const bouton of document.querySelectorAll(".navigation button")) {
    bouton.addEventListener("click", () => voir(bouton.dataset.vue));
  }
  $("#regles-onglets").addEventListener("keydown", naviguerOnglets);
  /* Raccourcis 1 à 9 : choisir la réponse correspondante dans le questionnaire. */
  document.addEventListener("keydown", (e) => {
    if (e.metaKey || e.ctrlKey || e.altKey || $("#questionnaire").hidden) return;
    if (/^(INPUT|SELECT|TEXTAREA)$/.test(document.activeElement?.tagName)) return;
    if (!/^[1-9]$/.test(e.key)) return;
    const option = document.querySelectorAll("#questionnaire .option")[Number(e.key) - 1];
    if (option) { e.preventDefault(); option.click(); }
  });
  $("#exemple-arbre").append(arbre(EXEMPLE));
  document.body.classList.add("prolog-visible");
  $("#commencer").addEventListener("click", avancer);

  try {
    const d = await api("/api/questions");
    for (const q of d.questions) etat.questions[q.id] = q;
  } catch (e) {
    afficherErreur($("#intro"), e, () => location.reload());
  }
}

demarrer();
