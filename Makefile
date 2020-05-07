prefix ?= /usr/local

TOOL_NAME = bow-openapi
PREFIX_BIN = $(prefix)/bin
RESOURCES_PATH = $(prefix)/lib/bowopenapi
BUILD_PATH = /tmp/$(TOOL_NAME)
SWAGGER_JAR = "https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.19/swagger-codegen-cli-3.0.19.jar"

.PHONY: linux
linux: clean structure dependencies install

.PHONY: macos
macos: clean structure install
		swift test --generate-linuxmain

.PHONY: fixtures
fixtures:
		@rm -rf ./Tests/Fixtures/FixturesAPI
		$(TOOL_NAME) --name FixturesAPI --schema ./Tests/Fixtures/petstore.yaml --output ./Tests/Fixtures/FixturesAPI --verbose

.PHONY: xcode
xcode: macos fixtures
		swift package generate-xcodeproj

.PHONY: install
install:
		@rm -rf ./Tests/Fixtures/FixturesAPI
	 	@tar -xvf ./Tests/Fixtures/FixturesAPI.tar.gz -C ./Tests/Fixtures/
		@swift build --disable-sandbox --configuration release --build-path $(BUILD_PATH)/build
		@install $(BUILD_PATH)/build/release/$(TOOL_NAME) $(PREFIX_BIN)/$(TOOL_NAME)
		@cp -R ./Templates $(RESOURCES_PATH)
		@cp ./Tests/Fixtures/petstore.yaml $(RESOURCES_PATH)

.PHONY: dependencies
dependencies:
		apt update && apt install openjdk-8-jre-headless
		wget $(SWAGGER_JAR) --output-document $(BUILD_PATH)/swagger-codegen-cli.jar
		install $(BUILD_PATH)/swagger-codegen-cli.jar $(PREFIX_BIN)/swagger-codegen-cli.jar

.PHONY: structure
structure:
		@install -d $(BUILD_PATH)/
		@install -d $(PREFIX_BIN)/
		@install -d $(RESOURCES_PATH)/

.PHONY: uninstall
uninstall:
		@rm -rf $(PREFIX_BIN)/swagger-codegen-cli.jar
		@rm -rf $(PREFIX_BIN)/$(TOOL_NAME)
		@rm -rf $(RESOURCES_PATH)

.PHONY: clean
clean: uninstall
		@rm -rf $(BUILD_PATH)
