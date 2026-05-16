// lib/domain/models/catalog_credits.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_credits.freezed.dart';
part 'catalog_credits.g.dart';

/// One person in either the cast or crew list returned by the backend
/// ``/credits`` endpoint. The fields are nullable because the same
/// model carries both (cast members have ``character`` set; crew
/// members have ``job`` set). [profileUrl] is a fully-qualified TMDB
/// image URL when present.
@freezed
class CatalogCreditPerson with _$CatalogCreditPerson {
  const factory CatalogCreditPerson({
    required int id,
    required String name,
    String? character,
    String? job,
    @JsonKey(name: 'profile_url') String? profileUrl,
    int? order,
  }) = _CatalogCreditPerson;

  factory CatalogCreditPerson.fromJson(Map<String, dynamic> json) =>
      _$CatalogCreditPersonFromJson(json);
}

/// Wraps the cast + crew lists for one title. The backend caps cast at
/// 10 and crew at 6 (curated jobs only), so consumers can render the
/// whole payload without further trimming.
@freezed
class CatalogCredits with _$CatalogCredits {
  const factory CatalogCredits({
    @Default(<CatalogCreditPerson>[]) List<CatalogCreditPerson> cast,
    @Default(<CatalogCreditPerson>[]) List<CatalogCreditPerson> crew,
  }) = _CatalogCredits;

  factory CatalogCredits.fromJson(Map<String, dynamic> json) =>
      _$CatalogCreditsFromJson(json);
}
