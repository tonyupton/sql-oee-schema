CREATE TABLE OEE.CounterEvents (
	Id int IDENTITY,
	EquipmentEventId int NOT NULL,
	CounterId int        NOT NULL,
	BeginValue int,
	EndValue int,
	DeltaValue int,
	CONSTRAINT CounterEvents_pk PRIMARY KEY (Id),
	CONSTRAINT CounterEvents_pk_2 UNIQUE (EquipmentEventId, CounterId),
	CONSTRAINT CounterEvents_Counters_Id_fk FOREIGN KEY (CounterId) REFERENCES OEE.Counters,
	CONSTRAINT CounterEvents_EquipmentEvents_Id_fk FOREIGN KEY (EquipmentEventId) REFERENCES OEE.EquipmentEvents
)
go

