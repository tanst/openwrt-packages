#
# Copyright (C) 2012-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nginx
PKG_VERSION:=1.31.2
PKG_RELEASE:=1

PKG_SOURCE:=nginx-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://nginx.org/download/
PKG_HASH:=skip

PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de> \
				Christian Marangi <ansuelsmth@gmail.com>
PKG_LICENSE:=2-clause BSD-like license
PKG_CPE_ID:=cpe:/a:nginx:nginx

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_BUILD_FLAGS:=gc-sections lto

# official modules
PKG_MOD_ALL := \
	stream

PKG_CONFIG_DEPENDS := \
	CONFIG_NGINX_STUB_STATUS \
	CONFIG_NGINX_HTTP_CHARSET \
	CONFIG_NGINX_HTTP_GZIP \
	CONFIG_NGINX_HTTP_GZIP_STATIC \
	CONFIG_NGINX_HTTP_ACCESS \
	CONFIG_NGINX_HTTP_AUTH_BASIC \
	CONFIG_NGINX_HTTP_AUTH_REQUEST \
	CONFIG_NGINX_HTTP_MAP \
	CONFIG_NGINX_HTTP_REWRITE \
	CONFIG_NGINX_HTTP_PROXY \
	CONFIG_NGINX_HTTP_LIMIT_CONN \
	CONFIG_NGINX_HTTP_LIMIT_REQ \
	CONFIG_NGINX_HTTP_UPSTREAM_HASH \
	CONFIG_NGINX_HTTP_UPSTREAM_IP_HASH \
	CONFIG_NGINX_HTTP_UPSTREAM_LEAST_CONN \
	CONFIG_NGINX_HTTP_UPSTREAM_KEEPALIVE \
	CONFIG_NGINX_HTTP_CACHE \
	CONFIG_NGINX_HTTP_V2 \
	CONFIG_NGINX_HTTP_QUIC \
	CONFIG_NGINX_PCRE \
	CONFIG_NGINX_HTTP_REAL_IP \
	CONFIG_NGINX_HTTP_SECURE_LINK \
	CONFIG_NGINX_HTTP_SUB \
	CONFIG_NGINX_STREAM_REAL_IP \
	CONFIG_OPENSSL_ENGINE \
	CONFIG_OPENSSL_WITH_NPN

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/nginx/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Nginx web server
  URL:=http://nginx.org/
  DEPENDS:=+libopenssl +libpthread
  # TODO: add PROVIDES when removing nginx
  # PROVIDES:=nginx
endef

define Package/nginx/description
 nginx is an HTTP and reverse proxy server, as well as a mail proxy server, \
 written by Igor Sysoev.
endef

define Package/nginx/conffiles
/etc/nginx/
endef

define Package/nginx-ssl
  $(Package/nginx/default)
  TITLE += with SSL support
  VARIANT:=ssl
  DEPENDS+= +NGINX_PCRE:libpcre2 \
	+NGINX_HTTP_GZIP:zlib
  CONFLICTS:=nginx-full
endef

Package/nginx-ssl/description = $(Package/nginx/description) \
  This variant is compiled with SSL support enabled. To enable additional module \
  select them in the nginx default configuration menu.

define Package/nginx-ssl/config
  source "$(SOURCE)/Config_ssl.in"
endef

Package/nginx-ssl/conffiles = $(Package/nginx/conffiles)

IsEnabled = $(or $(filter full,$(BUILD_VARIANT)),$(CONFIG_$(1)))
IsDisabled = $(if $(call IsEnabled,$(1)),,1)

config_files := mime.types \
	$(if $(call IsEnabled,NGINX_HTTP_CHARSET),koi-utf koi-win win-utf)

define Package/nginx-ssl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nginx $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/nginx/module.d
	$(INSTALL_DIR) $(1)/etc/nginx/conf.d
	$(INSTALL_DATA) $(addprefix $(PKG_INSTALL_DIR)/etc/nginx/,$(config_files)) $(1)/etc/nginx/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nginx.init $(1)/etc/init.d/nginx
	$(INSTALL_CONF) ./files/nginx.conf $(1)/etc/nginx/
	$(INSTALL_CONF) ./files/default.conf $(1)/etc/nginx/conf.d
endef

define Package/nginx-ssl/prerm
#!/bin/sh
[ -z "$${IPKG_INSTROOT}" ] || exit 0
[ "$${PKG_UPGRADE}" = "1" ] && exit 0
eval $$(/usr/bin/nginx-util get_env)
[ "$$(uci get "nginx.$${LAN_NAME}.$${MANAGE_SSL}")" = "self-signed" ] || exit 0
rm -f "$$(uci get "nginx.$${LAN_NAME}.ssl_certificate")"
rm -f "$$(uci get "nginx.$${LAN_NAME}.ssl_certificate_key")"
exit 0
endef

define Package/nginx-full
  $(Package/nginx/default)
  TITLE += with ALL config selected
  DEPENDS+=+libpcre2 +zlib
  VARIANT:=full
  PROVIDES += nginx-ssl
endef

Package/nginx-full/description = $(Package/nginx/description) \
  This variant is compiled with ALL config selected.

Package/nginx-full/install = $(Package/nginx-ssl/install)

Package/nginx-full/prerm = $(Package/nginx-ssl/prerm)

Package/nginx-full/conffiles = $(Package/nginx/conffiles)



define Quilt/Refresh/Package
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/nginx,nginx/)
endef

define Build/Patch
	$(if $(QUILT),rm -rf $(PKG_BUILD_DIR)/patches; mkdir -p $(PKG_BUILD_DIR)/patches)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/nginx,nginx/)
	$(if $(QUILT),touch $(PKG_BUILD_DIR)/.quilt_used)
endef

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	$(PKG_UNPACK)
	$(Build/Patch)
endef

# $(1) module name
# $(2) module additional dependency
# $(3) module so name (stripped of the finaly _module.so)
# $(4) module description
define BuildModule
  define Package/nginx-mod-$(1)
    $(call Package/nginx/default)
    DEPENDS:=+nginx-ssl $(2)
    TITLE:=Nginx $(1) module
  endef

  define Package/nginx-mod-$(1)/description
    $(strip $(4))
  endef

  define Package/nginx-mod-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/nginx/modules
	$(INSTALL_DIR) $$(1)/etc/nginx/module.d
	$(foreach m,$(3),
	  $(CP) $$(PKG_INSTALL_DIR)/usr/lib/nginx/modules/$(m)_module.so $$(1)/usr/lib/nginx/modules && \
	  echo "load_module /usr/lib/nginx/modules/$(m)_module.so;" > $$(1)/etc/nginx/module.d/$(m).module
	)
	$(call Module/nginx-mod-$(1)/install,$$(1))
  endef

  $$(eval $$(call BuildPackage,nginx-mod-$(1)))
endef

CONFIGURE_VARS += CONFIG_BIG_ENDIAN=$(CONFIG_BIG_ENDIAN)

CONFIGURE_ARGS += \
	--crossbuild=Linux::$(ARCH) \
	--prefix=/usr \
	--conf-path=/etc/nginx/nginx.conf \
	--modules-path=/usr/lib/nginx/modules \
	--error-log-path=stderr \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/lock/nginx.lock \
	--http-log-path=/var/log/nginx/access.log \
	--http-client-body-temp-path=/var/lib/nginx/body \
	--http-proxy-temp-path=/var/lib/nginx/proxy \
	--with-cc="$(TARGET_CC)" \
	--with-ld-opt="$(TARGET_LDFLAGS)" \
	--without-http_upstream_zone_module \
	--with-compat \
	--with-http_ssl_module \
	--without-http_ssi_module \
	--without-http_userid_module \
	--without-http_autoindex_module \
	--without-http_geo_module \
	--without-http_split_clients_module \
	--without-http_referer_module \
	--without-http_fastcgi_module \
	--without-http_uwsgi_module \
	--without-http_scgi_module \
	--without-http_memcached_module \
	--without-http_empty_gif_module \
	--without-http_browser_module \
	--without-http_flv_module \
	--without-http_dav_module \
	$(if $(call IsDisabled,NGINX_HTTP_CACHE),--without-http-cache) \
	$(if $(call IsDisabled,NGINX_PCRE),--without-pcre) \
	$(if $(call IsDisabled,NGINX_HTTP_CHARSET),--without-http_charset_module) \
	$(if $(call IsDisabled,NGINX_HTTP_GZIP),--without-http_gzip_module) \
	$(if $(call IsDisabled,NGINX_HTTP_ACCESS),--without-http_access_module) \
	$(if $(call IsDisabled,NGINX_HTTP_AUTH_BASIC),--without-http_auth_basic_module) \
	$(if $(call IsDisabled,NGINX_HTTP_MAP),--without-http_map_module) \
	$(if $(call IsDisabled,NGINX_HTTP_REWRITE),--without-http_rewrite_module) \
	$(if $(call IsDisabled,NGINX_HTTP_PROXY),--without-http_proxy_module) \
	$(if $(call IsDisabled,NGINX_HTTP_LIMIT_CONN),--without-http_limit_conn_module) \
	$(if $(call IsDisabled,NGINX_HTTP_LIMIT_REQ),--without-http_limit_req_module) \
	$(if $(call IsDisabled,NGINX_HTTP_UPSTREAM_HASH),--without-http_upstream_hash_module) \
	$(if $(call IsDisabled,NGINX_HTTP_UPSTREAM_IP_HASH),--without-http_upstream_ip_hash_module) \
	$(if $(call IsDisabled,NGINX_HTTP_UPSTREAM_LEAST_CONN),--without-http_upstream_least_conn_module) \
	$(if $(call IsDisabled,NGINX_HTTP_UPSTREAM_KEEPALIVE),--without-http_upstream_keepalive_module) \
	$(if $(call IsEnabled,IPV6),--with-ipv6) \
	$(if $(call IsEnabled,NGINX_HTTP_GZIP_STATIC),--with-http_gzip_static_module) \
	$(if $(call IsEnabled,NGINX_STUB_STATUS),--with-http_stub_status_module) \
	$(if $(call IsEnabled,NGINX_HTTP_AUTH_REQUEST),--with-http_auth_request_module) \
	$(if $(call IsEnabled,NGINX_HTTP_QUIC),--with-http_v3_module) \
	$(if $(call IsEnabled,NGINX_HTTP_V2),--with-http_v2_module) \
	$(if $(call IsEnabled,NGINX_HTTP_REAL_IP),--with-http_realip_module) \
	$(if $(call IsEnabled,NGINX_HTTP_SECURE_LINK),--with-http_secure_link_module) \
	$(if $(call IsEnabled,NGINX_HTTP_SUB),--with-http_sub_module) \
	$(if $(CONFIG_PACKAGE_nginx-mod-stream),--with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module) \
	$(if $(call IsEnabled,NGINX_STREAM_REAL_IP),--with-stream_realip_module)

$(eval $(call BuildPackage,nginx-ssl))
$(eval $(call BuildPackage,nginx-full))
$(eval $(call BuildModule,stream,+@NGINX_STREAM_CORE_MODULE, \
	ngx_stream, Add support for NGINX request streaming.))
