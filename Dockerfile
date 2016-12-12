FROM ubuntu:16.04

# Install required software packages:

RUN apt-get update
RUN apt-get install -y -y maven git openjdk-8-jdk openjdk-8-jre-headless tomcat7 postgresql-client
RUN apt-get install -y -y tomcat7-admin wget unzip

# Configure tomcat7-admin (please change the passwords to your needs):

RUN cp /var/lib/tomcat7/conf/tomcat-users.xml /var/lib/tomcat7/conf/tomcat-users.xml.orig
RUN echo "<?xml version='1.0' encoding='utf-8'?>" > /var/lib/tomcat7/conf/tomcat-users.xml 
RUN echo "<tomcat-users>" >> /var/lib/tomcat7/conf/tomcat-users.xml 
RUN echo '<role rolename="manager-gui"/>' >> /var/lib/tomcat7/conf/tomcat-users.xml 
RUN echo '<user username="manager" password="manager" roles="manager-gui"/>' >> /var/lib/tomcat7/conf/tomcat-users.xml 
RUN echo "</tomcat-users>" >> /var/lib/tomcat7/conf/tomcat-users.xml 

# Expose port 8080 to the client:

EXPOSE 8080

# Register Maven repository from Mainz:

COPY settings.xml /root/.m2/

# Checkout source code and build it:

RUN git clone https://bitbucket.org/medinfo_mainz/mainzelliste.git
WORKDIR mainzelliste
RUN mvn clean install
RUN cp target/mainzelliste-1.5.0.war /var/lib/tomcat7/webapps/

# Download necessary Java libraries:

RUN wget https://jdbc.postgresql.org/download/postgresql-9.4.1208.jar
RUN wget http://repo1.maven.org/maven2/com/sun/jersey/jersey-archive/1.17.1/jersey-archive-1.17.1.zip
RUN unzip jersey-archive-1.17.1.zip

# Configure tomcat (see Mainzelliste documentation about that):

RUN mkdir -p /home/tomcat7/.java/.systemPrefs 
RUN mkdir /home/tomcat7/.java/.userPrefs 
RUN chmod -R 755 /home/tomcat7/.java 
RUN chown -R tomcat7:tomcat7 /home/tomcat7 
COPY tomcat7.defaults /etc/defaults/tomcat7

# Upload the default Mainzelliste configuration:

RUN mkdir /etc/mainzelliste
COPY mainzelliste.conf /etc/mainzelliste/mainzelliste.conf

# Installation of the Mainzelliste-Client (this is not a GUI, but a http-interface):

#WORKDIR /
#RUN git clone https://bitbucket.org/medinfo_mainz/mainzelliste.client.git
#WORKDIR mainzelliste.client
#RUN mvn clean package

CMD /bin/bash
