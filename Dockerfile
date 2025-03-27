FROM ca0abinary/docker-pentaho AS sources

FROM openjdk:7-jre-alpine
MAINTAINER Jonathan DeMarks
# Based on work done by Wellington Marinho (https://github.com/wmarinho/docker-pentaho)
# Note: Really, really requires Postgres 9.5, any higher version will break without an updated driver (in commented section below).

ENV MAJOR_VERSION 7.0
ENV MINOR_VERSION 7.0.0.0-25
ENV PENTAHO_HOME /opt/pentaho
ENV PENTAHO_JAVA_HOME $JAVA_HOME
ENV PENTAHO_SERVER ${PENTAHO_HOME}/server/pentaho-server
ENV CATALINA_OPTS="-Djava.awt.headless=true -Xms4096m -Xmx6144m -XX:MaxPermSize=256m -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000"

# Get support packages
RUN apk add --update wget unzip bash postgresql-client ttf-dejavu

# Setup pentaho user
RUN mkdir -p ${PENTAHO_HOME}/server; mkdir ${PENTAHO_HOME}/.pentaho; adduser -D -s /bin/sh -h ${PENTAHO_HOME} pentaho; chown -R pentaho:pentaho ${PENTAHO_HOME}
USER pentaho
WORKDIR ${PENTAHO_HOME}/server

# Get Pentaho Server
COPY --from=sources /opt/pentaho/server ${PENTAHO_HOME}/server

# Copy scripts and fix permissions
USER root
COPY scripts ${PENTAHO_HOME}/scripts
COPY config ${PENTAHO_HOME}/config
RUN chown -R pentaho:pentaho ${PENTAHO_HOME}/scripts && chmod -R +x ${PENTAHO_HOME}/scripts
USER pentaho

# Volumes:
# Administration and user accounts:
#   /opt/pentaho/server/pentaho-server/data/hsqldb
# Jackrabbit document repository:
#   /opt/pentaho/server/pentaho-server/pentaho-solutions/system/jackrabbit/repository
VOLUME [ '/opt/pentaho/server/pentaho-server/data/hsqldb', '/opt/pentaho/server/pentaho-server/pentaho-solutions/system/jackrabbit/repository' ]

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "$PENTAHO_HOME/scripts/run.sh"]
