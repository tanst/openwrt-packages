# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) Toy

include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.70.0
PKG_RELEASE:=1

# 自动映射 OpenWrt 架构到 frp 的官方架构命名 (如 aarch64 -> arm64)
ifeq ($(ARCH),aarch64)
  FRP_ARCH:=arm64
else ifeq ($(ARCH),x86_64)
  FRP_ARCH:=amd64
else ifeq ($(ARCH),arm)
  FRP_ARCH:=arm
else ifeq ($(ARCH),mipsel)
  FRP_ARCH:=mipsle
else
  FRP_ARCH:=$(ARCH)
endif

# frp 官方包的命名格式为：frp_0.69.1_linux_arm64.tar.gz
PKG_TAR_NAME:=frp_$(PKG_VERSION)_linux_$(FRP_ARCH)
PKG_SOURCE:=$(PKG_TAR_NAME).tar.gz
PKG_SOURCE_URL:=https://github.com/fatedier/frp/releases/download/v$(PKG_VERSION)/
PKG_HASH:=skip

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

# 对应解压后的目录名
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_TAR_NAME)

include $(INCLUDE_DIR)/package.mk

# 彻底删除了 PKG_BUILD_DEPENDS:=golang/host node/host 和相关 GO_PKG 变量

define Build/Configure
endef

# 提取核心步骤，可选择启用 UPX 极限压缩
define Build/Compile
	# 为克服路由器的 overlay 空间限制，强烈建议对体积较大的 frpc 和 frps 进行压缩。
	# 确认你的编译系统已安装 upx 后，取消下方两行的注释即可：
	# upx --best $(PKG_BUILD_DIR)/frpc
	# upx --best $(PKG_BUILD_DIR)/frps
endef

# 直接从解压目录拷贝对应的二进制文件 ($(2) 代表 frpc 或 frps)
define Package/frp/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(2) $(1)/usr/bin/
endef

define Package/frp/template
  define Package/$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=$(1) - fast reverse proxy $(2) (Pre-compiled)
    URL:=https://github.com/fatedier/frp
    # 移除了 DEPENDS:=$(GO_ARCH_DEPENDS)，因为直接下发二进制包不再依赖 Go 环境校验
  endef

  define Package/$(1)/description
    $(1) is a fast reverse proxy $(2) that helps you expose a local server
    behind a NAT or firewall to the internet.
  endef

  define Package/$(1)/install
    $(call Package/frp/install,$$(1),$(1))
  endef
endef

$(eval $(call Package/frp/template,frpc,client))
$(eval $(call Package/frp/template,frps,server))
$(eval $(call BuildPackage,frpc))
$(eval $(call BuildPackage,frps))