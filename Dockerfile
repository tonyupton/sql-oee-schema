FROM mcr.microsoft.com/mssql/server:2022-latest

# Create a config directory
WORKDIR /usr/config

# Bundle config source
COPY /config /usr/config

ENTRYPOINT ["./entrypoint.sh"]