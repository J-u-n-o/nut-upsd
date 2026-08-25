FROM alpine:3.24

# Metadata params
ARG VCS_REF
ARG BUILD_DATE

# https://networkupstools.org/download.html
ENV NUT_VERSION_RANGE="2.8"
ENV NUT_VERSION="2.8.5"
ENV NUT_SHA256="18bf32e59eb764b13da3c4fa70384926d7fa584cb31d2fe7f137a570633eeec1"

ENV SHUTDOWN_CMD="echo 'System shutdown not configured!'"

# Metadata
LABEL org.label-schema.vendor="J-u-n-o" \
	org.label-schema.url="https://github.com/J-u-n-o/nut-upsd#readme" \
	org.label-schema.name="gh-deployer container" \
	org.label-schema.description="UPS daemon" \
	org.label-schema.version=${NUT_VERSION} \
	org.label-schema.vcs-url="https://github.com/J-u-n-o/nut-upsd.git" \
	org.label-schema.vcs-ref=${VCS_REF} \
	org.label-schema.build-date=${BUILD_DATE} \
	org.label-schema.docker.schema-version="1.0"

# Find similar config in: https://git.alpinelinux.org/aports/tree/testing/nut/APKBUILD?id=17c662d69ebf24fbff2fa065d7544863ada956a5
# Dependencies install
RUN set -ex; \
	# run dependencies
	apk add --update  --no-cache \
		shadow \
		openssh-client \
		libtool \
		libusb \
		libusb-compat \
		nss \
	; \
	# build dependencies
	apk add --update --no-cache --virtual .build-deps \
		libtool \
		libusb-dev \
		libusb-compat-dev \
		avahi-dev \
		avahi-libs \
		net-snmp-dev \
		openssl-dev \
		nss-dev \
		neon-dev \
		build-base \
	;

# Nut installation
RUN set -ex; \
	# download and extract
	cd /tmp; \
	printf "%s  nut-${NUT_VERSION}.tar.gz\n" "$NUT_SHA256" > nut-$NUT_VERSION.tar.gz.sha256; \
	wget https://www.networkupstools.org/source/$NUT_VERSION_RANGE/nut-$NUT_VERSION.tar.gz; \
	tar xfz nut-$NUT_VERSION.tar.gz; \
	sha256sum -c -w nut-$NUT_VERSION.tar.gz.sha256; \
	cd nut-$NUT_VERSION \
	; \
	# build
	./configure \
		--prefix=/usr \
		--sysconfdir=/etc/nut \
		--localstatedir=/var \
		--with-all=auto \
		--with-usb=libusb-1.0 \
		--with-ssl=openssl \
		--with-user=nut \
		--with-group=nut \
		--with-statepath=/var/lib/nut \
		--with-altpidpath=/run/nut \
		--with-pidpath=/run/nut \
		--with-rundir=/run/nut \
		--with-pkgconfig-dir=/usr/lib/x86_64-linux-gnu/pkgconfig \
		--with-doc=no \
		--with-nut-scanner=yes \
	; \
	# install
	make install \
	; \
	# create nut user
	adduser -D -h /var/run/nut nut; \
	chgrp -R nut /etc/nut; \
	chmod -R o-rwx /etc/nut; \
	install -d -m 750 -o nut -g nut /var/run/nut \
	; \
	install -d -m 755 -o nut -g nut /var/lib/nut \
    ; \
	# cleanup
	rm -r /tmp/nut-$NUT_VERSION.tar.gz /tmp/nut-$NUT_VERSION.tar.gz.sha256 /tmp/nut-$NUT_VERSION; \
	rm -r /usr/share/man/man5 /usr/share/man/man8; \
	apk del .build-deps    

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

WORKDIR /var/run/nut

EXPOSE 3493
