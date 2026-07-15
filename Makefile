# Snap - macOS Screenshot App Makefile
# Optimized for Apple Silicon / macOS 15+

APP_NAME = Snap
BUNDLE_ID = com.snap.screenshot
VERSION = 1.0.0
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
APP_DIR = $(RELEASE_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_DIR)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

.PHONY: all clean build app zip dmg install help release

all: app

help:
	@echo "Snap - macOS Screenshot App Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make build     - Build the Swift executable (arm64)"
	@echo "  make app       - Create .app bundle"
	@echo "  make zip       - Create ZIP archive"
	@echo "  make dmg       - Create DMG installer"
	@echo "  make install   - Install to /Applications"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make release   - Build app + ZIP + DMG"

build:
	@echo "Building Snap for Apple Silicon (macOS 15)..."
	swift build -c release --arch arm64

app: build
	@echo "Creating .app bundle..."
	@mkdir -p $(MACOS_DIR)
	@mkdir -p $(RESOURCES_DIR)
	@BIN=$$(swift build -c release --arch arm64 --show-bin-path)/SnapApp; \
	 if [ ! -f "$$BIN" ]; then \
	   BIN=$$(find $(BUILD_DIR) -type f -name SnapApp -perm -111 | head -1); \
	 fi; \
	 if [ -z "$$BIN" ] || [ ! -f "$$BIN" ]; then \
	   echo "ERROR: SnapApp binary not found"; exit 1; \
	 fi; \
	 echo "Using binary: $$BIN"; \
	 cp "$$BIN" $(MACOS_DIR)/$(APP_NAME)
	@cp SnapApp/Resources/Info.plist $(CONTENTS_DIR)/
	@echo "App bundle created at: $(APP_DIR)"

zip: app
	@echo "Creating ZIP archive..."
	@cd $(RELEASE_DIR) && zip -r $(APP_NAME)-$(VERSION).zip $(APP_NAME).app
	@echo "ZIP created at: $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).zip"

dmg: app
	@echo "Creating DMG installer..."
	@rm -rf $(RELEASE_DIR)/dmg
	@mkdir -p $(RELEASE_DIR)/dmg
	@cp -R $(APP_DIR) $(RELEASE_DIR)/dmg/
	@ln -sf /Applications $(RELEASE_DIR)/dmg/Applications
	@hdiutil create -volname "$(APP_NAME)" \
		-srcfolder $(RELEASE_DIR)/dmg \
		-ov -format UDZO \
		$(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg
	@rm -rf $(RELEASE_DIR)/dmg
	@echo "DMG created at: $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg"

install: app
	@echo "Installing to /Applications..."
	@cp -r $(APP_DIR) /Applications/
	@echo "Installed to /Applications/$(APP_NAME).app"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -rf .swiftpm
	@echo "Clean complete"

release: clean build app zip dmg
	@echo ""
	@echo "Release build complete!"
	@echo "  App:  $(APP_DIR)"
	@echo "  ZIP:  $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).zip"
	@echo "  DMG:  $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg"
	@du -sh $(APP_DIR)
	@du -sh $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).zip
	@du -sh $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg

.DEFAULT_GOAL := help
