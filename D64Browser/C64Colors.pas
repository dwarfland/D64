namespace D64Browser;

type
  // via http://unusedino.de/ec64/technical/misc/vic656x/colors/
  C64Colors = public static class
  private
  protected
  public
    property Blue: NSColor := NSColor.colorWithCalibratedRed( 53.0/256.0) green( 40.0/256.0) blue(121.0/256.0) alpha(1.0); readonly; lazy;
    property LightBlue: NSColor := NSColor.colorWithCalibratedRed(108.0/256.0) green( 94.0/256.0) blue(181.0/256.0) alpha(1.0); readonly; lazy;

  end;

end.