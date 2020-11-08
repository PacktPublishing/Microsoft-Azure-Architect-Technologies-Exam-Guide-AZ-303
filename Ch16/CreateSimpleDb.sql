SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Items](
	[Id] [int] NOT NULL,
	[Category] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[Completed] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT [dbo].[Items] ([Id], [Category], [Name], [Description], [Completed]) VALUES (1, N'personal', N'groceries', N'Get Milk and Eggs', 0)
GO
INSERT [dbo].[Items] ([Id], [Category], [Name], [Description], [Completed]) VALUES (2, N'work', N'SQL Lecture', N'Create SQL Lecture', 0)
GO