CREATE TABLE OEE.States (
	Id int IDENTITY,
	StateClassId int NOT NULL,
	Name varchar(50) NOT NULL,
	Value int        NOT NULL,
	Running bit,
	Slow bit         NOT NULL,
	Waste bit        NOT NULL,
	Recordable bit   NOT NULL,
	CONSTRAINT States_pk PRIMARY KEY (Id),
	CONSTRAINT States_pk_2 UNIQUE (StateClassId, Name),
	CONSTRAINT States_pk_3 UNIQUE (StateClassId, Value),
	CONSTRAINT States_StateClasses_Id_fk FOREIGN KEY (StateClassId) REFERENCES OEE.StateClasses
)
go

