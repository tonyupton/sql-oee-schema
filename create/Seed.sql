INSERT INTO OEE.ShiftSchedules (Name) VALUES (N'Operations');

INSERT INTO OEE.Shifts (Name, ScheduleId) VALUES (N'A', 1);
INSERT INTO OEE.Shifts (Name, ScheduleId) VALUES (N'B', 1);
INSERT INTO OEE.Shifts (Name, ScheduleId) VALUES (N'C', 1);

INSERT INTO OEE.StateClasses (Name) VALUES (N'Machine');

INSERT INTO OEE.States (StateClassId, Name, Value, Running, Slow, Waste, Recordable) VALUES (1, N'Down', 0, 0, 0, 0, 1);
INSERT INTO OEE.States (StateClassId, Name, Value, Running, Slow, Waste, Recordable) VALUES (1, N'Running', 1, 1, 0, 0, 0);
INSERT INTO OEE.States (StateClassId, Name, Value, Running, Slow, Waste, Recordable) VALUES (1, N'Scrapping', 2, 1, 0, 1, 1);

INSERT INTO OEE.Jobs (Reference) VALUES (N'1000001');
INSERT INTO OEE.Jobs (Reference) VALUES (N'1000002');
INSERT INTO OEE.Jobs (Reference) VALUES (N'1000003');
INSERT INTO OEE.Jobs (Reference) VALUES (N'1000004');
INSERT INTO OEE.Jobs (Reference) VALUES (N'1000005');

INSERT INTO OEE.Equipment (Enterprise, Site, Area, Line, Cell, Description, ShiftScheduleId, StateClassId) VALUES (N'Enterprise', N'Site', N'Area', N'Line 1', null, null, 1, 1);
INSERT INTO OEE.Equipment (Enterprise, Site, Area, Line, Cell, Description, ShiftScheduleId, StateClassId) VALUES (N'Enterprise', N'Site', N'Area', N'Line 2', null, null, 1, 1);
INSERT INTO OEE.Equipment (Enterprise, Site, Area, Line, Cell, Description, ShiftScheduleId, StateClassId) VALUES (N'Enterprise', N'Site 2', N'Area', N'Line 1', N'Cell', null, null, 1);