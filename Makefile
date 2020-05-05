#/bin/bash

TOOL_NAME = bow-openapi
PREFIX_BIN = /usr/local/bin
BASE_TEMPLATES_PATH = $(PREFIX_BIN)/bow
TEMPLATES_PATH = $(BASE_TEMPLATES_PATH)/openapi/templates
BUILD_PATH = /tmp/$(TOOL_NAME)
BINARIES_PATH = $(BUILD_PATH)/release
SWAGGER_JAR = "https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.19/swagger-codegen-cli-3.0.19.jar"

.PHONY: linux
linux: clean dependencies basic fixtures

.PHONY: macos
macos: clean basic fixtures

.PHONY: xcode
xcode: macos
		swift package generate-xcodeproj

.PHONY: basic
basic:
	 	tar -xvf ./Tests/Fixtures/FixturesAPI.tar.gz -C ./Tests/Fixtures/
		swift build -c release --build-path $(BUILD_PATH)
		mkdir -p $(TEMPLATES_PATH)
		@install $(BINARIES_PATH)/bow-openapi $(PREFIX_BIN)/bow-openapi
		@install ./Templates/* $(TEMPLATES_PATH)

.PHONY: fixtures
fixtures:
		@rm -rf ./Tests/Fixtures/FixturesAPI
		bow-openapi --name FixturesAPI --schema ./Tests/Fixtures/petstore.yaml --output ./Tests/Fixtures/FixturesAPI --verbose

.PHONY: dependencies
dependencies:
		apt update && apt install openjdk-8-jre-headless
		mkdir -p $(BUILD_PATH)
		wget $(SWAGGER_JAR) --output-document $(BUILD_PATH)/swagger-codegen-cli.jar
		@install $(BUILD_PATH)/swagger-codegen-cli.jar $(PREFIX_BIN)/swagger-codegen-cli.jar

.PHONY: clean
clean:
		@rm -rf  $(PREFIX_BIN)/swagger-codegen-cli.jar
		@rm -rf  $(PREFIX_BIN)/bow-openapi
		@rm -rf  $(BASE_TEMPLATES_PATH)
		@rm -rf  $(BUILD_PATH)
