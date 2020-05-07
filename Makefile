prefix ?= /usr/local

TOOL_NAME = bow-openapi
PREFIX_BIN = $(prefix)/bin
TEMPLATES_PATH = $(PREFIX_BIN)/bowopenapi-templates
BUILD_PATH = /tmp/$(TOOL_NAME)
BINARIES_PATH = $(BUILD_PATH)/release
SWAGGER_JAR = "https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.19/swagger-codegen-cli-3.0.19.jar"

.PHONY: linux
linux: clean dependencies basic fixtures
		echo "🎉 Bow OpenAPI intalled in Linux"
		
.PHONY: macos
macos: clean basic fixtures
		echo "🎉 Bow OpenAPI intalled in macOS"

.PHONY: xcode
xcode: macos
		swift package generate-xcodeproj

.PHONY: basic
basic: install_folders
	 	tar -xvf ./Tests/Fixtures/FixturesAPI.tar.gz -C ./Tests/Fixtures/
		swift build --disable-sandbox -c release --build-path $(BUILD_PATH)
		@install $(BINARIES_PATH)/bow-openapi $(PREFIX_BIN)/bow-openapi
		@cp ./Templates/* $(TEMPLATES_PATH)

.PHONY: fixtures
fixtures:
		@rm -rf ./Tests/Fixtures/FixturesAPI
		bow-openapi --name FixturesAPI --schema ./Tests/Fixtures/petstore.yaml --output ./Tests/Fixtures/FixturesAPI --verbose

.PHONY: install_folders
install_folders:
	@install -d "$(PREFIX_BIN)"
	@install -d "$(TEMPLATES_PATH)"

.PHONY: dependencies
dependencies:
		apt update && apt install openjdk-8-jre-headless
		@mkdir -p $(BUILD_PATH)
		wget $(SWAGGER_JAR) --output-document $(BUILD_PATH)/swagger-codegen-cli.jar
		@install $(BUILD_PATH)/swagger-codegen-cli.jar $(PREFIX_BIN)/swagger-codegen-cli.jar

.PHONY: clean
clean:
		@rm -rf  $(PREFIX_BIN)/swagger-codegen-cli.jar
		@rm -rf  $(PREFIX_BIN)/bow-openapi
		@rm -rf  $(BASE_TEMPLATES_PATH)
		@rm -rf  $(BUILD_PATH)
