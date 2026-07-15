# Snap - macOS Screenshot App Makefile

APP_NAME = Snap
BUNDLE_ID = com.snap.screenshot
VERSION = 1.0.0
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
APP_DIR = $(RELEASE_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_DIR)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

.PHONY: all clean build app dmg install help

all: app

help:
	@echo "Snap - macOS Screenshot App Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make build     - Build the Swift executable"
	@echo "  make app       - Create .app bundle"
	@echo "  make dmg       - Create DMG installer"
	@echo "  make zip       - Create ZIP archive"
	@echo "  make install   - Install to /Applications"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make release   - Build everything for release"

build:
	@echo "🔨 Building Snap..."
	swift build -c release --arch arm64 --arch x86_64

app: build
	@echo "📦 Creating .app bundle..."
	@mkdir -p $(MACOS_DIR)
	@mkdir -p $(RESOURCES_DIR)
	
	@echo "📋 Copying executable..."
	@cp $(BUILD_DIR)/apple/Products/Release/SnapApp $(MACOS_DIR)/$(APP_NAME) || \
	 cp $(BUILD_DIR)/release/SnapApp $(MACOS_DIR)/$(APP_NAME)
	
	@echo "📋 Copying Info.plist..."
	@cp SnapApp/Resources/Info.plist $(CONTENTS_DIR)/
	
	@echo "🎨 Creating app icon..."
	@mkdir -p $(RESOURCES_DIR)/$(APP_NAME).iconset
	@# Note: You need to add icon files later
	@# iconutil -c icns $(RESOURCES_DIR)/$(APP_NAME).iconset -o $(RESOURCES_DIR)/AppIcon.icns
	
	@echo "✅ App bundle created at: $(APP_DIR)"

dmg: app
	@echo "💿 Creating DMG installer..."
	@mkdir -p $(RELEASE_DIR)/dmg
	@cp -r $(APP_DIR) $(RELEASE_DIR)/dmg/
	@ln -sf /Applications $(RELEASE_DIR)/dmg/Applications
	@hdiutil create -volname "$(APP_NAME)" \
		-srcfolder $(RELEASE_DIR)/dmg \
		-ov -format UDZO \
		$(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg
	@rm -rf $(RELEASE_DIR)/dmg
	@echo "✅ DMG created at: $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg"

zip: app
	@echo "📦 Creating ZIP archive..."
	@cd $(RELEASE_DIR) && zip -r $(APP_NAME)-$(VERSION).zip $(APP_NAME).app
	@echo "✅ ZIP created at: $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).zip"

install: app
	@echo "📥 Installing to /Applications..."
	@sudo cp -r $(APP_DIR) /Applications/
	@echo "✅ Installed to /Applications/$(APP_NAME).app"

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -rf .swiftpm
	@echo "✅ Clean complete"

release: clean build app zip dmg
	@echo ""
	@echo "🎉 Release build complete!"
	@echo ""
	@echo "📦 Build artifacts:"
	@echo "  App:  $(APP_DIR)"
	@echo "  ZIP:  $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).zip"
	@echo "  DMG:  $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg"
	@echo ""
	@echo "📋 File sizes:"
	@du -sh $(APP_DIR)
	@du -sh $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).zip
	@du -sh $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg
	@echo ""
	@echo "🚀 Ready to upload to GitHub Release!"

.DEFAULT_GOAL := help
