CREATE TABLE OEE.EquipmentEvents (
	Id int IDENTITY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL,
	StateEventId int,
	JobEventId int,
	ShiftEventId int,
	CONSTRAINT EquipmentEvents_pk PRIMARY KEY (Id),
	CONSTRAINT EquipmentEvents_uk UNIQUE (EquipmentId, BeginTime),
	CONSTRAINT EquipmentEvents_Equipment_Id_fk FOREIGN KEY (EquipmentId) REFERENCES OEE.Equipment,
	CONSTRAINT EquipmentEvents_JobEvents_Id_fk FOREIGN KEY (JobEventId) REFERENCES OEE.JobEvents,
	CONSTRAINT EquipmentEvents_ShiftEvents_Id_fk FOREIGN KEY (ShiftEventId) REFERENCES OEE.ShiftEvents,
	CONSTRAINT EquipmentEvents_StateEvents_Id_fk FOREIGN KEY (StateEventId) REFERENCES OEE.StateEvents
)
go

