# Atelier — Aller plus loin après l'étape 4

**Durée indicative : 1 h 30** · Branche : `atelier/fiabilisation-actualisation`

Objectif : rendre l'actualisation de SensorHub plus robuste face aux erreurs et aux actions répétées de l'utilisateur. On part de l'application existante : états, Repository et notification ne sont pas recréés.

## Où j'en suis

Légende : `[x]` fait · `[ ]` à faire / à vérifier à la main

**Avant l'atelier (PDF de cours)**
- [x] Étape 1 — Interface statique (Freezed, `SensorCard`, hors ligne distinct)
- [x] Étape 2 — Extraction du ViewModel
- [x] Étape 3 — Repository + Fake (délai, erreur, injection)
- [x] Étape 4 — ViewModel réactif (`sealed AsyncState`, `ChangeNotifier`)

**Atelier**
- [x] 1. Branche `atelier/fiabilisation-actualisation`
- [x] 2. Nouvelle tentative après erreur (même instance du ViewModel)
- [x] 3. Actualisations répétées sans superposition
- [x] 4. Compteur de chargements dans le Fake (`loadCount`)
- [x] 5. Dernière actualisation réussie
- [x] Bonus — Données anciennes (> 30 s, 10 s en démo)
- [x] 6. Scénarios de démonstration préparés (`--dart-define=SCENARIO=...`)
- [x] Tests automatisés du ViewModel (`test/dashboard_view_model_test.dart`)
- [x] 7. Commit
- [ ] 7. Push et lien de la branche à partager
- [ ] Démonstration manuelle des 7 scénarios (voir « Quoi tester »)

## Énoncé

### 1. Créer une nouvelle branche

```bash
git switch -c atelier/fiabilisation-actualisation
```

Tout le travail est réalisé et poussé sur cette branche.

### 2. Gérer une nouvelle tentative

Scénario : le premier chargement échoue → l'application affiche l'erreur → l'utilisateur relance → la seconde tentative réussit et affiche les capteurs. La même instance du ViewModel est conservée pendant tout le scénario.

### 3. Gérer les actualisations répétées

Avec une réponse lente de plusieurs secondes, déclencher rapidement plusieurs actualisations. L'application doit faire en sorte que :

- plusieurs chargements ne se superposent pas ;
- l'utilisateur comprenne qu'une actualisation est en cours ;
- une nouvelle actualisation reste possible lorsque la précédente est terminée.

La solution est libre, mais il faut pouvoir expliquer la décision et l'endroit où la logique est placée.

### 4. Vérifier le nombre d'appels

Ajouter au FakeRepository un compteur du nombre de chargements réellement exécutés. Il sert uniquement à observer et à prouver que plusieurs actions rapides ne provoquent pas plusieurs chargements simultanés.

### 5. Afficher la dernière actualisation réussie

- avant le premier succès : `Aucune actualisation réussie` ;
- après un succès : l'heure de l'actualisation ;
- après une erreur : l'heure du dernier succès est conservée ;
- une nouvelle réussite met à jour l'heure.

Une tentative en erreur n'est jamais une actualisation réussie.

### 6. Préparer la démonstration

| Scénario | Résultat attendu |
|---|---|
| Premier chargement en erreur | L'erreur est visible et une nouvelle tentative est possible |
| Nouvelle tentative | Le chargement réussit avec la même instance du ViewModel |
| Réponse lente | L'utilisateur comprend qu'une opération est en cours |
| Actions répétées | Les chargements ne se superposent pas |
| Fin du chargement | Une nouvelle actualisation devient possible |
| Chargement réussi | L'heure de la dernière réussite est affichée |
| Erreur après un succès | L'heure du dernier succès est conservée |

Il faut pouvoir expliquer le trajet complet d'une actualisation, de l'action de l'utilisateur jusqu'au nouvel état publié par le ViewModel.

### Bonus — Signaler des données anciennes

Indiquer visuellement quand la dernière actualisation réussie date de plus de 30 secondes (10 s possible en démo). Une nouvelle réussite rend les données fraîches.

### 7. Pousser le travail sur GitHub

```bash
git status
git add <fichiers-modifiés>
git commit -m "Fiabilise les actualisations de SensorHub"
git push -u origin atelier/fiabilisation-actualisation
```

**Livrable** : le lien vers la branche GitHub. La démonstration doit prouver le comportement ; une explication seule ne suffit pas.

---

## Ce qui a été fait

| Fichier | Changement |
|---|---|
| `lib/repositories/fake_sensor_repository.dart` | `failingCalls` (numéros d'appels qui échouent, ex. `{1}`), `loadCount` (chargements réellement exécutés). `shouldThrow` et `delay` conservés. |
| `lib/view_models/dashboard_view_model.dart` | Garde anti-superposition (`_inFlight`), `isLoading`, `lastSuccessAt`, `lastRefreshLabel` (texte prêt pour l'UI), `isStale` + `staleAfter`, horloge injectable. |
| `lib/screens/sensor_list_screen.dart` | Écoute le ViewModel (`ListenableBuilder`), bouton ↻ désactivé pendant le chargement, « Actualisation en cours… », bouton « Réessayer » sur l'erreur, bandeau de dernière actualisation (orange si ancienne), `Timer` d'1 s pour détecter la péremption. |
| `lib/main.dart` | Scénarios via `--dart-define=SCENARIO=...`. Plus de `await` avant `runApp` : l'écran affiche lui-même le chargement. |
| `test/dashboard_view_model_test.dart` | 6 tests : états observés, retry même instance, appels rapides = 1 chargement, nouvelle actualisation possible, heure conservée en erreur, péremption. |
| `lib/router.dart` | Routage par id (`/sensor/:id`), travail précédent embarqué dans cette branche. |

### Décisions à pouvoir expliquer

- **Où est la garde ?** Dans le ViewModel (`load()`), pas dans la View. Il orchestre le chargement, donc la règle tient quelle que soit l'interface (bouton, pull-to-refresh, futur timer) et se teste sans widget. `load()` renvoie le même `Future` tant qu'un chargement est en cours.
- **Pourquoi un `Future?` plutôt qu'un `bool` ?** Les appelants simultanés attendent tous le même résultat, et on ne peut pas oublier de remettre un drapeau à `false` à un seul endroit sans le voir.
- **Pourquoi pas le test `state is Loading` ?** L'état initial est déjà `Loading` : le tout premier `load()` serait bloqué.
- **Le bouton désactivé suffit-il ?** Non, c'est un confort visuel. La vraie protection est dans le ViewModel.
- **Où est l'heure ?** Dans le ViewModel (`_lastSuccessAt`), mise à jour uniquement dans la branche succès. Le texte (`lastRefreshLabel`) est préparé là aussi : la View ne formate rien.
- **Pourquoi une horloge injectable ?** Pour tester l'heure et la péremption sans attendre 30 secondes.

### Trajet d'une actualisation

1. L'utilisateur touche ↻ ou « Réessayer » → `viewModel.load()`.
2. Si un chargement est en cours, `load()` renvoie le `Future` existant : rien d'autre ne se passe.
3. Sinon `_run()` publie `Loading` → `notifyListeners()` → l'écran affiche le spinner et désactive le bouton.
4. `repository.fetchAll()` s'exécute (`loadCount` +1).
5. Succès : `_lastSuccessAt` mis à jour, publie `Content`. Échec : `_lastSuccessAt` inchangé, publie `Failure`.
6. `_inFlight` repassé à `null` : une nouvelle actualisation est possible. L'écran se redessine.

---

## Quoi tester

### Tests automatiques

```bash
flutter analyze
flutter test
```

### Démonstration manuelle

Le scénario `demo` enchaîne tout : réponses lentes (4 s), les appels 1 et 3 échouent.

```bash
flutter run --dart-define=SCENARIO=demo
```

| # | Action | À voir |
|---|---|---|
| 1 | Lancer l'app | Spinner + « Actualisation en cours… » pendant 4 s, bandeau « Aucune actualisation réussie » |
| 2 | Attendre | **Erreur** + bouton « Réessayer » (appel 1) ; le bandeau dit toujours « Aucune actualisation réussie » |
| 3 | Taper « Réessayer » | Spinner, puis les 3 capteurs et « Dernière actualisation : HH:MM:SS » (appel 2) |
| 4 | Pendant un chargement, taper ↻ plusieurs fois | Bouton grisé, rien ne se superpose |
| 5 | Taper ↻ une fois le chargement fini | Un nouveau chargement démarre (appel 3), il échoue |
| 6 | Regarder le bandeau | **L'heure du succès de l'étape 3 est conservée** malgré l'erreur |
| 7 | Retaper « Réessayer » | Succès (appel 4), heure mise à jour |
| 8 | Bonus : `--dart-define=SCENARIO=stale`, attendre 10 s | Bandeau orange « — données anciennes » ; ↻ le remet en gris |

Autres scénarios : `SCENARIO=retry` (seul le 1er appel échoue, réponse rapide) et `SCENARIO=normal` (défaut).

**Preuve du nombre d'appels** : `loadCount` n'est pas affiché dans l'interface. Il est vérifié par le test « des actualisations rapides ne lancent qu'un seul chargement » (3 `load()` simultanés → `loadCount == 1`). Pour le montrer à l'oral, lancer `flutter test` et ouvrir ce test.
