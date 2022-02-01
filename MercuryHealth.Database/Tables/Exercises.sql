CREATE TABLE [dbo].[Exercises] (
    [Id]              INT	IDENTITY (1, 1) NOT NULL,
    [Name]            NVARCHAR (MAX)   NOT NULL,
	[FirstName]       NVARCHAR (MAX)   NULL,
	[LastName]        NVARCHAR (MAX)   NULL,
    [Description]     NVARCHAR (MAX)   NOT NULL,
    [ExerciseTime]    DATETIME         NOT NULL,
    [MusclesInvolved] NVARCHAR (MAX)   NULL,
    [Equipment]       NVARCHAR (MAX)   NULL,
    CONSTRAINT [PK_dbo.Exercises] PRIMARY KEY CLUSTERED ([Id] ASC)
);

