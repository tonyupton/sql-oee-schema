create table OEE.StateEvents
(
	Id int identity,
	EquipmentId int not null,
	BeginTime datetime not null,
	EndTime datetime,
	StateId int,
	ReasonId int,
	ReasonComment varchar(2000),
	constraint StateEvents_pk
		primary key (Id),
	constraint StateEvents_pk_2
		unique (BeginTime, EquipmentId),
	constraint StateEvents_Equipment_Id_fk
		foreign key (EquipmentId) references OEE.Equipment,
	constraint StateEvents_StateReasons_Id_fk
		foreign key (ReasonId) references OEE.StateReasons,
	constraint StateEvents_States_Id_fk
		foreign key (StateId) references OEE.States
)
go

