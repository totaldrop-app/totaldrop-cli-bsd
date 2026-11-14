# FreeBSD Ports Makefile for net/totaldrop-cli (amd64 / x86_64)

PORTNAME=	totaldrop-cli
DISTVERSIONPREFIX=	cli-v
DISTVERSION=	0.2.0-beta.5
CATEGORIES=	net security

MAINTAINER=	hello@totaldrop.app
COMMENT=	End-to-end encrypted peer-to-peer file transfer CLI
WWW=		https://totaldrop.app

LICENSE=	APACHE20 GPLv3RLE MIT
LICENSE_COMB=	multi
LICENSE_FILE_APACHE20=	${WRKSRC}/LICENSES/Apache-2.0.txt
LICENSE_FILE_GPLv3RLE=	${WRKSRC}/LICENSES/GPL-3.0-or-later.txt
LICENSE_FILE_MIT=	${WRKSRC}/LICENSES/MIT.txt

ONLY_FOR_ARCHS=	amd64 aarch64
ONLY_FOR_ARCHS_REASON=	Tested and supported on 64-bit FreeBSD x86_64 and arm64

USES=		cargo
USE_GITHUB=	yes
GH_ACCOUNT=	totaldrop-app
GH_PROJECT=	totaldrop

CARGO_BUILD_ARGS=	--package totaldrop-cli
CARGO_INSTALL_PATH=	crates/totaldrop-cli

USE_RC_SUBR=	totaldrop

PLIST_FILES=	bin/totaldrop

.include <bsd.port.mk>
