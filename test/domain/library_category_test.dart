import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/library_category.dart';

void main() {
  test('movie → film (anche con generi animazione)', () {
    expect(categoryFor('movie', const []), LibraryCategory.film);
    expect(categoryFor('movie', const ['Animazione']), LibraryCategory.film);
  });

  test('tv + Animazione → anime (case-insensitive)', () {
    expect(categoryFor('tv', const ['Animazione']), LibraryCategory.anime);
    expect(categoryFor('tv', const ['animazione']), LibraryCategory.anime);
    expect(categoryFor('tv', const ['Animation']), LibraryCategory.anime);
  });

  test('tv + Reality/Soap → show', () {
    expect(categoryFor('tv', const ['Reality']), LibraryCategory.show);
    expect(categoryFor('tv', const ['Soap']), LibraryCategory.show);
  });

  test('tv altri generi o vuoto → serieTv', () {
    expect(categoryFor('tv', const ['Dramma']), LibraryCategory.serieTv);
    expect(categoryFor('tv', const []), LibraryCategory.serieTv);
  });
}
