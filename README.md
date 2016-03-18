tomcat-dev
==========

![](http://tomcat.apache.org/images/tomcat-power.gif)

Installs and configures Apache Tomcat 6.

Version 2.3-39p
-------------

[![Install](https://raw.github.com/qubell-bazaar/component-skeleton/master/img/install.png)](https://express.tonomi.com/applications/upload?metadataUrl=https://raw.github.com/qubell-bazaar/component-tomcat-dev/2.3-39p/meta.yml)

Features
--------

 - Install and configure Tomcat in parallel on multiple compute
 - Deploy and update code in parallel (WAR file to a chosen context, all servers at once)
 - Scale out and back in
 - Stop and restart Tomcat services

Configurations
--------------
 - Tomcat 6.x (latest), CentOS 6.3 (us-east-1/ami-eb6b0182), AWS EC2 m1.small, root
 - Tomcat 6.x (latest), CentOS 5.3 (us-east-1/ami-beda31d7), AWS EC2 m1.small, root
 - Tomcat 6.x (latest), Ubuntu 12.04 (us-east-1/ami-d0f89fb9), AWS EC2 m1.small, ubuntu 
 - Tomcat 6.x (latest), Ubuntu 10.04 (us-east-1/ami-0fac7566), AWS EC2 m1.small, ubuntu

Pre-requisites
--------------
 - Configured Cloud Account a in chosen environment
 - Either installed Chef on target compute OR launch under root
 - Internet access from target compute:
  - Tomcat distibution: tomcat6, tomcat6-admin RPM for CentOS, tomcat6, tomcat6-admin-webapps Deb for Ubuntu
  - S3 bucket with Chef recipes: qubell-starter-kit-artifacts
  - If Chef is not installed: please install Chef 10.16.2 using http://www.opscode.com/chef/install.sh ```bash <($WGET -O - http://www.opscode.com/chef/install.sh) -v $CHEF_VERSION```

Implementation notes
--------------------
 - Installation is based on Chef recipes from http://community.opscode.com/cookbooks/tomcat

Example usage
-------------
```
- deploy-libs:
	action: serviceCall
	phase: deploy-libs
	precedingPhases: [ get-env-props ]
	parameters:
        timeout: 300
        service: app-manage
        command: deploy-libs
        arguments:
          lib-uri: "{$.lib-uri}"
                
- deploy-war:
	action: serviceCall
	phase: deploy-war
	precedingPhases: [ build-app, deploy-libs ]
	parameters:
        timeout: 300
        service: app-manage
        command: deploy-war
        arguments:
          war-uri: "{$.war-uri}"
          context-attrs: {
            "docBase": "{$.war-uri}",
            "path": "/",
            "debug": "5",
            "reloadable": "true",
            "crossContext": "true",
            "allowLinking": "true"
          }
          context-nodes:
            - Environments: {
                "name": "appEnvironment",
                "value": "_default",
                "type": "java.lang.String",
                "override": "false"
            }
            - Resource: {
                "name": "jdbc/datasource",
                "auth": "Container",
                "type": "javax.sql.DataSource",
                "maxActive": "8",
                "maxIdle": "8",
                "maxWait": "-1",
                "username": "{$.db-user}",
                "password": "{$.db-password}",
                "driverClassName": "com.mysql.jdbc.Driver",
                "url": "jdbc:mysql://{$.props.db-info.db-host[0]}:{$.props.db-info.db-port}/{$.db-name}?autoReconnect=true",
                "validationQuery": "select 1",
                "testOnReturn": "true",
                "testWhileIdle": "true"
            }

```
