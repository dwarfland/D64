﻿namespace D64;

type
  D64Info = public class
  public
    const TrackOffsets = [-1, // Tracks are one-based
                          $00000, $01500, $02A00, $03F00, $05400, $06900, $07E00, $09300, $0A800, $0BD00,
                          $0D200, $0E700, $0FC00, $11100, $12600, $13B00, $15000, $16500, $17800, $18B00,
                          $19E00, $1B100, $1C400, $1D700, $1EA00, $1FC00, $20E00, $22000, $23200, $24400,
                          $25600, $26700, $27800, $28900, $29A00, $2AB00, $2BC00, $2CD00, $2DE00, $2EF00];
    const SectorsPerTrack = [-1, // Tracks are one-based
                             21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
                             21, 21, 21, 21, 21, 21, 21, 19, 19, 19,
                             19, 19, 19, 19, 18, 18, 18, 18, 18, 18,
                             17, 17, 17, 17, 17, 17, 17, 17, 17, 17];
    const SectorSize = $100;
    const FileEntrySize = $20;
  end;

  D64Image = public class
  private
  protected
  public

    constructor withFile(aFilename: not nullable String);
    begin
      constructor withBinary(File.ReadBinary(aFilename));
    end;

    constructor withBinary(aBinary: not nullable Binary);
    begin
      if aBinary.Length < 174848 then
        raise new Exception("File to small to be a D64 image");
      Binary := aBinary;
      Directory := new D64Directory withImage(self);
    end;

    method GetSector(aSector: Integer) Track(aTrack: Integer): D64Sector;
    begin
      result := new D64Sector withImage(self) Sector(aSector) Track(aTrack);
    end;

    property Binary: ImmutableBinary read private write;
    property Directory: D64Directory read private write;
    property Files: ImmutableList<D64File> read Directory.Files;
    property Name: String read Directory.Name;

  end;

  D64Sector = public class
  public

    property Image: D64Image read private write;
    property Sector: Int32 read private write;
    property Track: Int32 read private write;
    property SectorOffset: Int32 read private write;

    property Bytes[aOffset: Byte]: Byte read get_Bytes; default;

    method GetBytes(aOffset: Byte; aCount: Int32): ImmutableBinary;
    begin
      if Integer(aOffset)+aCount > 256 then
        raise new Exception(String.Format("Invalid offset/count pair: {0},{1}", aOffset, aCount));

      result := Image.Binary.Subdata(SectorOffset+aOffset, aCount);
    end;

    method GetBytesAsArray(aOffset: Byte; aCount: Int32): array of Byte;
    begin
      if Integer(aOffset)+aCount > 256 then
        raise new Exception(String.Format("Invalid offset/count pair: {0},{1}", aOffset, aCount));

      result := Image.Binary.Read(SectorOffset+aOffset, aCount);
    end;

    method GetBytes(): ImmutableBinary; inline;
    begin
      result := GetBytes(0, D64Info.SectorSize);
    end;

    method GetBytesAsArray(): array of Byte; inline;
    begin
      result := GetBytesAsArray(0, D64Info.SectorSize);
    end;

    method GetString(aOffset: Byte; aCount: Int32): String;
    begin
      var lArray := GetBytesAsArray(aOffset, aCount);
      result := Encoding.ASCII.GetString(lArray).TrimEnd([#$a0]);
    end;

    [ToString]
    method ToString: String;
    begin
      result := Convert.ToHexString(Image.Binary.ToArray, SectorOffset, D64Info.SectorSize);
      var i := 32;
      while i < length(result) do begin
        result := result.Insert(i, Environment.LineBreak);
        inc(i, 32+length(Environment.LineBreak));
      end;
      result := String.Format("Track {0} Sector {1}:", Track, Sector)+Environment.LineBreak+result;
    end;

  unit
   constructor withImage(aImage: D64Image) Sector(aSector: Integer) Track(aTrack: Integer);
   begin
     Image := aImage;
     Sector := aSector;
     Track := aTrack;

     if (aTrack < 1) or (aTrack > length(D64Info.TrackOffsets)) then
       raise new Exception(String.Format("Invalid track number {0}", aTrack));

     var lTrackOffset := D64Info.TrackOffsets[aTrack];
     if lTrackOffset > Image.Binary.Length then
       raise new Exception(String.Format("Image too small to contain track {0}", aTrack));
     if (aSector < 0) or (aSector >= D64Info.SectorsPerTrack[aTrack]) then
       raise new Exception(String.Format("Invalid sector number {0} for track {1}", aSector, aTrack));

     SectorOffset := lTrackOffset+aSector*D64Info.SectorSize;
     if SectorOffset+D64Info.SectorSize > Image.Binary.Length then
       raise new Exception(String.Format("Image too small to contain sector {0} on track {1}", aSector, aTrack));
   end;

  private

    method get_Bytes(aOffset: Byte): Byte;
    begin
      var data := Image.Binary.Read(SectorOffset+aOffset, 1);
      result := data[0];
    end;

  end;

  D64Directory = public class
  public

    property Image: D64Image read private write;
    property BAMSector: D64Sector read private write;
    property BAM: ImmutableBinary read private write;
    property DiskVersion: Byte read BAMSector[2];
    property Name: String read private write;
    property FreeSectors: Int32 read private write;
    property TotalSectors: Int32 read private write;
    property Files: ImmutableList<D64File> read private write;

    [ToString]
    method ToString: String;
    begin
      result := "";
      result := result+String.Format("Name: '{0}'", Name)+Environment.LineBreak;
      result := result+String.Format("Disk Version: ${0}", Convert.ToHexString(DiskVersion))+Environment.LineBreak;
      result := result+String.Format("Free Sectors: {0} of {1}", FreeSectors, TotalSectors)+Environment.LineBreak;
      result := result+String.Format("Free Bytes: {0} of {1}", FreeSectors*D64Info.SectorSize, TotalSectors*D64Info.SectorSize)+Environment.LineBreak;
      for each f in Files do
        result := result+String.Format("'{0}' {1}, {2}", f.Name, f.FileType, f.Size)+Environment.LineBreak;
    end;

  unit

    constructor withImage(aImage: D64Image);
    begin
      Image := aImage;
      BAMSector := Image.GetSector(0) Track(18);

      Name := BAMSector.GetString($90, $10);

      BAM := BAMSector.GetBytes($04, $8f-$04);
      var lBAMBytes := BAM.ToArray;
      var lFree := 0;
      var lTotal := 0;
      for t: Byte := 1 to 35 do begin
        if t ≠ 18 then begin
          var lOffset := (t-1)*4;
          //writeLn(String.Format("{0} of {1} Free", BAM[lOffset], D64Info.SectorsPerTrack[t]));
          inc(lFree, lBAMBytes[lOffset]);
          inc(lTotal, D64Info.SectorsPerTrack[t]);
        end;
      end;
      FreeSectors := lFree;
      TotalSectors := lTotal;

      var lNextTrack := 18;
      var lNextSector := 1;

      var lFiles := new List<D64File>();
      while lNextTrack ≠ 0 do begin

        var lSector := Image.GetSector(lNextSector) Track(lNextTrack);
        var lBytes := lSector.GetBytesAsArray();
        lNextTrack := lBytes[$00];
        lNextSector := lBytes[$01];
        for f: Int32 := 0 to 7 do begin

          var lOffset := f*D64Info.FileEntrySize;
          if lBytes[lOffset+$01] = $ff then
            break;
          var lFileType := lBytes[lOffset+$02];
          if lFileType ≠ 0 then
            lFiles.Add(new D64File withImage(Image) Sector(lSector) &Index(f));

        end;
      end;
      Files := lFiles;

    end;

  end;

  D64File = public class
  public

    property Image: D64Image read private write;
    property FileTypeCode: Byte read private write;
    property FileType: String read private write;
    property Name: String read private write;
    property Size: Int32 read private write;
    property StartTrack: Byte read private write;
    property StartSector: Byte read private write;
    property &Locked: Byte read private write;
    property Closed: Byte read private write;

    property SideTrack: Byte read private write;
    property SideSector: Byte read private write;
    property RecordLength: Byte read private write;

    method GetBytes: ImmutableBinary;
    begin
      var lNextTrack := StartTrack;
      var lNextSector := StartSector;
      //var lResult := new Binary(Size); // H3 parameter 1 is "Int32" should be "array of Byte"
      var lResult := new Binary();

      while lNextTrack ≠ 0 do begin

        var lSector := Image.GetSector(lNextSector) Track(lNextTrack);
        var lBytes := lSector.GetBytesAsArray();

        lNextTrack := lBytes[$00];
        lNextSector := lBytes[$01];

        if lNextTrack ≠ 0 then
          lResult.Write(lBytes, $02, $100-$02)
        else if lNextSector ≤ $100-$02 then
          lResult.Write(lBytes, $02, lNextSector)
        else
          raise new Exception("Invalid size in last record.");

      end;
      result := lResult;

    end;

  unit

    constructor withImage(aImage: D64Image) Sector(aSector: D64Sector) &Index(aIndex: Byte);
    begin
      if (aIndex < 0) or (aIndex > 7) then
        raise new Exception(String.Format("Invalid fine Index: {0}", aIndex));

      Image := aImage;
      var lOffset := aIndex*D64Info.FileEntrySize;
      var lBytes := aSector.GetBytesAsArray(lOffset, D64Info.FileEntrySize);
      FileTypeCode := lBytes[$02];
      if FileTypeCode ≠ 0 then begin
        FileType := case (FileTypeCode and $07) of
          $00: "DEL";
          $01: "SEQ";
          $02: "PRG";
          $03: "USR";
          $04: "REL";
        end;
        &Locked := FileTypeCode and $40;
        &Closed := FileTypeCode and $80;
        StartTrack := lBytes[$03];
        StartSector := lBytes[$04];
        Name := aSector.GetString(lOffset+$05, $10);
        Size := Int32(lBytes[$1e])+Int32(lBytes[$1f])*$100;

        SideTrack := lBytes[$15];
        SideSector := lBytes[$16];
        RecordLength := lBytes[$17];

        //&write(Convert.ToHexString(lBytes));
        //&write(" ");
        //writeLn(String.Format("'{0}' {1}, {2}", Name, FileTypeCode, Size));
      end;
    end;
  end;

end.