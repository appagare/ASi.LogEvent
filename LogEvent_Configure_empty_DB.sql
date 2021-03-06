/*
create this SQL user
UN: LogEventUser
PW: LEU2o!0
*/

USE [master]
GO
/****** Object:  Database [LogEvent]    Script Date: 09/09/2012 20:04:25 ******/
/*
CREATE DATABASE [LogEvent] ON  PRIMARY 
( NAME = N'LogEvent', FILENAME = N'C:\SQLData\LogEvent.mdf' , SIZE = 2048KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'LogEvent_log', FILENAME = N'C:\SQLData\LogEvent_log.ldf' , SIZE = 1280KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
*/
/*
ALTER DATABASE [LogEvent] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [LogEvent].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [LogEvent] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [LogEvent] SET ANSI_NULLS OFF
GO
ALTER DATABASE [LogEvent] SET ANSI_PADDING OFF
GO
ALTER DATABASE [LogEvent] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [LogEvent] SET ARITHABORT OFF
GO
ALTER DATABASE [LogEvent] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [LogEvent] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [LogEvent] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [LogEvent] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [LogEvent] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [LogEvent] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [LogEvent] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [LogEvent] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [LogEvent] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [LogEvent] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [LogEvent] SET  DISABLE_BROKER
GO
ALTER DATABASE [LogEvent] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [LogEvent] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [LogEvent] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [LogEvent] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [LogEvent] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [LogEvent] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [LogEvent] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [LogEvent] SET  READ_WRITE
GO
ALTER DATABASE [LogEvent] SET RECOVERY SIMPLE
GO
ALTER DATABASE [LogEvent] SET  MULTI_USER
GO
ALTER DATABASE [LogEvent] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [LogEvent] SET DB_CHAINING OFF
GO
*/
USE [LogEvent]
GO
/****** Object:  User [LogEventUser]    Script Date: 09/09/2012 20:04:25 ******/
CREATE USER [LogEventUser] FOR LOGIN [LogEventUser] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Table [dbo].[luMessageTypes]    Script Date: 09/09/2012 20:04:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[luMessageTypes](
	[MessageTypeID] [tinyint] NOT NULL,
	[MessageTypeDescription] [varchar](50) NOT NULL,
 CONSTRAINT [PK_tlkpMessageType] PRIMARY KEY CLUSTERED 
(
	[MessageTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[buApplication]    Script Date: 09/09/2012 20:04:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[buApplication](
	[AppID] [int] IDENTITY(1,1) NOT NULL,
	[AppName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_buApplication] PRIMARY KEY CLUSTERED 
(
	[AppID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_buApplication] UNIQUE NONCLUSTERED 
(
	[AppName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[buLog]    Script Date: 09/09/2012 20:04:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[buLog](
	[EventID] [int] IDENTITY(1,1) NOT NULL,
	[AppID] [int] NOT NULL,
	[DateTime] [datetime] NOT NULL,
	[MessageTypeID] [tinyint] NOT NULL,
	[Source] [varchar](500) NOT NULL,
	[Message] [ntext] NOT NULL,
 CONSTRAINT [PK_buLog] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[buApplicationEmail]    Script Date: 09/09/2012 20:04:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[buApplicationEmail](
	[AppID] [int] NOT NULL,
	[EmailAddress] [varchar](50) NOT NULL,
 CONSTRAINT [PK_buApplicationEmail] PRIMARY KEY CLUSTERED 
(
	[AppID] ASC,
	[EmailAddress] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[LogPurge]    Script Date: 09/09/2012 20:04:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LogPurge]

AS

-- delete data that is over 6 mo. (184 days) old
delete from buLog where [Datetime] < dateadd(day, -185, getdate())
GO
/****** Object:  StoredProcedure [dbo].[insLog]    Script Date: 09/09/2012 20:04:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Name: 		insLog
	Purpose:	Insert a record into the buLog table. If application name does not exist, this proc creates it
	Input:		@pdtDateTime = date/time of the event
			@pstrApplicationName = name of the application logging the event
			@pintMessageType = message type indicator
			@pstrProcess = name of the application's process logging the event
			@pstrMessage = event message
	Returns:  	None
*/
CREATE Procedure [dbo].[insLog]
(
	@pdtDateTime datetime,
	@pstrApplicationName varchar(50),
	@pintMessageTypeID tinyint,
	@pstrSource as varchar(500),
	@pstrMessage as ntext
)
AS

declare @intAppID as int
set @intAppID = 0

-- fetch the AppID by name
set rowcount 1
set @intAppID = (select coalesce(AppID, 0) from buApplication with (nolock) where [AppName] = @pstrApplicationName)
set rowcount  0

-- if App name does not exist, create it
if (@intAppID = 0) or ((select count(*) from buApplication with (nolock) where [AppName] = @pstrApplicationName) < 1)
	begin
		insert into buApplication
		select @pstrApplicationName
		set @intAppID = @@IDENTITY
	end

-- log the message
insert into buLog
select @intAppID, @pdtDateTime, @pintMessageTypeID, @pstrSource, @pstrMessage
GO
/****** Object:  View [dbo].[v_ApplicationEvents]    Script Date: 09/09/2012 20:04:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_ApplicationEvents]
AS
SELECT     a.AppName, l.EventID, l.AppID, l.DateTime, l.MessageTypeID, l.Source, l.Message
FROM         dbo.buApplication AS a INNER JOIN
                      dbo.buLog AS l ON a.AppID = l.AppID
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 95
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "l"
            Begin Extent = 
               Top = 6
               Left = 236
               Bottom = 125
               Right = 402
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_ApplicationEvents'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_ApplicationEvents'
GO
/****** Object:  View [dbo].[v_ApplicationEmail]    Script Date: 09/09/2012 20:04:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_ApplicationEmail]
AS
SELECT     a.AppID, a.[AppName], ae.EmailAddress
FROM         buApplication a 
INNER JOIN buApplicationEmail ae
ON a.AppID = ae.AppID
GO
/****** Object:  StoredProcedure [dbo].[selApplicationEmail]    Script Date: 09/09/2012 20:04:38 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	Name: 		selApplicationEmail
	Purpose:	Returns a semi-colon delimited string of email addresses associated to an application.
	Returns:  	Semi-colon delimited string of email addresses or empty string if application name does not exist or
			no e-mail addresses are associated to it.
*/
CREATE Procedure [dbo].[selApplicationEmail]
(
	@pstrApplicationName varchar(50)
)
AS

declare @strEmail varchar(50)
declare @strEmailAddresses varchar(1000)
set @strEmailAddresses = ''

declare AppEmail cursor

for 
   select EmailAddress
   from v_ApplicationEmail with (nolock) where [AppName] = @pstrApplicationName
open AppEmail
fetch next from AppEmail into @strEmail
while (@@FETCH_STATUS <> -1)
	begin
	   if (@@FETCH_STATUS <> -2)
	   begin 
		set @strEmailAddresses = @strEmailAddresses + @strEmail + '; '
	   end
	   fetch next from AppEmail into @strEmail
END
CLOSE AppEmail
DEALLOCATE AppEmail

if right(@strEmailAddresses, 2) = '; '
	begin
		set @strEmailAddresses = left(@strEmailAddresses, len(@strEmailAddresses) -1)
	end

select @strEmailAddresses as Recipients
GO
/****** Object:  StoredProcedure [dbo].[LogViewerSearch]    Script Date: 09/09/2012 20:04:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
LogEvent Viewer search
*/
CREATE PROCEDURE [dbo].[LogViewerSearch]
(
  @MessageLike as varchar(200),
  @RecordCount as int = 0,
  @StartDate as datetime = null,
  @EndDate as datetime = null,
  @AppID as int = 0,
  @SortAsc as tinyint = 0
)

AS

if (@RecordCount < 1)
  begin
    -- default = 200
    set @RecordCount = 200
  end

/*
@MessageLike logic:

@MessageLike = "test" will result in "%test%"
@MessageLike = "test%" will result in "test%"
@MessageLike = "%test" will result in "%test"

*/

if ((left(@MessageLike,1) != '%') and (right(@MessageLike,1) != '%'))
  begin
	set @MessageLike = '%' + @MessageLike + '%'
  end
  

if (@AppID > 0)
  begin
  -- filter on appid
    if (@StartDate is null)
      begin
        -- no date restriction
        if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID and [Message] like @MessageLike order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID and [Message] like @MessageLike order by [EventID] desc
          end
       end -- startdate is null
    else if (@EndDate is null)
	  begin
	    -- startdate only
	    if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID and [DateTime] >= @StartDate and [Message] like @MessageLike order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID and [DateTime] >= @StartDate and [Message] like @MessageLike order by [EventID] desc
          end
	  end -- enddate is null
	else
	  begin
	    -- start and end date
	    if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID and [DateTime] between @StartDate and @EndDate and [Message] like @MessageLike order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID and [DateTime] between @StartDate and @EndDate and [Message] like @MessageLike order by [EventID] desc
          end
	   end -- enddate != null
  end -- end AppID
else
  begin
	-- return all apps
    if (@StartDate is null)
      begin
        -- no date restriction
        if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where [Message] like @MessageLike order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where [Message] like @MessageLike order by [EventID] desc
          end
       end -- startdate is null
    else if (@EndDate is null)
	  begin
	    -- startdate only
	    if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where [DateTime] >= @StartDate and [Message] like @MessageLike order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where [DateTime] >= @StartDate and [Message] like @MessageLike order by [EventID] desc
          end
	  end -- enddate is null
	else
	  begin
	    -- start and end date
	    if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where [DateTime] between @StartDate and @EndDate and [Message] like @MessageLike order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where [DateTime] between @StartDate and @EndDate and [Message] like @MessageLike order by [EventID] desc
          end
	   end -- enddate != null
  end
GO
/****** Object:  StoredProcedure [dbo].[LogViewer]    Script Date: 09/09/2012 20:04:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
LogEvent Viewer
typical calls:
-- default call = recent 200 events
select top 200 * from v_ApplicationEvents order by  DateTime desc

-- by appid, set appid 
-- by date range, set start and end
-- recent by date
select top 200 * from v_ApplicationEvents where appidorder by  DateTime desc
*/
CREATE PROCEDURE [dbo].[LogViewer]
(
  @RecordCount as int = 0,
  @StartDate as datetime = null,
  @EndDate as datetime = null,
  @AppID as int = 0,
  @SortAsc as tinyint = 0
)

AS

if (@RecordCount < 1)
  begin
    -- default = 200
    set @RecordCount = 200
  end


if (@AppID > 0)
  begin
  -- filter on appid
    if (@StartDate is null)
      begin
        -- no date restriction
        if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID order by [EventID] desc
          end
       end -- startdate is null
    else if (@EndDate is null)
	  begin
	    -- startdate only
	    if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID and [DateTime] >= @StartDate order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID and [DateTime] >= @StartDate order by [EventID] desc
          end
	  end -- enddate is null
	else
	  begin
	    -- start and end date
	    if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID and [DateTime] between @StartDate and @EndDate order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where AppID=@AppID and [DateTime] between @StartDate and @EndDate order by [EventID] desc
          end
	   end -- enddate != null
  end -- end AppID
else
  begin
	-- return all apps
    if (@StartDate is null)
      begin
        -- no date restriction
        if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) order by [EventID] desc
          end
       end -- startdate is null
    else if (@EndDate is null)
	  begin
	    -- startdate only
	    if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where [DateTime] >= @StartDate order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where [DateTime] >= @StartDate order by [EventID] desc
          end
	  end -- enddate is null
	else
	  begin
	    -- start and end date
	    if (@SortAsc = 1)
          begin
          -- sort asc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where [DateTime] between @StartDate and @EndDate order by [EventID] asc
          end
        else
          begin
          -- sort desc
            select top (@RecordCount) * from v_ApplicationEvents with (nolock) where [DateTime] between @StartDate and @EndDate order by [EventID] desc
          end
	   end -- enddate != null
  end
GO
/****** Object:  ForeignKey [FK_buLog_buApplication]    Script Date: 09/09/2012 20:04:26 ******/
ALTER TABLE [dbo].[buLog]  WITH CHECK ADD  CONSTRAINT [FK_buLog_buApplication] FOREIGN KEY([AppID])
REFERENCES [dbo].[buApplication] ([AppID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[buLog] CHECK CONSTRAINT [FK_buLog_buApplication]
GO
/****** Object:  ForeignKey [FK_buLog_luMessageTypes]    Script Date: 09/09/2012 20:04:26 ******/
ALTER TABLE [dbo].[buLog]  WITH CHECK ADD  CONSTRAINT [FK_buLog_luMessageTypes] FOREIGN KEY([MessageTypeID])
REFERENCES [dbo].[luMessageTypes] ([MessageTypeID])
GO
ALTER TABLE [dbo].[buLog] CHECK CONSTRAINT [FK_buLog_luMessageTypes]
GO
/****** Object:  ForeignKey [FK_buApplicationEmail_buApplication]    Script Date: 09/09/2012 20:04:26 ******/
ALTER TABLE [dbo].[buApplicationEmail]  WITH CHECK ADD  CONSTRAINT [FK_buApplicationEmail_buApplication] FOREIGN KEY([AppID])
REFERENCES [dbo].[buApplication] ([AppID])
GO
ALTER TABLE [dbo].[buApplicationEmail] CHECK CONSTRAINT [FK_buApplicationEmail_buApplication]
GO


  insert into luMessageTypes select 0, 'Start'
  insert into luMessageTypes select 1, 'Error'
  insert into luMessageTypes select 2, 'Information'
  insert into luMessageTypes select 3, 'Debug'
  insert into luMessageTypes select 4, 'Finish'
  insert into luMessageTypes select 9, 'Custom'
  go
  
grant select on v_ApplicationEmail to LogEventUser
grant select on v_ApplicationEvents to LogEventUser

grant exec on insLog to LogEventUser
grant exec on LogPurge to LogEventUser
grant exec on LogViewer to LogEventUser
grant exec on LogViewerSearch to LogEventUser
grant exec on selApplicationEmail to LogEventUser
go

