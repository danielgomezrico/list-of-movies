import 'package:flutter_test/flutter_test.dart';
import 'package:movie_flutter/widgets/movie_showcase/movie_showcase_status.dart';
import 'package:movie_flutter/widgets/movie_showcase/movie_showcase_view_model.dart';

import '../../test_utils/mocks.dart';
import 'stubs.dart';

typedef _Status = MovieShowcaseStatus;

void main() {
  final moviesRepository = MockMoviesRepository();

  MovieShowcaseViewModel subject() {
    return MovieShowcaseViewModel(moviesRepository);
  }

  group('constructor', () {
    test('initializes status', () {
      final viewModel = subject();

      expect(
        viewModel.status,
        isA<_Status>()
            .having((s) => s.items, 'items', isEmpty)
            .having((s) => s.isLoadingVisible, 'isLoadingVisible', isTrue)
            .having((s) => s.isEmptyVisible, 'isEmptyVisible', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', null)
            .having((s) => s.items, 'items', isEmpty),
      );
    });
  });

  group('onInit', () {
    MovieShowcaseViewModelOnInitSpy subject() {
      return MovieShowcaseViewModelOnInitSpy(moviesRepository);
    }

    late MovieShowcaseViewModelOnInitSpy viewModel;
    late Stream<_Status> status;

    setUpAll(() async {
      viewModel = subject();
      status = viewModel.statusChanges();

      await viewModel.onInit();
    });

    test('shows loading status', () {
      expect(
        status,
        emits(
          isA<_Status>()
              .having((s) => s.isLoadingVisible, 'isLoadingVisible', isTrue)
              .having((s) => s.isEmptyVisible, 'isEmptyVisible', isFalse)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ),
      );
    });

    test('shows the next movie', () {
      expect(viewModel.showNextMoviesCount, 1);
    });
  });

  group('.onBottomReached', () {
    MovieShowcaseViewModelShowNextMoviesSpy subject() {
      return MovieShowcaseViewModelShowNextMoviesSpy(moviesRepository);
    }

    test('after it reaches the bottom it shows next movies', () async {
      var viewModel = subject();
      await viewModel.onBottomReached();
      expect(viewModel.showNextMoviesCount, 1);
    });
  });

  group('.showNextMovies', () {
    group('having multiple pages', () {
      test('it joins them all', () async {
        when(moviesRepository.movies(any)).thenFutureInOrder([
          ResultMother.okPagedResult(
            payload: [MovieSummaryMother.base],
          ),
          ResultMother.okPagedResult(
            payload: [MovieSummaryMother.base, MovieSummaryMother.base],
          ),
        ]);

        final viewModel = subject();

        final status = viewModel.statusChanges();

        await viewModel.showNextMovies();
        await viewModel.showNextMovies();

        expect(
          status,
          emitsInOrder([
            isA<_Status>().having((s) => s.items, 'items', hasLength(1)),
            isA<_Status>().having((s) => s.items, 'items', hasLength(3)),
          ]),
        );
      });
    });

    group('after getting empty movies', () {
      test('updates the UI', () async {
        when(moviesRepository.movies(any)).thenOk(const []);

        final viewModel = subject();

        final status = viewModel.statusChanges();

        await viewModel.onInit();

        expect(
          status,
          emitsInOrder([
            isA<_Status>()
                .having((s) => s.isLoadingVisible, 'isLoadingVisible', isTrue)
                .having((s) => s.isEmptyVisible, 'isEmptyVisible', isFalse),
            isA<_Status>()
                .having((s) => s.isLoadingVisible, 'isLoadingVisible', isFalse)
                .having((s) => s.items, 'items', isEmpty)
                .having((s) => s.isEmptyVisible, 'isEmptyVisible', isTrue),
          ]),
        );
      });

      group('after getting all items', () {
        test('shows the items', () async {
          when(moviesRepository.movies(any)).thenOk(const [
            MovieSummaryMother.base,
            MovieSummaryMother.base,
          ]);

          final viewModel = subject();

          final status = viewModel.statusChanges();

          await viewModel.onInit();

          expect(
            status,
            emitsInOrder([
              isA<_Status>()
                  .having((s) => s.isLoadingVisible, 'isLoadingVisible', isTrue)
                  .having((s) => s.items, 'items', isEmpty)
                  .having((s) => s.isEmptyVisible, 'isEmptyVisible', isFalse),
              isA<_Status>()
                  .having(
                    (s) => s.isLoadingVisible,
                    'isLoadingVisible',
                    isFalse,
                  )
                  .having((s) => s.items, 'items', hasLength(2))
                  .having((s) => s.isEmptyVisible, 'isEmptyVisible', isFalse),
            ]),
          );
        });
      });

      group('after getting an error', () {
        test('shows the error', () async {
          when(moviesRepository.movies(any)).thenError();

          final viewModel = subject();

          final status = viewModel.statusChanges();

          await viewModel.onInit();

          expect(
            status,
            emitsInOrder([
              isA<_Status>()
                  .having((s) => s.isLoadingVisible, 'isLoadingVisible', isTrue)
                  .having((s) => s.items, 'items', isEmpty)
                  .having((s) => s.isEmptyVisible, 'isEmptyVisible', isFalse)
                  .having((s) => s.errorMessage, 'error', isNull),
              isA<_Status>()
                  .having(
                    (s) => s.isLoadingVisible,
                    'isLoadingVisible',
                    isFalse,
                  )
                  .having((s) => s.errorMessage, 'error', 'error')
                  .having((s) => s.isEmptyVisible, 'isEmptyVisible', isFalse),
            ]),
          );
        });
      });
    });

    group('after getting an error getting movies', () {
      test('emits the status', () async {
        when(moviesRepository.movies(any)).thenError();

        final viewModel = subject();
        final status = viewModel.statusChanges();

        await viewModel.showNextMovies();

        expect(
          status,
          emits(isA<_Status>()
              .having((s) => s.isLoadingVisible, 'isLoadingVisible', isFalse)
              .having((s) => s.errorMessage, 'errorMessage', 'error')
              .having((s) => s.isEmptyVisible, 'isEmptyVisible', isFalse)),
        );
      });
    });
  });
}
