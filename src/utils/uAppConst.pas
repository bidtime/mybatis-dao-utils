unit uAppConst;

interface

uses Messages;

const
  WM_MIDASICON    = WM_USER + 110;
  UI_INITIALIZE   = WM_MIDASICON + 1;

const
  //Do not localize
  //KEY_IE            = 'SOFTWARE\Microsoft\Internet Explorer';
  SServiceName      = 'mybatis_dao';
  SApplicationName  = 'mybatis dao app';

resourcestring
  SServiceOnly = 'The Server can only be run as a service on NT 3.51 and prior';
  SAlreadyRunning = '程序正在运行';
  SErrClose = '真的要退出程序吗？';
{  SErrChangeSettings = 'Cannot change settings when there are active connections. Kill connections?';
  SQueryDisconnect = 'Disconnecting clients can cause application errors. Continue?';
  SOpenError = 'Error opening port %d with error: %s';
  SHostUnknown = '(Unknown)';
  SNotShown = '(Not Shown)';
  SNoWinSock2 = 'WinSock 2 must be installed to use the socket connection';
  SStatusline = '%d current connections';
  SNotUntilRestart = 'This change will not take affect until the Socket Server is restarted';
}

implementation

end.

