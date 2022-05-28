/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

/*
Do NOT Reset table AccessLogs						

DELETE FROM [dbo].[AccessLogs];
GO

SET IDENTITY_INSERT [dbo].[AccessLogs] ON
INSERT INTO [dbo].[AccessLogs] ([Id], [PageName],[AccessDate]) VALUES (1, N'Home', GetDate())
SET IDENTITY_INSERT [dbo].[AccessLogs] OFF

*/

DELETE FROM [dbo].[Nutrition];
GO

SET IDENTITY_INSERT [dbo].[Nutrition] ON
GO

INSERT INTO [dbo].[Nutrition] ([Id], [Description], [Quantity], [MealTime], [Tags], [Calories], [ProteinInGrams], [FatInGrams], [CarbohydratesInGrams], [SodiumInGrams]) VALUES (20, N'Apple', 1, N'2022-03-22 00:00:00', N'fruit, snack', 116, CAST(0.60 AS Decimal(18, 2)), CAST(0.40 AS Decimal(18, 2)), CAST(38.80 AS Decimal(18, 2)), CAST(2.00 AS Decimal(18, 2)))
GO
INSERT INTO [dbo].[Nutrition] ([Id], [Description], [Quantity], [MealTime], [Tags], [Calories], [ProteinInGrams], [FatInGrams], [CarbohydratesInGrams], [SodiumInGrams]) VALUES (21, N'Pineapple', 1, N'2022-03-22 00:00:00', N'fruit, snack', 82, CAST(0.90 AS Decimal(18, 2)), CAST(0.20 AS Decimal(18, 2)), CAST(21.60 AS Decimal(18, 2)), CAST(1.60 AS Decimal(18, 2)))
GO
INSERT INTO [dbo].[Nutrition] ([Id], [Description], [Quantity], [MealTime], [Tags], [Calories], [ProteinInGrams], [FatInGrams], [CarbohydratesInGrams], [SodiumInGrams]) VALUES (22, N'Coconut', 1, N'2022-03-22 00:00:00', N'fruit, snack', 159, CAST(1.50 AS Decimal(18, 2)), CAST(15.10 AS Decimal(18, 2)), CAST(6.90 AS Decimal(18, 2)), CAST(9.00 AS Decimal(18, 2)))
GO
INSERT INTO [dbo].[Nutrition] ([Id], [Description], [Quantity], [MealTime], [Tags], [Calories], [ProteinInGrams], [FatInGrams], [CarbohydratesInGrams], [SodiumInGrams]) VALUES (23, N'Strawberry', 1, N'2022-03-22 00:00:00', N'fruit, snack', 47, CAST(1.00 AS Decimal(18, 2)), CAST(0.40 AS Decimal(18, 2)), CAST(11.00 AS Decimal(18, 2)), CAST(1.40 AS Decimal(18, 2)))
GO
INSERT INTO [dbo].[Nutrition] ([Id], [Description], [Quantity], [MealTime], [Tags], [Calories], [ProteinInGrams], [FatInGrams], [CarbohydratesInGrams], [SodiumInGrams]) VALUES (24, N'Pear', 1, N'2022-03-22 00:00:00', N'fruit, snack', 102, CAST(0.60 AS Decimal(18, 2)), CAST(0.20 AS Decimal(18, 2)), CAST(27.10 AS Decimal(18, 2)), CAST(1.80 AS Decimal(18, 2)))
GO
INSERT INTO [dbo].[Nutrition] ([Id], [Description], [Quantity], [MealTime], [Tags], [Calories], [ProteinInGrams], [FatInGrams], [CarbohydratesInGrams], [SodiumInGrams]) VALUES (25, N'Banana', 1, N'2022-03-22 00:00:00', N'fruit, snack', 105, CAST(1.30 AS Decimal(18, 2)), CAST(0.40 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(1.20 AS Decimal(18, 2)))
GO
INSERT INTO [dbo].[Nutrition] ([Id], [Description], [Quantity], [MealTime], [Tags], [Calories], [ProteinInGrams], [FatInGrams], [CarbohydratesInGrams], [SodiumInGrams]) VALUES (26, N'Orange', 1, N'2022-03-22 00:00:00', N'fruit, snack', 135, CAST(1.35 AS Decimal(18, 2)), CAST(0.45 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(1.25 AS Decimal(18, 2)))
GO

SET IDENTITY_INSERT [dbo].[Nutrition] OFF
GO

DELETE FROM [dbo].[Exercises];
GO

SET IDENTITY_INSERT [dbo].[Exercises] ON
GO

INSERT INTO [dbo].[Exercises] ([Id], [Name], [Description], [ExerciseTime], [MusclesInvolved], [Equipment]) VALUES (20, N'Walking', N'The physical and mental benefits of walking are both well documented.', N'2022-03-22 00:00:00', N'Legs', N'None')
GO
INSERT INTO [dbo].[Exercises] ([Id], [Name], [Description], [ExerciseTime], [MusclesInvolved], [Equipment]) VALUES (21, N'Dancing', N'Much like walking, dancing has both physical and mental benefits.', N'2022-03-22 00:00:00', N'Legs', N'None')
GO
INSERT INTO [dbo].[Exercises] ([Id], [Name], [Description], [ExerciseTime], [MusclesInvolved], [Equipment]) VALUES (22, N'Stretching', N'Exercise isn’t just about cardio.', N'2022-03-22 00:00:00', N'Legs', N'None')
GO
INSERT INTO [dbo].[Exercises] ([Id], [Name], [Description], [ExerciseTime], [MusclesInvolved], [Equipment]) VALUES (23, N'Jumping', N'An easy way to get your heart going is to jump up and down.', N'2022-03-22 00:00:00', N'Legs', N'None')
GO
INSERT INTO [dbo].[Exercises] ([Id], [Name], [Description], [ExerciseTime], [MusclesInvolved], [Equipment]) VALUES (24, N'Sit/Stand', N'Most of us sit down and stand up at least a few times a day.', N'2022-03-22 00:00:00', N'Legs', N'None')
GO
INSERT INTO [dbo].[Exercises] ([Id], [Name], [Description], [ExerciseTime], [MusclesInvolved], [Equipment]) VALUES (25, N'Leg Raises', N'Another exercise that just about anyone can do is the leg raise.', N'2022-03-22 00:00:00', N'Legs', N'None')
GO
INSERT INTO [dbo].[Exercises] ([Id], [Name], [Description], [ExerciseTime], [MusclesInvolved], [Equipment]) VALUES (26, N'Arms Up/Circles', N'Arm raises can be done by virtually anyone, anywhere.', N'2022-03-22 00:00:00', N'Legs', N'None')
GO
INSERT INTO [dbo].[Exercises] ([Id], [Name], [Description], [ExerciseTime], [MusclesInvolved], [Equipment]) VALUES (27, N'Treadclimber', N'Elliptical motion, stair climber effect, and forward motion.', N'2022-03-22 00:00:00', N'Legs', N'None')
GO

SET IDENTITY_INSERT [dbo].[Exercises] OFF
GO
