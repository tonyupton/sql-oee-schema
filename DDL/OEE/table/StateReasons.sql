CREATE TABLE OEE.StateReasons (
	Id int IDENTITY,
	StateId int      NOT NULL,
	Name varchar(50) NOT NULL,
	Category varchar(50),
	Scheduled bit DEFAULT 0 NOT NULL,
	CONSTRAINT StateReasons_pk PRIMARY KEY (Id),
	CONSTRAINT StateReasons_pk_2 UNIQUE (StateId, Category, Name),
	CONSTRAINT StateReasons_States_Id_fk FOREIGN KEY (StateId) REFERENCES OEE.States,
)
go

