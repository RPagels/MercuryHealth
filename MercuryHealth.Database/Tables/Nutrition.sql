CREATE TABLE [dbo].[Nutrition] (

    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [Description]          NVARCHAR (MAX)  NULL,
    [Quantity]             REAL            NOT NULL,
    [MealTime]             DATETIME        NOT NULL,
    [Tags]                 NVARCHAR (MAX)  NULL,
    [Calories]             INT             NOT NULL,
    [ProteinInGrams]       DECIMAL (18, 2) NOT NULL,
    [FatInGrams]           DECIMAL (18, 2) NOT NULL,
    [CarbohydratesInGrams] DECIMAL (18, 2) NOT NULL,
    [SodiumInGrams]        DECIMAL (18, 2) NOT NULL,
	[Color]				   NVARCHAR(MAX)   NULL
    CONSTRAINT [PK_dbo.Nutrition] PRIMARY KEY CLUSTERED ([Id] ASC)
);
