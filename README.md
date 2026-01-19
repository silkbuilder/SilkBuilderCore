# SilkBuilder Core Installation Guide

This guide provides step-by-step instructions for installing, configuring, and starting SilkBuilder Core, a web application that runs on Apache Tomcat.

Learn more about SilkBuilder [here](https://silkbuilder.com).

## System Requirements

To ensure compatibility and smooth operation, verify that your environment meets the following prerequisites:

- **Apache Tomcat**: Version 10 or higher
- **Java**: Version 17 or higher
- **Database**: One of the following supported relational databases:
  - MySQL
  - PostgreSQL
  - Microsoft SQL Server
  - Oracle

**Note 1**: The /WEB-INF/lib folder contains Java drivers for the supported databases. You can remove or replace these drivers with the ones of your preference.

- MySQL: mysql-connector-j-9.1.0.jar
- MS SQL Server: mssql-jdbc-12.8.1.jre11.jar
- PostgreSQL: postgresql-42.7.5.jar
- Oracle: ojdbc11.jar

**Note 2**: Ensure your database is installed correctly, accessible, and configured with the necessary permissions for the application user.

## Installation Steps

1. **Download the Repository**:
   - Navigate to the repository main page and click the "code" button.
   - Download the repository as a ZIP file.

2. **Unzip the Contents**:
   - Extract the ZIP file to a temporary directory on your server.

3. **Initialize the Database Structure**:
   - Use the provided SQL scripts. 
4. **Deploy to Tomcat**:
   - Copy the extracted contents into the application folder in your Tomcat webapps directory, which hosts SilkBuilder Core.
   - Tomcat will automatically deploy the application upon startup or restart.

**Tip**: If you're deploying to a production environment, consider configuring an SSL connection.

## Database Structure

The folder ```/WEB-INF/sql``` contains the SQL scripts to initialize the SilkBuiderCore database. A file exists for every supported database:

* MySQL: SilkBuilder-core-mysql.sql
* MS SQL Server: SilkBuilder-core-mssql.sql
* PostgreSQL: SilkBuilder-core-pgsql.sql
* Oracle: SilkBuilder-core-oracle.sql

It is recommended to initialize the database before configuring the Tomcat application.

## Application Configuration

All configuration is done in the `/WEB-INF/applicationContext.xml` file within your deployed webapp directory. This Spring configuration file sets up encryption and database connections.

### Step 1: Configure CryptLoader
The CryptLoader handles encryption for sensitive data. Provide a strong password and salt to secure the encryption process.

Edit the bean as follows:

```xml
<bean id="CryptLoader" class="com.oopsclick.silk.security.CryptLoader">
    <constructor-arg name="secure1" value="[your-strong-password]" />
    <constructor-arg name="secure2" value="[your-salt-string]" />
	  <constructor-arg name="secure3" value="core" />
</bean>
```

- Replace `[your-strong-password]` with a secure, complex password.
- Replace `[your-salt-string]` with a unique salt value (e.g., a random string of at least 16 characters).

**Security Note**: Use a password manager to generate and store these values. Never commit them to version control.

### Step 2: Configure Database Source and Controller
Set up the data source for your chosen database and link it to the SilkSqlController.

First, define the data source bean:

```xml
<bean id="[data-source-id]" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
    <property name="driverClassName" value="[database-driver-class]" />
    <property name="url" value="[database-jdbc-url]" />
    <property name="username" value="[database-username]" />
    <property name="password" value="[database-password]" />
</bean>
```

- Replace `[data-source-id]` with a unique ID (e.g., `silkDataSource`).
- `[database-driver-class]`: Use the appropriate JDBC driver class. The Examples below are pre-installed:
  - MySQL: `com.mysql.cj.jdbc.Driver`
  - PostgreSQL: `org.postgresql.Driver`
  - MS SQL Server: `com.microsoft.sqlserver.jdbc.SQLServerDriver`
  - Oracle: `oracle.jdbc.OracleDriver`
- `[database-jdbc-url]`: The JDBC connection URL, e.g.:
  - MySQL: `jdbc:mysql://[dbhost]:3306/[database]?useSSL=false`
  - MS SQL Server: `jdbc:sqlserver://[dbhost]:1433;databaseName=[database];encrypt=false;`
  - PostgreSQL: `jdbc:postgresql://[dbhost]:5432/[databae]`
  - Oracle: `jdbc:oracle:thin:@[dbhost]:1521/[service_name]`
- `[database-username]` and `[database-password]`: Credentials for a database user with read/write access.

Next, configure the SilkSqlController bean and reference the data source:

```xml
<bean id="SilkSqlController" class="com.oopsclick.silk.dbo.SqlController">
    <property name="dataSource" ref="[data-source-id]" />
    <property name="translatorIn" value="writeLanguage" />
    <property name="translatorOut" value="readLanguage" />
    <property name="silkDatabaseID" value="[database-engine-id]" />
</bean>
```

- Replace `[data-source-id]` with the ID you defined earlier.
- `[database-engine-id]`: Select the numeric ID matching your database (as commented in the code):
  - 1 - MS SQL Server
  - 2 - MySQL
  - 3 - PostgreSQL
  - 4 - Oracle

## Starting the Application

1. **Restart Tomcat**:
   - Restart your Tomcat server to apply the changes and deploy the application.
   - On Linux/Mac: Use commands like `sudo systemctl restart tomcat` or `./catalina.sh restart` in the Tomcat bin directory.
   - On Windows: Use the Tomcat service manager or restart via the command line.

2. **Access the Application**:
   - Open a web browser and navigate to the application's URL, e.g., `http://your-server:8080/` if using the ROOT folder, or `http://your-server:8080/your-application/` (adjust for your Tomcat port and context path).
   - You should see the SilkBuilder welcome page prompting for the admin password.

3. **Initial Login and Password Change**:
   - Use the default password: `admin`.
   - After logging in, immediately change the password using the "Set Password" option in the application interface.

**Security Warning**: Failing to change the default password exposes your application to unauthorized access. Always use a strong, unique password and enable additional security measures, such as HTTPS, in production.

## Troubleshooting

- **Tomcat Deployment Issues**: Check Tomcat logs (e.g., `catalina.out`) for errors during startup.
- **Database Connection Errors**: Verify JDBC details, firewall rules, and database availability.

If you encounter issues, consult the Tomcat documentation or your database vendor's guides for further assistance. For application-specific support, refer to the [SilkBuilder](https:docs.silkbuilder.com) documentation.

