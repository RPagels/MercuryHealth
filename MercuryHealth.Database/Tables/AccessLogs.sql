CREATE TABLE [dbo].[AccessLogs] (
    [Id]  INT            IDENTITY (1, 1) NOT NULL,
    [PageName]   NVARCHAR (128) NOT NULL,
    [AccessDate] DATETIME       NOT NULL,
	[Visits] INT NULL,
	CONSTRAINT [PK_dbo.AccessLogs] PRIMARY KEY CLUSTERED ([Id] ASC)
);
