create table [oee].[PerformanceEvents]
(
	[Id] int identity,
	[EquipmentId] int not null,
	[IdealRate] float,
	[ScheduleRate] float,
	[BeginTime] datetime not null,
	[EndTime] datetime,
	constraint [PK_EquipmentPerformanceEvents]
		primary key ([Id])
)
go

