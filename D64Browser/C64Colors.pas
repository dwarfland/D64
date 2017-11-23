namespace D64Browser;

//
// Based on Info from http://unusedino.de/ec64/technical/misc/vic656x/colors/
//

type
  C64Colors = public static class
  public
    property Blue:      NSColor := GetColor($06); lazy; readonly;
    property LightBlue: NSColor := GetColor($0e); lazy; readonly;

    class method initialize; override;
    begin
      fRGB := [[  0.0/256.0,  0.0/256.0,  0.0/256.0], // $0-:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $01:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $02:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $03:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $04:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $05:
               [ 53.0/256.0, 40.0/256.0,121.0/256.0], // $06: Blue
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $07:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $08:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $09:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $0a:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $0b:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $0c:
               [  0.0/256.0,  0.0/256.0,  0.0/256.0], // $0d:
               [108.0/256.0, 94.0/256.0,181.0/256.0], // $0e: Light Blue
               [  0.0/256.0,  0.0/256.0,  0.0/256.0]];// $0f:
    end;

  private

    class method GetColor(aIndex: Int32): NSColor;
    begin
      result := NSColor.colorWithCalibratedRed(fRGB[aIndex][0]) green(fRGB[aIndex][1]) blue(fRGB[aIndex][2]) alpha(1.0);
    end;

    fRGB: array[0..15] of array[0..2] of Double;

  end;

end.