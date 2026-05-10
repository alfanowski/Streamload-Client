// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CatalogItemsTable extends CatalogItems
    with TableInfo<$CatalogItemsTable, CatalogItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
      'tmdb_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mediaTypeMeta =
      const VerificationMeta('mediaType');
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
      'media_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originalTitleMeta =
      const VerificationMeta('originalTitle');
  @override
  late final GeneratedColumn<String> originalTitle = GeneratedColumn<String>(
      'original_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _posterUrlMeta =
      const VerificationMeta('posterUrl');
  @override
  late final GeneratedColumn<String> posterUrl = GeneratedColumn<String>(
      'poster_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _backdropUrlMeta =
      const VerificationMeta('backdropUrl');
  @override
  late final GeneratedColumn<String> backdropUrl = GeneratedColumn<String>(
      'backdrop_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _overviewMeta =
      const VerificationMeta('overview');
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
      'overview', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
      'rating', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _runtimeMinutesMeta =
      const VerificationMeta('runtimeMinutes');
  @override
  late final GeneratedColumn<int> runtimeMinutes = GeneratedColumn<int>(
      'runtime_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _seasonsCountMeta =
      const VerificationMeta('seasonsCount');
  @override
  late final GeneratedColumn<int> seasonsCount = GeneratedColumn<int>(
      'seasons_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _genresJsonMeta =
      const VerificationMeta('genresJson');
  @override
  late final GeneratedColumn<String> genresJson = GeneratedColumn<String>(
      'genres_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _metadataFetchedAtMeta =
      const VerificationMeta('metadataFetchedAt');
  @override
  late final GeneratedColumn<DateTime> metadataFetchedAt =
      GeneratedColumn<DateTime>('metadata_fetched_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        tmdbId,
        mediaType,
        title,
        originalTitle,
        year,
        posterUrl,
        backdropUrl,
        overview,
        rating,
        runtimeMinutes,
        seasonsCount,
        genresJson,
        metadataFetchedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tmdb_id')) {
      context.handle(_tmdbIdMeta,
          tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta));
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta));
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('original_title')) {
      context.handle(
          _originalTitleMeta,
          originalTitle.isAcceptableOrUnknown(
              data['original_title']!, _originalTitleMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('poster_url')) {
      context.handle(_posterUrlMeta,
          posterUrl.isAcceptableOrUnknown(data['poster_url']!, _posterUrlMeta));
    }
    if (data.containsKey('backdrop_url')) {
      context.handle(
          _backdropUrlMeta,
          backdropUrl.isAcceptableOrUnknown(
              data['backdrop_url']!, _backdropUrlMeta));
    }
    if (data.containsKey('overview')) {
      context.handle(_overviewMeta,
          overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('runtime_minutes')) {
      context.handle(
          _runtimeMinutesMeta,
          runtimeMinutes.isAcceptableOrUnknown(
              data['runtime_minutes']!, _runtimeMinutesMeta));
    }
    if (data.containsKey('seasons_count')) {
      context.handle(
          _seasonsCountMeta,
          seasonsCount.isAcceptableOrUnknown(
              data['seasons_count']!, _seasonsCountMeta));
    }
    if (data.containsKey('genres_json')) {
      context.handle(
          _genresJsonMeta,
          genresJson.isAcceptableOrUnknown(
              data['genres_json']!, _genresJsonMeta));
    }
    if (data.containsKey('metadata_fetched_at')) {
      context.handle(
          _metadataFetchedAtMeta,
          metadataFetchedAt.isAcceptableOrUnknown(
              data['metadata_fetched_at']!, _metadataFetchedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tmdbId, mediaType};
  @override
  CatalogItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItemRow(
      tmdbId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tmdb_id'])!,
      mediaType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      originalTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_title']),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year']),
      posterUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poster_url']),
      backdropUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backdrop_url']),
      overview: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}overview']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating']),
      runtimeMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}runtime_minutes']),
      seasonsCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seasons_count']),
      genresJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genres_json'])!,
      metadataFetchedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}metadata_fetched_at'])!,
    );
  }

  @override
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }
}

class CatalogItemRow extends DataClass implements Insertable<CatalogItemRow> {
  final int tmdbId;
  final String mediaType;
  final String title;
  final String? originalTitle;
  final int? year;
  final String? posterUrl;
  final String? backdropUrl;
  final String? overview;
  final double? rating;
  final int? runtimeMinutes;
  final int? seasonsCount;
  final String genresJson;
  final DateTime metadataFetchedAt;
  const CatalogItemRow(
      {required this.tmdbId,
      required this.mediaType,
      required this.title,
      this.originalTitle,
      this.year,
      this.posterUrl,
      this.backdropUrl,
      this.overview,
      this.rating,
      this.runtimeMinutes,
      this.seasonsCount,
      required this.genresJson,
      required this.metadataFetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['media_type'] = Variable<String>(mediaType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || originalTitle != null) {
      map['original_title'] = Variable<String>(originalTitle);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || posterUrl != null) {
      map['poster_url'] = Variable<String>(posterUrl);
    }
    if (!nullToAbsent || backdropUrl != null) {
      map['backdrop_url'] = Variable<String>(backdropUrl);
    }
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || runtimeMinutes != null) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes);
    }
    if (!nullToAbsent || seasonsCount != null) {
      map['seasons_count'] = Variable<int>(seasonsCount);
    }
    map['genres_json'] = Variable<String>(genresJson);
    map['metadata_fetched_at'] = Variable<DateTime>(metadataFetchedAt);
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      tmdbId: Value(tmdbId),
      mediaType: Value(mediaType),
      title: Value(title),
      originalTitle: originalTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(originalTitle),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      posterUrl: posterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(posterUrl),
      backdropUrl: backdropUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(backdropUrl),
      overview: overview == null && nullToAbsent
          ? const Value.absent()
          : Value(overview),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      runtimeMinutes: runtimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(runtimeMinutes),
      seasonsCount: seasonsCount == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonsCount),
      genresJson: Value(genresJson),
      metadataFetchedAt: Value(metadataFetchedAt),
    );
  }

  factory CatalogItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItemRow(
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      title: serializer.fromJson<String>(json['title']),
      originalTitle: serializer.fromJson<String?>(json['originalTitle']),
      year: serializer.fromJson<int?>(json['year']),
      posterUrl: serializer.fromJson<String?>(json['posterUrl']),
      backdropUrl: serializer.fromJson<String?>(json['backdropUrl']),
      overview: serializer.fromJson<String?>(json['overview']),
      rating: serializer.fromJson<double?>(json['rating']),
      runtimeMinutes: serializer.fromJson<int?>(json['runtimeMinutes']),
      seasonsCount: serializer.fromJson<int?>(json['seasonsCount']),
      genresJson: serializer.fromJson<String>(json['genresJson']),
      metadataFetchedAt:
          serializer.fromJson<DateTime>(json['metadataFetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tmdbId': serializer.toJson<int>(tmdbId),
      'mediaType': serializer.toJson<String>(mediaType),
      'title': serializer.toJson<String>(title),
      'originalTitle': serializer.toJson<String?>(originalTitle),
      'year': serializer.toJson<int?>(year),
      'posterUrl': serializer.toJson<String?>(posterUrl),
      'backdropUrl': serializer.toJson<String?>(backdropUrl),
      'overview': serializer.toJson<String?>(overview),
      'rating': serializer.toJson<double?>(rating),
      'runtimeMinutes': serializer.toJson<int?>(runtimeMinutes),
      'seasonsCount': serializer.toJson<int?>(seasonsCount),
      'genresJson': serializer.toJson<String>(genresJson),
      'metadataFetchedAt': serializer.toJson<DateTime>(metadataFetchedAt),
    };
  }

  CatalogItemRow copyWith(
          {int? tmdbId,
          String? mediaType,
          String? title,
          Value<String?> originalTitle = const Value.absent(),
          Value<int?> year = const Value.absent(),
          Value<String?> posterUrl = const Value.absent(),
          Value<String?> backdropUrl = const Value.absent(),
          Value<String?> overview = const Value.absent(),
          Value<double?> rating = const Value.absent(),
          Value<int?> runtimeMinutes = const Value.absent(),
          Value<int?> seasonsCount = const Value.absent(),
          String? genresJson,
          DateTime? metadataFetchedAt}) =>
      CatalogItemRow(
        tmdbId: tmdbId ?? this.tmdbId,
        mediaType: mediaType ?? this.mediaType,
        title: title ?? this.title,
        originalTitle:
            originalTitle.present ? originalTitle.value : this.originalTitle,
        year: year.present ? year.value : this.year,
        posterUrl: posterUrl.present ? posterUrl.value : this.posterUrl,
        backdropUrl: backdropUrl.present ? backdropUrl.value : this.backdropUrl,
        overview: overview.present ? overview.value : this.overview,
        rating: rating.present ? rating.value : this.rating,
        runtimeMinutes:
            runtimeMinutes.present ? runtimeMinutes.value : this.runtimeMinutes,
        seasonsCount:
            seasonsCount.present ? seasonsCount.value : this.seasonsCount,
        genresJson: genresJson ?? this.genresJson,
        metadataFetchedAt: metadataFetchedAt ?? this.metadataFetchedAt,
      );
  CatalogItemRow copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItemRow(
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      title: data.title.present ? data.title.value : this.title,
      originalTitle: data.originalTitle.present
          ? data.originalTitle.value
          : this.originalTitle,
      year: data.year.present ? data.year.value : this.year,
      posterUrl: data.posterUrl.present ? data.posterUrl.value : this.posterUrl,
      backdropUrl:
          data.backdropUrl.present ? data.backdropUrl.value : this.backdropUrl,
      overview: data.overview.present ? data.overview.value : this.overview,
      rating: data.rating.present ? data.rating.value : this.rating,
      runtimeMinutes: data.runtimeMinutes.present
          ? data.runtimeMinutes.value
          : this.runtimeMinutes,
      seasonsCount: data.seasonsCount.present
          ? data.seasonsCount.value
          : this.seasonsCount,
      genresJson:
          data.genresJson.present ? data.genresJson.value : this.genresJson,
      metadataFetchedAt: data.metadataFetchedAt.present
          ? data.metadataFetchedAt.value
          : this.metadataFetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemRow(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('title: $title, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('year: $year, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('backdropUrl: $backdropUrl, ')
          ..write('overview: $overview, ')
          ..write('rating: $rating, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('seasonsCount: $seasonsCount, ')
          ..write('genresJson: $genresJson, ')
          ..write('metadataFetchedAt: $metadataFetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      tmdbId,
      mediaType,
      title,
      originalTitle,
      year,
      posterUrl,
      backdropUrl,
      overview,
      rating,
      runtimeMinutes,
      seasonsCount,
      genresJson,
      metadataFetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItemRow &&
          other.tmdbId == this.tmdbId &&
          other.mediaType == this.mediaType &&
          other.title == this.title &&
          other.originalTitle == this.originalTitle &&
          other.year == this.year &&
          other.posterUrl == this.posterUrl &&
          other.backdropUrl == this.backdropUrl &&
          other.overview == this.overview &&
          other.rating == this.rating &&
          other.runtimeMinutes == this.runtimeMinutes &&
          other.seasonsCount == this.seasonsCount &&
          other.genresJson == this.genresJson &&
          other.metadataFetchedAt == this.metadataFetchedAt);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItemRow> {
  final Value<int> tmdbId;
  final Value<String> mediaType;
  final Value<String> title;
  final Value<String?> originalTitle;
  final Value<int?> year;
  final Value<String?> posterUrl;
  final Value<String?> backdropUrl;
  final Value<String?> overview;
  final Value<double?> rating;
  final Value<int?> runtimeMinutes;
  final Value<int?> seasonsCount;
  final Value<String> genresJson;
  final Value<DateTime> metadataFetchedAt;
  final Value<int> rowid;
  const CatalogItemsCompanion({
    this.tmdbId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.title = const Value.absent(),
    this.originalTitle = const Value.absent(),
    this.year = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.backdropUrl = const Value.absent(),
    this.overview = const Value.absent(),
    this.rating = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.seasonsCount = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.metadataFetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    required int tmdbId,
    required String mediaType,
    required String title,
    this.originalTitle = const Value.absent(),
    this.year = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.backdropUrl = const Value.absent(),
    this.overview = const Value.absent(),
    this.rating = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.seasonsCount = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.metadataFetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : tmdbId = Value(tmdbId),
        mediaType = Value(mediaType),
        title = Value(title);
  static Insertable<CatalogItemRow> custom({
    Expression<int>? tmdbId,
    Expression<String>? mediaType,
    Expression<String>? title,
    Expression<String>? originalTitle,
    Expression<int>? year,
    Expression<String>? posterUrl,
    Expression<String>? backdropUrl,
    Expression<String>? overview,
    Expression<double>? rating,
    Expression<int>? runtimeMinutes,
    Expression<int>? seasonsCount,
    Expression<String>? genresJson,
    Expression<DateTime>? metadataFetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (mediaType != null) 'media_type': mediaType,
      if (title != null) 'title': title,
      if (originalTitle != null) 'original_title': originalTitle,
      if (year != null) 'year': year,
      if (posterUrl != null) 'poster_url': posterUrl,
      if (backdropUrl != null) 'backdrop_url': backdropUrl,
      if (overview != null) 'overview': overview,
      if (rating != null) 'rating': rating,
      if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
      if (seasonsCount != null) 'seasons_count': seasonsCount,
      if (genresJson != null) 'genres_json': genresJson,
      if (metadataFetchedAt != null) 'metadata_fetched_at': metadataFetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemsCompanion copyWith(
      {Value<int>? tmdbId,
      Value<String>? mediaType,
      Value<String>? title,
      Value<String?>? originalTitle,
      Value<int?>? year,
      Value<String?>? posterUrl,
      Value<String?>? backdropUrl,
      Value<String?>? overview,
      Value<double?>? rating,
      Value<int?>? runtimeMinutes,
      Value<int?>? seasonsCount,
      Value<String>? genresJson,
      Value<DateTime>? metadataFetchedAt,
      Value<int>? rowid}) {
    return CatalogItemsCompanion(
      tmdbId: tmdbId ?? this.tmdbId,
      mediaType: mediaType ?? this.mediaType,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      year: year ?? this.year,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      overview: overview ?? this.overview,
      rating: rating ?? this.rating,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      seasonsCount: seasonsCount ?? this.seasonsCount,
      genresJson: genresJson ?? this.genresJson,
      metadataFetchedAt: metadataFetchedAt ?? this.metadataFetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (originalTitle.present) {
      map['original_title'] = Variable<String>(originalTitle.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (posterUrl.present) {
      map['poster_url'] = Variable<String>(posterUrl.value);
    }
    if (backdropUrl.present) {
      map['backdrop_url'] = Variable<String>(backdropUrl.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (runtimeMinutes.present) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes.value);
    }
    if (seasonsCount.present) {
      map['seasons_count'] = Variable<int>(seasonsCount.value);
    }
    if (genresJson.present) {
      map['genres_json'] = Variable<String>(genresJson.value);
    }
    if (metadataFetchedAt.present) {
      map['metadata_fetched_at'] = Variable<DateTime>(metadataFetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('title: $title, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('year: $year, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('backdropUrl: $backdropUrl, ')
          ..write('overview: $overview, ')
          ..write('rating: $rating, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('seasonsCount: $seasonsCount, ')
          ..write('genresJson: $genresJson, ')
          ..write('metadataFetchedAt: $metadataFetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TvEpisodesTable extends TvEpisodes
    with TableInfo<$TvEpisodesTable, TvEpisodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TvEpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
      'tmdb_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mediaTypeMeta =
      const VerificationMeta('mediaType');
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
      'media_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('tv'));
  static const VerificationMeta _seasonNumberMeta =
      const VerificationMeta('seasonNumber');
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
      'season_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _episodeNumberMeta =
      const VerificationMeta('episodeNumber');
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
      'episode_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _overviewMeta =
      const VerificationMeta('overview');
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
      'overview', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _airDateMeta =
      const VerificationMeta('airDate');
  @override
  late final GeneratedColumn<DateTime> airDate = GeneratedColumn<DateTime>(
      'air_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _runtimeMinutesMeta =
      const VerificationMeta('runtimeMinutes');
  @override
  late final GeneratedColumn<int> runtimeMinutes = GeneratedColumn<int>(
      'runtime_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _stillUrlMeta =
      const VerificationMeta('stillUrl');
  @override
  late final GeneratedColumn<String> stillUrl = GeneratedColumn<String>(
      'still_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        tmdbId,
        mediaType,
        seasonNumber,
        episodeNumber,
        title,
        overview,
        airDate,
        runtimeMinutes,
        stillUrl
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tv_episodes';
  @override
  VerificationContext validateIntegrity(Insertable<TvEpisodeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tmdb_id')) {
      context.handle(_tmdbIdMeta,
          tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta));
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta));
    }
    if (data.containsKey('season_number')) {
      context.handle(
          _seasonNumberMeta,
          seasonNumber.isAcceptableOrUnknown(
              data['season_number']!, _seasonNumberMeta));
    } else if (isInserting) {
      context.missing(_seasonNumberMeta);
    }
    if (data.containsKey('episode_number')) {
      context.handle(
          _episodeNumberMeta,
          episodeNumber.isAcceptableOrUnknown(
              data['episode_number']!, _episodeNumberMeta));
    } else if (isInserting) {
      context.missing(_episodeNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('overview')) {
      context.handle(_overviewMeta,
          overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta));
    }
    if (data.containsKey('air_date')) {
      context.handle(_airDateMeta,
          airDate.isAcceptableOrUnknown(data['air_date']!, _airDateMeta));
    }
    if (data.containsKey('runtime_minutes')) {
      context.handle(
          _runtimeMinutesMeta,
          runtimeMinutes.isAcceptableOrUnknown(
              data['runtime_minutes']!, _runtimeMinutesMeta));
    }
    if (data.containsKey('still_url')) {
      context.handle(_stillUrlMeta,
          stillUrl.isAcceptableOrUnknown(data['still_url']!, _stillUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey =>
      {tmdbId, mediaType, seasonNumber, episodeNumber};
  @override
  TvEpisodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TvEpisodeRow(
      tmdbId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tmdb_id'])!,
      mediaType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_type'])!,
      seasonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season_number'])!,
      episodeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode_number'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      overview: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}overview']),
      airDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}air_date']),
      runtimeMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}runtime_minutes']),
      stillUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}still_url']),
    );
  }

  @override
  $TvEpisodesTable createAlias(String alias) {
    return $TvEpisodesTable(attachedDatabase, alias);
  }
}

class TvEpisodeRow extends DataClass implements Insertable<TvEpisodeRow> {
  final int tmdbId;
  final String mediaType;
  final int seasonNumber;
  final int episodeNumber;
  final String? title;
  final String? overview;
  final DateTime? airDate;
  final int? runtimeMinutes;
  final String? stillUrl;
  const TvEpisodeRow(
      {required this.tmdbId,
      required this.mediaType,
      required this.seasonNumber,
      required this.episodeNumber,
      this.title,
      this.overview,
      this.airDate,
      this.runtimeMinutes,
      this.stillUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['media_type'] = Variable<String>(mediaType);
    map['season_number'] = Variable<int>(seasonNumber);
    map['episode_number'] = Variable<int>(episodeNumber);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    if (!nullToAbsent || airDate != null) {
      map['air_date'] = Variable<DateTime>(airDate);
    }
    if (!nullToAbsent || runtimeMinutes != null) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes);
    }
    if (!nullToAbsent || stillUrl != null) {
      map['still_url'] = Variable<String>(stillUrl);
    }
    return map;
  }

  TvEpisodesCompanion toCompanion(bool nullToAbsent) {
    return TvEpisodesCompanion(
      tmdbId: Value(tmdbId),
      mediaType: Value(mediaType),
      seasonNumber: Value(seasonNumber),
      episodeNumber: Value(episodeNumber),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      overview: overview == null && nullToAbsent
          ? const Value.absent()
          : Value(overview),
      airDate: airDate == null && nullToAbsent
          ? const Value.absent()
          : Value(airDate),
      runtimeMinutes: runtimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(runtimeMinutes),
      stillUrl: stillUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(stillUrl),
    );
  }

  factory TvEpisodeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TvEpisodeRow(
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      seasonNumber: serializer.fromJson<int>(json['seasonNumber']),
      episodeNumber: serializer.fromJson<int>(json['episodeNumber']),
      title: serializer.fromJson<String?>(json['title']),
      overview: serializer.fromJson<String?>(json['overview']),
      airDate: serializer.fromJson<DateTime?>(json['airDate']),
      runtimeMinutes: serializer.fromJson<int?>(json['runtimeMinutes']),
      stillUrl: serializer.fromJson<String?>(json['stillUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tmdbId': serializer.toJson<int>(tmdbId),
      'mediaType': serializer.toJson<String>(mediaType),
      'seasonNumber': serializer.toJson<int>(seasonNumber),
      'episodeNumber': serializer.toJson<int>(episodeNumber),
      'title': serializer.toJson<String?>(title),
      'overview': serializer.toJson<String?>(overview),
      'airDate': serializer.toJson<DateTime?>(airDate),
      'runtimeMinutes': serializer.toJson<int?>(runtimeMinutes),
      'stillUrl': serializer.toJson<String?>(stillUrl),
    };
  }

  TvEpisodeRow copyWith(
          {int? tmdbId,
          String? mediaType,
          int? seasonNumber,
          int? episodeNumber,
          Value<String?> title = const Value.absent(),
          Value<String?> overview = const Value.absent(),
          Value<DateTime?> airDate = const Value.absent(),
          Value<int?> runtimeMinutes = const Value.absent(),
          Value<String?> stillUrl = const Value.absent()}) =>
      TvEpisodeRow(
        tmdbId: tmdbId ?? this.tmdbId,
        mediaType: mediaType ?? this.mediaType,
        seasonNumber: seasonNumber ?? this.seasonNumber,
        episodeNumber: episodeNumber ?? this.episodeNumber,
        title: title.present ? title.value : this.title,
        overview: overview.present ? overview.value : this.overview,
        airDate: airDate.present ? airDate.value : this.airDate,
        runtimeMinutes:
            runtimeMinutes.present ? runtimeMinutes.value : this.runtimeMinutes,
        stillUrl: stillUrl.present ? stillUrl.value : this.stillUrl,
      );
  TvEpisodeRow copyWithCompanion(TvEpisodesCompanion data) {
    return TvEpisodeRow(
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      title: data.title.present ? data.title.value : this.title,
      overview: data.overview.present ? data.overview.value : this.overview,
      airDate: data.airDate.present ? data.airDate.value : this.airDate,
      runtimeMinutes: data.runtimeMinutes.present
          ? data.runtimeMinutes.value
          : this.runtimeMinutes,
      stillUrl: data.stillUrl.present ? data.stillUrl.value : this.stillUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TvEpisodeRow(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('title: $title, ')
          ..write('overview: $overview, ')
          ..write('airDate: $airDate, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('stillUrl: $stillUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tmdbId, mediaType, seasonNumber,
      episodeNumber, title, overview, airDate, runtimeMinutes, stillUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TvEpisodeRow &&
          other.tmdbId == this.tmdbId &&
          other.mediaType == this.mediaType &&
          other.seasonNumber == this.seasonNumber &&
          other.episodeNumber == this.episodeNumber &&
          other.title == this.title &&
          other.overview == this.overview &&
          other.airDate == this.airDate &&
          other.runtimeMinutes == this.runtimeMinutes &&
          other.stillUrl == this.stillUrl);
}

class TvEpisodesCompanion extends UpdateCompanion<TvEpisodeRow> {
  final Value<int> tmdbId;
  final Value<String> mediaType;
  final Value<int> seasonNumber;
  final Value<int> episodeNumber;
  final Value<String?> title;
  final Value<String?> overview;
  final Value<DateTime?> airDate;
  final Value<int?> runtimeMinutes;
  final Value<String?> stillUrl;
  final Value<int> rowid;
  const TvEpisodesCompanion({
    this.tmdbId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.overview = const Value.absent(),
    this.airDate = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.stillUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TvEpisodesCompanion.insert({
    required int tmdbId,
    this.mediaType = const Value.absent(),
    required int seasonNumber,
    required int episodeNumber,
    this.title = const Value.absent(),
    this.overview = const Value.absent(),
    this.airDate = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.stillUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : tmdbId = Value(tmdbId),
        seasonNumber = Value(seasonNumber),
        episodeNumber = Value(episodeNumber);
  static Insertable<TvEpisodeRow> custom({
    Expression<int>? tmdbId,
    Expression<String>? mediaType,
    Expression<int>? seasonNumber,
    Expression<int>? episodeNumber,
    Expression<String>? title,
    Expression<String>? overview,
    Expression<DateTime>? airDate,
    Expression<int>? runtimeMinutes,
    Expression<String>? stillUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (mediaType != null) 'media_type': mediaType,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (title != null) 'title': title,
      if (overview != null) 'overview': overview,
      if (airDate != null) 'air_date': airDate,
      if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
      if (stillUrl != null) 'still_url': stillUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TvEpisodesCompanion copyWith(
      {Value<int>? tmdbId,
      Value<String>? mediaType,
      Value<int>? seasonNumber,
      Value<int>? episodeNumber,
      Value<String?>? title,
      Value<String?>? overview,
      Value<DateTime?>? airDate,
      Value<int?>? runtimeMinutes,
      Value<String?>? stillUrl,
      Value<int>? rowid}) {
    return TvEpisodesCompanion(
      tmdbId: tmdbId ?? this.tmdbId,
      mediaType: mediaType ?? this.mediaType,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      airDate: airDate ?? this.airDate,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      stillUrl: stillUrl ?? this.stillUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (airDate.present) {
      map['air_date'] = Variable<DateTime>(airDate.value);
    }
    if (runtimeMinutes.present) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes.value);
    }
    if (stillUrl.present) {
      map['still_url'] = Variable<String>(stillUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TvEpisodesCompanion(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('title: $title, ')
          ..write('overview: $overview, ')
          ..write('airDate: $airDate, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('stillUrl: $stillUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogSourcesTable extends CatalogSources
    with TableInfo<$CatalogSourcesTable, CatalogSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
      'tmdb_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mediaTypeMeta =
      const VerificationMeta('mediaType');
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
      'media_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pluginShortNameMeta =
      const VerificationMeta('pluginShortName');
  @override
  late final GeneratedColumn<String> pluginShortName = GeneratedColumn<String>(
      'plugin_short_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceUrlMeta =
      const VerificationMeta('serviceUrl');
  @override
  late final GeneratedColumn<String> serviceUrl = GeneratedColumn<String>(
      'service_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceMediaIdMeta =
      const VerificationMeta('serviceMediaId');
  @override
  late final GeneratedColumn<String> serviceMediaId = GeneratedColumn<String>(
      'service_media_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qualityMaxHeightMeta =
      const VerificationMeta('qualityMaxHeight');
  @override
  late final GeneratedColumn<int> qualityMaxHeight = GeneratedColumn<int>(
      'quality_max_height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _audioLangsJsonMeta =
      const VerificationMeta('audioLangsJson');
  @override
  late final GeneratedColumn<String> audioLangsJson = GeneratedColumn<String>(
      'audio_langs_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _subsLangsJsonMeta =
      const VerificationMeta('subsLangsJson');
  @override
  late final GeneratedColumn<String> subsLangsJson = GeneratedColumn<String>(
      'subs_langs_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _successCountMeta =
      const VerificationMeta('successCount');
  @override
  late final GeneratedColumn<int> successCount = GeneratedColumn<int>(
      'success_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _failureCountMeta =
      const VerificationMeta('failureCount');
  @override
  late final GeneratedColumn<int> failureCount = GeneratedColumn<int>(
      'failure_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastVerifiedAtMeta =
      const VerificationMeta('lastVerifiedAt');
  @override
  late final GeneratedColumn<DateTime> lastVerifiedAt =
      GeneratedColumn<DateTime>('last_verified_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        tmdbId,
        mediaType,
        pluginShortName,
        serviceUrl,
        serviceMediaId,
        qualityMaxHeight,
        audioLangsJson,
        subsLangsJson,
        successCount,
        failureCount,
        lastVerifiedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_sources';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogSourceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tmdb_id')) {
      context.handle(_tmdbIdMeta,
          tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta));
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta));
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('plugin_short_name')) {
      context.handle(
          _pluginShortNameMeta,
          pluginShortName.isAcceptableOrUnknown(
              data['plugin_short_name']!, _pluginShortNameMeta));
    } else if (isInserting) {
      context.missing(_pluginShortNameMeta);
    }
    if (data.containsKey('service_url')) {
      context.handle(
          _serviceUrlMeta,
          serviceUrl.isAcceptableOrUnknown(
              data['service_url']!, _serviceUrlMeta));
    } else if (isInserting) {
      context.missing(_serviceUrlMeta);
    }
    if (data.containsKey('service_media_id')) {
      context.handle(
          _serviceMediaIdMeta,
          serviceMediaId.isAcceptableOrUnknown(
              data['service_media_id']!, _serviceMediaIdMeta));
    } else if (isInserting) {
      context.missing(_serviceMediaIdMeta);
    }
    if (data.containsKey('quality_max_height')) {
      context.handle(
          _qualityMaxHeightMeta,
          qualityMaxHeight.isAcceptableOrUnknown(
              data['quality_max_height']!, _qualityMaxHeightMeta));
    }
    if (data.containsKey('audio_langs_json')) {
      context.handle(
          _audioLangsJsonMeta,
          audioLangsJson.isAcceptableOrUnknown(
              data['audio_langs_json']!, _audioLangsJsonMeta));
    }
    if (data.containsKey('subs_langs_json')) {
      context.handle(
          _subsLangsJsonMeta,
          subsLangsJson.isAcceptableOrUnknown(
              data['subs_langs_json']!, _subsLangsJsonMeta));
    }
    if (data.containsKey('success_count')) {
      context.handle(
          _successCountMeta,
          successCount.isAcceptableOrUnknown(
              data['success_count']!, _successCountMeta));
    }
    if (data.containsKey('failure_count')) {
      context.handle(
          _failureCountMeta,
          failureCount.isAcceptableOrUnknown(
              data['failure_count']!, _failureCountMeta));
    }
    if (data.containsKey('last_verified_at')) {
      context.handle(
          _lastVerifiedAtMeta,
          lastVerifiedAt.isAcceptableOrUnknown(
              data['last_verified_at']!, _lastVerifiedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tmdbId, mediaType, pluginShortName};
  @override
  CatalogSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogSourceRow(
      tmdbId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tmdb_id'])!,
      mediaType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_type'])!,
      pluginShortName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}plugin_short_name'])!,
      serviceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_url'])!,
      serviceMediaId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}service_media_id'])!,
      qualityMaxHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quality_max_height']),
      audioLangsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}audio_langs_json'])!,
      subsLangsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subs_langs_json'])!,
      successCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}success_count'])!,
      failureCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}failure_count'])!,
      lastVerifiedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_verified_at'])!,
    );
  }

  @override
  $CatalogSourcesTable createAlias(String alias) {
    return $CatalogSourcesTable(attachedDatabase, alias);
  }
}

class CatalogSourceRow extends DataClass
    implements Insertable<CatalogSourceRow> {
  final int tmdbId;
  final String mediaType;
  final String pluginShortName;
  final String serviceUrl;
  final String serviceMediaId;
  final int? qualityMaxHeight;
  final String audioLangsJson;
  final String subsLangsJson;
  final int successCount;
  final int failureCount;
  final DateTime lastVerifiedAt;
  const CatalogSourceRow(
      {required this.tmdbId,
      required this.mediaType,
      required this.pluginShortName,
      required this.serviceUrl,
      required this.serviceMediaId,
      this.qualityMaxHeight,
      required this.audioLangsJson,
      required this.subsLangsJson,
      required this.successCount,
      required this.failureCount,
      required this.lastVerifiedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['media_type'] = Variable<String>(mediaType);
    map['plugin_short_name'] = Variable<String>(pluginShortName);
    map['service_url'] = Variable<String>(serviceUrl);
    map['service_media_id'] = Variable<String>(serviceMediaId);
    if (!nullToAbsent || qualityMaxHeight != null) {
      map['quality_max_height'] = Variable<int>(qualityMaxHeight);
    }
    map['audio_langs_json'] = Variable<String>(audioLangsJson);
    map['subs_langs_json'] = Variable<String>(subsLangsJson);
    map['success_count'] = Variable<int>(successCount);
    map['failure_count'] = Variable<int>(failureCount);
    map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt);
    return map;
  }

  CatalogSourcesCompanion toCompanion(bool nullToAbsent) {
    return CatalogSourcesCompanion(
      tmdbId: Value(tmdbId),
      mediaType: Value(mediaType),
      pluginShortName: Value(pluginShortName),
      serviceUrl: Value(serviceUrl),
      serviceMediaId: Value(serviceMediaId),
      qualityMaxHeight: qualityMaxHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityMaxHeight),
      audioLangsJson: Value(audioLangsJson),
      subsLangsJson: Value(subsLangsJson),
      successCount: Value(successCount),
      failureCount: Value(failureCount),
      lastVerifiedAt: Value(lastVerifiedAt),
    );
  }

  factory CatalogSourceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogSourceRow(
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      pluginShortName: serializer.fromJson<String>(json['pluginShortName']),
      serviceUrl: serializer.fromJson<String>(json['serviceUrl']),
      serviceMediaId: serializer.fromJson<String>(json['serviceMediaId']),
      qualityMaxHeight: serializer.fromJson<int?>(json['qualityMaxHeight']),
      audioLangsJson: serializer.fromJson<String>(json['audioLangsJson']),
      subsLangsJson: serializer.fromJson<String>(json['subsLangsJson']),
      successCount: serializer.fromJson<int>(json['successCount']),
      failureCount: serializer.fromJson<int>(json['failureCount']),
      lastVerifiedAt: serializer.fromJson<DateTime>(json['lastVerifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tmdbId': serializer.toJson<int>(tmdbId),
      'mediaType': serializer.toJson<String>(mediaType),
      'pluginShortName': serializer.toJson<String>(pluginShortName),
      'serviceUrl': serializer.toJson<String>(serviceUrl),
      'serviceMediaId': serializer.toJson<String>(serviceMediaId),
      'qualityMaxHeight': serializer.toJson<int?>(qualityMaxHeight),
      'audioLangsJson': serializer.toJson<String>(audioLangsJson),
      'subsLangsJson': serializer.toJson<String>(subsLangsJson),
      'successCount': serializer.toJson<int>(successCount),
      'failureCount': serializer.toJson<int>(failureCount),
      'lastVerifiedAt': serializer.toJson<DateTime>(lastVerifiedAt),
    };
  }

  CatalogSourceRow copyWith(
          {int? tmdbId,
          String? mediaType,
          String? pluginShortName,
          String? serviceUrl,
          String? serviceMediaId,
          Value<int?> qualityMaxHeight = const Value.absent(),
          String? audioLangsJson,
          String? subsLangsJson,
          int? successCount,
          int? failureCount,
          DateTime? lastVerifiedAt}) =>
      CatalogSourceRow(
        tmdbId: tmdbId ?? this.tmdbId,
        mediaType: mediaType ?? this.mediaType,
        pluginShortName: pluginShortName ?? this.pluginShortName,
        serviceUrl: serviceUrl ?? this.serviceUrl,
        serviceMediaId: serviceMediaId ?? this.serviceMediaId,
        qualityMaxHeight: qualityMaxHeight.present
            ? qualityMaxHeight.value
            : this.qualityMaxHeight,
        audioLangsJson: audioLangsJson ?? this.audioLangsJson,
        subsLangsJson: subsLangsJson ?? this.subsLangsJson,
        successCount: successCount ?? this.successCount,
        failureCount: failureCount ?? this.failureCount,
        lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      );
  CatalogSourceRow copyWithCompanion(CatalogSourcesCompanion data) {
    return CatalogSourceRow(
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      pluginShortName: data.pluginShortName.present
          ? data.pluginShortName.value
          : this.pluginShortName,
      serviceUrl:
          data.serviceUrl.present ? data.serviceUrl.value : this.serviceUrl,
      serviceMediaId: data.serviceMediaId.present
          ? data.serviceMediaId.value
          : this.serviceMediaId,
      qualityMaxHeight: data.qualityMaxHeight.present
          ? data.qualityMaxHeight.value
          : this.qualityMaxHeight,
      audioLangsJson: data.audioLangsJson.present
          ? data.audioLangsJson.value
          : this.audioLangsJson,
      subsLangsJson: data.subsLangsJson.present
          ? data.subsLangsJson.value
          : this.subsLangsJson,
      successCount: data.successCount.present
          ? data.successCount.value
          : this.successCount,
      failureCount: data.failureCount.present
          ? data.failureCount.value
          : this.failureCount,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogSourceRow(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('pluginShortName: $pluginShortName, ')
          ..write('serviceUrl: $serviceUrl, ')
          ..write('serviceMediaId: $serviceMediaId, ')
          ..write('qualityMaxHeight: $qualityMaxHeight, ')
          ..write('audioLangsJson: $audioLangsJson, ')
          ..write('subsLangsJson: $subsLangsJson, ')
          ..write('successCount: $successCount, ')
          ..write('failureCount: $failureCount, ')
          ..write('lastVerifiedAt: $lastVerifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      tmdbId,
      mediaType,
      pluginShortName,
      serviceUrl,
      serviceMediaId,
      qualityMaxHeight,
      audioLangsJson,
      subsLangsJson,
      successCount,
      failureCount,
      lastVerifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogSourceRow &&
          other.tmdbId == this.tmdbId &&
          other.mediaType == this.mediaType &&
          other.pluginShortName == this.pluginShortName &&
          other.serviceUrl == this.serviceUrl &&
          other.serviceMediaId == this.serviceMediaId &&
          other.qualityMaxHeight == this.qualityMaxHeight &&
          other.audioLangsJson == this.audioLangsJson &&
          other.subsLangsJson == this.subsLangsJson &&
          other.successCount == this.successCount &&
          other.failureCount == this.failureCount &&
          other.lastVerifiedAt == this.lastVerifiedAt);
}

class CatalogSourcesCompanion extends UpdateCompanion<CatalogSourceRow> {
  final Value<int> tmdbId;
  final Value<String> mediaType;
  final Value<String> pluginShortName;
  final Value<String> serviceUrl;
  final Value<String> serviceMediaId;
  final Value<int?> qualityMaxHeight;
  final Value<String> audioLangsJson;
  final Value<String> subsLangsJson;
  final Value<int> successCount;
  final Value<int> failureCount;
  final Value<DateTime> lastVerifiedAt;
  final Value<int> rowid;
  const CatalogSourcesCompanion({
    this.tmdbId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.pluginShortName = const Value.absent(),
    this.serviceUrl = const Value.absent(),
    this.serviceMediaId = const Value.absent(),
    this.qualityMaxHeight = const Value.absent(),
    this.audioLangsJson = const Value.absent(),
    this.subsLangsJson = const Value.absent(),
    this.successCount = const Value.absent(),
    this.failureCount = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogSourcesCompanion.insert({
    required int tmdbId,
    required String mediaType,
    required String pluginShortName,
    required String serviceUrl,
    required String serviceMediaId,
    this.qualityMaxHeight = const Value.absent(),
    this.audioLangsJson = const Value.absent(),
    this.subsLangsJson = const Value.absent(),
    this.successCount = const Value.absent(),
    this.failureCount = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : tmdbId = Value(tmdbId),
        mediaType = Value(mediaType),
        pluginShortName = Value(pluginShortName),
        serviceUrl = Value(serviceUrl),
        serviceMediaId = Value(serviceMediaId);
  static Insertable<CatalogSourceRow> custom({
    Expression<int>? tmdbId,
    Expression<String>? mediaType,
    Expression<String>? pluginShortName,
    Expression<String>? serviceUrl,
    Expression<String>? serviceMediaId,
    Expression<int>? qualityMaxHeight,
    Expression<String>? audioLangsJson,
    Expression<String>? subsLangsJson,
    Expression<int>? successCount,
    Expression<int>? failureCount,
    Expression<DateTime>? lastVerifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (mediaType != null) 'media_type': mediaType,
      if (pluginShortName != null) 'plugin_short_name': pluginShortName,
      if (serviceUrl != null) 'service_url': serviceUrl,
      if (serviceMediaId != null) 'service_media_id': serviceMediaId,
      if (qualityMaxHeight != null) 'quality_max_height': qualityMaxHeight,
      if (audioLangsJson != null) 'audio_langs_json': audioLangsJson,
      if (subsLangsJson != null) 'subs_langs_json': subsLangsJson,
      if (successCount != null) 'success_count': successCount,
      if (failureCount != null) 'failure_count': failureCount,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogSourcesCompanion copyWith(
      {Value<int>? tmdbId,
      Value<String>? mediaType,
      Value<String>? pluginShortName,
      Value<String>? serviceUrl,
      Value<String>? serviceMediaId,
      Value<int?>? qualityMaxHeight,
      Value<String>? audioLangsJson,
      Value<String>? subsLangsJson,
      Value<int>? successCount,
      Value<int>? failureCount,
      Value<DateTime>? lastVerifiedAt,
      Value<int>? rowid}) {
    return CatalogSourcesCompanion(
      tmdbId: tmdbId ?? this.tmdbId,
      mediaType: mediaType ?? this.mediaType,
      pluginShortName: pluginShortName ?? this.pluginShortName,
      serviceUrl: serviceUrl ?? this.serviceUrl,
      serviceMediaId: serviceMediaId ?? this.serviceMediaId,
      qualityMaxHeight: qualityMaxHeight ?? this.qualityMaxHeight,
      audioLangsJson: audioLangsJson ?? this.audioLangsJson,
      subsLangsJson: subsLangsJson ?? this.subsLangsJson,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (pluginShortName.present) {
      map['plugin_short_name'] = Variable<String>(pluginShortName.value);
    }
    if (serviceUrl.present) {
      map['service_url'] = Variable<String>(serviceUrl.value);
    }
    if (serviceMediaId.present) {
      map['service_media_id'] = Variable<String>(serviceMediaId.value);
    }
    if (qualityMaxHeight.present) {
      map['quality_max_height'] = Variable<int>(qualityMaxHeight.value);
    }
    if (audioLangsJson.present) {
      map['audio_langs_json'] = Variable<String>(audioLangsJson.value);
    }
    if (subsLangsJson.present) {
      map['subs_langs_json'] = Variable<String>(subsLangsJson.value);
    }
    if (successCount.present) {
      map['success_count'] = Variable<int>(successCount.value);
    }
    if (failureCount.present) {
      map['failure_count'] = Variable<int>(failureCount.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogSourcesCompanion(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('pluginShortName: $pluginShortName, ')
          ..write('serviceUrl: $serviceUrl, ')
          ..write('serviceMediaId: $serviceMediaId, ')
          ..write('qualityMaxHeight: $qualityMaxHeight, ')
          ..write('audioLangsJson: $audioLangsJson, ')
          ..write('subsLangsJson: $subsLangsJson, ')
          ..write('successCount: $successCount, ')
          ..write('failureCount: $failureCount, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchProgressTable extends WatchProgress
    with TableInfo<$WatchProgressTable, WatchProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
      'tmdb_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mediaTypeMeta =
      const VerificationMeta('mediaType');
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
      'media_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seasonNumberMeta =
      const VerificationMeta('seasonNumber');
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
      'season_number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _episodeNumberMeta =
      const VerificationMeta('episodeNumber');
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
      'episode_number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _positionSecondsMeta =
      const VerificationMeta('positionSeconds');
  @override
  late final GeneratedColumn<int> positionSeconds = GeneratedColumn<int>(
      'position_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        tmdbId,
        mediaType,
        seasonNumber,
        episodeNumber,
        positionSeconds,
        durationSeconds,
        completed,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_progress';
  @override
  VerificationContext validateIntegrity(Insertable<WatchProgressRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tmdb_id')) {
      context.handle(_tmdbIdMeta,
          tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta));
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta));
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('season_number')) {
      context.handle(
          _seasonNumberMeta,
          seasonNumber.isAcceptableOrUnknown(
              data['season_number']!, _seasonNumberMeta));
    }
    if (data.containsKey('episode_number')) {
      context.handle(
          _episodeNumberMeta,
          episodeNumber.isAcceptableOrUnknown(
              data['episode_number']!, _episodeNumberMeta));
    }
    if (data.containsKey('position_seconds')) {
      context.handle(
          _positionSecondsMeta,
          positionSeconds.isAcceptableOrUnknown(
              data['position_seconds']!, _positionSecondsMeta));
    } else if (isInserting) {
      context.missing(_positionSecondsMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey =>
      {tmdbId, mediaType, seasonNumber, episodeNumber};
  @override
  WatchProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchProgressRow(
      tmdbId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tmdb_id'])!,
      mediaType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_type'])!,
      seasonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season_number'])!,
      episodeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode_number'])!,
      positionSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position_seconds'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WatchProgressTable createAlias(String alias) {
    return $WatchProgressTable(attachedDatabase, alias);
  }
}

class WatchProgressRow extends DataClass
    implements Insertable<WatchProgressRow> {
  final int tmdbId;
  final String mediaType;
  final int seasonNumber;
  final int episodeNumber;
  final int positionSeconds;
  final int durationSeconds;
  final bool completed;
  final DateTime updatedAt;
  const WatchProgressRow(
      {required this.tmdbId,
      required this.mediaType,
      required this.seasonNumber,
      required this.episodeNumber,
      required this.positionSeconds,
      required this.durationSeconds,
      required this.completed,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['media_type'] = Variable<String>(mediaType);
    map['season_number'] = Variable<int>(seasonNumber);
    map['episode_number'] = Variable<int>(episodeNumber);
    map['position_seconds'] = Variable<int>(positionSeconds);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['completed'] = Variable<bool>(completed);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WatchProgressCompanion toCompanion(bool nullToAbsent) {
    return WatchProgressCompanion(
      tmdbId: Value(tmdbId),
      mediaType: Value(mediaType),
      seasonNumber: Value(seasonNumber),
      episodeNumber: Value(episodeNumber),
      positionSeconds: Value(positionSeconds),
      durationSeconds: Value(durationSeconds),
      completed: Value(completed),
      updatedAt: Value(updatedAt),
    );
  }

  factory WatchProgressRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchProgressRow(
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      seasonNumber: serializer.fromJson<int>(json['seasonNumber']),
      episodeNumber: serializer.fromJson<int>(json['episodeNumber']),
      positionSeconds: serializer.fromJson<int>(json['positionSeconds']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      completed: serializer.fromJson<bool>(json['completed']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tmdbId': serializer.toJson<int>(tmdbId),
      'mediaType': serializer.toJson<String>(mediaType),
      'seasonNumber': serializer.toJson<int>(seasonNumber),
      'episodeNumber': serializer.toJson<int>(episodeNumber),
      'positionSeconds': serializer.toJson<int>(positionSeconds),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'completed': serializer.toJson<bool>(completed),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WatchProgressRow copyWith(
          {int? tmdbId,
          String? mediaType,
          int? seasonNumber,
          int? episodeNumber,
          int? positionSeconds,
          int? durationSeconds,
          bool? completed,
          DateTime? updatedAt}) =>
      WatchProgressRow(
        tmdbId: tmdbId ?? this.tmdbId,
        mediaType: mediaType ?? this.mediaType,
        seasonNumber: seasonNumber ?? this.seasonNumber,
        episodeNumber: episodeNumber ?? this.episodeNumber,
        positionSeconds: positionSeconds ?? this.positionSeconds,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        completed: completed ?? this.completed,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  WatchProgressRow copyWithCompanion(WatchProgressCompanion data) {
    return WatchProgressRow(
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      positionSeconds: data.positionSeconds.present
          ? data.positionSeconds.value
          : this.positionSeconds,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      completed: data.completed.present ? data.completed.value : this.completed,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchProgressRow(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('positionSeconds: $positionSeconds, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completed: $completed, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tmdbId, mediaType, seasonNumber,
      episodeNumber, positionSeconds, durationSeconds, completed, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchProgressRow &&
          other.tmdbId == this.tmdbId &&
          other.mediaType == this.mediaType &&
          other.seasonNumber == this.seasonNumber &&
          other.episodeNumber == this.episodeNumber &&
          other.positionSeconds == this.positionSeconds &&
          other.durationSeconds == this.durationSeconds &&
          other.completed == this.completed &&
          other.updatedAt == this.updatedAt);
}

class WatchProgressCompanion extends UpdateCompanion<WatchProgressRow> {
  final Value<int> tmdbId;
  final Value<String> mediaType;
  final Value<int> seasonNumber;
  final Value<int> episodeNumber;
  final Value<int> positionSeconds;
  final Value<int> durationSeconds;
  final Value<bool> completed;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WatchProgressCompanion({
    this.tmdbId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.positionSeconds = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completed = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchProgressCompanion.insert({
    required int tmdbId,
    required String mediaType,
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    required int positionSeconds,
    required int durationSeconds,
    this.completed = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : tmdbId = Value(tmdbId),
        mediaType = Value(mediaType),
        positionSeconds = Value(positionSeconds),
        durationSeconds = Value(durationSeconds);
  static Insertable<WatchProgressRow> custom({
    Expression<int>? tmdbId,
    Expression<String>? mediaType,
    Expression<int>? seasonNumber,
    Expression<int>? episodeNumber,
    Expression<int>? positionSeconds,
    Expression<int>? durationSeconds,
    Expression<bool>? completed,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (mediaType != null) 'media_type': mediaType,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (positionSeconds != null) 'position_seconds': positionSeconds,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completed != null) 'completed': completed,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchProgressCompanion copyWith(
      {Value<int>? tmdbId,
      Value<String>? mediaType,
      Value<int>? seasonNumber,
      Value<int>? episodeNumber,
      Value<int>? positionSeconds,
      Value<int>? durationSeconds,
      Value<bool>? completed,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return WatchProgressCompanion(
      tmdbId: tmdbId ?? this.tmdbId,
      mediaType: mediaType ?? this.mediaType,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (positionSeconds.present) {
      map['position_seconds'] = Variable<int>(positionSeconds.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchProgressCompanion(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('positionSeconds: $positionSeconds, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completed: $completed, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
      'tmdb_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mediaTypeMeta =
      const VerificationMeta('mediaType');
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
      'media_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [tmdbId, mediaType, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(Insertable<FavoriteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tmdb_id')) {
      context.handle(_tmdbIdMeta,
          tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta));
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta));
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tmdbId, mediaType};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      tmdbId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tmdb_id'])!,
      mediaType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_type'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final int tmdbId;
  final String mediaType;
  final DateTime addedAt;
  const FavoriteRow(
      {required this.tmdbId, required this.mediaType, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['media_type'] = Variable<String>(mediaType);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      tmdbId: Value(tmdbId),
      mediaType: Value(mediaType),
      addedAt: Value(addedAt),
    );
  }

  factory FavoriteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tmdbId': serializer.toJson<int>(tmdbId),
      'mediaType': serializer.toJson<String>(mediaType),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  FavoriteRow copyWith({int? tmdbId, String? mediaType, DateTime? addedAt}) =>
      FavoriteRow(
        tmdbId: tmdbId ?? this.tmdbId,
        mediaType: mediaType ?? this.mediaType,
        addedAt: addedAt ?? this.addedAt,
      );
  FavoriteRow copyWithCompanion(FavoritesCompanion data) {
    return FavoriteRow(
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tmdbId, mediaType, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.tmdbId == this.tmdbId &&
          other.mediaType == this.mediaType &&
          other.addedAt == this.addedAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<int> tmdbId;
  final Value<String> mediaType;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.tmdbId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required int tmdbId,
    required String mediaType,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : tmdbId = Value(tmdbId),
        mediaType = Value(mediaType);
  static Insertable<FavoriteRow> custom({
    Expression<int>? tmdbId,
    Expression<String>? mediaType,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (mediaType != null) 'media_type': mediaType,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith(
      {Value<int>? tmdbId,
      Value<String>? mediaType,
      Value<DateTime>? addedAt,
      Value<int>? rowid}) {
    return FavoritesCompanion(
      tmdbId: tmdbId ?? this.tmdbId,
      mediaType: mediaType ?? this.mediaType,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchlistTable extends Watchlist
    with TableInfo<$WatchlistTable, WatchlistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
      'tmdb_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mediaTypeMeta =
      const VerificationMeta('mediaType');
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
      'media_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [tmdbId, mediaType, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlist';
  @override
  VerificationContext validateIntegrity(Insertable<WatchlistRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tmdb_id')) {
      context.handle(_tmdbIdMeta,
          tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta));
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta));
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tmdbId, mediaType};
  @override
  WatchlistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchlistRow(
      tmdbId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tmdb_id'])!,
      mediaType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_type'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $WatchlistTable createAlias(String alias) {
    return $WatchlistTable(attachedDatabase, alias);
  }
}

class WatchlistRow extends DataClass implements Insertable<WatchlistRow> {
  final int tmdbId;
  final String mediaType;
  final DateTime addedAt;
  const WatchlistRow(
      {required this.tmdbId, required this.mediaType, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['media_type'] = Variable<String>(mediaType);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  WatchlistCompanion toCompanion(bool nullToAbsent) {
    return WatchlistCompanion(
      tmdbId: Value(tmdbId),
      mediaType: Value(mediaType),
      addedAt: Value(addedAt),
    );
  }

  factory WatchlistRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchlistRow(
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tmdbId': serializer.toJson<int>(tmdbId),
      'mediaType': serializer.toJson<String>(mediaType),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  WatchlistRow copyWith({int? tmdbId, String? mediaType, DateTime? addedAt}) =>
      WatchlistRow(
        tmdbId: tmdbId ?? this.tmdbId,
        mediaType: mediaType ?? this.mediaType,
        addedAt: addedAt ?? this.addedAt,
      );
  WatchlistRow copyWithCompanion(WatchlistCompanion data) {
    return WatchlistRow(
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistRow(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tmdbId, mediaType, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchlistRow &&
          other.tmdbId == this.tmdbId &&
          other.mediaType == this.mediaType &&
          other.addedAt == this.addedAt);
}

class WatchlistCompanion extends UpdateCompanion<WatchlistRow> {
  final Value<int> tmdbId;
  final Value<String> mediaType;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const WatchlistCompanion({
    this.tmdbId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchlistCompanion.insert({
    required int tmdbId,
    required String mediaType,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : tmdbId = Value(tmdbId),
        mediaType = Value(mediaType);
  static Insertable<WatchlistRow> custom({
    Expression<int>? tmdbId,
    Expression<String>? mediaType,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (mediaType != null) 'media_type': mediaType,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchlistCompanion copyWith(
      {Value<int>? tmdbId,
      Value<String>? mediaType,
      Value<DateTime>? addedAt,
      Value<int>? rowid}) {
    return WatchlistCompanion(
      tmdbId: tmdbId ?? this.tmdbId,
      mediaType: mediaType ?? this.mediaType,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistCompanion(')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  static const VerificationMeta _audioPrefLangMeta =
      const VerificationMeta('audioPrefLang');
  @override
  late final GeneratedColumn<String> audioPrefLang = GeneratedColumn<String>(
      'audio_pref_lang', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ita'));
  static const VerificationMeta _subsPrefLangMeta =
      const VerificationMeta('subsPrefLang');
  @override
  late final GeneratedColumn<String> subsPrefLang = GeneratedColumn<String>(
      'subs_pref_lang', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ita'));
  static const VerificationMeta _qualityCapHeightMeta =
      const VerificationMeta('qualityCapHeight');
  @override
  late final GeneratedColumn<int> qualityCapHeight = GeneratedColumn<int>(
      'quality_cap_height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _autoplayNextEpisodeMeta =
      const VerificationMeta('autoplayNextEpisode');
  @override
  late final GeneratedColumn<bool> autoplayNextEpisode = GeneratedColumn<bool>(
      'autoplay_next_episode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("autoplay_next_episode" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _skipIntroMeta =
      const VerificationMeta('skipIntro');
  @override
  late final GeneratedColumn<bool> skipIntro = GeneratedColumn<bool>(
      'skip_intro', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("skip_intro" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
      'theme', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('auto'));
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
      'locale', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('it-IT'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        key,
        audioPrefLang,
        subsPrefLang,
        qualityCapHeight,
        autoplayNextEpisode,
        skipIntro,
        theme,
        locale,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSettingsRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    }
    if (data.containsKey('audio_pref_lang')) {
      context.handle(
          _audioPrefLangMeta,
          audioPrefLang.isAcceptableOrUnknown(
              data['audio_pref_lang']!, _audioPrefLangMeta));
    }
    if (data.containsKey('subs_pref_lang')) {
      context.handle(
          _subsPrefLangMeta,
          subsPrefLang.isAcceptableOrUnknown(
              data['subs_pref_lang']!, _subsPrefLangMeta));
    }
    if (data.containsKey('quality_cap_height')) {
      context.handle(
          _qualityCapHeightMeta,
          qualityCapHeight.isAcceptableOrUnknown(
              data['quality_cap_height']!, _qualityCapHeightMeta));
    }
    if (data.containsKey('autoplay_next_episode')) {
      context.handle(
          _autoplayNextEpisodeMeta,
          autoplayNextEpisode.isAcceptableOrUnknown(
              data['autoplay_next_episode']!, _autoplayNextEpisodeMeta));
    }
    if (data.containsKey('skip_intro')) {
      context.handle(_skipIntroMeta,
          skipIntro.isAcceptableOrUnknown(data['skip_intro']!, _skipIntroMeta));
    }
    if (data.containsKey('theme')) {
      context.handle(
          _themeMeta, theme.isAcceptableOrUnknown(data['theme']!, _themeMeta));
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta,
          locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      audioPrefLang: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}audio_pref_lang'])!,
      subsPrefLang: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subs_pref_lang'])!,
      qualityCapHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quality_cap_height']),
      autoplayNextEpisode: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}autoplay_next_episode'])!,
      skipIntro: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}skip_intro'])!,
      theme: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme'])!,
      locale: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locale'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSettingsRow extends DataClass implements Insertable<UserSettingsRow> {
  final String key;
  final String audioPrefLang;
  final String subsPrefLang;
  final int? qualityCapHeight;
  final bool autoplayNextEpisode;
  final bool skipIntro;
  final String theme;
  final String locale;
  final DateTime updatedAt;
  const UserSettingsRow(
      {required this.key,
      required this.audioPrefLang,
      required this.subsPrefLang,
      this.qualityCapHeight,
      required this.autoplayNextEpisode,
      required this.skipIntro,
      required this.theme,
      required this.locale,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['audio_pref_lang'] = Variable<String>(audioPrefLang);
    map['subs_pref_lang'] = Variable<String>(subsPrefLang);
    if (!nullToAbsent || qualityCapHeight != null) {
      map['quality_cap_height'] = Variable<int>(qualityCapHeight);
    }
    map['autoplay_next_episode'] = Variable<bool>(autoplayNextEpisode);
    map['skip_intro'] = Variable<bool>(skipIntro);
    map['theme'] = Variable<String>(theme);
    map['locale'] = Variable<String>(locale);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      key: Value(key),
      audioPrefLang: Value(audioPrefLang),
      subsPrefLang: Value(subsPrefLang),
      qualityCapHeight: qualityCapHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityCapHeight),
      autoplayNextEpisode: Value(autoplayNextEpisode),
      skipIntro: Value(skipIntro),
      theme: Value(theme),
      locale: Value(locale),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSettingsRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsRow(
      key: serializer.fromJson<String>(json['key']),
      audioPrefLang: serializer.fromJson<String>(json['audioPrefLang']),
      subsPrefLang: serializer.fromJson<String>(json['subsPrefLang']),
      qualityCapHeight: serializer.fromJson<int?>(json['qualityCapHeight']),
      autoplayNextEpisode:
          serializer.fromJson<bool>(json['autoplayNextEpisode']),
      skipIntro: serializer.fromJson<bool>(json['skipIntro']),
      theme: serializer.fromJson<String>(json['theme']),
      locale: serializer.fromJson<String>(json['locale']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'audioPrefLang': serializer.toJson<String>(audioPrefLang),
      'subsPrefLang': serializer.toJson<String>(subsPrefLang),
      'qualityCapHeight': serializer.toJson<int?>(qualityCapHeight),
      'autoplayNextEpisode': serializer.toJson<bool>(autoplayNextEpisode),
      'skipIntro': serializer.toJson<bool>(skipIntro),
      'theme': serializer.toJson<String>(theme),
      'locale': serializer.toJson<String>(locale),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSettingsRow copyWith(
          {String? key,
          String? audioPrefLang,
          String? subsPrefLang,
          Value<int?> qualityCapHeight = const Value.absent(),
          bool? autoplayNextEpisode,
          bool? skipIntro,
          String? theme,
          String? locale,
          DateTime? updatedAt}) =>
      UserSettingsRow(
        key: key ?? this.key,
        audioPrefLang: audioPrefLang ?? this.audioPrefLang,
        subsPrefLang: subsPrefLang ?? this.subsPrefLang,
        qualityCapHeight: qualityCapHeight.present
            ? qualityCapHeight.value
            : this.qualityCapHeight,
        autoplayNextEpisode: autoplayNextEpisode ?? this.autoplayNextEpisode,
        skipIntro: skipIntro ?? this.skipIntro,
        theme: theme ?? this.theme,
        locale: locale ?? this.locale,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserSettingsRow copyWithCompanion(UserSettingsCompanion data) {
    return UserSettingsRow(
      key: data.key.present ? data.key.value : this.key,
      audioPrefLang: data.audioPrefLang.present
          ? data.audioPrefLang.value
          : this.audioPrefLang,
      subsPrefLang: data.subsPrefLang.present
          ? data.subsPrefLang.value
          : this.subsPrefLang,
      qualityCapHeight: data.qualityCapHeight.present
          ? data.qualityCapHeight.value
          : this.qualityCapHeight,
      autoplayNextEpisode: data.autoplayNextEpisode.present
          ? data.autoplayNextEpisode.value
          : this.autoplayNextEpisode,
      skipIntro: data.skipIntro.present ? data.skipIntro.value : this.skipIntro,
      theme: data.theme.present ? data.theme.value : this.theme,
      locale: data.locale.present ? data.locale.value : this.locale,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsRow(')
          ..write('key: $key, ')
          ..write('audioPrefLang: $audioPrefLang, ')
          ..write('subsPrefLang: $subsPrefLang, ')
          ..write('qualityCapHeight: $qualityCapHeight, ')
          ..write('autoplayNextEpisode: $autoplayNextEpisode, ')
          ..write('skipIntro: $skipIntro, ')
          ..write('theme: $theme, ')
          ..write('locale: $locale, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      key,
      audioPrefLang,
      subsPrefLang,
      qualityCapHeight,
      autoplayNextEpisode,
      skipIntro,
      theme,
      locale,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsRow &&
          other.key == this.key &&
          other.audioPrefLang == this.audioPrefLang &&
          other.subsPrefLang == this.subsPrefLang &&
          other.qualityCapHeight == this.qualityCapHeight &&
          other.autoplayNextEpisode == this.autoplayNextEpisode &&
          other.skipIntro == this.skipIntro &&
          other.theme == this.theme &&
          other.locale == this.locale &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<UserSettingsRow> {
  final Value<String> key;
  final Value<String> audioPrefLang;
  final Value<String> subsPrefLang;
  final Value<int?> qualityCapHeight;
  final Value<bool> autoplayNextEpisode;
  final Value<bool> skipIntro;
  final Value<String> theme;
  final Value<String> locale;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.key = const Value.absent(),
    this.audioPrefLang = const Value.absent(),
    this.subsPrefLang = const Value.absent(),
    this.qualityCapHeight = const Value.absent(),
    this.autoplayNextEpisode = const Value.absent(),
    this.skipIntro = const Value.absent(),
    this.theme = const Value.absent(),
    this.locale = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.key = const Value.absent(),
    this.audioPrefLang = const Value.absent(),
    this.subsPrefLang = const Value.absent(),
    this.qualityCapHeight = const Value.absent(),
    this.autoplayNextEpisode = const Value.absent(),
    this.skipIntro = const Value.absent(),
    this.theme = const Value.absent(),
    this.locale = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<UserSettingsRow> custom({
    Expression<String>? key,
    Expression<String>? audioPrefLang,
    Expression<String>? subsPrefLang,
    Expression<int>? qualityCapHeight,
    Expression<bool>? autoplayNextEpisode,
    Expression<bool>? skipIntro,
    Expression<String>? theme,
    Expression<String>? locale,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (audioPrefLang != null) 'audio_pref_lang': audioPrefLang,
      if (subsPrefLang != null) 'subs_pref_lang': subsPrefLang,
      if (qualityCapHeight != null) 'quality_cap_height': qualityCapHeight,
      if (autoplayNextEpisode != null)
        'autoplay_next_episode': autoplayNextEpisode,
      if (skipIntro != null) 'skip_intro': skipIntro,
      if (theme != null) 'theme': theme,
      if (locale != null) 'locale': locale,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? audioPrefLang,
      Value<String>? subsPrefLang,
      Value<int?>? qualityCapHeight,
      Value<bool>? autoplayNextEpisode,
      Value<bool>? skipIntro,
      Value<String>? theme,
      Value<String>? locale,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UserSettingsCompanion(
      key: key ?? this.key,
      audioPrefLang: audioPrefLang ?? this.audioPrefLang,
      subsPrefLang: subsPrefLang ?? this.subsPrefLang,
      qualityCapHeight: qualityCapHeight ?? this.qualityCapHeight,
      autoplayNextEpisode: autoplayNextEpisode ?? this.autoplayNextEpisode,
      skipIntro: skipIntro ?? this.skipIntro,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (audioPrefLang.present) {
      map['audio_pref_lang'] = Variable<String>(audioPrefLang.value);
    }
    if (subsPrefLang.present) {
      map['subs_pref_lang'] = Variable<String>(subsPrefLang.value);
    }
    if (qualityCapHeight.present) {
      map['quality_cap_height'] = Variable<int>(qualityCapHeight.value);
    }
    if (autoplayNextEpisode.present) {
      map['autoplay_next_episode'] = Variable<bool>(autoplayNextEpisode.value);
    }
    if (skipIntro.present) {
      map['skip_intro'] = Variable<bool>(skipIntro.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('key: $key, ')
          ..write('audioPrefLang: $audioPrefLang, ')
          ..write('subsPrefLang: $subsPrefLang, ')
          ..write('qualityCapHeight: $qualityCapHeight, ')
          ..write('autoplayNextEpisode: $autoplayNextEpisode, ')
          ..write('skipIntro: $skipIntro, ')
          ..write('theme: $theme, ')
          ..write('locale: $locale, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, kind, payloadJson, createdAt, attempts, nextAttemptAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at'])!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final int id;
  final String kind;
  final String payloadJson;
  final DateTime createdAt;
  final int attempts;
  final DateTime nextAttemptAt;
  const OutboxRow(
      {required this.id,
      required this.kind,
      required this.payloadJson,
      required this.createdAt,
      required this.attempts,
      required this.nextAttemptAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      nextAttemptAt: Value(nextAttemptAt),
    );
  }

  factory OutboxRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
    };
  }

  OutboxRow copyWith(
          {int? id,
          String? kind,
          String? payloadJson,
          DateTime? createdAt,
          int? attempts,
          DateTime? nextAttemptAt}) =>
      OutboxRow(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        attempts: attempts ?? this.attempts,
        nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      );
  OutboxRow copyWithCompanion(OutboxCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, payloadJson, createdAt, attempts, nextAttemptAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<DateTime> nextAttemptAt;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String payloadJson,
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
  })  : kind = Value(kind),
        payloadJson = Value(payloadJson);
  static Insertable<OutboxRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
    });
  }

  OutboxCompanion copyWith(
      {Value<int>? id,
      Value<String>? kind,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? attempts,
      Value<DateTime>? nextAttemptAt}) {
    return OutboxCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }
}

class $InstalledPluginsTable extends InstalledPlugins
    with TableInfo<$InstalledPluginsTable, InstalledPluginRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstalledPluginsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _shortNameMeta =
      const VerificationMeta('shortName');
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
      'short_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
      'sha256', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _installedAtMeta =
      const VerificationMeta('installedAt');
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
      'installed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [shortName, version, sha256, filePath, enabled, installedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installed_plugins';
  @override
  VerificationContext validateIntegrity(Insertable<InstalledPluginRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('short_name')) {
      context.handle(_shortNameMeta,
          shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta));
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(_sha256Meta,
          sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta));
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('installed_at')) {
      context.handle(
          _installedAtMeta,
          installedAt.isAcceptableOrUnknown(
              data['installed_at']!, _installedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {shortName};
  @override
  InstalledPluginRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstalledPluginRow(
      shortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}short_name'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
      sha256: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sha256'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      installedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}installed_at'])!,
    );
  }

  @override
  $InstalledPluginsTable createAlias(String alias) {
    return $InstalledPluginsTable(attachedDatabase, alias);
  }
}

class InstalledPluginRow extends DataClass
    implements Insertable<InstalledPluginRow> {
  final String shortName;
  final String version;
  final String sha256;
  final String filePath;
  final bool enabled;
  final DateTime installedAt;
  const InstalledPluginRow(
      {required this.shortName,
      required this.version,
      required this.sha256,
      required this.filePath,
      required this.enabled,
      required this.installedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['short_name'] = Variable<String>(shortName);
    map['version'] = Variable<String>(version);
    map['sha256'] = Variable<String>(sha256);
    map['file_path'] = Variable<String>(filePath);
    map['enabled'] = Variable<bool>(enabled);
    map['installed_at'] = Variable<DateTime>(installedAt);
    return map;
  }

  InstalledPluginsCompanion toCompanion(bool nullToAbsent) {
    return InstalledPluginsCompanion(
      shortName: Value(shortName),
      version: Value(version),
      sha256: Value(sha256),
      filePath: Value(filePath),
      enabled: Value(enabled),
      installedAt: Value(installedAt),
    );
  }

  factory InstalledPluginRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstalledPluginRow(
      shortName: serializer.fromJson<String>(json['shortName']),
      version: serializer.fromJson<String>(json['version']),
      sha256: serializer.fromJson<String>(json['sha256']),
      filePath: serializer.fromJson<String>(json['filePath']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shortName': serializer.toJson<String>(shortName),
      'version': serializer.toJson<String>(version),
      'sha256': serializer.toJson<String>(sha256),
      'filePath': serializer.toJson<String>(filePath),
      'enabled': serializer.toJson<bool>(enabled),
      'installedAt': serializer.toJson<DateTime>(installedAt),
    };
  }

  InstalledPluginRow copyWith(
          {String? shortName,
          String? version,
          String? sha256,
          String? filePath,
          bool? enabled,
          DateTime? installedAt}) =>
      InstalledPluginRow(
        shortName: shortName ?? this.shortName,
        version: version ?? this.version,
        sha256: sha256 ?? this.sha256,
        filePath: filePath ?? this.filePath,
        enabled: enabled ?? this.enabled,
        installedAt: installedAt ?? this.installedAt,
      );
  InstalledPluginRow copyWithCompanion(InstalledPluginsCompanion data) {
    return InstalledPluginRow(
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      version: data.version.present ? data.version.value : this.version,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      installedAt:
          data.installedAt.present ? data.installedAt.value : this.installedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstalledPluginRow(')
          ..write('shortName: $shortName, ')
          ..write('version: $version, ')
          ..write('sha256: $sha256, ')
          ..write('filePath: $filePath, ')
          ..write('enabled: $enabled, ')
          ..write('installedAt: $installedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(shortName, version, sha256, filePath, enabled, installedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstalledPluginRow &&
          other.shortName == this.shortName &&
          other.version == this.version &&
          other.sha256 == this.sha256 &&
          other.filePath == this.filePath &&
          other.enabled == this.enabled &&
          other.installedAt == this.installedAt);
}

class InstalledPluginsCompanion extends UpdateCompanion<InstalledPluginRow> {
  final Value<String> shortName;
  final Value<String> version;
  final Value<String> sha256;
  final Value<String> filePath;
  final Value<bool> enabled;
  final Value<DateTime> installedAt;
  final Value<int> rowid;
  const InstalledPluginsCompanion({
    this.shortName = const Value.absent(),
    this.version = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.filePath = const Value.absent(),
    this.enabled = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstalledPluginsCompanion.insert({
    required String shortName,
    required String version,
    required String sha256,
    required String filePath,
    this.enabled = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : shortName = Value(shortName),
        version = Value(version),
        sha256 = Value(sha256),
        filePath = Value(filePath);
  static Insertable<InstalledPluginRow> custom({
    Expression<String>? shortName,
    Expression<String>? version,
    Expression<String>? sha256,
    Expression<String>? filePath,
    Expression<bool>? enabled,
    Expression<DateTime>? installedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (shortName != null) 'short_name': shortName,
      if (version != null) 'version': version,
      if (sha256 != null) 'sha256': sha256,
      if (filePath != null) 'file_path': filePath,
      if (enabled != null) 'enabled': enabled,
      if (installedAt != null) 'installed_at': installedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstalledPluginsCompanion copyWith(
      {Value<String>? shortName,
      Value<String>? version,
      Value<String>? sha256,
      Value<String>? filePath,
      Value<bool>? enabled,
      Value<DateTime>? installedAt,
      Value<int>? rowid}) {
    return InstalledPluginsCompanion(
      shortName: shortName ?? this.shortName,
      version: version ?? this.version,
      sha256: sha256 ?? this.sha256,
      filePath: filePath ?? this.filePath,
      enabled: enabled ?? this.enabled,
      installedAt: installedAt ?? this.installedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstalledPluginsCompanion(')
          ..write('shortName: $shortName, ')
          ..write('version: $version, ')
          ..write('sha256: $sha256, ')
          ..write('filePath: $filePath, ')
          ..write('enabled: $enabled, ')
          ..write('installedAt: $installedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PluginKvTable extends PluginKv
    with TableInfo<$PluginKvTable, PluginKvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PluginKvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pluginShortNameMeta =
      const VerificationMeta('pluginShortName');
  @override
  late final GeneratedColumn<String> pluginShortName = GeneratedColumn<String>(
      'plugin_short_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [pluginShortName, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plugin_kv';
  @override
  VerificationContext validateIntegrity(Insertable<PluginKvRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plugin_short_name')) {
      context.handle(
          _pluginShortNameMeta,
          pluginShortName.isAcceptableOrUnknown(
              data['plugin_short_name']!, _pluginShortNameMeta));
    } else if (isInserting) {
      context.missing(_pluginShortNameMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pluginShortName, key};
  @override
  PluginKvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PluginKvRow(
      pluginShortName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}plugin_short_name'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $PluginKvTable createAlias(String alias) {
    return $PluginKvTable(attachedDatabase, alias);
  }
}

class PluginKvRow extends DataClass implements Insertable<PluginKvRow> {
  final String pluginShortName;
  final String key;
  final String value;
  const PluginKvRow(
      {required this.pluginShortName, required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plugin_short_name'] = Variable<String>(pluginShortName);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PluginKvCompanion toCompanion(bool nullToAbsent) {
    return PluginKvCompanion(
      pluginShortName: Value(pluginShortName),
      key: Value(key),
      value: Value(value),
    );
  }

  factory PluginKvRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PluginKvRow(
      pluginShortName: serializer.fromJson<String>(json['pluginShortName']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pluginShortName': serializer.toJson<String>(pluginShortName),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  PluginKvRow copyWith({String? pluginShortName, String? key, String? value}) =>
      PluginKvRow(
        pluginShortName: pluginShortName ?? this.pluginShortName,
        key: key ?? this.key,
        value: value ?? this.value,
      );
  PluginKvRow copyWithCompanion(PluginKvCompanion data) {
    return PluginKvRow(
      pluginShortName: data.pluginShortName.present
          ? data.pluginShortName.value
          : this.pluginShortName,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PluginKvRow(')
          ..write('pluginShortName: $pluginShortName, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pluginShortName, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PluginKvRow &&
          other.pluginShortName == this.pluginShortName &&
          other.key == this.key &&
          other.value == this.value);
}

class PluginKvCompanion extends UpdateCompanion<PluginKvRow> {
  final Value<String> pluginShortName;
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PluginKvCompanion({
    this.pluginShortName = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PluginKvCompanion.insert({
    required String pluginShortName,
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : pluginShortName = Value(pluginShortName),
        key = Value(key),
        value = Value(value);
  static Insertable<PluginKvRow> custom({
    Expression<String>? pluginShortName,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pluginShortName != null) 'plugin_short_name': pluginShortName,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PluginKvCompanion copyWith(
      {Value<String>? pluginShortName,
      Value<String>? key,
      Value<String>? value,
      Value<int>? rowid}) {
    return PluginKvCompanion(
      pluginShortName: pluginShortName ?? this.pluginShortName,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pluginShortName.present) {
      map['plugin_short_name'] = Variable<String>(pluginShortName.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PluginKvCompanion(')
          ..write('pluginShortName: $pluginShortName, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$StreamloadDatabase extends GeneratedDatabase {
  _$StreamloadDatabase(QueryExecutor e) : super(e);
  $StreamloadDatabaseManager get managers => $StreamloadDatabaseManager(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  late final $TvEpisodesTable tvEpisodes = $TvEpisodesTable(this);
  late final $CatalogSourcesTable catalogSources = $CatalogSourcesTable(this);
  late final $WatchProgressTable watchProgress = $WatchProgressTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $WatchlistTable watchlist = $WatchlistTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $InstalledPluginsTable installedPlugins =
      $InstalledPluginsTable(this);
  late final $PluginKvTable pluginKv = $PluginKvTable(this);
  late final CatalogDao catalogDao = CatalogDao(this as StreamloadDatabase);
  late final UserSettingsDao userSettingsDao =
      UserSettingsDao(this as StreamloadDatabase);
  late final InstalledPluginsDao installedPluginsDao =
      InstalledPluginsDao(this as StreamloadDatabase);
  late final PluginKvDao pluginKvDao = PluginKvDao(this as StreamloadDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        catalogItems,
        tvEpisodes,
        catalogSources,
        watchProgress,
        favorites,
        watchlist,
        userSettings,
        outbox,
        installedPlugins,
        pluginKv
      ];
}

typedef $$CatalogItemsTableCreateCompanionBuilder = CatalogItemsCompanion
    Function({
  required int tmdbId,
  required String mediaType,
  required String title,
  Value<String?> originalTitle,
  Value<int?> year,
  Value<String?> posterUrl,
  Value<String?> backdropUrl,
  Value<String?> overview,
  Value<double?> rating,
  Value<int?> runtimeMinutes,
  Value<int?> seasonsCount,
  Value<String> genresJson,
  Value<DateTime> metadataFetchedAt,
  Value<int> rowid,
});
typedef $$CatalogItemsTableUpdateCompanionBuilder = CatalogItemsCompanion
    Function({
  Value<int> tmdbId,
  Value<String> mediaType,
  Value<String> title,
  Value<String?> originalTitle,
  Value<int?> year,
  Value<String?> posterUrl,
  Value<String?> backdropUrl,
  Value<String?> overview,
  Value<double?> rating,
  Value<int?> runtimeMinutes,
  Value<int?> seasonsCount,
  Value<String> genresJson,
  Value<DateTime> metadataFetchedAt,
  Value<int> rowid,
});

class $$CatalogItemsTableFilterComposer
    extends Composer<_$StreamloadDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalTitle => $composableBuilder(
      column: $table.originalTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get posterUrl => $composableBuilder(
      column: $table.posterUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backdropUrl => $composableBuilder(
      column: $table.backdropUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overview => $composableBuilder(
      column: $table.overview, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasonsCount => $composableBuilder(
      column: $table.seasonsCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get genresJson => $composableBuilder(
      column: $table.genresJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get metadataFetchedAt => $composableBuilder(
      column: $table.metadataFetchedAt,
      builder: (column) => ColumnFilters(column));
}

class $$CatalogItemsTableOrderingComposer
    extends Composer<_$StreamloadDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalTitle => $composableBuilder(
      column: $table.originalTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get posterUrl => $composableBuilder(
      column: $table.posterUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backdropUrl => $composableBuilder(
      column: $table.backdropUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overview => $composableBuilder(
      column: $table.overview, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasonsCount => $composableBuilder(
      column: $table.seasonsCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get genresJson => $composableBuilder(
      column: $table.genresJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get metadataFetchedAt => $composableBuilder(
      column: $table.metadataFetchedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$CatalogItemsTableAnnotationComposer
    extends Composer<_$StreamloadDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get originalTitle => $composableBuilder(
      column: $table.originalTitle, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get posterUrl =>
      $composableBuilder(column: $table.posterUrl, builder: (column) => column);

  GeneratedColumn<String> get backdropUrl => $composableBuilder(
      column: $table.backdropUrl, builder: (column) => column);

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes, builder: (column) => column);

  GeneratedColumn<int> get seasonsCount => $composableBuilder(
      column: $table.seasonsCount, builder: (column) => column);

  GeneratedColumn<String> get genresJson => $composableBuilder(
      column: $table.genresJson, builder: (column) => column);

  GeneratedColumn<DateTime> get metadataFetchedAt => $composableBuilder(
      column: $table.metadataFetchedAt, builder: (column) => column);
}

class $$CatalogItemsTableTableManager extends RootTableManager<
    _$StreamloadDatabase,
    $CatalogItemsTable,
    CatalogItemRow,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (
      CatalogItemRow,
      BaseReferences<_$StreamloadDatabase, $CatalogItemsTable, CatalogItemRow>
    ),
    CatalogItemRow,
    PrefetchHooks Function()> {
  $$CatalogItemsTableTableManager(
      _$StreamloadDatabase db, $CatalogItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> tmdbId = const Value.absent(),
            Value<String> mediaType = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> originalTitle = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> posterUrl = const Value.absent(),
            Value<String?> backdropUrl = const Value.absent(),
            Value<String?> overview = const Value.absent(),
            Value<double?> rating = const Value.absent(),
            Value<int?> runtimeMinutes = const Value.absent(),
            Value<int?> seasonsCount = const Value.absent(),
            Value<String> genresJson = const Value.absent(),
            Value<DateTime> metadataFetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemsCompanion(
            tmdbId: tmdbId,
            mediaType: mediaType,
            title: title,
            originalTitle: originalTitle,
            year: year,
            posterUrl: posterUrl,
            backdropUrl: backdropUrl,
            overview: overview,
            rating: rating,
            runtimeMinutes: runtimeMinutes,
            seasonsCount: seasonsCount,
            genresJson: genresJson,
            metadataFetchedAt: metadataFetchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int tmdbId,
            required String mediaType,
            required String title,
            Value<String?> originalTitle = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> posterUrl = const Value.absent(),
            Value<String?> backdropUrl = const Value.absent(),
            Value<String?> overview = const Value.absent(),
            Value<double?> rating = const Value.absent(),
            Value<int?> runtimeMinutes = const Value.absent(),
            Value<int?> seasonsCount = const Value.absent(),
            Value<String> genresJson = const Value.absent(),
            Value<DateTime> metadataFetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemsCompanion.insert(
            tmdbId: tmdbId,
            mediaType: mediaType,
            title: title,
            originalTitle: originalTitle,
            year: year,
            posterUrl: posterUrl,
            backdropUrl: backdropUrl,
            overview: overview,
            rating: rating,
            runtimeMinutes: runtimeMinutes,
            seasonsCount: seasonsCount,
            genresJson: genresJson,
            metadataFetchedAt: metadataFetchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogItemsTableProcessedTableManager = ProcessedTableManager<
    _$StreamloadDatabase,
    $CatalogItemsTable,
    CatalogItemRow,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (
      CatalogItemRow,
      BaseReferences<_$StreamloadDatabase, $CatalogItemsTable, CatalogItemRow>
    ),
    CatalogItemRow,
    PrefetchHooks Function()>;
typedef $$TvEpisodesTableCreateCompanionBuilder = TvEpisodesCompanion Function({
  required int tmdbId,
  Value<String> mediaType,
  required int seasonNumber,
  required int episodeNumber,
  Value<String?> title,
  Value<String?> overview,
  Value<DateTime?> airDate,
  Value<int?> runtimeMinutes,
  Value<String?> stillUrl,
  Value<int> rowid,
});
typedef $$TvEpisodesTableUpdateCompanionBuilder = TvEpisodesCompanion Function({
  Value<int> tmdbId,
  Value<String> mediaType,
  Value<int> seasonNumber,
  Value<int> episodeNumber,
  Value<String?> title,
  Value<String?> overview,
  Value<DateTime?> airDate,
  Value<int?> runtimeMinutes,
  Value<String?> stillUrl,
  Value<int> rowid,
});

class $$TvEpisodesTableFilterComposer
    extends Composer<_$StreamloadDatabase, $TvEpisodesTable> {
  $$TvEpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overview => $composableBuilder(
      column: $table.overview, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get airDate => $composableBuilder(
      column: $table.airDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stillUrl => $composableBuilder(
      column: $table.stillUrl, builder: (column) => ColumnFilters(column));
}

class $$TvEpisodesTableOrderingComposer
    extends Composer<_$StreamloadDatabase, $TvEpisodesTable> {
  $$TvEpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overview => $composableBuilder(
      column: $table.overview, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get airDate => $composableBuilder(
      column: $table.airDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stillUrl => $composableBuilder(
      column: $table.stillUrl, builder: (column) => ColumnOrderings(column));
}

class $$TvEpisodesTableAnnotationComposer
    extends Composer<_$StreamloadDatabase, $TvEpisodesTable> {
  $$TvEpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => column);

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<DateTime> get airDate =>
      $composableBuilder(column: $table.airDate, builder: (column) => column);

  GeneratedColumn<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes, builder: (column) => column);

  GeneratedColumn<String> get stillUrl =>
      $composableBuilder(column: $table.stillUrl, builder: (column) => column);
}

class $$TvEpisodesTableTableManager extends RootTableManager<
    _$StreamloadDatabase,
    $TvEpisodesTable,
    TvEpisodeRow,
    $$TvEpisodesTableFilterComposer,
    $$TvEpisodesTableOrderingComposer,
    $$TvEpisodesTableAnnotationComposer,
    $$TvEpisodesTableCreateCompanionBuilder,
    $$TvEpisodesTableUpdateCompanionBuilder,
    (
      TvEpisodeRow,
      BaseReferences<_$StreamloadDatabase, $TvEpisodesTable, TvEpisodeRow>
    ),
    TvEpisodeRow,
    PrefetchHooks Function()> {
  $$TvEpisodesTableTableManager(_$StreamloadDatabase db, $TvEpisodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TvEpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TvEpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TvEpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> tmdbId = const Value.absent(),
            Value<String> mediaType = const Value.absent(),
            Value<int> seasonNumber = const Value.absent(),
            Value<int> episodeNumber = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> overview = const Value.absent(),
            Value<DateTime?> airDate = const Value.absent(),
            Value<int?> runtimeMinutes = const Value.absent(),
            Value<String?> stillUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TvEpisodesCompanion(
            tmdbId: tmdbId,
            mediaType: mediaType,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            title: title,
            overview: overview,
            airDate: airDate,
            runtimeMinutes: runtimeMinutes,
            stillUrl: stillUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int tmdbId,
            Value<String> mediaType = const Value.absent(),
            required int seasonNumber,
            required int episodeNumber,
            Value<String?> title = const Value.absent(),
            Value<String?> overview = const Value.absent(),
            Value<DateTime?> airDate = const Value.absent(),
            Value<int?> runtimeMinutes = const Value.absent(),
            Value<String?> stillUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TvEpisodesCompanion.insert(
            tmdbId: tmdbId,
            mediaType: mediaType,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            title: title,
            overview: overview,
            airDate: airDate,
            runtimeMinutes: runtimeMinutes,
            stillUrl: stillUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TvEpisodesTableProcessedTableManager = ProcessedTableManager<
    _$StreamloadDatabase,
    $TvEpisodesTable,
    TvEpisodeRow,
    $$TvEpisodesTableFilterComposer,
    $$TvEpisodesTableOrderingComposer,
    $$TvEpisodesTableAnnotationComposer,
    $$TvEpisodesTableCreateCompanionBuilder,
    $$TvEpisodesTableUpdateCompanionBuilder,
    (
      TvEpisodeRow,
      BaseReferences<_$StreamloadDatabase, $TvEpisodesTable, TvEpisodeRow>
    ),
    TvEpisodeRow,
    PrefetchHooks Function()>;
typedef $$CatalogSourcesTableCreateCompanionBuilder = CatalogSourcesCompanion
    Function({
  required int tmdbId,
  required String mediaType,
  required String pluginShortName,
  required String serviceUrl,
  required String serviceMediaId,
  Value<int?> qualityMaxHeight,
  Value<String> audioLangsJson,
  Value<String> subsLangsJson,
  Value<int> successCount,
  Value<int> failureCount,
  Value<DateTime> lastVerifiedAt,
  Value<int> rowid,
});
typedef $$CatalogSourcesTableUpdateCompanionBuilder = CatalogSourcesCompanion
    Function({
  Value<int> tmdbId,
  Value<String> mediaType,
  Value<String> pluginShortName,
  Value<String> serviceUrl,
  Value<String> serviceMediaId,
  Value<int?> qualityMaxHeight,
  Value<String> audioLangsJson,
  Value<String> subsLangsJson,
  Value<int> successCount,
  Value<int> failureCount,
  Value<DateTime> lastVerifiedAt,
  Value<int> rowid,
});

class $$CatalogSourcesTableFilterComposer
    extends Composer<_$StreamloadDatabase, $CatalogSourcesTable> {
  $$CatalogSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pluginShortName => $composableBuilder(
      column: $table.pluginShortName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceUrl => $composableBuilder(
      column: $table.serviceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceMediaId => $composableBuilder(
      column: $table.serviceMediaId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qualityMaxHeight => $composableBuilder(
      column: $table.qualityMaxHeight,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioLangsJson => $composableBuilder(
      column: $table.audioLangsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subsLangsJson => $composableBuilder(
      column: $table.subsLangsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get successCount => $composableBuilder(
      column: $table.successCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failureCount => $composableBuilder(
      column: $table.failureCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastVerifiedAt => $composableBuilder(
      column: $table.lastVerifiedAt,
      builder: (column) => ColumnFilters(column));
}

class $$CatalogSourcesTableOrderingComposer
    extends Composer<_$StreamloadDatabase, $CatalogSourcesTable> {
  $$CatalogSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pluginShortName => $composableBuilder(
      column: $table.pluginShortName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceUrl => $composableBuilder(
      column: $table.serviceUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceMediaId => $composableBuilder(
      column: $table.serviceMediaId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qualityMaxHeight => $composableBuilder(
      column: $table.qualityMaxHeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioLangsJson => $composableBuilder(
      column: $table.audioLangsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subsLangsJson => $composableBuilder(
      column: $table.subsLangsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get successCount => $composableBuilder(
      column: $table.successCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failureCount => $composableBuilder(
      column: $table.failureCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastVerifiedAt => $composableBuilder(
      column: $table.lastVerifiedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$CatalogSourcesTableAnnotationComposer
    extends Composer<_$StreamloadDatabase, $CatalogSourcesTable> {
  $$CatalogSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get pluginShortName => $composableBuilder(
      column: $table.pluginShortName, builder: (column) => column);

  GeneratedColumn<String> get serviceUrl => $composableBuilder(
      column: $table.serviceUrl, builder: (column) => column);

  GeneratedColumn<String> get serviceMediaId => $composableBuilder(
      column: $table.serviceMediaId, builder: (column) => column);

  GeneratedColumn<int> get qualityMaxHeight => $composableBuilder(
      column: $table.qualityMaxHeight, builder: (column) => column);

  GeneratedColumn<String> get audioLangsJson => $composableBuilder(
      column: $table.audioLangsJson, builder: (column) => column);

  GeneratedColumn<String> get subsLangsJson => $composableBuilder(
      column: $table.subsLangsJson, builder: (column) => column);

  GeneratedColumn<int> get successCount => $composableBuilder(
      column: $table.successCount, builder: (column) => column);

  GeneratedColumn<int> get failureCount => $composableBuilder(
      column: $table.failureCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastVerifiedAt => $composableBuilder(
      column: $table.lastVerifiedAt, builder: (column) => column);
}

class $$CatalogSourcesTableTableManager extends RootTableManager<
    _$StreamloadDatabase,
    $CatalogSourcesTable,
    CatalogSourceRow,
    $$CatalogSourcesTableFilterComposer,
    $$CatalogSourcesTableOrderingComposer,
    $$CatalogSourcesTableAnnotationComposer,
    $$CatalogSourcesTableCreateCompanionBuilder,
    $$CatalogSourcesTableUpdateCompanionBuilder,
    (
      CatalogSourceRow,
      BaseReferences<_$StreamloadDatabase, $CatalogSourcesTable,
          CatalogSourceRow>
    ),
    CatalogSourceRow,
    PrefetchHooks Function()> {
  $$CatalogSourcesTableTableManager(
      _$StreamloadDatabase db, $CatalogSourcesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> tmdbId = const Value.absent(),
            Value<String> mediaType = const Value.absent(),
            Value<String> pluginShortName = const Value.absent(),
            Value<String> serviceUrl = const Value.absent(),
            Value<String> serviceMediaId = const Value.absent(),
            Value<int?> qualityMaxHeight = const Value.absent(),
            Value<String> audioLangsJson = const Value.absent(),
            Value<String> subsLangsJson = const Value.absent(),
            Value<int> successCount = const Value.absent(),
            Value<int> failureCount = const Value.absent(),
            Value<DateTime> lastVerifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogSourcesCompanion(
            tmdbId: tmdbId,
            mediaType: mediaType,
            pluginShortName: pluginShortName,
            serviceUrl: serviceUrl,
            serviceMediaId: serviceMediaId,
            qualityMaxHeight: qualityMaxHeight,
            audioLangsJson: audioLangsJson,
            subsLangsJson: subsLangsJson,
            successCount: successCount,
            failureCount: failureCount,
            lastVerifiedAt: lastVerifiedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int tmdbId,
            required String mediaType,
            required String pluginShortName,
            required String serviceUrl,
            required String serviceMediaId,
            Value<int?> qualityMaxHeight = const Value.absent(),
            Value<String> audioLangsJson = const Value.absent(),
            Value<String> subsLangsJson = const Value.absent(),
            Value<int> successCount = const Value.absent(),
            Value<int> failureCount = const Value.absent(),
            Value<DateTime> lastVerifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogSourcesCompanion.insert(
            tmdbId: tmdbId,
            mediaType: mediaType,
            pluginShortName: pluginShortName,
            serviceUrl: serviceUrl,
            serviceMediaId: serviceMediaId,
            qualityMaxHeight: qualityMaxHeight,
            audioLangsJson: audioLangsJson,
            subsLangsJson: subsLangsJson,
            successCount: successCount,
            failureCount: failureCount,
            lastVerifiedAt: lastVerifiedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogSourcesTableProcessedTableManager = ProcessedTableManager<
    _$StreamloadDatabase,
    $CatalogSourcesTable,
    CatalogSourceRow,
    $$CatalogSourcesTableFilterComposer,
    $$CatalogSourcesTableOrderingComposer,
    $$CatalogSourcesTableAnnotationComposer,
    $$CatalogSourcesTableCreateCompanionBuilder,
    $$CatalogSourcesTableUpdateCompanionBuilder,
    (
      CatalogSourceRow,
      BaseReferences<_$StreamloadDatabase, $CatalogSourcesTable,
          CatalogSourceRow>
    ),
    CatalogSourceRow,
    PrefetchHooks Function()>;
typedef $$WatchProgressTableCreateCompanionBuilder = WatchProgressCompanion
    Function({
  required int tmdbId,
  required String mediaType,
  Value<int> seasonNumber,
  Value<int> episodeNumber,
  required int positionSeconds,
  required int durationSeconds,
  Value<bool> completed,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$WatchProgressTableUpdateCompanionBuilder = WatchProgressCompanion
    Function({
  Value<int> tmdbId,
  Value<String> mediaType,
  Value<int> seasonNumber,
  Value<int> episodeNumber,
  Value<int> positionSeconds,
  Value<int> durationSeconds,
  Value<bool> completed,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$WatchProgressTableFilterComposer
    extends Composer<_$StreamloadDatabase, $WatchProgressTable> {
  $$WatchProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get positionSeconds => $composableBuilder(
      column: $table.positionSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$WatchProgressTableOrderingComposer
    extends Composer<_$StreamloadDatabase, $WatchProgressTable> {
  $$WatchProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get positionSeconds => $composableBuilder(
      column: $table.positionSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$WatchProgressTableAnnotationComposer
    extends Composer<_$StreamloadDatabase, $WatchProgressTable> {
  $$WatchProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => column);

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => column);

  GeneratedColumn<int> get positionSeconds => $composableBuilder(
      column: $table.positionSeconds, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WatchProgressTableTableManager extends RootTableManager<
    _$StreamloadDatabase,
    $WatchProgressTable,
    WatchProgressRow,
    $$WatchProgressTableFilterComposer,
    $$WatchProgressTableOrderingComposer,
    $$WatchProgressTableAnnotationComposer,
    $$WatchProgressTableCreateCompanionBuilder,
    $$WatchProgressTableUpdateCompanionBuilder,
    (
      WatchProgressRow,
      BaseReferences<_$StreamloadDatabase, $WatchProgressTable,
          WatchProgressRow>
    ),
    WatchProgressRow,
    PrefetchHooks Function()> {
  $$WatchProgressTableTableManager(
      _$StreamloadDatabase db, $WatchProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> tmdbId = const Value.absent(),
            Value<String> mediaType = const Value.absent(),
            Value<int> seasonNumber = const Value.absent(),
            Value<int> episodeNumber = const Value.absent(),
            Value<int> positionSeconds = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchProgressCompanion(
            tmdbId: tmdbId,
            mediaType: mediaType,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            positionSeconds: positionSeconds,
            durationSeconds: durationSeconds,
            completed: completed,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int tmdbId,
            required String mediaType,
            Value<int> seasonNumber = const Value.absent(),
            Value<int> episodeNumber = const Value.absent(),
            required int positionSeconds,
            required int durationSeconds,
            Value<bool> completed = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchProgressCompanion.insert(
            tmdbId: tmdbId,
            mediaType: mediaType,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            positionSeconds: positionSeconds,
            durationSeconds: durationSeconds,
            completed: completed,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WatchProgressTableProcessedTableManager = ProcessedTableManager<
    _$StreamloadDatabase,
    $WatchProgressTable,
    WatchProgressRow,
    $$WatchProgressTableFilterComposer,
    $$WatchProgressTableOrderingComposer,
    $$WatchProgressTableAnnotationComposer,
    $$WatchProgressTableCreateCompanionBuilder,
    $$WatchProgressTableUpdateCompanionBuilder,
    (
      WatchProgressRow,
      BaseReferences<_$StreamloadDatabase, $WatchProgressTable,
          WatchProgressRow>
    ),
    WatchProgressRow,
    PrefetchHooks Function()>;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required int tmdbId,
  required String mediaType,
  Value<DateTime> addedAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<int> tmdbId,
  Value<String> mediaType,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$StreamloadDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$StreamloadDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$StreamloadDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$FavoritesTableTableManager extends RootTableManager<
    _$StreamloadDatabase,
    $FavoritesTable,
    FavoriteRow,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (
      FavoriteRow,
      BaseReferences<_$StreamloadDatabase, $FavoritesTable, FavoriteRow>
    ),
    FavoriteRow,
    PrefetchHooks Function()> {
  $$FavoritesTableTableManager(_$StreamloadDatabase db, $FavoritesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> tmdbId = const Value.absent(),
            Value<String> mediaType = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoritesCompanion(
            tmdbId: tmdbId,
            mediaType: mediaType,
            addedAt: addedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int tmdbId,
            required String mediaType,
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoritesCompanion.insert(
            tmdbId: tmdbId,
            mediaType: mediaType,
            addedAt: addedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoritesTableProcessedTableManager = ProcessedTableManager<
    _$StreamloadDatabase,
    $FavoritesTable,
    FavoriteRow,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (
      FavoriteRow,
      BaseReferences<_$StreamloadDatabase, $FavoritesTable, FavoriteRow>
    ),
    FavoriteRow,
    PrefetchHooks Function()>;
typedef $$WatchlistTableCreateCompanionBuilder = WatchlistCompanion Function({
  required int tmdbId,
  required String mediaType,
  Value<DateTime> addedAt,
  Value<int> rowid,
});
typedef $$WatchlistTableUpdateCompanionBuilder = WatchlistCompanion Function({
  Value<int> tmdbId,
  Value<String> mediaType,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$WatchlistTableFilterComposer
    extends Composer<_$StreamloadDatabase, $WatchlistTable> {
  $$WatchlistTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$WatchlistTableOrderingComposer
    extends Composer<_$StreamloadDatabase, $WatchlistTable> {
  $$WatchlistTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$WatchlistTableAnnotationComposer
    extends Composer<_$StreamloadDatabase, $WatchlistTable> {
  $$WatchlistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$WatchlistTableTableManager extends RootTableManager<
    _$StreamloadDatabase,
    $WatchlistTable,
    WatchlistRow,
    $$WatchlistTableFilterComposer,
    $$WatchlistTableOrderingComposer,
    $$WatchlistTableAnnotationComposer,
    $$WatchlistTableCreateCompanionBuilder,
    $$WatchlistTableUpdateCompanionBuilder,
    (
      WatchlistRow,
      BaseReferences<_$StreamloadDatabase, $WatchlistTable, WatchlistRow>
    ),
    WatchlistRow,
    PrefetchHooks Function()> {
  $$WatchlistTableTableManager(_$StreamloadDatabase db, $WatchlistTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchlistTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchlistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchlistTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> tmdbId = const Value.absent(),
            Value<String> mediaType = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchlistCompanion(
            tmdbId: tmdbId,
            mediaType: mediaType,
            addedAt: addedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int tmdbId,
            required String mediaType,
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchlistCompanion.insert(
            tmdbId: tmdbId,
            mediaType: mediaType,
            addedAt: addedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WatchlistTableProcessedTableManager = ProcessedTableManager<
    _$StreamloadDatabase,
    $WatchlistTable,
    WatchlistRow,
    $$WatchlistTableFilterComposer,
    $$WatchlistTableOrderingComposer,
    $$WatchlistTableAnnotationComposer,
    $$WatchlistTableCreateCompanionBuilder,
    $$WatchlistTableUpdateCompanionBuilder,
    (
      WatchlistRow,
      BaseReferences<_$StreamloadDatabase, $WatchlistTable, WatchlistRow>
    ),
    WatchlistRow,
    PrefetchHooks Function()>;
typedef $$UserSettingsTableCreateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<String> key,
  Value<String> audioPrefLang,
  Value<String> subsPrefLang,
  Value<int?> qualityCapHeight,
  Value<bool> autoplayNextEpisode,
  Value<bool> skipIntro,
  Value<String> theme,
  Value<String> locale,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$UserSettingsTableUpdateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<String> key,
  Value<String> audioPrefLang,
  Value<String> subsPrefLang,
  Value<int?> qualityCapHeight,
  Value<bool> autoplayNextEpisode,
  Value<bool> skipIntro,
  Value<String> theme,
  Value<String> locale,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UserSettingsTableFilterComposer
    extends Composer<_$StreamloadDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioPrefLang => $composableBuilder(
      column: $table.audioPrefLang, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subsPrefLang => $composableBuilder(
      column: $table.subsPrefLang, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qualityCapHeight => $composableBuilder(
      column: $table.qualityCapHeight,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoplayNextEpisode => $composableBuilder(
      column: $table.autoplayNextEpisode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get skipIntro => $composableBuilder(
      column: $table.skipIntro, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get theme => $composableBuilder(
      column: $table.theme, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$StreamloadDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioPrefLang => $composableBuilder(
      column: $table.audioPrefLang,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subsPrefLang => $composableBuilder(
      column: $table.subsPrefLang,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qualityCapHeight => $composableBuilder(
      column: $table.qualityCapHeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoplayNextEpisode => $composableBuilder(
      column: $table.autoplayNextEpisode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get skipIntro => $composableBuilder(
      column: $table.skipIntro, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get theme => $composableBuilder(
      column: $table.theme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$StreamloadDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get audioPrefLang => $composableBuilder(
      column: $table.audioPrefLang, builder: (column) => column);

  GeneratedColumn<String> get subsPrefLang => $composableBuilder(
      column: $table.subsPrefLang, builder: (column) => column);

  GeneratedColumn<int> get qualityCapHeight => $composableBuilder(
      column: $table.qualityCapHeight, builder: (column) => column);

  GeneratedColumn<bool> get autoplayNextEpisode => $composableBuilder(
      column: $table.autoplayNextEpisode, builder: (column) => column);

  GeneratedColumn<bool> get skipIntro =>
      $composableBuilder(column: $table.skipIntro, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableManager extends RootTableManager<
    _$StreamloadDatabase,
    $UserSettingsTable,
    UserSettingsRow,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSettingsRow,
      BaseReferences<_$StreamloadDatabase, $UserSettingsTable, UserSettingsRow>
    ),
    UserSettingsRow,
    PrefetchHooks Function()> {
  $$UserSettingsTableTableManager(
      _$StreamloadDatabase db, $UserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> audioPrefLang = const Value.absent(),
            Value<String> subsPrefLang = const Value.absent(),
            Value<int?> qualityCapHeight = const Value.absent(),
            Value<bool> autoplayNextEpisode = const Value.absent(),
            Value<bool> skipIntro = const Value.absent(),
            Value<String> theme = const Value.absent(),
            Value<String> locale = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion(
            key: key,
            audioPrefLang: audioPrefLang,
            subsPrefLang: subsPrefLang,
            qualityCapHeight: qualityCapHeight,
            autoplayNextEpisode: autoplayNextEpisode,
            skipIntro: skipIntro,
            theme: theme,
            locale: locale,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> audioPrefLang = const Value.absent(),
            Value<String> subsPrefLang = const Value.absent(),
            Value<int?> qualityCapHeight = const Value.absent(),
            Value<bool> autoplayNextEpisode = const Value.absent(),
            Value<bool> skipIntro = const Value.absent(),
            Value<String> theme = const Value.absent(),
            Value<String> locale = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion.insert(
            key: key,
            audioPrefLang: audioPrefLang,
            subsPrefLang: subsPrefLang,
            qualityCapHeight: qualityCapHeight,
            autoplayNextEpisode: autoplayNextEpisode,
            skipIntro: skipIntro,
            theme: theme,
            locale: locale,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$StreamloadDatabase,
    $UserSettingsTable,
    UserSettingsRow,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSettingsRow,
      BaseReferences<_$StreamloadDatabase, $UserSettingsTable, UserSettingsRow>
    ),
    UserSettingsRow,
    PrefetchHooks Function()>;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  required String kind,
  required String payloadJson,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<DateTime> nextAttemptAt,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  Value<String> kind,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<DateTime> nextAttemptAt,
});

class $$OutboxTableFilterComposer
    extends Composer<_$StreamloadDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer
    extends Composer<_$StreamloadDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$StreamloadDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);
}

class $$OutboxTableTableManager extends RootTableManager<
    _$StreamloadDatabase,
    $OutboxTable,
    OutboxRow,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxRow, BaseReferences<_$StreamloadDatabase, $OutboxTable, OutboxRow>),
    OutboxRow,
    PrefetchHooks Function()> {
  $$OutboxTableTableManager(_$StreamloadDatabase db, $OutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime> nextAttemptAt = const Value.absent(),
          }) =>
              OutboxCompanion(
            id: id,
            kind: kind,
            payloadJson: payloadJson,
            createdAt: createdAt,
            attempts: attempts,
            nextAttemptAt: nextAttemptAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String kind,
            required String payloadJson,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime> nextAttemptAt = const Value.absent(),
          }) =>
              OutboxCompanion.insert(
            id: id,
            kind: kind,
            payloadJson: payloadJson,
            createdAt: createdAt,
            attempts: attempts,
            nextAttemptAt: nextAttemptAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableProcessedTableManager = ProcessedTableManager<
    _$StreamloadDatabase,
    $OutboxTable,
    OutboxRow,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxRow, BaseReferences<_$StreamloadDatabase, $OutboxTable, OutboxRow>),
    OutboxRow,
    PrefetchHooks Function()>;
typedef $$InstalledPluginsTableCreateCompanionBuilder
    = InstalledPluginsCompanion Function({
  required String shortName,
  required String version,
  required String sha256,
  required String filePath,
  Value<bool> enabled,
  Value<DateTime> installedAt,
  Value<int> rowid,
});
typedef $$InstalledPluginsTableUpdateCompanionBuilder
    = InstalledPluginsCompanion Function({
  Value<String> shortName,
  Value<String> version,
  Value<String> sha256,
  Value<String> filePath,
  Value<bool> enabled,
  Value<DateTime> installedAt,
  Value<int> rowid,
});

class $$InstalledPluginsTableFilterComposer
    extends Composer<_$StreamloadDatabase, $InstalledPluginsTable> {
  $$InstalledPluginsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sha256 => $composableBuilder(
      column: $table.sha256, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => ColumnFilters(column));
}

class $$InstalledPluginsTableOrderingComposer
    extends Composer<_$StreamloadDatabase, $InstalledPluginsTable> {
  $$InstalledPluginsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sha256 => $composableBuilder(
      column: $table.sha256, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => ColumnOrderings(column));
}

class $$InstalledPluginsTableAnnotationComposer
    extends Composer<_$StreamloadDatabase, $InstalledPluginsTable> {
  $$InstalledPluginsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => column);
}

class $$InstalledPluginsTableTableManager extends RootTableManager<
    _$StreamloadDatabase,
    $InstalledPluginsTable,
    InstalledPluginRow,
    $$InstalledPluginsTableFilterComposer,
    $$InstalledPluginsTableOrderingComposer,
    $$InstalledPluginsTableAnnotationComposer,
    $$InstalledPluginsTableCreateCompanionBuilder,
    $$InstalledPluginsTableUpdateCompanionBuilder,
    (
      InstalledPluginRow,
      BaseReferences<_$StreamloadDatabase, $InstalledPluginsTable,
          InstalledPluginRow>
    ),
    InstalledPluginRow,
    PrefetchHooks Function()> {
  $$InstalledPluginsTableTableManager(
      _$StreamloadDatabase db, $InstalledPluginsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstalledPluginsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstalledPluginsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstalledPluginsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> shortName = const Value.absent(),
            Value<String> version = const Value.absent(),
            Value<String> sha256 = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime> installedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstalledPluginsCompanion(
            shortName: shortName,
            version: version,
            sha256: sha256,
            filePath: filePath,
            enabled: enabled,
            installedAt: installedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String shortName,
            required String version,
            required String sha256,
            required String filePath,
            Value<bool> enabled = const Value.absent(),
            Value<DateTime> installedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstalledPluginsCompanion.insert(
            shortName: shortName,
            version: version,
            sha256: sha256,
            filePath: filePath,
            enabled: enabled,
            installedAt: installedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InstalledPluginsTableProcessedTableManager = ProcessedTableManager<
    _$StreamloadDatabase,
    $InstalledPluginsTable,
    InstalledPluginRow,
    $$InstalledPluginsTableFilterComposer,
    $$InstalledPluginsTableOrderingComposer,
    $$InstalledPluginsTableAnnotationComposer,
    $$InstalledPluginsTableCreateCompanionBuilder,
    $$InstalledPluginsTableUpdateCompanionBuilder,
    (
      InstalledPluginRow,
      BaseReferences<_$StreamloadDatabase, $InstalledPluginsTable,
          InstalledPluginRow>
    ),
    InstalledPluginRow,
    PrefetchHooks Function()>;
typedef $$PluginKvTableCreateCompanionBuilder = PluginKvCompanion Function({
  required String pluginShortName,
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$PluginKvTableUpdateCompanionBuilder = PluginKvCompanion Function({
  Value<String> pluginShortName,
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$PluginKvTableFilterComposer
    extends Composer<_$StreamloadDatabase, $PluginKvTable> {
  $$PluginKvTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pluginShortName => $composableBuilder(
      column: $table.pluginShortName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$PluginKvTableOrderingComposer
    extends Composer<_$StreamloadDatabase, $PluginKvTable> {
  $$PluginKvTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pluginShortName => $composableBuilder(
      column: $table.pluginShortName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$PluginKvTableAnnotationComposer
    extends Composer<_$StreamloadDatabase, $PluginKvTable> {
  $$PluginKvTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pluginShortName => $composableBuilder(
      column: $table.pluginShortName, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PluginKvTableTableManager extends RootTableManager<
    _$StreamloadDatabase,
    $PluginKvTable,
    PluginKvRow,
    $$PluginKvTableFilterComposer,
    $$PluginKvTableOrderingComposer,
    $$PluginKvTableAnnotationComposer,
    $$PluginKvTableCreateCompanionBuilder,
    $$PluginKvTableUpdateCompanionBuilder,
    (
      PluginKvRow,
      BaseReferences<_$StreamloadDatabase, $PluginKvTable, PluginKvRow>
    ),
    PluginKvRow,
    PrefetchHooks Function()> {
  $$PluginKvTableTableManager(_$StreamloadDatabase db, $PluginKvTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PluginKvTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PluginKvTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PluginKvTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> pluginShortName = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PluginKvCompanion(
            pluginShortName: pluginShortName,
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String pluginShortName,
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              PluginKvCompanion.insert(
            pluginShortName: pluginShortName,
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PluginKvTableProcessedTableManager = ProcessedTableManager<
    _$StreamloadDatabase,
    $PluginKvTable,
    PluginKvRow,
    $$PluginKvTableFilterComposer,
    $$PluginKvTableOrderingComposer,
    $$PluginKvTableAnnotationComposer,
    $$PluginKvTableCreateCompanionBuilder,
    $$PluginKvTableUpdateCompanionBuilder,
    (
      PluginKvRow,
      BaseReferences<_$StreamloadDatabase, $PluginKvTable, PluginKvRow>
    ),
    PluginKvRow,
    PrefetchHooks Function()>;

class $StreamloadDatabaseManager {
  final _$StreamloadDatabase _db;
  $StreamloadDatabaseManager(this._db);
  $$CatalogItemsTableTableManager get catalogItems =>
      $$CatalogItemsTableTableManager(_db, _db.catalogItems);
  $$TvEpisodesTableTableManager get tvEpisodes =>
      $$TvEpisodesTableTableManager(_db, _db.tvEpisodes);
  $$CatalogSourcesTableTableManager get catalogSources =>
      $$CatalogSourcesTableTableManager(_db, _db.catalogSources);
  $$WatchProgressTableTableManager get watchProgress =>
      $$WatchProgressTableTableManager(_db, _db.watchProgress);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$WatchlistTableTableManager get watchlist =>
      $$WatchlistTableTableManager(_db, _db.watchlist);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$InstalledPluginsTableTableManager get installedPlugins =>
      $$InstalledPluginsTableTableManager(_db, _db.installedPlugins);
  $$PluginKvTableTableManager get pluginKv =>
      $$PluginKvTableTableManager(_db, _db.pluginKv);
}
