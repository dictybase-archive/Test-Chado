FROM perl:5.20
MAINTAINER Siddhartha Basu <siddhartha-basu@northwestern.edu>

RUN apt-get update \
    && apt-get -y install libdb-dev \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ADD cpanfile /tmp/
ADD dist.ini /tmp/
RUN cd /tmp \
    && cpanm -n --quiet --installdeps . \
    && cpanm -n --quiet DBD::Pg Dist::Zilla  \
    && dzil authordeps --missing | cpanm -n --quiet  \
    && rm -rf /tmp/*
WORKDIR /usr/src/test-chado
ENV HARNESS_OPTIONS j6
CMD perl Build.PL && ./Build test
