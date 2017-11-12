namespace D64Browser;

type
  DisassemblyViewer = public class(TextBasedViewer)
  public
    method CanHandleFile(aFile: not nullable D64File): ViewerRole; override;
    begin
      result := ViewerRole.CanHandle;
    end;

  protected

    method GetTextForFile(aFile: not nullable D64File): not nullable String; override;
    begin
      var lDisassemblyGenerator := new DisassemblyGenerator;
      result := lDisassemblyGenerator.Generate(aFile.GetBytes.ToArray);
    end;
  end;

  DisassemblyGenerator = unit class
  public

    method Generate(aBytes: array of Byte): not nullable String;
    begin
      lBytes := aBytes;
      result := "";

      len := length(lBytes);
      i := 0;
      try
        while i < len do begin
          var j = i;
          var lOp := GenerateOpcode;
          inc(i);
          var lLine := "";
          while j < i do begin
            lLine := lLine+Convert.ToHexString(lBytes[j], 2)+" ";
            inc(j);
          end;
          result := result+lLine.PadEnd(3*3)+lOp+Environment.LineBreak;;
        end;
      except
        on E: UnexpectedEndExcetpion do
          result := result+"// unexpecyted end"
      end;

    end;

  private

    var lBytes: array of Byte;
    var len: Int32;
    var i: Int32;

    method GetNextByte: Byte;
    begin
      inc(i);
      result := lBytes[i];
    end;

    method GetNextByteAsHex: String;
    begin
      inc(i);
      result := Convert.ToHexString(lBytes[i], 2);
    end;

    method GetNextByteAsRelative: String;
    begin
      inc(i);
      var lVal := int8_t(lBytes[i]);
      var lAbs := Math.Abs(lVal);
      result := " "+(if lVal < 0 then "-" else "")+Convert.ToHexString(lAbs, 2);
    end;

    method GetNextByteAsInX: String;
    begin
      result := " ($"+GetNextByteAsHex+"),X";
    end;

    method GetNextByteAsInY: String;
    begin
      result := " ($"+GetNextByteAsHex+"),Y";
    end;

    method GetNextByteAsZP: String;
    begin
      result := " $"+GetNextByteAsHex;
    end;

    method GetNextByteAsZPX: String;
    begin
      result := GetNextByteAsZP+",X";
    end;

    method GetNextByteAsZPY: String;
    begin
      result := GetNextByteAsZP+",Y";
    end;

    method GetNextByteAsAbs: String;
    begin
      var lLow := GetNextByteAsHex;
      var lHigh := GetNextByteAsHex;
      result := " $"+lHigh+lLow;
    end;

    method GetNextByteAsAbsX: String;
    begin
      result := GetNextByteAsAbs+",X";
    end;

    method GetNextByteAsAbsY: String;
    begin
      result := GetNextByteAsAbs+",Y";
    end;

    method GetNextByteAsImm: String;
    begin
      result := " #"+GetNextByteAsHex;
    end;

    method GenerateOpcode(): String;
    begin
      var lCode := lBytes[i];
      case lCode of
        $00: result := "BRK";
        $01: result := "ORA"+GetNextByteAsInX;
        $02: result := "KIL";
        $03: result := "SLO"+GetNextByteAsInX;
        $04: result := "NOP"+GetNextByteAsZP;
        $05: result := "ORA"+GetNextByteAsZP;
        $06: result := "ASL"+GetNextByteAsZP;
        $07: result := "SLO"+GetNextByteAsZP;
        $08: result := "PHP";
        $09: result := "ORA"+GetNextByteAsImm;
        $0a: result := "ASL";
        $0b: result := "ANC"+GetNextByteAsImm;
        $0c: result := "NOP"+GetNextByteAsAbs;
        $0d: result := "ORA"+GetNextByteAsAbs;
        $0e: result := "ASL"+GetNextByteAsAbs;
        $0f: result := "SLO"+GetNextByteAsAbs;

        $10: result := "BRK"+GetNextByteAsRelative;
        $11: result := "ORA"+GetNextByteAsInY;
        $12: result := "KIL";
        $13: result := "SLO"+GetNextByteAsInY;
        $14: result := "NOP"+GetNextByteAsZPX;
        $15: result := "ORA"+GetNextByteAsZPX;
        $16: result := "ASL"+GetNextByteAsZPX;
        $17: result := "SLO"+GetNextByteAsZPY;
        $18: result := "PHP";
        $19: result := "ORA"+GetNextByteAsAbsY;
        $1a: result := "ASL";
        $1b: result := "ANC"+GetNextByteAsAbsY;
        $1c: result := "NOP"+GetNextByteAsAbsX;
        $1d: result := "ORA"+GetNextByteAsAbsX;
        $1e: result := "ASL"+GetNextByteAsAbsX;
        $1f: result := "SLO"+GetNextByteAsAbsX;

        $20: result := "JSR";
        $21: result := "AND";
        $22: result := "KIL";
        $23: result := "RLA";
        $24: result := "BIT";
        $25: result := "AND";
        $26: result := "ROL";
        $27: result := "RLA";
        $28: result := "PLP";
        $29: result := "AND";
        $2a: result := "ROL";
        $2b: result := "ANC";
        $2c: result := "BIT";
        $2d: result := "AND";
        $2e: result := "ROL";
        $2f: result := "RLA";

        $30: result := "BMI";
        $31: result := "AND";
        $32: result := "KIL";
        $33: result := "RLA";
        $34: result := "NOP";
        $35: result := "AND";
        $36: result := "ROL";
        $37: result := "RLA";
        $38: result := "SEC";
        $39: result := "AND";
        $3a: result := "NOP";
        $3b: result := "RLA";
        $3c: result := "NOP";
        $3d: result := "AND";
        $3e: result := "ROL";
        $3f: result := "RLA";

        $40: result := "RTI";
        $41: result := "EOR";
        $42: result := "KIL";
        $43: result := "SRE";
        $44: result := "NOP";
        $45: result := "EOR";
        $46: result := "LSR";
        $47: result := "SRE";
        $48: result := "PHA";
        $49: result := "EOR";
        $4a: result := "LSR";
        $4b: result := "ALR";
        $4c: result := "JMP";
        $4d: result := "EOR";
        $4e: result := "LSR";
        $4f: result := "SRE";

        $50: result := "BVC";
        $51: result := "EOR";
        $52: result := "KIL";
        $53: result := "SRE";
        $54: result := "NOP";
        $55: result := "EOR";
        $56: result := "LSR";
        $57: result := "SRE";
        $58: result := "CLI";
        $59: result := "EOR";
        $5a: result := "NOP";
        $5b: result := "SRE";
        $5c: result := "NOP";
        $5d: result := "EOR";
        $5e: result := "LSR";
        $5f: result := "SRE";

        $60: result := "RTS";
        $61: result := "ADC";
        $62: result := "KIL";
        $63: result := "RRA";
        $64: result := "NOP";
        $65: result := "ADC";
        $66: result := "ROR";
        $67: result := "RRA";
        $68: result := "PLA";
        $69: result := "ADC";
        $6a: result := "ROR";
        $6b: result := "ARR";
        $6c: result := "JMP";
        $6d: result := "ADC";
        $6e: result := "ROR";
        $6f: result := "RRA";

        $70: result := "BVS";
        $71: result := "ADC";
        $72: result := "KIL";
        $73: result := "RRA";
        $74: result := "NOP";
        $75: result := "ADC";
        $76: result := "ROR";
        $77: result := "RRA";
        $78: result := "SEI";
        $79: result := "ADC";
        $7a: result := "NOP";
        $7b: result := "RRA";
        $7c: result := "NOP";
        $7d: result := "ADC";
        $7e: result := "ROR";
        $7f: result := "RRA";

        $80: result := "NOP";
        $81: result := "STA";
        $82: result := "NOP";
        $83: result := "SAX";
        $84: result := "STY";
        $85: result := "STA";
        $86: result := "STX";
        $87: result := "SAX";
        $88: result := "DEY";
        $89: result := "NOP";
        $8a: result := "TXA";
        $8b: result := "XXA";
        $8c: result := "STY";
        $8d: result := "STA";
        $8e: result := "STX";
        $8f: result := "SAX";

        $90: result := "BCC";
        $91: result := "STA";
        $92: result := "KIL";
        $93: result := "AHX";
        $94: result := "STY";
        $95: result := "STA";
        $96: result := "STX";
        $97: result := "SAX";
        $98: result := "TYA";
        $99: result := "STA";
        $9a: result := "TXS";
        $9b: result := "TAS";
        $9c: result := "SHY";
        $9d: result := "STA";
        $9e: result := "SHX";
        $9f: result := "AHX";

        $a0: result := "LDY";
        $a1: result := "LDA";
        $a2: result := "LDX";
        $a3: result := "LAX";
        $a4: result := "LDY";
        $a5: result := "LDA";
        $a6: result := "LDX";
        $a7: result := "LAX";
        $a8: result := "TAY";
        $a9: result := "LDA";
        $aa: result := "TAX";
        $ab: result := "LAX";
        $ac: result := "LDY";
        $ad: result := "LDA";
        $ae: result := "LDX";
        $af: result := "LAX";

        $b0: result := "BCS";
        $b1: result := "LDA";
        $b2: result := "KIL";
        $b3: result := "LAX";
        $b4: result := "LDY";
        $b5: result := "LDA";
        $b6: result := "LDX";
        $b7: result := "LAX";
        $b8: result := "CLV";
        $b9: result := "LDA";
        $ba: result := "TSX";
        $bb: result := "LAS";
        $bc: result := "LDY";
        $bd: result := "LDA";
        $be: result := "LDX";
        $bf: result := "LAX";

        $c0: result := "CPY";
        $c1: result := "CMP";
        $c2: result := "NOP";
        $c3: result := "DCP";
        $c4: result := "CPY";
        $c5: result := "CMP";
        $c6: result := "DEC";
        $c7: result := "DCP";
        $c8: result := "INY";
        $c9: result := "CMP";
        $ca: result := "DEX";
        $cb: result := "AXS";
        $cc: result := "CMY";
        $cd: result := "CMP";
        $ce: result := "DEC";
        $cf: result := "DCP";

        $d0: result := "BNE";
        $d1: result := "CMP";
        $d2: result := "KIL";
        $d3: result := "DCP";
        $d4: result := "NOP";
        $d5: result := "CMP";
        $d6: result := "DEC";
        $d7: result := "DCP";
        $d8: result := "CLD";
        $d9: result := "CMP";
        $da: result := "NOP";
        $db: result := "DCP";
        $dc: result := "NOP";
        $dd: result := "CMP";
        $de: result := "DEC";
        $df: result := "DCP";

        $e0: result := "CPX";
        $e1: result := "SBC";
        $e2: result := "NOP";
        $e3: result := "ISC";
        $e4: result := "CPX";
        $e5: result := "SBC";
        $e6: result := "INC";
        $e7: result := "ISC";
        $e8: result := "INX";
        $e9: result := "SBC";
        $ea: result := "NOP";
        $eb: result := "SBC";
        $ec: result := "CPS";
        $ed: result := "SBC";
        $ee: result := "INC";
        $ef: result := "ISC";

        $f0: result := "BEW";
        $f1: result := "SBC";
        $f2: result := "KIL";
        $f3: result := "ISC";
        $f4: result := "NOP";
        $f5: result := "SBC";
        $f6: result := "INC";
        $f7: result := "ISC";
        $f8: result := "SED";
        $f9: result := "SBC";
        $fa: result := "NOP";
        $fb: result := "ISC";
        $fc: result := "NOP";
        $fd: result := "SBC";
        $fe: result := "INC";
        $ff: result := "ISC";
      end;
      //lResult := lResult+GenerateOpcode()+Environment.LineBreak;
    end;

  end;

  UnexpectedEndExcetpion = unit class(Exception)
  end;

end.