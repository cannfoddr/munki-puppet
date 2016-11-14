FROM nginx:alpine
MAINTAINER Adrian Merwood "adrian@adrian-merwood.net"

ENV PUPPET_VERSION="4.6.2" FACTER_VERSION="2.4.6"

LABEL org.label-schema.vendor="Puppet" \
      org.label-schema.url="https://github.com/cannfoddr/munki-puppet" \
      org.label-schema.name="Munki server with Puppet 4.x for certificates" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version=$PUPPET_VERSION \
      org.label-schema.vcs-url="https://github.com/cannfoddr/munki-puppet" \
#      org.label-schema.vcs-ref="791b5505348e901a21b2ca2700068e2743019848" \
      org.label-schema.build-date="2016-11-14T14:55:00Z" \
      org.label-schema.schema-version="1.0" \
      com.puppet.dockerfile="/Dockerfile"

RUN apk add --update \
      ca-certificates \
      pciutils \
      ruby \
      ruby-irb \
      ruby-rdoc \
      && \
    echo http://dl-4.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories && \
    apk add --update shadow && \
    rm -rf /var/cache/apk/* && \
    gem install puppet:"$PUPPET_VERSION" facter:"$FACTER_VERSION" && \
    /usr/bin/puppet module install puppetlabs-apk
	
RUN mkdir -p /munki_repo && \
      mkdir -p /etc/nginx/sites-enabled/

ADD nginx.conf /etc/nginx/nginx.conf
ADD munki-repo.conf /etc/nginx/sites-enabled/

VOLUME /munki_repo

EXPOSE 443

# Workaround for https://tickets.puppetlabs.com/browse/FACT-1351
RUN rm /usr/lib/ruby/gems/2.3.0/gems/facter-"$FACTER_VERSION"/lib/facter/blockdevices.rb

COPY Dockerfile /