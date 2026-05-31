// lib/domain/models/library_category.dart
//
// Classifica un titolo de "La mia lista" in una delle 4 categorie. Si basa sui
// NOMI dei generi (la cache drift salva `genresJson = jsonEncode(genres)` dove
// `genres` è List<String> localizzata it-IT — NON ID numerici). Il backend filtra
// già Talk/News, quindi tra gli "show" arrivano di fatto solo Reality e Soap.
enum LibraryCategory { film, serieTv, show, anime }

LibraryCategory categoryFor(String mediaType, List<String> genres) {
  if (mediaType == 'movie') return LibraryCategory.film;
  // mediaType == 'tv'
  final g = genres.map((s) => s.toLowerCase().trim()).toSet();
  if (g.contains('animazione') || g.contains('animation')) {
    return LibraryCategory.anime;
  }
  const show = {'reality', 'soap'};
  if (g.any(show.contains)) return LibraryCategory.show;
  return LibraryCategory.serieTv;
}
