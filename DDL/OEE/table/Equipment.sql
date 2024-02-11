CREATE TABLE OEE.Equipment (
	Id int IDENTITY,
	Enterprise varchar(50) NOT NULL,
	Site varchar(50)       NOT NULL,
	Area varchar(50)       NOT NULL,
	Line varchar(50)       NOT NULL,
	Cell varchar(50),
	Description varchar(255),
	ShiftScheduleId int,
	StateClassId int,
	Path AS CONCAT([Enterprise], '/', [Site], '/', [Area], '/', [Line],
				   CASE WHEN [Cell] IS NULL THEN '' ELSE CONCAT('/', [Cell]) END),
	CONSTRAINT Equipment_pk PRIMARY KEY (Id),
	CONSTRAINT Equipment_pk_2 UNIQUE (Path),
	CONSTRAINT Equipment_StateClasses_Id_fk FOREIGN KEY (StateClassId) REFERENCES OEE.StateClasses
)
go

