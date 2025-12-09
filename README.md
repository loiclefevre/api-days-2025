# API Days 2025 - JSON Schema conference - Demos

This GitHub repository comes with numerous demos related to the support of JSON Schemas within the Oracle AI Database 26ai. You can access the demos from December 2024 [here](https://github.com/loiclefevre/apidays-paris-2024).

## Setup

Examples for Windows, running WSL2 for podman...

### Oracle SQL Developer Extension for VSCode
Install the [VSCode extension from the market place](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer).

### Database Installation
To install an Oracle AI database 26ai, install podman and then run (after replacing <path> with your own path to a shared folder named libs, shared between your OS and the container):

```bash
podman run -d --rm --name oracle -p 1521:1521 -e ORACLE_PASSWORD=free -e APP_USER=developer -e APP_USER_PASSWORD=free --volume C:\<path>\api-days-2025\libs:/opt/oracle/oradata/libs gvenzl/oracle-free:23.26.0
```

This command will configure a user named `developer` whose password will be `free`.

#### Enable MAX_STRING_SIZE=EXTENDED
From within a container shell:
```bash
podman exec -it oracle /bin/bash
```

```bash
sqlplus / as sysdba
```

Then run these commands:

```sql
alter system set max_string_size=extended scope=spfile;
shutdown immediate;
startup upgrade;
alter pluggable database all open upgrade;
exit;
```

```bash
cd $ORACLE_HOME/rdbms/admin/
$ORACLE_HOME/perl/bin/perl catcon.pl -d $ORACLE_HOME/rdbms/admin -l /tmp -b utl32k_output utl32k.sql
```

```bash
sqlplus / as sysdba
```

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
SELECT warning FROM sys.utl32k_warnings;
-- there should be no rows!
exit;
```

#### Copy ONNX model into the container
```bash
podman cp ALL-MINILM-L12-V2.onnx oracle:/opt/oracle/
```

### Oracle REST Data Services Installation
- Download from: [here](https://download.oracle.com/otn_software/java/ords/ords-latest.zip)
- Install ORDS (here on Windows):
```bat
REM Unzip into ords-latest/ folder
REM 
cd ords-latest\bin
mkdir ..\config
mkdir ..\config\global\doc_root
set ORDS_CONFIG_FOLDER=..\config
.\ords.exe --config %ORDS_CONFIG_FOLDER% install --admin-user SYS --db-hostname localhost --db-port 1521 --db-servicename freepdb1 --proxy-user --feature-db-api true --feature-rest-enabled-sql true --feature-sdw true
free
free
free

.\ords.exe --config %ORDS_CONFIG_FOLDER% config set mongo.enabled true
.\ords.exe --config %ORDS_CONFIG_FOLDER% config set standalone.http.port 80
.\ords.exe --config %ORDS_CONFIG_FOLDER% config set jdbc.MaxConnectionReuseCount 5000
.\ords.exe --config %ORDS_CONFIG_FOLDER% config set jdbc.MaxConnectionReuseTime 900
REM not standard setting
.\ords.exe --config %ORDS_CONFIG_FOLDER% config set jdbc.SecondsToTrustIdleConnection 1
.\ords.exe --config %ORDS_CONFIG_FOLDER% config set jdbc.InitialLimit 20
.\ords.exe --config %ORDS_CONFIG_FOLDER% config set jdbc.MaxLimit 20

REM Prepare for hosting static files
mkdir ..\config\global\doc_root

REM START!
.\ords.exe --config %ORDS_CONFIG_FOLDER% serve
```

#### Configure database user
Open a shell within the container:

```bash
podman exec -it oracle /bin/bash
```

Then run:
```bash
sqlplus developer/free@localhost/freepdb1
```

and:

```sql
-- Connected as developer/free
exec ords.enable_schema;
```

This will enable ORDS to work with the developer user.

### SQL Developer Extension for VSCode setup
Add 2 new connections to the users `developer` and `sys` in order to simplify demos execution.

Refer to this [documentation](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer#connectivity) taking into account that:

 - `sys` user must have the `SYSDBA` role
 - Password is `free` for both users
 - Hostname is `localhost`
 - Port is `1521`
 - Service name is `freepdb1`

## Demos

All the demos available are SQL notebooks that you can run using the installed SQL Developer Extension for VSCode.

### Developer user privileges
In order for the demos to work properly, additional privileges are required for the `developer` user:
```sql
-- connected as sys/free@localhost/freepdb1 as sysdba using SQL Developer Extension for VSCode or using sqlplus / as sysdba

-- switch to freepdb1 database container if needed
alter session set container=freepdb1;

-- manage editions
alter user developer enable editions;
grant create any edition, drop any edition to developer;
-- create MLE JavaScript modules
grant execute dynamic mle to developer;
grant create mle to developer;
-- manage hybrid vector indexes
grant ctxapp, unlimited tablespace to developer;
-- create ML model
grant create mining model to developer;
-- create directory
grant create any directory to developer;
-- access catalog
grant select_catalog_role to developer;
-- access Transactional Event Queue features
grant execute on dbms_aq to developer;
grant execute on dbms_aqadm to developer;
-- data redaction management
grant execute on dbms_redact to developer;
grant administer redaction policy to developer;
grant select on redaction_columns to developer;
```

### Install the Yaml-JSON JavaScript library

This [demo](./01-demo_yaml_json.sqlnb) shows how to load a JavaScript library and map the PL/SQL function onto exported functions to be able to then convert Yaml file into JSON.

### Install the Toon JavaScript library

