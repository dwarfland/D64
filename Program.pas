namespace D64;

type
  Program = class
  public

    class method Main(args: array of String): Int32;
    begin
      writeLn('Commondore D64 File Reader.');
      writeLn('Created by marc hoffman.');
      writeLn('Use at your own risk.');
      writeLn();
      if length(args) < 1 then begin
        writeLn("Syntax: D64 <filename.d64> <command>");
        writeLn();
        writeLn("Commands:");
        writeLn();
        writeLn("  --dir                                             (print directory listing)");
        writeLn("  --extract-file <0-based index> <destination>      (extarct file to local disk)");
        writeLn();
        exit 1;
      end;

      var lDisk := new DiskImage withFile(args[0]);

      if length(args) > 1 then begin

        case args[1] of
          "--dir": begin
              writeLn(#""0 "{lDisk.Name}"    {lDisk.Directory.DOSType}"");
              for each f in lDisk.Files do
                writeLn(#""{f.Size} "{f.Name}" {f.FileType}"");
              writeLn(#"{lDisk.Directory.FreeSectors} BLOCKS FREE ({lDisk.Directory.FreeSectors*lDisk.Format.SectorSize} BYTES)");
            end;
          "--files": begin
              for i: Int32 := 0 to lDisk.Files.Count-1 do begin
                var f := lDisk.Files[i];
                &write(#""{i}: {f.Size} "{f.Name}" {f.FileType}"");
                if f.FileType in ["PRG"] then
                  &write(#", {f.GetBytes.Length} bytes on disk");
                if f.LoadAddress ≠ $0801 then
                  &write(#", loads to ${Convert.ToHexString(f.LoadAddress, 4)}");
                writeLn();
              end;
            end;
          "--extract-file": begin
              if length(args) > 3 then begin
                var lIndex := Convert.TryToInt32(args[2]);
                if 0 <= lIndex < lDisk.Files.Count then begin
                  var lFile := lDisk.Files[lIndex];
                  var lBytes := lFile.GetBytes();
                  File.WriteBinary(args[3], lBytes);
                  writeLn(#"Wrote {lBytes.Length} bytes to {args[3]}");
                end
                else
                  writeLn("Invalid file index.");
              end;
            end;
        end;

      end;
    end;

  end;

end.
