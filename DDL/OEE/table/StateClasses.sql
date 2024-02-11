CREATE TABLE OEE.StateClasses (
	Id int IDENTITY,
	Name varchar(50) NOT NULL,
	CONSTRAINT StateClasses_pk PRIMARY KEY (Id),
	CONSTRAINT StateClasses_pk_2 UNIQUE (Name)
)
go

