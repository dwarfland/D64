namespace D64Browser;

type
  PlainTextViewer = public class(TextBasedViewer)
  public
    method CanHandleFile(aFile: not nullable D64File): ViewerRole; override;
    begin
      result := ViewerRole.CanHandle;
    end;

    property Name: not nullable String read "Text"; override;

  protected
    method GetTextForFile(aFile: not nullable D64File): not nullable String; override;
    begin
      var lBytes := aFile.GetBytes.ToArray;
      result := PETSCII.GetString(lBytes);
    end;
  end;

end.