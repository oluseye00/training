FROM tomcat:latest
COPY ./webapp.war /usr/local/tomcat/webapps
#COPY is a container command
RUN cp -r /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
