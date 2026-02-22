namespace D64QuickLook;

uses
  Foundation,
  AppKit;

type
  [NSApplicationMain, IBObject]
  AppDelegate = class(INSApplicationDelegate)
  public

    method applicationDidFinishLaunching(aNotification: NSNotification);
    begin
      fMainWindowController := new MainWindowController();
      fMainWindowController.showWindow(nil);
    end;

  private

    fMainWindowController: MainWindowController;

  end;

end.