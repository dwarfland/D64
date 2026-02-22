namespace D64Browser;

uses
  D64;

type
  ColorMode = public enum (C64, C128);

  [IBObject]
  MainWindowController = public class(NSWindowController, INSTableViewDataSource, INSTableViewDelegate)
  private
  protected

    property ColorMode: ColorMode := ColorMode.C64;

    property BackgroundColor: NSColor read case ColorMode of
      ColorMode.C64: C64Colors.Blue;
      ColorMode.C128: C64Colors.DarkGrey;
    end;

    property ForegroundColor: NSColor read case ColorMode of
      ColorMode.C64: C64Colors.LightBlue;
      ColorMode.C128: C64Colors.LightGreen;
    end;

  public

    constructor;
    begin
      inherited constructor withWindowNibName('MainWindowController');

      var fontURL := NSBundle.mainBundle.URLForResource("CBM") withExtension("ttf");
      var lError: CFErrorRef;
      if not CTFontManagerRegisterFontsForURL(bridge<CFURLRef>(fontURL), CTFontManagerScope.Process, var lError) then
        NSLog("error loading font");
    end;

    method windowDidLoad; override;
    begin
      inherited windowDidLoad();
      ContentsTableView.intercellSpacing := NSMakeSize(0, 0);
      ContentsTableView.backgroundColor := BackgroundColor;

      //Files := Folder.GetFiles("/Users/mh/Dropbox/C64", true).Select(f -> f as String).Where(f -> f.PathExtension in [".d64", ".d61"]).OrderBy(f -> f.LastPathComponent).ToList<String>();
      Files := new List<String>;
      Files.Add(List<String>(NSUserDefaults.standardUserDefaults.objectForKey("OpenFiles")));
      DiskImagesTableView.reloadData();
      UpdateViewerMenu();
    end;

    [IBAction]
    method setColors(aSender: id); public;
    begin
      //ContentsTableView.backgroundColor := C64Colors.Blue;
    end;


    [IBOutlet] property DiskImagesTableView: NSTableView;
    [IBOutlet] property ContentsTableView: NSTableView;
    [IBOutlet] property ViewerPlaceholderView: NSView;
    [IBOutlet] property ViewersPopup: NSPopUpButton;

    [IBAction]
    method ChangeColor(aSender: id); public;
    begin
      case NSMenuItem(aSender):identifier of
        "c64": ColorMode := ColorMode.C64;
        "c128": ColorMode := ColorMode.C128;
      end;
      ContentsTableView.backgroundColor := BackgroundColor;
      ContentsTableView.setNeedsDisplay;
    end;


    [IBAction]
    method LoadImages(aSender: id);
    begin
      var lPanel := NSOpenPanel.openPanel;
      lPanel.allowedFileTypes := new List<String>("d64", "d61"); // Cocoa uses dot-less extensions
      lPanel.allowsMultipleSelection := true;
      lPanel.beginSheetModalForWindow(window) completionHandler( success -> begin
        if success = NSFileHandlingPanelOKButton then begin
          for each u: NSURL in lPanel.URLs do
            Files.Add(u.path);
          NSUserDefaults.standardUserDefaults.setObject(Files) forKey("OpenFiles");
          NSUserDefaults.standardUserDefaults.synchronize;
          DiskImagesTableView.reloadData;
        end;
      end);
    end;

    [IBAction]
    method SaveFileToDisk(aSender: id);
    begin
      if assigned(CurrentFile) then begin
        var lPanel := NSSavePanel.savePanel;
        lPanel.nameFieldStringValue := CurrentFile.Name;
        lPanel.beginSheetModalForWindow(window) completionHandler( success -> begin
          if success = NSFileHandlingPanelOKButton then begin
            File.WriteBinary(lPanel.URL.path, CurrentFile.GetBytes);
          end;
        end);
      end;
    end;

    [IBAction]
    method ViewerChanged(aSender: id);
    begin
      ShowFile(CurrentFile) inViewer(ViewersPopup.selectedItem.representedObject)
    end;

  private

    property Files: List<String>;
    property CurrentDisk: DiskImage;
    property CurrentFile: D64File;

    property Viewers := new List<Viewer>(new BinaryViewer, new DisassemblyViewer, new PlainTextViewer);

    method validateUserInterfaceItem(aItem: INSValidatedUserInterfaceItem): Boolean;
    begin
      result := true;

      if aItem.action = selector(SaveFileToDisk:) then
        result := assigned(CurrentFile);

      case NSMenuItem(aItem):identifier of
        "c64": NSMenuItem(aItem).state := if ColorMode = ColorMode.C64 then NSOnState else NSOffState;
        "c128": NSMenuItem(aItem).state := if ColorMode = ColorMode.C128 then NSOnState else NSOffState;
      end;
    end;

    //
    // INSTableViewDataSource
    //

    method numberOfRowsInTableView(tableView: not nullable NSTableView): NSInteger;
    begin

      if tableView = DiskImagesTableView then begin
        result := Files:Count;
      end;

      if tableView = ContentsTableView then begin
        result := CurrentDisk:Files:Count;
      end;

    end;

    method tableView(tableView: not nullable NSTableView) objectValueForTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger): nullable id;
    begin

      if tableView = DiskImagesTableView then begin
        result := Files[row].LastPathComponent;
      end;

      if tableView = ContentsTableView then begin
        result := CurrentDisk.Files[row].Name;
      end;

    end;
    //method tableView(tableView: not nullable NSTableView) namesOfPromisedFilesDroppedAtDestination(dropDestination: not nullable NSURL) forDraggedRowsWithIndexes(indexSet: not nullable NSIndexSet): not nullable NSArray;
    //method tableView(tableView: not nullable NSTableView) acceptDrop(info: not nullable INSDraggingInfo) row(row: NSInteger) dropOperation(dropOperation: NSTableViewDropOperation): BOOL;
    //method tableView(tableView: not nullable NSTableView) validateDrop(info: not nullable INSDraggingInfo) proposedRow(row: NSInteger) proposedDropOperation(dropOperation: NSTableViewDropOperation): NSDragOperation;
    //method tableView(tableView: not nullable NSTableView) writeRowsWithIndexes(rowIndexes: not nullable NSIndexSet) toPasteboard(pboard: not nullable NSPasteboard): BOOL;
    //method tableView(tableView: not nullable NSTableView) updateDraggingItemsForDrag(draggingInfo: not nullable INSDraggingInfo);
    //method tableView(tableView: not nullable NSTableView) draggingSession(session: not nullable NSDraggingSession) endedAtPoint(screenPoint: NSPoint) operation(operation: NSDragOperation);
    //method tableView(tableView: not nullable NSTableView) draggingSession(session: not nullable NSDraggingSession) willBeginAtPoint(screenPoint: NSPoint) forRowIndexes(rowIndexes: not nullable NSIndexSet);
    //method tableView(tableView: not nullable NSTableView) pasteboardWriterForRow(row: NSInteger): nullable INSPasteboardWriting;
    //method tableView(tableView: not nullable NSTableView) sortDescriptorsDidChange(oldDescriptors: not nullable NSArray);
    //method tableView(tableView: not nullable NSTableView) setObjectValue(object: nullable id) forTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger);

    //
    // INSTableViewDelegate
    //
    //method tableView(tableView: not nullable NSTableView) rowActionsForRow(row: NSInteger) edge(edge: NSTableRowActionEdge): not nullable NSArray;
    //method tableView(tableView: not nullable NSTableView) shouldReorderColumn(columnIndex: NSInteger) toColumn(newColumnIndex: NSInteger): BOOL;
    //method tableView(tableView: not nullable NSTableView) sizeToFitWidthOfColumn(column: NSInteger): CGFloat;
    //method tableView(tableView: not nullable NSTableView) isGroupRow(row: NSInteger): BOOL;
    //method tableView(tableView: not nullable NSTableView) shouldTypeSelectForEvent(&event: not nullable NSEvent) withCurrentSearchString(searchString: nullable NSString): BOOL;
    //method tableView(tableView: not nullable NSTableView) nextTypeSelectMatchFromRow(startRow: NSInteger) toRow(endRow: NSInteger) forString(searchString: not nullable NSString): NSInteger;
    //method tableView(tableView: not nullable NSTableView) typeSelectStringForTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger): nullable NSString;
    method tableView(tableView: not nullable NSTableView) heightOfRow(row: NSInteger): CGFloat;
    begin
      if tableView = DiskImagesTableView then begin
        result := 18.0;
      end;
      if tableView = ContentsTableView then begin
        result := 16.0;
      end;
    end;

    //method tableView(tableView: not nullable NSTableView) didDragTableColumn(tableColumn: not nullable NSTableColumn);
    //method tableView(tableView: not nullable NSTableView) didClickTableColumn(tableColumn: not nullable NSTableColumn);
    //method tableView(tableView: not nullable NSTableView) mouseDownInHeaderOfTableColumn(tableColumn: not nullable NSTableColumn);
    //method tableView(tableView: not nullable NSTableView) shouldSelectTableColumn(tableColumn: nullable NSTableColumn): BOOL;
    //method tableView(tableView: not nullable NSTableView) selectionIndexesForProposedSelection(proposedSelectionIndexes: not nullable NSIndexSet): not nullable NSIndexSet;
    //method tableView(tableView: not nullable NSTableView) shouldSelectRow(row: NSInteger): BOOL;
    method tableView(tableView: not nullable NSTableView) dataCellForTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger): nullable NSCell;
    begin
      result := tableColumn:dataCell;
      if assigned(result) then begin

        if tableView = DiskImagesTableView then begin
        end;

        if tableView = ContentsTableView then begin
          (result as NSTextFieldCell).textColor := ForegroundColor;
          result:font := NSFont.fontWithName("CBM") size(16.0);
        end;

      end;
    end;
    //method tableView(tableView: not nullable NSTableView) shouldTrackCell(cell: not nullable NSCell) forTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger): BOOL;
    //method tableView(tableView: not nullable NSTableView) shouldShowCellExpansionForTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger): BOOL;
    //method tableView(tableView: not nullable NSTableView) toolTipForCell(cell: not nullable NSCell) rect(rect: NSRectPointer) tableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger) mouseLocation(mouseLocation: NSPoint): not nullable NSString;
    //method tableView(tableView: not nullable NSTableView) shouldEditTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger): BOOL;
    //method tableView(tableView: not nullable NSTableView) willDisplayCell(cell: not nullable id) forTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger);
    //method tableView(tableView: not nullable NSTableView) didRemoveRowView(rowView: not nullable NSTableRowView) forRow(row: NSInteger);
    //method tableView(tableView: not nullable NSTableView) didAddRowView(rowView: not nullable NSTableRowView) forRow(row: NSInteger);
    //method tableView(tableView: not nullable NSTableView) rowViewForRow(row: NSInteger): nullable NSTableRowView;
    //method tableView(tableView: not nullable NSTableView) viewForTableColumn(tableColumn: nullable NSTableColumn) row(row: NSInteger): nullable NSView;
    //method selectionShouldChangeInTableView(tableView: not nullable NSTableView): Boolean;

    method tableViewSelectionDidChange(notification: not nullable NSNotification);
    begin

      if notification.object = DiskImagesTableView then begin
        var lRow := DiskImagesTableView.selectedRow;
        CurrentDisk := nil;
        ContentsTableView.reloadData;
        try
          CurrentDisk := new DiskImage withFile(Files[lRow]);
          ContentsTableView.reloadData;
        except
          on E: Exception do
            NSLog('E %@', E);
        end;
      end;

      if notification.object = ContentsTableView then begin
        CurrentFile := nil;
        var lRow := ContentsTableView.selectedRow;
        if lRow > -1 then begin

          CurrentFile := CurrentDisk.Files[lRow];
          ShowFile(CurrentDisk.Files[lRow]) inViewer(ViewersPopup.selectedItem.representedObject);

        end;

      end;

    end;

    //method tableViewColumnDidMove(notification: not nullable NSNotification);
    //method tableViewColumnDidResize(notification: not nullable NSNotification);
    //method tableViewSelectionIsChanging(notification: not nullable NSNotification);

    method UpdateViewerMenu;
    begin
      ViewersPopup.removeAllItems;
      for each v in Viewers.OrderBy(v -> v.Name) do begin
        var m := new NSMenuItem withTitle(v.Name) action(nil) keyEquivalent("");
        m.representedObject := v;
        ViewersPopup.menu.addItem(m);
      end;
    end;

    method ShowFile(aFile: D64File) inViewer(aViewer: Viewer);
    begin
      for each v in ViewerPlaceholderView.subviews.copy do
        v.removeFromSuperview;
      if assigned(aFile) and not aFile.IsDirectory then begin
        var lView := aViewer.GetViewForFile(aFile);
        if aFile = CurrentFile then begin

          lView.translatesAutoresizingMaskIntoConstraints := true;
          lView.autoresizingMask := NSAutoresizingMaskOptions.NSViewWidthSizable or NSAutoresizingMaskOptions.NSViewHeightSizable;
          lView.frame := ViewerPlaceholderView.bounds;

          //lView.translatesAutoresizingMaskIntoConstraints := false;
          ViewerPlaceholderView.addSubview(lView);
          //ViewerPlaceholderView.addConstraint(NSLayoutConstraint.constraintWithItem(lView) attribute(NSLayoutAttribute.Top)    relatedBy(NSLayoutRelation.Equal) toItem(ViewerPlaceholderView) attribute(NSLayoutAttribute.Top) multiplier(1) constant(0));
          //ViewerPlaceholderView.addConstraint(NSLayoutConstraint.constraintWithItem(lView) attribute(NSLayoutAttribute.Bottom) relatedBy(NSLayoutRelation.Equal) toItem(ViewerPlaceholderView) attribute(NSLayoutAttribute.Bottom) multiplier(1) constant(0));
          //ViewerPlaceholderView.addConstraint(NSLayoutConstraint.constraintWithItem(lView) attribute(NSLayoutAttribute.Left)   relatedBy(NSLayoutRelation.Equal) toItem(ViewerPlaceholderView) attribute(NSLayoutAttribute.Left) multiplier(1) constant(0));
          //ViewerPlaceholderView.addConstraint(NSLayoutConstraint.constraintWithItem(lView) attribute(NSLayoutAttribute.Right)  relatedBy(NSLayoutRelation.Equal) toItem(ViewerPlaceholderView) attribute(NSLayoutAttribute.Right) multiplier(1) constant(0));
        end;
      end;
    end;

  end;

end.