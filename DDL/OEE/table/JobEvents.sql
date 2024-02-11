CREATE TABLE OEE.JobEvents (
	Id int IDENTITY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL,
	JobId int          NOT NULL,
	CONSTRAINT JobEvents_pk PRIMARY KEY (Id),
	CONSTRAINT JobEvents_pk_2 UNIQUE (EquipmentId, BeginTime),
	CONSTRAINT JobEvents_Jobs_Id_fk FOREIGN KEY (JobId) REFERENCES OEE.Jobs
)
go

