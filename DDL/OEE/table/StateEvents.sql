CREATE TABLE OEE.StateEvents (
	Id int IDENTITY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL,
	StateId int,
	ReasonId int,
	ReasonComment varchar(2000),
	CONSTRAINT StateEvents_pk PRIMARY KEY (Id),
	CONSTRAINT StateEvents_pk_2 UNIQUE (BeginTime, EquipmentId),
	CONSTRAINT StateEvents_Equipment_Id_fk FOREIGN KEY (EquipmentId) REFERENCES OEE.Equipment,
	CONSTRAINT StateEvents_StateReasons_Id_fk FOREIGN KEY (ReasonId) REFERENCES OEE.StateReasons,
	CONSTRAINT StateEvents_States_Id_fk FOREIGN KEY (StateId) REFERENCES OEE.States
)
go

