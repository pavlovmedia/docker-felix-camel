FROM sdempsay/docker-java8
MAINTAINER Shawn Dempsay <shawn@dempsay.org>

ENV DEBIAN_FRONTEND noninteractive

# Set the top level version for things
# Felix
ENV felix_version 5.4.0
ENV felix_package=org.apache.felix.main.distribution-${felix_version}.tar.gz
ENV felix_base http://repo1.maven.org/maven2/org/apache/felix

# Camel
ENV camel_version 2.16.1
ENV camel_base http://repo1.maven.org/maven2/org/apache/camel/

## Install felix
ADD ${felix_base}/org.apache.felix.main.distribution/${felix_version}/${felix_package} /tmp/
RUN mkdir -p /opt/felix && \
    cd /opt/felix && \
    tar xvzf /tmp/${felix_package} && \
    ln -s /opt/felix/felix-framework-${felix_version} /opt/felix/current

## Initial plugin set, this will get us up with a webconle, logging, scr, and web
ADD ${felix_base}/org.apache.felix.configadmin/1.8.6/org.apache.felix.configadmin-1.8.6.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.eventadmin/1.4.2/org.apache.felix.eventadmin-1.4.2.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.fileinstall/3.5.0/org.apache.felix.fileinstall-3.5.0.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.http.api/2.3.2/org.apache.felix.http.api-2.3.2.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.http.jetty/3.0.2/org.apache.felix.http.jetty-3.0.2.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.http.servlet-api/1.1.0/org.apache.felix.http.servlet-api-1.1.0.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.http.whiteboard/2.3.2/org.apache.felix.http.whiteboard-2.3.2.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.metatype/1.0.12/org.apache.felix.metatype-1.0.12.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.log/1.0.1/org.apache.felix.log-1.0.1.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.scr/1.8.2/org.apache.felix.scr-1.8.2.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.webconsole/4.2.8/org.apache.felix.webconsole-4.2.8-all.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.webconsole.plugins.ds/1.0.0/org.apache.felix.webconsole.plugins.ds-1.0.0.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.webconsole.plugins.event/1.1.2/org.apache.felix.webconsole.plugins.event-1.1.2.jar /opt/felix/current/bundle/

## Jax-RS and Jackson
ADD http://repo1.maven.org/maven2/com/eclipsesource/jaxrs/publisher/5.0/publisher-5.0.jar /opt/felix/current/bundle/
ADD http://repo1.maven.org/maven2/com/eclipsesource/jaxrs/jersey-all/2.18/jersey-all-2.18.jar /opt/felix/current/bundle/
ADD http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.4.0/jackson-core-2.4.0.jar /opt/felix/current/bundle/
ADD http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.4.0/jackson-annotations-2.4.0.jar /opt/felix/current/bundle/
ADD http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.4.0/jackson-databind-2.4.0.jar /opt/felix/current/bundle/

# Next up is camel
ADD ${camel_base}/camel-core/${camel_version}/camel-core-${camel_version}.jar /opt/felix/current/bundle/
ADD ${camel_base}/camel-core-osgi/${camel_version}/camel-core-osgi-${camel_version}.jar /opt/felix/current/bundle/
ADD ${camel_base}/camel-scr/${camel_version}/camel-scr-${camel_version}.jar /opt/felix/current/bundle/

# we need some support
ENV slf4j_version 1.7.13
ADD http://repo1.maven.org/maven2/org/slf4j/slf4j-api/${slf4j_version}/slf4j-api-${slf4j_version}.jar /opt/felix/current/bundle/
ADD http://repo1.maven.org/maven2/org/slf4j/slf4j-simple/${slf4j_version}/slf4j-simple-${slf4j_version}.jar /opt/felix/current/bundle/

# Sprinkle in some base configs
RUN echo 'felix.cm.dir=/opt/felix/current/configs' >> /opt/felix/current/conf/config.properties
RUN echo 'felix.fileinstall.start.level=2' >> /opt/felix/current/conf/config.properties
RUN echo 'org.osgi.framework.startlevel.beginning=2' >> /opt/felix/current/conf/config.properties
RUN echo 'org.osgi.framework.bootdelegation=sun.*,com.sun.*' >> /opt/felix/current/conf/config.properties
RUN mkdir -p /opt/felix/current/configs

VOLUME /opt/felix/current/configs
VOLUME /opt/felix/current/load

EXPOSE 8080
EXPOSE 8000

#
# Copy our startup script
#

COPY files/startFelix.sh /opt/felix/current/
CMD /opt/felix/current/startFelix.sh
