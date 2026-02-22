namespace D64Browser;

//
// Based on Info from http://unusedino.de/ec64/technical/misc/vic656x/colors/
//

type
  C64Colors = public static class
  public
    property Black:     NSColor := GetColor($00); lazy; readonly; // Black
    property White:     NSColor := GetColor($01); lazy; readonly; // White
    property Red:       NSColor := GetColor($02); lazy; readonly; // Red
    property Cyan:      NSColor := GetColor($03); lazy; readonly; // Cyan
    property Purple:    NSColor := GetColor($04); lazy; readonly; // Purple
    property Green:     NSColor := GetColor($05); lazy; readonly; // Green
    property Blue:      NSColor := GetColor($06); lazy; readonly; // Blue
    property Yellow:    NSColor := GetColor($07); lazy; readonly; // Yellow
    property LightRed:  NSColor := GetColor($08); lazy; readonly; // Light Red
    property LightGreen: NSColor := GetColor($09); lazy; readonly; // Light Green
    property LightBlue: NSColor := GetColor($0A); lazy; readonly; // Light Blue
    property LightGrey: NSColor := GetColor($0B); lazy; readonly; // Light Grey
    property DarkGrey:  NSColor := GetColor($0C); lazy; readonly; // Dark Grey
    property LightYellow: NSColor := GetColor($0D); lazy; readonly; // Light Yellow
    property DarkBlue:  NSColor := GetColor($0E); lazy; readonly; // Dark Blue
    property LightPurple: NSColor := GetColor($0F); lazy; readonly; // Light Purple

    class method initialize; override;
    begin
      fRGB := [[  0.0/256.0,  0.0/256.0,  0.0/256.0], // $00: Black
               [255.0/256.0,255.0/256.0,255.0/256.0], // $01: White
               [255.0/256.0,  0.0/256.0,  0.0/256.0], // $02: Red
               [  0.0/256.0,255.0/256.0,255.0/256.0], // $03: Cyan
               [128.0/256.0,  0.0/256.0,128.0/256.0], // $04: Purple
               [  0.0/256.0,255.0/256.0,  0.0/256.0], // $05: Green
               [  0.0/256.0,  0.0/256.0,255.0/256.0], // $06: Blue
               [255.0/256.0,255.0/256.0,  0.0/256.0], // $07: Yellow
               [255.0/256.0,128.0/256.0,128.0/256.0], // $08: Light Red
               [128.0/256.0,255.0/256.0,128.0/256.0], // $09: Light Green
               [128.0/256.0,128.0/256.0,255.0/256.0], // $0A: Light Blue
               [192.0/256.0,192.0/256.0,192.0/256.0], // $0B: Light Grey
               [128.0/256.0,128.0/256.0,128.0/256.0], // $0C: Dark Grey
               [255.0/256.0,255.0/256.0,128.0/256.0], // $0D: Light Yellow
               [  0.0/256.0,  0.0/256.0,128.0/256.0], // $0E: Dark Blue
               [255.0/256.0,128.0/256.0,255.0/256.0]];// $0F: Light Purple
    end;

  private

    class method GetColor(aIndex: Int32): NSColor;
    begin
      result := NSColor.colorWithCalibratedRed(fRGB[aIndex][0]) green(fRGB[aIndex][1]) blue(fRGB[aIndex][2]) alpha(1.0);
    end;

    fRGB: array[0..15] of array[0..2] of Double;

  end;

  C128VdcColors = public static class
  public
    // RGBI 16-color palette used by the 8563 VDC (80-column mode)

    property Black:        NSColor := GetColor($00); lazy; readonly;
    property DarkBlue:     NSColor := GetColor($01); lazy; readonly;
    property DarkGreen:    NSColor := GetColor($02); lazy; readonly;
    property DarkCyan:     NSColor := GetColor($03); lazy; readonly;
    property DarkRed:      NSColor := GetColor($04); lazy; readonly;
    property DarkMagenta:  NSColor := GetColor($05); lazy; readonly;
    property Brown:        NSColor := GetColor($06); lazy; readonly;
    property LightGray:    NSColor := GetColor($07); lazy; readonly;

    property DarkGray:     NSColor := GetColor($08); lazy; readonly;
    property Blue:         NSColor := GetColor($09); lazy; readonly;
    property Green:        NSColor := GetColor($0A); lazy; readonly;
    property Cyan:         NSColor := GetColor($0B); lazy; readonly;
    property Red:          NSColor := GetColor($0C); lazy; readonly;
    property Magenta:      NSColor := GetColor($0D); lazy; readonly;
    property Yellow:       NSColor := GetColor($0E); lazy; readonly;
    property White:        NSColor := GetColor($0F); lazy; readonly;

    class method initialize; override;
    begin
      // Standard RGBI palette (0 or 170, plus intensity → 255)
      // This matches common C128 80-col emulator output.

      fRGB := [
        [  0.0/255.0,   0.0/255.0,   0.0/255.0], // $00 Black
        [  0.0/255.0,   0.0/255.0, 170.0/255.0], // $01 Dark Blue
        [  0.0/255.0, 170.0/255.0,   0.0/255.0], // $02 Dark Green
        [  0.0/255.0, 170.0/255.0, 170.0/255.0], // $03 Dark Cyan
        [170.0/255.0,   0.0/255.0,   0.0/255.0], // $04 Dark Red
        [170.0/255.0,   0.0/255.0, 170.0/255.0], // $05 Dark Magenta
        [170.0/255.0,  85.0/255.0,   0.0/255.0], // $06 Brown / Dark Yellow
        [170.0/255.0, 170.0/255.0, 170.0/255.0], // $07 Light Gray

        [ 85.0/255.0,  85.0/255.0,  85.0/255.0], // $08 Dark Gray
        [ 85.0/255.0,  85.0/255.0, 255.0/255.0], // $09 Blue
        [ 85.0/255.0, 255.0/255.0,  85.0/255.0], // $0A Green
        [ 85.0/255.0, 255.0/255.0, 255.0/255.0], // $0B Cyan
        [255.0/255.0,  85.0/255.0,  85.0/255.0], // $0C Red
        [255.0/255.0,  85.0/255.0, 255.0/255.0], // $0D Magenta
        [255.0/255.0, 255.0/255.0,  85.0/255.0], // $0E Yellow
        [255.0/255.0, 255.0/255.0, 255.0/255.0]  // $0F White
      ];
    end;

  private
    class method GetColor(aIndex: Int32): NSColor;
    begin
      result := NSColor.colorWithCalibratedRed(fRGB[aIndex][0])
                                       green(fRGB[aIndex][1])
                                        blue(fRGB[aIndex][2])
                                       alpha(1.0);
    end;

    fRGB: array[0..15] of array[0..2] of Double;
  end;

end.