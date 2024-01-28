create table oee.StateEvents
(
	Id int identity,
	EquipmentId int not null,
	BeginTime datetime not null,
	EndTime datetime,
	StateId int,
	ReasonId int,
	ReasonComment varchar(2000),
	constraint PK_EquipmentStateEvents
		primary key (Id)
)
go

