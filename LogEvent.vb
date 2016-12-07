Imports ASi.DataAccess.SqlHelper
'calling app. or machine.config needs the following settings:
'LogEvent_QueuePath = queue server/path such as servername\$Private\LogEvent
'LogEvent_ConnectString = DB connect string for "LogEventUser" SQL user; 
'call app must pass in decrypted connect string - component no longer obtains it's own connect string
' note: password not encrypted in config by default. So, if you want it encrypted, must decrypt in calling app. and pass into New() 
'LogEvent_Mailserver = mailserver to use such as "mail.domain.net"
'LogEvent_MailFrom = default sender such as "no-reply@domain.net"

Public Class LogEvent

    Private Const SMTP_TIMEOUT As Integer = 60
    Private Const SMTP_PORT As Integer = 25
    Private _ConnectString As String = "" 'set in New()
    Private _QueueOverrideToSystem As Boolean = False
    Private _DBOverrideToSystem As Boolean = False


    'these defaults are updated in New() 
    Private _QueuePath As String = ".\Private$\LogEvent"
    Private _MailServer As String = "127.0.0.1"
    Private _MailFrom As String = "no-reply@domain.net"

    Public Enum MessageType
        Start = 0
        [Error] = 1
        Information = 2
        Debug = 3
        Finish = 4
        Custom = 9
    End Enum

    Public Enum LogType
        Queue = 0
        Database = 1
        SystemEventLog = 2
        Email = 4
    End Enum
       
    'general purpose method
    Public Sub LogEvent(ByVal ApplicationName As String, _
        ByVal Source As String, _
        ByVal Message As String, _
        ByVal MessageType As ASi.LogEvent.LogEvent.MessageType, _
        ByVal LogType As ASi.LogEvent.LogEvent.LogType)

        Select Case LogType
            Case ASi.LogEvent.LogEvent.LogType.Queue
                'log to the queue
                Me.LogEventQueue(ApplicationName, Source, Message, MessageType, False)
            Case ASi.LogEvent.LogEvent.LogType.Database
                'log to db
                LogEventDatabase(ApplicationName, Source, Message, MessageType)
            Case LogType.Email
                If MessageType = MessageType.Error Then
                    'send high priority e-mail
                    LogEventEmail(ApplicationName, Source, Message, MessageType, "", True)
                Else
                    'send normal priority e-mail
                    LogEventEmail(ApplicationName, Source, Message, MessageType, "", False)
                End If
            Case LogType.SystemEventLog
                Dim strMessage As String = "Application: " & ApplicationName & vbCrLf & _
                                            "Source: " & Source & vbCrLf & _
                                            "Message: " & Message
                If MessageType = MessageType.Error Then
                    'log a system error
                    LogEventSystem(strMessage, EventLogEntryType.Error)
                Else
                    'log a system information
                    LogEventSystem(strMessage, EventLogEntryType.Information)
                End If
        End Select

    End Sub
    Public Sub LogEventDatabase(ByVal ApplicationName As String, _
    ByVal Source As String, _
    ByVal Message As String, _
    ByVal MessageType As ASi.LogEvent.LogEvent.MessageType)
        'Purpose: Log the event to the database.

        If _DBOverrideToSystem = True Then
            'override because New() detected a DB setting problem
            Dim strMessage As String = "Application: " & ApplicationName & vbCrLf & _
                                            "Source: " & Source & vbCrLf & _
                                            "Message: " & Message
            If Message = ASi.LogEvent.LogEvent.MessageType.Error Then
                LogEventSystem(strMessage, EventLogEntryType.Error)
            Else
                LogEventSystem(strMessage, EventLogEntryType.Information)
            End If

            Exit Sub
        End If

        Try
            'log to the db
            ExecuteNonQuery(_ConnectString, CommandType.StoredProcedure, "insLog", _
                        New SqlClient.SqlParameter("@pdtDateTime", Now), _
                        New SqlClient.SqlParameter("@pstrApplicationName", Left(ApplicationName, 50)), _
                        New SqlClient.SqlParameter("@pintMessageTypeID", CByte(MessageType)), _
                        New SqlClient.SqlParameter("@pstrSource", Left(Source, 500)), _
                        New SqlClient.SqlParameter("@pstrMessage", Message))

        Catch ex As Exception
            'if logging to the db fails, log to the eventlog
            LogEventSystem("LogEventDB Error[" & ApplicationName & "][" & Source & "][" & Message & "] ex:" & ex.Message, MessageType)
        End Try

    End Sub
    Public Sub LogEventEmail(ByVal ApplicationName As String, _
        ByVal Source As String, _
        ByVal Message As String, _
        ByVal MessageType As ASi.LogEvent.LogEvent.MessageType, _
        ByVal Subject As String, _
        ByVal Priority As Boolean)
        'Purpose:   Send an e-mail log notification base on e-mail addresses associated to an application.
       
        Dim strMessageType As String = _MessageTypeString(MessageType)

        Try
            'fetch the e-mail recipients
            Dim strRecipients As String = CType(ExecuteScalar(_ConnectString, CommandType.StoredProcedure, _
            "selApplicationEmail", New SqlClient.SqlParameter("@pstrApplicationName", ApplicationName)), String)

            If strRecipients <> "" Then
                _SendMail(_MailFrom, strRecipients, ApplicationName & ": " & Source & ": " & strMessageType & _
                IIf(Subject <> "", ": " & Subject, ""), Message, Priority)
            Else
                'try a queue log
                LogEventQueue(ApplicationName, Source, Message, MessageType, True)
            End If
        Catch ex As Exception
            'if logging to the email fails, log to Windows
            LogEventSystem("LogEventEmail Error[" & ApplicationName & "][" & Source & "][" & Message & "] ex:" & ex.Message, MessageType)
        End Try
    End Sub
    Public Sub LogEventQueue(ByVal ApplicationName As String, _
       ByVal Source As String, _
       ByVal Message As String, _
       ByVal MessageType As ASi.LogEvent.LogEvent.MessageType, _
       ByVal Recoverable As Boolean)

        If _QueueOverrideToSystem = True Then
            'override because New() detected a queue setting problem
            Dim strMessage As String = "Application: " & ApplicationName & vbCrLf & _
                                            "Source: " & Source & vbCrLf & _
                                            "Message: " & Message
            If Message = ASi.LogEvent.LogEvent.MessageType.Error Then
                LogEventSystem(strMessage, EventLogEntryType.Error)
            Else
                LogEventSystem(strMessage, EventLogEntryType.Information)
            End If

            Exit Sub
        End If


        Try
            'log to queue
            ASi.MSMQHelper.MsmqHelper.SendMessage(_QueuePath, _
                _ConstructQueueMessage(ApplicationName, Source, Message, MessageType), Recoverable)
        Catch ex As Exception
            'if logging to the queue fails, log to the eventlog
            LogEventSystem("LogEventQueue Error[" & ApplicationName & "][" & Source & "][" & Message & "] ex:" & ex.Message, MessageType)
        End Try

    End Sub
    Public Sub LogEventSystem(ByVal Message As String, ByVal Type As EventLogEntryType)
        'Purpose:   Write an event to the system event log.
        'Input:     Message = string message to log.
        '           Type = enumerated Event log type (EventLogEntryType.Error or EventLogEntryType.Information)
        EventLog.WriteEntry("ASi.LogEvent.LogEvent", Message, Type)
    End Sub
    
    Public Sub New(Optional ByVal ConnectStringOverride As String = "")

        Dim ar As New System.Configuration.AppSettingsReader
        Dim ErrString As String = ""
        On Error Resume Next


        'get the queuepath such as "servername\PRIVATE$\queuename"
        _QueuePath = ar.GetValue("LogEvent_QueuePath", GetType(System.String))

        'get the DB connect string - s/b LogEventUser SQL user; password not encrypted in config.
        _ConnectString = ar.GetValue("LogEvent_ConnectString", GetType(System.String))

        If ConnectStringOverride <> "" Then
            'allow caller to pass in connect string. this allows it to be encrypted in web.configs
            'this should be the default (i.e. - you should pass it in rather than let the component try to obtain it)
            _ConnectString = ConnectStringOverride
        End If

        'get the mail settings
        _MailServer = ar.GetValue("LogEvent_Mailserver", GetType(System.String))
        _MailFrom = ar.GetValue("LogEvent_MailFrom", GetType(System.String))

        'validate settings - don't log missing config values; each instance of New will flood windows eventlog
        If _QueuePath Is Nothing OrElse _QueuePath.Trim = "" OrElse InStr(_QueuePath, "\$PRIVATE\", CompareMethod.Text) < 1 Then
            _QueueOverrideToSystem = True
            'LogEventSystem("Missing LogEvent_QueuePath: Queue writes will write to Windows EventLog.", EventLogEntryType.Error)
        Else
            _QueuePath = _QueuePath.Trim
        End If

        If _ConnectString Is Nothing OrElse _ConnectString.Trim = "" Then
            _DBOverrideToSystem = True
            LogEventSystem("Missing LogEvent_ConnectString setting: DB writes write to Windows EventLog.", EventLogEntryType.Error)
        Else
            _ConnectString = _ConnectString.Trim
        End If

        If _MailServer Is Nothing OrElse _MailServer.Trim = "" Then
            'LogEventSystem("Missing LogEvent_Mailserver setting: Email events will write to Windows EventLog.", EventLogEntryType.Error)
        Else
            _MailServer = _MailServer.Trim
        End If
        If _MailFrom Is Nothing OrElse _MailFrom.Trim = "" Then
            _MailFrom = "no-reply@domain.net"
        End If

        ar = Nothing

    End Sub

    Private Function _ConstructQueueMessage(ByVal ApplicationName As String, _
       ByVal Source As String, _
       ByVal Message As String, _
       ByVal MessageType As ASi.LogEvent.LogEvent.MessageType) As String
        'turn the buffer into a simple XML document
        '<message app='appname' type='Information' src='sub'>msg goes here</message>
        Return "<message app='" & ApplicationName & "' type='" & _MessageTypeString(MessageType) & "' src='" & Source & "'>" & _
            _EncodeXML(Message) & _
            "</message>"
    End Function

    Private Function _EncodeXML(ByVal Value As String) As String
        Value = Replace(Value, "&", "&amp;")
        Value = Replace(Value, "<", "&lt;")
        Value = Replace(Value, ">", "&gt;")
        Value = Replace(Value, Chr(34), "&quot;")
        Value = Replace(Value, "'", "&#39;")
        Return Value
    End Function

    Private Function _MessageTypeString(ByVal MessageType As ASi.LogEvent.LogEvent.MessageType) As String
        'Purpose:   Return the string representation of the message type.
        Select Case MessageType
            Case MessageType.Debug
                Return "DEBUG"
            Case MessageType.Error
                Return "ERROR"
            Case MessageType.Finish
                Return "FINISH"
            Case MessageType.Information
                Return "INFORMATION"
            Case MessageType.Start
                Return "START"
            Case Else
                'shouldn't happen, but return "" rather than Nothing
                Return ""
        End Select
    End Function

    Private Sub _SendMail(ByVal EmailFrom As String, _
        ByVal Recipients As String, _
        ByVal Subject As String, _
        ByVal Message As String, _
        ByVal Priority As Boolean)

        'Purpose:   Send an e-mail. This will occur if the user requests it or when a disk log fails.
        'Inputs:    From = From e-mail address
        '           Recipients = semi-colon delimited list of recipient e-mail addresses
        '           Subject = subject of the e-mail message. 
        '           Message = body of the e-mail.
        '           Priority = optional priority flag. If omitted, defaults to Normal


        Try
            Dim SendMail As New ASi.Net.Smtp
            Dim m As New ASi.Net.Mime.Message

            m.To = Recipients
            m.From = EmailFrom
            m.Subject = Subject
            m.Body = Message
            If Priority = True Then
                m.Headers.Add("X-Priority", "1")
                m.Headers.Add("Priority", "Urgent")
                m.Headers.Add("Importance", "High")
            Else
                m.Headers.Add("Importance", "Normal")
            End If

            SendMail.Connect(_MailServer, SMTP_PORT, SMTP_TIMEOUT)
            SendMail.SendMessage(m, SMTP_TIMEOUT)
            SendMail.Disconnect()
            SendMail = Nothing

        Catch ex As Exception
            LogEventSystem("LogEvent SendMail Error. " & ex.Message, EventLogEntryType.Error)
        End Try

    End Sub

End Class

