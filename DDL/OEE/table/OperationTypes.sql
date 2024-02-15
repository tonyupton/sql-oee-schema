CREATE TABLE OEE.OperationTypes (
	Id int IDENTITY,
	Name varchar(50)   NOT NULL,
	ExcludeFromOEE bit NOT NULL,
	CONSTRAINT OperationTypes_pk PRIMARY KEY (Id),
	CONSTRAINT OperationTypes_pk_2 UNIQUE (Name)
)
go

