#/bin/bash

TOOL_NAME = bow-openapi
PREFIX_BIN = /usr/local/bin
TEMPLATES_PATH = $(PREFIX_BIN)/bow/openapi/templates
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
		swift build -c release --build-path $(BUILD_PATH)
		sudo mv $(BINARIES_PATH)/bow-openapi $(PREFIX_BIN)/bow-openapi
		sudo chmod +x $(PREFIX_BIN)/bow-openapi
		sudo mkdir -p $(TEMPLATES_PATH)
		sudo cp -R ./Templates/* $(TEMPLATES_PATH)
		sudo chmod +rx -R $(TEMPLATES_PATH)

.PHONY: fixtures
fixtures:
		rm -rf ./Tests/Fixtures/FixturesAPI
		bow-openapi --name FixturesAPI --schema ./Tests/Fixtures/petstore.yaml --output ./Tests/Fixtures/FixturesAPI --verbose

.PHONY: dependencies
dependencies:
		sudo apt update
		sudo apt install openjdk-8-jre-headless
		sudo wget $(SWAGGER_JAR) --output-document $(PREFIX_BIN)/swagger-codegen-cli.jar
		sudo chmod +x $(PREFIX_BIN)/swagger-codegen-cli.jar

.PHONY: clean
clean:
		sudo rm -rf $(PREFIX_BIN)/swagger-codegen-cli.jar
		sudo rm -rf $(PREFIX_BIN)/bow-openapi
		sudo rm -rf $(TEMPLATES_PATH)
		sudo rm -rf $(BUILD_PATH)
