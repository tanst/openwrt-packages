include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.69.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fatedier/frp/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=79a62c1071ddb947e95146ad7b1cb8b25f182fed548a4a8a68d5fca06b37502c

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

# 必须保留 node/host 用于编译 frp 自带的 Web 静态前端，否则会报 dist 错误
PKG_BUILD_DEPENDS:=golang/host node/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/fatedier/frp
GO_PKG_BUILD_PKG:=github.com/fatedier/frp/cmd/...
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=github.com/fatedier/frp/pkg/util/version.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

# 核心编译步骤：先编译前端网页，再编译 go 核心
define Build/Compile
	( \
		$(MAKE) -C $(PKG_BUILD_DIR)/web/frpc install ; \
		$(MAKE) -C $(PKG_BUILD_DIR)/web/frps install ; \
		$(MAKE) -C $(PKG_BUILD_DIR) web ; \
		$(call GoPackage/Build/Compile) ; \
	)
endef

# 提取核心：只创建 /usr/bin 并安装二进制文件，剔除 config, init.d 和 uci-defaults
define Package/frp/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/$(2) $(1)/usr/bin/
endef

define Package/frp/template
  define Package/$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=$(1) - fast reverse proxy $(2)
    URL:=https://github.com/fatedier/frp
    DEPENDS:=$(GO_ARCH_DEPENDS)
  endef

  define Package/$(1)/description
    $(1) is a fast reverse proxy $(2) that helps you expose a local server
    behind a NAT or firewall to the internet.
  endef

  # 删除了 define Package/$(1)/conffiles 段，不再视其为配置文件

  define Package/$(1)/install
    $(call Package/frp/install,$$(1),$(1))
  endef
endef

$(eval $(call Package/frp/template,frpc,client))
$(eval $(call Package/frp/template,frps,server))
$(eval $(call BuildPackage,frpc))
$(eval $(call BuildPackage,frps))
