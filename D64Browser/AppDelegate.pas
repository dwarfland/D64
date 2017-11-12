namespace D64Browser;

interface

uses
  AppKit,
  Foundation;

type
  [NSApplicationMain, IBObject]
  AppDelegate = class(INSApplicationDelegate)
  private
    fMainWindowController: MainWindowController;
  protected
  public
    method applicationDidFinishLaunching(aNotification: NSNotification);
  end;

implementation

method AppDelegate.applicationDidFinishLaunching(aNotification: NSNotification);
begin
  fMainWindowController := new MainWindowController();
  fMainWindowController.showWindow(nil);
end;

end.