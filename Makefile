SHELL := /bin/sh

# build/, test/ and coverage/ are directories here, so every target is phony.
.PHONY: install update update-major outdated bootstrap-linux bootstrap-android bootstrap-web \
	run run-linux run-web run-android preview devices emulators emulator-phone emulator-tablet \
	unit-test coverage integration-test-linux integration-test-phone integration-test-tablet update-goldens \
	analyze check build-web build-linux build-apk clean help


# Configurable variables — override on the command line as needed.
DEVICE           := $(if $(DEVICE),$(DEVICE),linux)
ANDROID_DEVICE   := $(if $(ANDROID_DEVICE),$(ANDROID_DEVICE),emulator-5554)
PHONE_AVD        := $(if $(PHONE_AVD),$(PHONE_AVD),Medium_Phone_API_35)
TABLET_AVD       := $(if $(TABLET_AVD),$(TABLET_AVD),Tablet_Landscape_API_35)
# Android numbers emulators in launch order (see `make devices`): the first one up is
# emulator-5554, the next emulator-5556. Override if you start them differently.
PHONE_DEVICE     := $(if $(PHONE_DEVICE),$(PHONE_DEVICE),emulator-5554)
TABLET_DEVICE    := $(if $(TABLET_DEVICE),$(TABLET_DEVICE),emulator-5556)
TEST_PATH        := $(TEST_PATH)
SCENARIO         := $(SCENARIO)
ARGS             := $(ARGS)

# Git-ignored paths that building, testing and running generate. IDE and agent
# folders (.idea/, .vscode/, .claude/) are settings, not build output, so they stay.
CLEAN_PATHS := build .dart_tool coverage android linux web .flutter-plugins-dependencies

# One scenario file under integration_test/, or all of them when SCENARIO is empty.
# Only the desktop run takes one: on a phone or tablet the suite is a single file.
INTEGRATION_PATH := integration_test$(if $(SCENARIO),/$(SCENARIO))

# Generate a git-ignored platform folder, as the README prescribes. `flutter create`
# also rewrites .metadata and pubspec.lock and adds a counter test; those are put back
# from copies (not `git checkout`, which would discard uncommitted edits). If it
# fails, the half-made folder is removed so the next run starts over instead of
# seeing "already exists". $(1) is the platform: linux, android or web.
define create_platform
@if [ -d $(1) ]; then \
	echo "$(1)/ already exists, nothing to do"; \
else \
	tmp=$$(mktemp -d) || exit 1; \
	cp .metadata pubspec.lock "$$tmp"; \
	if [ -f test/widget_test.dart ]; then had_test=1; else had_test=0; fi; \
	flutter create --platforms=$(1) .; rc=$$?; \
	cp "$$tmp/.metadata" "$$tmp/pubspec.lock" .; \
	[ $$had_test = 1 ] || rm -f test/widget_test.dart; \
	[ $$rc = 0 ] || rm -rf $(1); \
	rm -rf "$$tmp"; \
	exit $$rc; \
fi
endef

# ─── Dependencies ────────────────────────────────────────────────────────────

install: # @HELP Install dependencies (flutter pub get).
install:
	@flutter pub get

update: # @HELP Update dependencies to the latest versions pubspec.yaml allows.
update:
	@flutter pub upgrade

update-major: # @HELP Also bump pubspec.yaml past major versions. Rewrites pubspec.yaml; review the diff, then run check.
update-major:
	@flutter pub upgrade --major-versions

outdated: # @HELP Show which dependencies have newer versions available.
outdated:
	@flutter pub outdated

bootstrap-linux: # @HELP Generate the git-ignored linux/ folder if it is missing.
bootstrap-linux:
	$(call create_platform,linux)

bootstrap-android: # @HELP Generate the git-ignored android/ folder if it is missing.
bootstrap-android:
	$(call create_platform,android)

bootstrap-web: # @HELP Generate the git-ignored web/ folder if it is missing.
bootstrap-web:
	$(call create_platform,web)

# ─── Run ─────────────────────────────────────────────────────────────────────

run: # @HELP Run the app on DEVICE (default linux). Extra flutter flags via ARGS.
run:
	@flutter run -d $(DEVICE) $(ARGS)

run-linux: # @HELP Run the app as a Linux desktop app.
run-linux:
	@flutter run -d linux $(ARGS)

run-web: # @HELP Run the app in Chrome.
run-web:
	@flutter run -d chrome $(ARGS)

run-android: # @HELP Run the app on ANDROID_DEVICE (default emulator-5554).
run-android:
	@flutter run -d $(ANDROID_DEVICE) $(ARGS)

preview: # @HELP Open the widget preview environment (the @Preview widgets).
preview:
	@flutter widget-preview start

devices: # @HELP List connected devices.
devices:
	@flutter devices

emulators: # @HELP List available Android emulators.
emulators:
	@flutter emulators

emulator-phone: # @HELP Start the phone emulator (PHONE_AVD).
emulator-phone:
	@flutter emulators --launch $(PHONE_AVD)

emulator-tablet: # @HELP Start the landscape tablet emulator (TABLET_AVD).
emulator-tablet:
	@flutter emulators --launch $(TABLET_AVD)

# ─── Tests ───────────────────────────────────────────────────────────────────

unit-test: # @HELP Run the headless suite under test/. Narrow it with TEST_PATH=<file or dir>.
unit-test:
	@flutter test $(TEST_PATH) $(ARGS)

coverage: # @HELP Run the unit tests with coverage; HTML report in coverage/html if lcov is installed.
coverage:
	@flutter test --coverage $(TEST_PATH) $(ARGS)
	@if command -v genhtml >/dev/null 2>&1; then \
		genhtml coverage/lcov.info --output-directory coverage/html >/dev/null && \
		echo "HTML report: coverage/html/index.html"; \
	else \
		echo "coverage/lcov.info written (install lcov for an HTML report)"; \
	fi

integration-test-linux: # @HELP Run integration_test/ on the Linux desktop: wide and ultrawide flows, page scenarios, goldens. One file: SCENARIO=<name>_scenarios.dart.
integration-test-linux:
	@flutter test $(INTEGRATION_PATH) -d linux $(ARGS)

integration-test-phone: # @HELP Run the compact-tier flows on PHONE_DEVICE (default emulator-5554; start it with emulator-phone).
integration-test-phone:
	@flutter test integration_test -d $(PHONE_DEVICE) $(ARGS)

integration-test-tablet: # @HELP Run the medium-tier flows on TABLET_DEVICE (default emulator-5556; start it with emulator-tablet).
integration-test-tablet:
	@flutter test integration_test -d $(TABLET_DEVICE) $(ARGS)

update-goldens: # @HELP Regenerate integration_test/goldens/ on the Linux desktop.
update-goldens:
	@flutter test integration_test -d linux --update-goldens

# ─── Code quality ────────────────────────────────────────────────────────────

analyze: # @HELP Run flutter analyze on the whole project.
analyze:
	@flutter analyze

check: # @HELP Run analyze, then the unit tests (the gate before a change is done).
check: analyze unit-test

# ─── Build ───────────────────────────────────────────────────────────────────

build-web: # @HELP Build the release web bundle into build/web.
build-web:
	@flutter build web --release $(ARGS)

build-linux: # @HELP Build the release Linux desktop bundle.
build-linux:
	@flutter build linux --release $(ARGS)

build-apk: # @HELP Build the release Android APK.
build-apk:
	@flutter build apk --release $(ARGS)

clean: # @HELP Delete the git-ignored generated folders: build, .dart_tool, coverage, android, linux, web. Then run install and bootstrap-*.
clean:
	@if [ -n "$$(find android \( -name '*.jks' -o -name '*.keystore' -o -name key.properties \) 2>/dev/null)" ]; then \
		echo "android/ holds signing keys; move them out of it before running clean"; \
		exit 1; \
	fi
	@rm -rf $(CLEAN_PATHS)

help: # @HELP Print configurable variables and all available targets.
help:
	@echo "VARIABLES:" && \
	echo "  DEVICE           = $(DEVICE)" && \
	echo "  ANDROID_DEVICE   = $(ANDROID_DEVICE)" && \
	echo "  PHONE_AVD        = $(PHONE_AVD)" && \
	echo "  TABLET_AVD       = $(TABLET_AVD)" && \
	echo "  PHONE_DEVICE     = $(PHONE_DEVICE)" && \
	echo "  TABLET_DEVICE    = $(TABLET_DEVICE)" && \
	echo "  TEST_PATH        = $(TEST_PATH)" && \
	echo "  SCENARIO         = $(SCENARIO)" && \
	echo "  ARGS             = $(ARGS)" && \
	echo " " && \
	echo "TARGETS:" && \
	grep -E '^.*: *# *@HELP' $(MAKEFILE_LIST) \
	    | awk ' \
	        BEGIN {FS = ": *# *@HELP"}; \
	        { printf "  %-35s %s\n", $$1, $$2 }; \
	        '
