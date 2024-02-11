CREATE TABLE OEE.Jobs (
	Id int IDENTITY,
	Reference varchar(50) NOT NULL,
	CONSTRAINT Jobs_pk PRIMARY KEY (Id),
	CONSTRAINT Jobs_pk_2 UNIQUE (Id)
)
go

