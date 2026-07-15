# Snap - macOS Screenshot App Makefile
# Optimized for Apple Silicon / macOS 15+

APP_NAME = Snap
BUNDLE_ID = com.snap.screenshot
VERSION ?= 1.0.1
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
APP_DIR = $(RELEASE_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_DIR)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

.PHONY: all clean build app dmg install help release verify-app

all: app

help:
	@echo "Snap - macOS Screenshot App Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make build     - Build the Swift executable (arm64)"
	@echo "  make app       - Create .app bundle"
	@echo "  make dmg       - Create DMG installer"
	@echo "  make install   - Install to /Applications"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make release   - Build app + DMG"
	@echo ""
	@echo "Variables:"
	@echo "  VERSION=$(VERSION)  (override with: make dmg VERSION=1.0.1)"

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
	@# Ensure Info.plist executable name matches the bundled binary
	@/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable $(APP_NAME)" $(CONTENTS_DIR)/Info.plist 2>/dev/null \
		|| /usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string $(APP_NAME)" $(CONTENTS_DIR)/Info.plist
	@/usr/libexec/PlistBuddy -c "Set :CFBundleName $(APP_NAME)" $(CONTENTS_DIR)/Info.plist 2>/dev/null || true
	@chmod +x $(MACOS_DIR)/$(APP_NAME)
	@# Ad-hoc sign so LaunchServices accepts the bundle structure
	@codesign --force --deep --sign - $(APP_DIR)
	@$(MAKE) verify-app
	@echo "App bundle created at: $(APP_DIR)"

verify-app:
	@echo "Verifying .app bundle..."
	@test -d "$(APP_DIR)" || (echo "ERROR: missing $(APP_DIR)"; exit 1)
	@test -f "$(MACOS_DIR)/$(APP_NAME)" || (echo "ERROR: missing executable $(MACOS_DIR)/$(APP_NAME)"; exit 1)
	@test -x "$(MACOS_DIR)/$(APP_NAME)" || (echo "ERROR: executable not executable"; exit 1)
	@test -f "$(CONTENTS_DIR)/Info.plist" || (echo "ERROR: missing Info.plist"; exit 1)
	@EXEC=$$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' $(CONTENTS_DIR)/Info.plist); \
	 if [ "$$EXEC" != "$(APP_NAME)" ]; then \
	   echo "ERROR: CFBundleExecutable='$$EXEC' but binary is '$(APP_NAME)'"; exit 1; \
	 fi
	@codesign --verify --verbose=2 $(APP_DIR)
	@echo "Bundle verification OK"

dmg: app
	@echo "Creating DMG installer (VERSION=$(VERSION))..."
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
	@echo "If macOS says the app is damaged, run:"
	@echo "  xattr -cr /Applications/$(APP_NAME).app"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -rf .swiftpm
	@echo "Clean complete"

release: clean build app dmg
	@echo ""
	@echo "Release build complete!"
	@echo "  App:  $(APP_DIR)"
	@echo "  DMG:  $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg"
	@du -sh $(APP_DIR)
	@du -sh $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg

.DEFAULT_GOAL := help
