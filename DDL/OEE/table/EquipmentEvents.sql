CREATE TABLE OEE.EquipmentEvents (
	Id int IDENTITY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL,
	ShiftEventId int,
	OperationEventId int,
	StateEventId int,
	JobEventId int,
	DurationMillis int,
	PerformanceCount float,
	WasteCount float,
	Availability float,
	Performance float,
	Quality float,
	OEE float,
	CONSTRAINT EquipmentEvents_pk PRIMARY KEY (Id),
	CONSTRAINT EquipmentEvents_uk UNIQUE (EquipmentId, BeginTime),
	CONSTRAINT EquipmentEvents_Equipment_Id_fk FOREIGN KEY (EquipmentId) REFERENCES OEE.Equipment,
	CONSTRAINT EquipmentEvents_JobEvents_Id_fk FOREIGN KEY (JobEventId) REFERENCES OEE.JobEvents,
	CONSTRAINT EquipmentEvents_OperationEvents_Id_fk FOREIGN KEY (OperationEventId) REFERENCES OEE.OperationEvents,
	CONSTRAINT EquipmentEvents_ShiftEvents_Id_fk FOREIGN KEY (ShiftEventId) REFERENCES OEE.ShiftEvents,
	CONSTRAINT EquipmentEvents_StateEvents_Id_fk FOREIGN KEY (StateEventId) REFERENCES OEE.StateEvents
)
go

