BUILD_VERSION   = 1.0.0
BUILD_NOTES     = UAT 环境
FIREBASE_APP_ID = 1:45242611620:ios:04e0e22ea7a2bea434f331
# 运行 `firebase login:ci` 获取 token，然后传入：make distribute FIREBASE_TOKEN=xxx
FIREBASE_TOKEN  ?=

BREW_RUBY      = /opt/homebrew/opt/ruby/bin
BREW_RUBY_GEMS = /opt/homebrew/lib/ruby/gems/4.0.0/bin
BUNDLE         = $(BREW_RUBY)/bundle

.PHONY: distribute setup

## 首次使用：安装 Fastlane 及插件
setup:
	cd ios && PATH="$(BREW_RUBY_GEMS):$(BREW_RUBY):$$PATH" $(BUNDLE) install

## 打包并上传到 Firebase App Distribution
## 覆盖默认值：make distribute BUILD_VERSION=1.2.0 BUILD_NOTES="修复登录问题"
distribute:
	cd ios && PATH="$(BREW_RUBY_GEMS):$(BREW_RUBY):$$PATH" \
		FIREBASE_APP_ID="$(FIREBASE_APP_ID)" \
		FIREBASE_TOKEN="$(FIREBASE_TOKEN)" \
		$(BUNDLE) exec fastlane distribute \
		version:"$(BUILD_VERSION)" \
		notes:"$(BUILD_NOTES)" \
		env_file:"../.env.json"
