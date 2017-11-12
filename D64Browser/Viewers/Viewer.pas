namespace D64Browser;

type
  ViewerRole = public enum (CannotHandle, CanHandle, CanHandleWell);

  Viewer = public abstract class
  public
    method GetViewForFile(aFile: not nullable D64File): not nullable NSView; abstract;
    method CanHandleFile(aFile: not nullable D64File): ViewerRole; abstract;
  end;

  TextBasedViewer = public abstract class(Viewer)
  public

    method GetViewForFile(aFile: not nullable D64File): not nullable NSView; override; final;
    begin
      var lView := new NSTextView as not nullable;
      lView.font := NSFont.fontWithName("Menlo") size(10);
      //lView.drawsBackground = false
      lView.textStorage:font := lView.font;
      lView.string := GetTextForFile(aFile);
      result := lView;
    end;

  protected
    method GetTextForFile(aFile: not nullable D64File): not nullable String; abstract;
  end;

  ImageBasedViewer = public abstract class(Viewer)
  public

    method GetViewForFile(aFile: not nullable D64File): not nullable NSView; override; final;
    begin
      var lView := new NSImageView as not nullable;
      lView.image := GetImageForFile(aFile);
      lView.imageScaling := NSImageScaling.ScaleProportionally;
      result := lView;
    end;

  protected
    method GetImageForFile(aFile: not nullable D64File): not nullable NSImage; abstract;
  end;

end.