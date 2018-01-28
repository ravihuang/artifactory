FROM tomcat:7-jre7

MAINTAINER Matthias Grüter <matthias@grueter.name>

# To update, check https://bintray.com/jfrog/artifactory/jfrog-artifactory-oss-zip/view
ENV ARTIFACTORY_VERSION 5.8.3
ENV ARTIFACTORY_SHA256 c84e19779b3a7e62b86fdd3a71ba6b975838ac4f4531379d284290cc28637461

# Disable Tomcat's manager application.
RUN rm -rf webapps/*

# Redirect URL from / to artifactory/ using UrlRewriteFilter
COPY urlrewrite/WEB-INF/lib/urlrewritefilter.jar /
COPY urlrewrite/WEB-INF/urlrewrite.xml /
RUN \
  mkdir -p webapps/ROOT/WEB-INF/lib && \
  mv /urlrewritefilter.jar webapps/ROOT/WEB-INF/lib && \
  mv /urlrewrite.xml webapps/ROOT/WEB-INF/

# Fetch and install Artifactory OSS war archive.
RUN \
  echo $ARTIFACTORY_SHA256 artifactory.zip > artifactory.zip.sha256 && \
  curl -L -o artifactory.zip https://bintray.com/jfrog/artifactory/download_file?file_path=jfrog-artifactory-oss-5.8.3.zip && \
  sha256sum -c artifactory.zip.sha256 && \
  unzip -j artifactory.zip "artifactory-*/webapps/artifactory.war" -d webapps && \
  rm artifactory.zip

# Expose tomcat runtime options through the RUNTIME_OPTS environment variable.
#   Example to set the JVM's max heap size to 256MB use the flag
#   '-e RUNTIME_OPTS="-Xmx256m"' when starting a container.
RUN echo 'export CATALINA_OPTS="$RUNTIME_OPTS"' > bin/setenv.sh

# Artifactory home
RUN mkdir -p /artifactory
ENV ARTIFACTORY_HOME /artifactory

# Expose Artifactories data, log and backup directory.
VOLUME /artifactory/data
VOLUME /artifactory/logs
VOLUME /artifactory/backup

WORKDIR /artifactory
