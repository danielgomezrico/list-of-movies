import 'package:hive_built_value_flutter/hive_flutter.dart';
import 'package:movie_flutter/api/repositories/models/movie.dart';
import 'package:movie_flutter/common/database/storage.dart';
import 'package:movie_flutter/common/result.dart';

const _tag = '[load][storage]';

class FavoriteMovieStorage extends Storage {
  Box<Movie>? _box;

  @override
  String get name => 'FAVORITE_MOVIE_STORAGE';

  @override
  Future<void> initialize() async {
    _box = await Hive.openBox<Movie>('movie.favorite');
  }

  Future<Result<Movie>> get(int movieId) async {
    final box = _box;
    if (box == null) {
      return Result.error('$_tag $name box is not initialized');
    }

    try {
      final movie = box.get(movieId);

      if (movie == null) {
        return Result.error('$_tag Movie not found');
      }

      return Result.ok(movie);
    } catch (e) {
      return Result.error('$_tag Error getting $e');
    }
  }

  Future<Result<List<Movie>>> getAll() async {
    final box = _box;
    if (box == null) {
      return Result.error('$_tag $name box is not initialized');
    }

    try {
      final movies = box.values.toList();

      return Result.ok(movies);
    } catch (e) {
      return Result.error('$_tag Error getting $e');
    }
  }

  Future<EmptyResult> append(Movie movie) async {
    final box = _box;
    if (box == null) {
      return EmptyResult.error('$_tag $name box is not initialized');
    }

    try {
      box.put(movie.id, movie);

      return Future.value(emptyOk);
    } catch (e) {
      return Result.error('$_tag Error appending $e');
    }
  }

  Future<EmptyResult> delete(Movie movie) async {
    final box = _box;
    if (box == null) {
      return EmptyResult.error('$_tag $name box is not initialized');
    }

    try {
      box.delete(movie.id);

      return Future.value(emptyOk);
    } catch (e) {
      return Result.error('$_tag Error appending $e');
    }
  }

  @override
  Future<EmptyResult> deleteAll() async {
    final box = _box;
    if (box == null) {
      return EmptyResult.error('$_tag $name box is not initialized');
    }

    try {
      await box.clear();

      return Future.value(emptyOk);
    } catch (e) {
      return Result.error('$_tag Error deleting $e');
    }
  }
}
