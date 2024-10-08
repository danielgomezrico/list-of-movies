import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:movie_flutter/common/change_notifier/change_notifier_value.dart';
import 'package:movie_flutter/common/di/modules.dart';
import 'package:movie_flutter/widget/empty.dart';
import 'package:movie_flutter/widget/favorite_movies/favorite_movies_view_model.dart';
import 'package:movie_flutter/widget/loading.dart';
import 'package:movie_flutter/widget/movie_summary_item/movie_summary_item.dart';
import 'package:movie_flutter/widget/retry_error.dart';

class FavoriteMovies extends StatefulWidget {
  const FavoriteMovies({super.key});

  @override
  State<FavoriteMovies> createState() => _FavoriteMoviesState();
}

class _FavoriteMoviesState extends State<FavoriteMovies> {
  late FavoriteMoviesViewModel _viewModel;

  @override
  void initState() {
    _viewModel = ViewModelModule.favoriteMoviesViewModel();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _viewModel.onInit();
    });

    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        title: const Text('Favorite Movies'),
      ),
      body: ChangeNotifierValue(
        value: _viewModel,
        builder: (_, viewModel) {
          if (viewModel.status.isLoadingVisible) {
            return const Center(child: Loading());
          } else if (viewModel.status.isEmptyVisible) {
            return const Center(child: Empty());
          } else if (viewModel.status.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RetryError(
                  message: 'Error: ${viewModel.status.errorMessage}',
                  onRetry: viewModel.onInit,
                ),
              ),
            );
          } else {
            return movies(viewModel);
          }
        },
      ),
    );
  }

  Widget movies(FavoriteMoviesViewModel viewModel) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: viewModel.status.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final item = viewModel.status.items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: MovieSummaryItem(
            movieSummary: item,
            key: ValueKey(item.movieId),
          ),
        );
      },
    );
  }
}
