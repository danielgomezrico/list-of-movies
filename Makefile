help:
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'

doctor: ## Run you if you have any issues starting the project
	 ./scripts/doctor.sh

autogenerate: ## Auto generate files
	dart run build_runner build

autogenerate_watching: ## Auto generate files and keep watching for changes
	dart run build_runner watch

run: ## Run the project on device
	flutter run

test_unit: ## Run tests with coverage
	./scripts/test-with-coverage.sh

test_integration: ## Run integration tests
	./scripts/ingration-test-with-coverage.sh

build_android: ## Build android
	flutter build apk --release

lint: ## Run all linters
	./scripts/validate-lint.sh

format: ## Auto format the code base following lint rules
	dart format lib/ test/

check_linters: ## Run all linters
	flutter analyze
	flutter format --set-exit-if-changed lib/ test/ integration_test/

app_uninstall: ## Uninstall app from android device for tests
	adb uninstall com.movie.movie_flutter
