FROM mcr.microsoft.com/mssql/server:2022-latest

# Create a config directory
WORKDIR /usr/config

# Bundle config source
COPY /config /usr/config

# Execute entrypoint.sh shell script
ENTRYPOINT ["./entrypoint.sh"]