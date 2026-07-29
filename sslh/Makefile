#
# Copyright (C) 2009-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=sslh
PKG_VERSION:=2.3.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://rutschle.net/tech/sslh/
PKG_HASH:=51a5516ec5cb01823633b4d8cacdeee4efa0c56ef620d1c996d4f52ca51a601b

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_MAINTAINER:=Jonathan McCrohan <jmccrohan@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/sslh
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	TITLE:=SSL/SSH multiplexer (minimal, sslh-fork binary only)
	DEPENDS:=+libconfig +libcap +libpcre2 +libproxyprotocol
	URL:=https://rutschle.net/tech/sslh/README.html
endef

MAKE_FLAGS += \
	USELIBCAP=1 \
	USE_PROXYPROTOCOL=1

define Build/Compile
	$(call Build/Compile/Default,sslh-fork)
endef

define Package/sslh/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sslh-fork $(1)/usr/sbin/sslh
endef

$(eval $(call BuildPackage,sslh))
