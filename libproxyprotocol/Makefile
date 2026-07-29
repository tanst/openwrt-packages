include $(TOPDIR)/rules.mk

PKG_NAME:=libproxyprotocol
PKG_VERSION:=1.3.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/kosmas-valianos/libproxyprotocol.git
PKG_SOURCE_VERSION:=main
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=GPL-2.0-or-later
PKG_MAINTAINER:=Your Name <your.email@example.com>

include $(INCLUDE_DIR)/package.mk

define Package/libproxyprotocol
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=HAProxy ProxyProtocol library
  URL:=https://github.com/kosmas-valianos/libproxyprotocol
endef

define Build/Compile
	mkdir -p $(PKG_BUILD_DIR)/libs
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(FPIC) -DPIC" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		libs/libproxyprotocol.so
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libs/*.so* $(1)/usr/lib/ 2>/dev/null || true
endef

define Package/libproxyprotocol/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libs/*.so* $(1)/usr/lib/ 2>/dev/null || true
endef

$(eval $(call BuildPackage,libproxyprotocol))