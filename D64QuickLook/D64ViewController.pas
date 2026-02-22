namespace D64QuickLook;

uses
  D64,
  Foundation,
  AppKit,
  QuickLookUI;

type
  [IBObject]
  D64ViewController = public class(NSViewController, IQLPreviewingController, INSTableViewDataSource, INSTableViewDelegate)
  public

    property ColorMode: ColorMode := ColorMode.C64;

    property BackgroundColor: NSColor;
    property ForegroundColor: NSColor;

    method loadView; override;
    begin
      inherited loadView();

      var lScroll := new NSScrollView withFrame(CGRectMake(0, 0, 800, 600));
      lScroll.autoresizingMask := NSAutoresizingMaskOptions.ViewWidthSizable or NSAutoresizingMaskOptions.ViewHeightSizable;
      lScroll.hasVerticalScroller := true;
      lScroll.hasHorizontalScroller := false;

      fTableView := new NSTableView withFrame(lScroll.bounds);
      fTableView.autoresizingMask := NSAutoresizingMaskOptions.ViewWidthSizable or NSAutoresizingMaskOptions.ViewHeightSizable;
      fTableView.dataSource := self;
      fTableView.delegate := self;
      fTableView.intercellSpacing := NSMakeSize(0, 0);
      //fTableView.backgroundColor := NSColor.colorWithDeviceRed(53.0/255.0) green(40.0/255.0) blue(121.0/255.0) alpha(1.0);
      fTableView.headerView := nil;
      fTableView.usesAlternatingRowBackgroundColors := false;

      var lColumn := new NSTableColumn withIdentifier("name");
      lColumn.width := 780;
      fTableView.addTableColumn(lColumn);

      lScroll.documentView := fTableView;
      self.view := lScroll;

    end;

    method preparePreviewOfFileAtURL(url: NSURL) completionHandler(handler: block(aError: NSError));
    begin
      try
        var lPath := if assigned(url) then url.path else nil;
        if (lPath = nil) or (length(lPath) = 0) then
          raise new Exception("No preview file URL received.");

        case url.pathExtension of
          "d71": begin
              BackgroundColor := D64Browser.C64Colors.DarkGrey;
              ForegroundColor := D64Browser.C64Colors.LightGreen;
            end;
          else begin
              BackgroundColor := D64Browser.C64Colors.Blue;
              ForegroundColor := D64Browser.C64Colors.LightBlue;
            end;
        end;
        fTableView.backgroundColor := BackgroundColor;

        fStatusMessage := nil;
        fCurrentDisk := new DiskImage withFile(lPath);
        if assigned(fTableView) then
          fTableView.reloadData();
        handler(nil);
      except
        on lException: Exception do begin
          fCurrentDisk := nil;
          fStatusMessage := #"Unable to preview this file: {lException.Message}";
          if assigned(fTableView) then
            fTableView.reloadData();
          handler(nil);
        end;
      end;
    end;

    method numberOfRowsInTableView(tableView: not nullable NSTableView): NSInteger;
    begin
      if assigned(fCurrentDisk) then
        exit fCurrentDisk.Files.Count;
      if assigned(fStatusMessage) and (length(fStatusMessage) > 0) then
        exit 1;
      exit 0;
    end;

    method tableView(tableView: not nullable NSTableView) objectValueForTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger): nullable id;
    begin
      if assigned(fStatusMessage) and (length(fStatusMessage) > 0) then
        exit fStatusMessage;

      if assigned(fCurrentDisk) and (row >= 0) and (row < fCurrentDisk.Files.Count) then
        exit fCurrentDisk.Files[row].Name;

      exit "";
    end;

    method tableView(tableView: not nullable NSTableView) heightOfRow(row: NSInteger): CGFloat;
    begin
      exit 16.0;
    end;

    method tableView(tableView: not nullable NSTableView) dataCellForTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger): nullable NSCell;
    begin
      if not assigned(tableColumn) then
        exit nil;

      result := tableColumn:dataCell;
      if assigned(result) then begin
        var lTextCell := result as NSTextFieldCell;
        if assigned(lTextCell) then begin
          lTextCell.textColor := ForegroundColor;
          lTextCell.font := NSFont.fontWithName("CBM") size(16.0);
        end;
      end;
    end;

  private

    fTableView: NSTableView;
    fCurrentDisk: DiskImage;
    fStatusMessage: String;

  end;

end.