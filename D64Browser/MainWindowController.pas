namespace D64Browser;

uses
  D64;

type
  [IBObject]
  MainWindowController = public class(NSWindowController, INSTableViewDataSource, INSTableViewDelegate)
  private
  protected

  public
    constructor;
    begin
      inherited constructor withWindowNibName('MainWindowController');

      var fontURL := NSBundle.mainBundle.URLForResource("CBM") withExtension("ttf");
      var lError: CFErrorRef;
      if not CTFontManagerRegisterFontsForURL(bridge<CFURLRef>(fontURL), CTFontManagerScope.Process, var lError) then
        NSLog('error loading font: %ld', lError);
    end;

    method windowDidLoad; override;
    begin
      inherited windowDidLoad();
      //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), begin

        //dispatch_async(dispatch_get_main_queue(), begin

        //end);
      //end);

      ContentsTableView.intercellSpacing := NSMakeSize(0, 0);
      ContentsTableView.backgroundColor := C64Colors.Blue;

      Files := Folder.GetFiles("/Users/mh/Dropbox/C64", true).Select(f -> f as String).Where(f -> f.PathExtension in [".d64", ".d61"]).OrderBy(f -> f.LastPathComponent).ToList<String>();
      DiskImagesTableView.reloadData();
    end;

    [IBOutlet] property DiskImagesTableView: NSTableView;
    [IBOutlet] property ContentsTableView: NSTableView;
    [IBOutlet] property ViewerPlaceholderView: NSView;
    [IBOutlet] property ViewersPopup: NSPopUpButton;

    [IBAction]
    method LoadImages(aSender: id);
    begin
    end;

    [IBAction]
    method SaveFileToDisk(aSender: id);
    begin
    end;


  private

    property Files: List<String>;
    property CurrentDisk: DiskImage;

    property Viewers := new List<Viewer>(new BinaryViewer, new DisassemblyViewer);

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
          (result as NSTextFieldCell).textColor := C64Colors.LightBlue;
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
        var lRow := ContentsTableView.selectedRow;
        if lRow > -1 then begin

          ShowFile(CurrentDisk.Files[lRow]) inViewer(Viewers[1]);

        end;

      end;

    end;

    //method tableViewColumnDidMove(notification: not nullable NSNotification);
    //method tableViewColumnDidResize(notification: not nullable NSNotification);
    //method tableViewSelectionIsChanging(notification: not nullable NSNotification);

    method ShowFile(aFile: D64File) inViewer(aViewer: Viewer);
    begin
      var lView := aViewer.GetViewForFile(aFile);
      for each v in ViewerPlaceholderView.subviews.copy do
        v.removeFromSuperview;
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

end.