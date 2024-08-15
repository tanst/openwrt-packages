include $(TOPDIR)/rules.mk

PKG_NAME:=q
PKG_VERSION:=0.19.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/natesales/q/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_MAINTAINER:=Toy <t@tanst.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/natesales/q
GO_PKG_BUILD_PKG:=$(GO_PKG)

GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/q
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=A tiny command-line DNS client
  URL:=https://github.com/natesales/q
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/q/description
  A tiny command line DNS client with support for UDP, TCP, DoT, DoH, DoQ and ODoH.
endef

define Package/q/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/q $(1)/usr/bin/q
endef

$(eval $(call GoBinPackage,q))
$(eval $(call BuildPackage,q))
