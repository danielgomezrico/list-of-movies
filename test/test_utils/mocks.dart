// This is the mock setup and its not required
// ignore_for_file: prefer-correct-test-file-name

import 'package:mockito/annotations.dart';
import 'package:movie_flutter/api/movies_repository.dart';

export 'package:mockito/mockito.dart';
export '../test_utils/extensions/provider_extensions.dart';
export '../test_utils/extensions/mockito_extensions.dart';
export '../test_utils/factories.dart';

export 'mocks.mocks.dart';

@GenerateMocks(
  [
    MoviesRepository,
  ],
)
// not required for mocks
// ignore: no-empty-block
void main() {}
