# FreeBSD Ports Makefile for net/totaldrop-qt6 (Wayland Qt 6 Desktop App on amd64)

PORTNAME=	totaldrop-qt6
DISTVERSIONPREFIX=	linux-v
DISTVERSION=	0.3.0-beta.6
CATEGORIES=	net wayland

MAINTAINER=	hello@totaldrop.app
COMMENT=	Native Wayland Qt 6 desktop client for TotalDrop encrypted file transfer
WWW=		https://totaldrop.app

LICENSE=	APACHE20 GPLv3RLE MIT
LICENSE_COMB=	multi

ONLY_FOR_ARCHS=	amd64 aarch64

LIB_DEPENDS=	libdbus-1.so:devel/dbus \
		libwayland-client.so:graphics/wayland
RUN_DEPENDS=	xdg-desktop-portal>0:deskutils/xdg-desktop-portal

USES=		cargo pkgconfig qt:6
USE_GITHUB=	yes
GH_ACCOUNT=	totaldrop-app
GH_PROJECT=	totaldrop
USE_QT=		base declarative svg wayland

MAKE_ENV=	CXX_QT_AUTORCC_OPTIONS="--format-version:1:--no-zstd"
CARGO_BUILD_ARGS=	--package totaldrop-linux
CARGO_INSTALL_PATH=	linux

PLIST_FILES=	bin/totaldrop-desktop \
		share/applications/app.totaldrop.TotalDrop.desktop \
		share/metainfo/app.totaldrop.TotalDrop.metainfo.xml

.include <bsd.port.mk>
