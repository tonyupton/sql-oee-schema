CREATE TABLE OEE.PerformanceEvents (
	Id int IDENTITY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL,
	IdealRate float,
	ScheduleRate float,
	CONSTRAINT PerformanceEvents_pk PRIMARY KEY (Id),
	CONSTRAINT PerformanceEvents_pk_2 UNIQUE (BeginTime, EquipmentId),
	CONSTRAINT PerformanceEvents_Equipment_Id_fk FOREIGN KEY (EquipmentId) REFERENCES OEE.Equipment
)
go

