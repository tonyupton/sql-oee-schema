CREATE TABLE OEE.OperationEvents (
	Id int IDENTITY,
	BeginTime datetime  NOT NULL,
	EndTime datetime,
	EquipmentId int     NOT NULL,
	OperationTypeId int NOT NULL,
	JobId int,
	IdealRate float,
	CONSTRAINT OperationEvents_pk PRIMARY KEY (Id),
	CONSTRAINT OperationEvents_pk_2 UNIQUE (BeginTime, EquipmentId),
	CONSTRAINT OperationEvents_Equipment_Id_fk FOREIGN KEY (EquipmentId) REFERENCES OEE.Equipment,
	CONSTRAINT OperationEvents_Jobs_Id_fk FOREIGN KEY (JobId) REFERENCES OEE.Jobs,
	CONSTRAINT OperationEvents_OperationTypes_Id_fk FOREIGN KEY (OperationTypeId) REFERENCES OEE.OperationTypes
)
go

EXEC sp_addextendedproperty 'MS_Description', 'Units per Minute', 'SCHEMA', 'OEE', 'TABLE', 'OperationEvents', 'COLUMN',
	 'IdealRate'
go

