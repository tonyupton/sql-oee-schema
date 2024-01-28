create table [oee].[ShiftSchedules]
(
	[Id] int identity,
	[Name] varchar(50) not null,
	constraint [PK_ShiftSchedules]
		primary key ([Id]),
	constraint [UK_ShiftSchedules_Name]
		unique ([Id])
)
go

