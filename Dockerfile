FROM suchja/wine:latest
MAINTAINER Jonata Weber <jonataa@gmail.com>

# get at least error information from wine
ENV WINEDEBUG -all,err+all

# unfortunately we later need to wait on wineserver. Thus a small script for waiting is supplied.
USER root
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		cabextract \
		xvfb
ADD waitonprocess.sh /scripts/
RUN chmod a+x /scripts/waitonprocess.sh

# Install Visual C++ Runtime 2013
USER xclient
RUN xvfb-run -a wine wineboot --init \
		&& /scripts/waitonprocess.sh wineserver
RUN xvfb-run -a winetricks --unattended vcrun2013\
		&& /scripts/waitonprocess.sh wineserver
RUN mkdir -p /home/xclient/zxpsign/bin
RUN curl -SL "https://github.com/Adobe-CEP/CEP-Resources/raw/master/ZXPSignCMD/3.0.30/win32/ZXPSignCmd.exe" -o /home/xclient/zxpsign/bin/ZXPSignCmd.exe

USER root
ADD docker-entrypoint.sh /scripts/
RUN chmod a+x /scripts/docker-entrypoint.sh

USER xclient
RUN mkdir /home/xclient/zxpsign/src
WORKDIR /home/xclient/zxpsign/src

ENTRYPOINT ["/scripts/docker-entrypoint.sh"]


