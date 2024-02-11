#!/bin/bash

sleep 60

# Run the setup script to config the DB and the schema in the DB
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i Setup.sql

# Run the setup script to config the DB and the schema in the DB
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d OEE_Database -i Create.sql

# Run the setup script to config the DB and the schema in the DB
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d OEE_Database -i Seed.sql