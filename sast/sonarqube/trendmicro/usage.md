## Install the agent

The Application Security java agent is provided as a jar file that needs to be configured as javaagent on the jvm command line.

    Add the java agent jar to the web application package, ensuring the jar file is in the class path. For example in the web application <root folder>/lib.

    Create the agent configuration file trend_app_protect.properties, which includes the key and secret among other configuration properties. The properties file needs to be in the classpath, alternatively, the configuration parameter com.trend.app_protect.config.file can be configured on the jvm command line to point to the properties file. The agent will look in the following locations for a config file. The first one found will be used.
        A file location specified via the com.trend.app_protect.config.file system property. Eg.: pass -Dcom.trend.app_protect.config.file=/path/to/trend_app_protect.properties to java.
        trend_app_protect.properties in the same directory of the trend_app_protect-X.X.X.jar.
        trend_app_protect.properties in the resources of your project.

The java agent and properties file configuration can be added to environment variables depending on the application server the application is running with, in order to be set on the jvm command line. Refer to the list below.

The Key and Secret can be found under Group Settings > Group Credentials.

The environment variables will take precedence over the configuration file.
Properties

The following properties are required for the agent to connect to the Application Security service:

```sh
key = <Your key>
secret = <Your secret>
```

## Enable Security

Application Security non-intrusively protects Java applications. We can add its Java agent to the deployed application start command. The agent uses Java Instrumentation to capture application invocations, analyze arguments like SQL statements and file locations, and perform necessary actions.

```sh

java -javaagent:./trend_app_protect-4.3.5.jar -

Dcom.trend.app_protect.config.file=./trend_app_protect.properties -jar

provider-search-0.0.1-SNAPSHOT.jar

[TREND APP PROTECT] Loading config from

file:/home/ubuntu/./trend_app_protect.properties

```

Additionally, we need to configure the agent with Application Security group credentials. We’ll do this by creating a properties file with the following details, then passing its location in the com.trend.app_protect.config.file JVM parameter.

key = YOUR_KEY

secret = YOUR_SECRET
