FROM alpine:3.8

ENV JMETER_VERSION 5.0
ENV JMETER_PLUGINS_MANAGER_VERSION 1.3
ENV CMDRUNNER_VERSION 2.2

ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN ${JMETER_HOME}/bin
ENV JMETER_LIB_FOLDER ${JMETER_HOME}/lib
ENV JMETER_PLUGINS_FOLDER ${JMETER_HOME}/lib/ext
ENV PATH $PATH:$JMETER_BIN

ENV JMETER_MIRROR_HOST https://www-us.apache.org/dist/jmeter
ENV JMETER_DOWNLOAD_URL ${JMETER_MIRROR_HOST}/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_PLUGINS_DOWNLOAD_URL http://repo1.maven.org/maven2/kg/apc

RUN apk update \
  && apk upgrade \
  && apk add ca-certificates \
  && update-ca-certificates \
  && apk add --update openjdk8-jre curl unzip bash \
  && rm -rf /var/cache/apk/*

RUN mkdir -p /tmp/jmeterinstaller  \
  && curl --location --silent --show-error ${JMETER_DOWNLOAD_URL} \
    --output /tmp/jmeterinstaller/apache-jmeter-${JMETER_VERSION}.tgz  \
  && mkdir -p /opt  \
  && tar -xzf /tmp/jmeterinstaller/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
  && rm -rf /tmp/jmeterinstaller

RUN mkdir -p /tmp/jmeterplugins \
  && cd /tmp/jmeterplugins \
  && curl --location --silent --show-error \
      ${JMETER_PLUGINS_DOWNLOAD_URL}/jmeter-plugins-manager/${JMETER_PLUGINS_MANAGER_VERSION}/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar \
        --output ${JMETER_PLUGINS_FOLDER}/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar \
  && curl --location --silent --show-error \
      ${JMETER_PLUGINS_DOWNLOAD_URL}/cmdrunner/${CMDRUNNER_VERSION}/cmdrunner-${CMDRUNNER_VERSION}.jar \
        --output ${JMETER_LIB_FOLDER}/cmdrunner-${CMDRUNNER_VERSION}.jar \
  && java -cp ${JMETER_PLUGINS_FOLDER}/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
  && PluginsManagerCMD.sh install \
    jpgc-casutg=2.6, \
    jpgc-graphs-basic=2.0, \
    jpgc-tst=2.5 \
  && PluginsManagerCMD.sh status \
  && jmeter --version \
  && rm -rf /tmp/jmeterplugins
