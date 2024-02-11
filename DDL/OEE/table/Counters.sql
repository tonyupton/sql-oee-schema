CREATE TABLE OEE.Counters (
	Id int IDENTITY,
	EquipmentId int NOT NULL,
	Name int        NOT NULL,
	Type int        NOT NULL,
	Mode int        NOT NULL,
	Value int,
	CONSTRAINT Counters_pk PRIMARY KEY (Id),
	CONSTRAINT Counters_pk_2 UNIQUE (EquipmentId, Name),
	CONSTRAINT Counters_Equipment_Id_fk FOREIGN KEY (EquipmentId) REFERENCES OEE.Equipment
)
go

