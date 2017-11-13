namespace D64Browser;

type
  BinaryViewer = public class(TextBasedViewer)
  public
    method CanHandleFile(aFile: not nullable D64File): ViewerRole; override;
    begin
      result := ViewerRole.CanHandle;
    end;

    property Name: not nullable String read "Binary"; override;

  protected

    method GetTextForFile(aFile: not nullable D64File): not nullable String; override;
    begin
      var lBytes := aFile.GetBytes.ToArray;
      var lCurrentHex := "";
      var lCurrentAscii := "";

      var lResult := new StringBuilder(length(lBytes)*6) as not nullable;
      for i: Int32 := 0 to length(lBytes) do begin
        lCurrentHex := lCurrentHex + Convert.ToHexString(lBytes[i], 2)+" ";
        lCurrentAscii := lCurrentAscii + (if lBytes[i] not in [32..127] then "." else chr(lBytes[i]));
        if i and $0f = $0f then begin
          lResult.AppendLine(lCurrentHex.PadEnd(10*3+2)+" "+lCurrentAscii);
          lCurrentHex := "";
          lCurrentAscii := "";
        end
        else if i and $07 = $07 then begin
          lCurrentHex := lCurrentHex+"  ";
          lCurrentAscii := lCurrentAscii+" ";
        end;
      end;
      result := lResult.ToString() as not nullable;
    end;
  end;

end.