USE [master]
GO

CREATE DATABASE OEE_Database;
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [oee_user]    Script Date: 2/10/2024 10:41:20 PM ******/
CREATE LOGIN [oee_user] WITH PASSWORD=N'5fA5GCeeksCO/yFlBZGNbWJS9bKQT0+GVrCvVm8pi3M=', DEFAULT_DATABASE=[OEE_Database], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER LOGIN [oee_user] DISABLE
GO

USE OEE_Database;
GO

CREATE SCHEMA OEE AUTHORIZATION [dbo]
GO