// "sealed class" : hiérarchie fermée. Dart connaît ici la liste exacte des
// sous-types possibles (Loading, Content, Failure) — aucune autre classe
// ailleurs ne peut en ajouter un 4e. Ça permet au compilateur de vérifier
// qu'un switch sur un AsyncState couvre bien tous les cas.
//
// "<T>" : générique, réutilisable pour n'importe quel type de donnée.
sealed class AsyncState<T> {
  const AsyncState();
}

// Chargement en cours. "final class" : pas de sous-classe possible.
final class Loading<T> extends AsyncState<T> {
  const Loading();
}

// Chargement réussi : on a la donnée (une liste, un capteur seul, ...).
final class Content<T> extends AsyncState<T> {
  const Content(this.data);

  final T data;
}

// Chargement échoué.
final class Failure<T> extends AsyncState<T> {
  const Failure(this.message);

  final String message;
}
