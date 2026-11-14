# OpenBSD Ports Makefile for net/totaldrop (arm64 / aarch64)

COMMENT =		end-to-end encrypted peer-to-peer file transfer CLI (ARM64)

GH_ACCOUNT =		totaldrop-app
GH_PROJECT =		totaldrop
GH_TAGNAME =		cli-v0.2.0-beta.5
PKGNAME =		totaldrop-0.2.0beta5

CATEGORIES =		net security
HOMEPAGE =		https://totaldrop.app
MAINTAINER =		TotalDrop Contributors <hello@totaldrop.app>

# CLI: GPLv3+; core/crypto/proto/l10n: MIT OR Apache-2.0
PERMIT_PACKAGE =	Yes

ONLY_FOR_ARCHS =	aarch64

WANTLIB +=		c c++abi m pthread

MODULES =		devel/cargo
MODCARGO_CARGO_BIN =	${LOCALBASE}/bin/cargo
MODCARGO_BUILD_ARGS =	--package totaldrop-cli
MODCARGO_INSTALL_TARGET_PATHS = crates/totaldrop-cli

SEPARATE_BUILD =	Yes

post-install:
	${INSTALL_DATA_DIR} ${PREFIX}/share/doc/totaldrop
	${INSTALL_DATA} ${WRKSRC}/LICENSES/GPL-3.0-or-later.txt \
		${WRKSRC}/LICENSES/MIT.txt \
		${WRKSRC}/LICENSES/Apache-2.0.txt \
		${PREFIX}/share/doc/totaldrop/

.include <bsd.port.mk>
