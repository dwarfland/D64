namespace D64Browser;

//
// Based on Info from https://www.c64-wiki.de/wiki/Opcode
//

type
  DisassemblyViewer = public class(TextBasedViewer)
  public

    method CanHandleFile(aFile: not nullable D64File): ViewerRole; override;
    begin
      result := ViewerRole.CanHandle;
    end;

    property Name: not nullable String read "Disassembly"; override;

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

      var lResult := new StringBuilder() as not nullable;
      len := length(lBytes);
      i := 0;
      try
        while i < len do begin
          var j := i;
          var lOp := GenerateOpcode;
          inc(i);
          var lLine := "";
          while j < i do begin
            lLine := lLine+Convert.ToHexString(lBytes[j], 2)+" ";
            inc(j);
          end;
          lResult.AppendLine(lLine.PadEnd(3*3)+lOp);
        end;
      except
        on E: UnexpectedEndExcetpion do
          lResult.Append("// unexpecyted end");
      end;

      result := lResult.ToString() as not nullable;
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

    method GetNextByteAsIndirect: String;
    begin
      result := " ($"+GetNextByteAsHex+")";
    end;

    method GetNextByteAsInX: String;
    begin
      result := GetNextByteAsIndirect+",X";
    end;

    method GetNextByteAsInY: String;
    begin
      result := GetNextByteAsIndirect+",Y";
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

    method GetNextByteAsAkk: String;
    begin
      result := " A";
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

        $20: result := "JSR"+GetNextByteAsAbs;
        $21: result := "AND"+GetNextByteAsInX;
        $22: result := "KIL";
        $23: result := "RLA"+GetNextByteAsInX;
        $24: result := "BIT"+GetNextByteAsZP;
        $25: result := "AND"+GetNextByteAsZP;
        $26: result := "ROL"+GetNextByteAsZP;
        $27: result := "RLA"+GetNextByteAsZP;
        $28: result := "PLP";
        $29: result := "AND"+GetNextByteAsImm;
        $2a: result := "ROL"+GetNextByteAsAkk;
        $2b: result := "ANC"+GetNextByteAsImm;
        $2c: result := "BIT"+GetNextByteAsAbs;
        $2d: result := "AND"+GetNextByteAsAbs;
        $2e: result := "ROL"+GetNextByteAsAbs;
        $2f: result := "RLA"+GetNextByteAsAbs;

        $30: result := "BMI"+GetNextByteAsRelative;
        $31: result := "AND"+GetNextByteAsInY;
        $32: result := "KIL";
        $33: result := "RLA"+GetNextByteAsInY;
        $34: result := "NOP"+GetNextByteAsZPX;
        $35: result := "AND"+GetNextByteAsZPX;
        $36: result := "ROL"+GetNextByteAsZPX;
        $37: result := "RLA"+GetNextByteAsZPY;
        $38: result := "SEC";
        $39: result := "AND"+GetNextByteAsAbsY;
        $3a: result := "NOP";
        $3b: result := "RLA"+GetNextByteAsAbsY;
        $3c: result := "NOP"+GetNextByteAsAbsX;
        $3d: result := "AND"+GetNextByteAsAbsX;
        $3e: result := "ROL"+GetNextByteAsAbsX;
        $3f: result := "RLA"+GetNextByteAsAbsX;

        $40: result := "RTI";
        $41: result := "EOR"+GetNextByteAsInX;
        $42: result := "KIL";
        $43: result := "SRE"+GetNextByteAsInX;
        $44: result := "NOP"+GetNextByteAsZP;
        $45: result := "EOR"+GetNextByteAsZP;
        $46: result := "LSR"+GetNextByteAsZP;
        $47: result := "SRE"+GetNextByteAsZP;
        $48: result := "PHA";
        $49: result := "EOR"+GetNextByteAsImm;
        $4a: result := "LSR"+GetNextByteAsAkk;
        $4b: result := "ALR"+GetNextByteAsImm;
        $4c: result := "JMP"+GetNextByteAsAbs;
        $4d: result := "EOR"+GetNextByteAsAbs;
        $4e: result := "LSR"+GetNextByteAsAbs;
        $4f: result := "SRE"+GetNextByteAsAbs;

        $50: result := "BVC"+GetNextByteAsRelative;
        $51: result := "EOR"+GetNextByteAsInY;
        $52: result := "KIL";
        $53: result := "SRE"+GetNextByteAsInY;
        $54: result := "NOP"+GetNextByteAsZPX;
        $55: result := "EOR"+GetNextByteAsZPX;
        $56: result := "LSR"+GetNextByteAsZPX;
        $57: result := "SRE"+GetNextByteAsZPX;
        $58: result := "CLI";
        $59: result := "EOR"+GetNextByteAsAbsY;
        $5a: result := "NOP";
        $5b: result := "SRE"+GetNextByteAsAbsY;
        $5c: result := "NOP"+GetNextByteAsAbsX;
        $5d: result := "EOR"+GetNextByteAsAbsX;
        $5e: result := "LSR"+GetNextByteAsAbsX;
        $5f: result := "SRE"+GetNextByteAsAbsX;

        $60: result := "RTS";
        $61: result := "ADC"+GetNextByteAsInX;
        $62: result := "KIL";
        $63: result := "RRA"+GetNextByteAsInX;
        $64: result := "NOP"+GetNextByteAsZP;
        $65: result := "ADC"+GetNextByteAsZP;
        $66: result := "ROR"+GetNextByteAsZP;
        $67: result := "RRA"+GetNextByteAsZP;
        $68: result := "PLA";
        $69: result := "ADC"+GetNextByteAsImm;
        $6a: result := "ROR"+GetNextByteAsAkk;
        $6b: result := "ARR"+GetNextByteAsImm;
        $6c: result := "JMP"+GetNextByteAsIndirect;
        $6d: result := "ADC"+GetNextByteAsAbs;
        $6e: result := "ROR"+GetNextByteAsAbs;
        $6f: result := "RRA"+GetNextByteAsAbs;

        $70: result := "BVS"+GetNextByteAsRelative;
        $71: result := "ADC"+GetNextByteAsInY;
        $72: result := "KIL";
        $73: result := "RRA"+GetNextByteAsInY;
        $74: result := "NOP"+GetNextByteAsZPX;
        $75: result := "ADC"+GetNextByteAsZPX;
        $76: result := "ROR"+GetNextByteAsZPX;
        $77: result := "RRA"+GetNextByteAsZPX;
        $78: result := "SEI";
        $79: result := "ADC"+GetNextByteAsAbsY;
        $7a: result := "NOP";
        $7b: result := "RRA"+GetNextByteAsAbsY;
        $7c: result := "NOP"+GetNextByteAsAbsX;
        $7d: result := "ADC"+GetNextByteAsAbsX;
        $7e: result := "ROR"+GetNextByteAsAbsX;
        $7f: result := "RRA"+GetNextByteAsAbsX;

        $80: result := "NOP"+GetNextByteAsImm;
        $81: result := "STA"+GetNextByteAsInX;
        $82: result := "NOP";
        $83: result := "SAX"+GetNextByteAsInX;
        $84: result := "STY"+GetNextByteAsZP;
        $85: result := "STA"+GetNextByteAsZP;
        $86: result := "STX"+GetNextByteAsZP;
        $87: result := "SAX"+GetNextByteAsZP;
        $88: result := "DEY";
        $89: result := "NOP"+GetNextByteAsImm;
        $8a: result := "TXA";
        $8b: result := "XXA"+GetNextByteAsImm;
        $8c: result := "STY"+GetNextByteAsAbs;
        $8d: result := "STA"+GetNextByteAsAbs;
        $8e: result := "STX"+GetNextByteAsAbs;
        $8f: result := "SAX"+GetNextByteAsAbs;

        $90: result := "BCC"+GetNextByteAsRelative;
        $91: result := "STA"+GetNextByteAsInY;
        $92: result := "KIL";
        $93: result := "AHX"+GetNextByteAsInY;
        $94: result := "STY"+GetNextByteAsZPX;
        $95: result := "STA"+GetNextByteAsZPX;
        $96: result := "STX"+GetNextByteAsZPY;
        $97: result := "SAX"+GetNextByteAsZPY;
        $98: result := "TYA";
        $99: result := "STA"+GetNextByteAsAbsY;
        $9a: result := "TXS";
        $9b: result := "TAS"+GetNextByteAsAbsY;
        $9c: result := "SHY"+GetNextByteAsAbsX;
        $9d: result := "STA"+GetNextByteAsAbsX;
        $9e: result := "SHX";
        $9f: result := "AHX"+GetNextByteAsAbsY;

        $a0: result := "LDY"+GetNextByteAsImm;
        $a1: result := "LDA"+GetNextByteAsInX;
        $a2: result := "LDX"+GetNextByteAsImm;
        $a3: result := "LAX"+GetNextByteAsInX;
        $a4: result := "LDY"+GetNextByteAsZP;
        $a5: result := "LDA"+GetNextByteAsZP;
        $a6: result := "LDX"+GetNextByteAsZP;
        $a7: result := "LAX"+GetNextByteAsZP;
        $a8: result := "TAY";
        $a9: result := "LDA"+GetNextByteAsImm;
        $aa: result := "TAX";
        $ab: result := "LAX"+GetNextByteAsImm;
        $ac: result := "LDY"+GetNextByteAsAbs;
        $ad: result := "LDA"+GetNextByteAsAbs;
        $ae: result := "LDX"+GetNextByteAsAbs;
        $af: result := "LAX"+GetNextByteAsAbs;

        $b0: result := "BCS"+GetNextByteAsRelative;
        $b1: result := "LDA"+GetNextByteAsInY;
        $b2: result := "KIL";
        $b3: result := "LAX"+GetNextByteAsInY;
        $b4: result := "LDY"+GetNextByteAsZPX;
        $b5: result := "LDA"+GetNextByteAsZPX;
        $b6: result := "LDX"+GetNextByteAsZPY;
        $b7: result := "LAX"+GetNextByteAsZPY;
        $b8: result := "CLV";
        $b9: result := "LDA"+GetNextByteAsAbsY;
        $ba: result := "TSX";
        $bb: result := "LAS"+GetNextByteAsAbsY;
        $bc: result := "LDY"+GetNextByteAsAbsX;
        $bd: result := "LDA"+GetNextByteAsAbsX;
        $be: result := "LDX"+GetNextByteAsAbsY;
        $bf: result := "LAX"+GetNextByteAsAbsY;

        $c0: result := "CPY"+GetNextByteAsImm;
        $c1: result := "CMP"+GetNextByteAsInX;
        $c2: result := "NOP"+GetNextByteAsImm;
        $c3: result := "DCP"+GetNextByteAsInX;
        $c4: result := "CPY"+GetNextByteAsZP;
        $c5: result := "CMP"+GetNextByteAsZP;
        $c6: result := "DEC"+GetNextByteAsZP;
        $c7: result := "DCP"+GetNextByteAsZP;
        $c8: result := "INY";
        $c9: result := "CMP"+GetNextByteAsImm;
        $ca: result := "DEX";
        $cb: result := "AXS"+GetNextByteAsImm;
        $cc: result := "CMY"+GetNextByteAsAbs;
        $cd: result := "CMP"+GetNextByteAsAbs;
        $ce: result := "DEC"+GetNextByteAsAbs;
        $cf: result := "DCP"+GetNextByteAsAbs;

        $d0: result := "BNE"+GetNextByteAsRelative;
        $d1: result := "CMP"+GetNextByteAsInY;
        $d2: result := "KIL";
        $d3: result := "DCP"+GetNextByteAsInY;
        $d4: result := "NOP"+GetNextByteAsZPX;
        $d5: result := "CMP"+GetNextByteAsZPX;
        $d6: result := "DEC"+GetNextByteAsZPX;
        $d7: result := "DCP"+GetNextByteAsZPX;
        $d8: result := "CLD";
        $d9: result := "CMP"+GetNextByteAsAbsY;
        $da: result := "NOP";
        $db: result := "DCP"+GetNextByteAsAbsY;
        $dc: result := "NOP"+GetNextByteAsAbsX;
        $dd: result := "CMP"+GetNextByteAsAbsX;
        $de: result := "DEC"+GetNextByteAsAbsX;
        $df: result := "DCP"+GetNextByteAsAbsX;

        $e0: result := "CPX"+GetNextByteAsImm;
        $e1: result := "SBC"+GetNextByteAsInX;
        $e2: result := "NOP"+GetNextByteAsImm;
        $e3: result := "ISC"+GetNextByteAsInX;
        $e4: result := "CPX"+GetNextByteAsZP;
        $e5: result := "SBC"+GetNextByteAsZP;
        $e6: result := "INC"+GetNextByteAsZP;
        $e7: result := "ISC"+GetNextByteAsZP;
        $e8: result := "INX";
        $e9: result := "SBC"+GetNextByteAsImm;
        $ea: result := "NOP";
        $eb: result := "SBC"+GetNextByteAsImm;
        $ec: result := "CPS"+GetNextByteAsAbs;
        $ed: result := "SBC"+GetNextByteAsAbs;
        $ee: result := "INC"+GetNextByteAsAbs;
        $ef: result := "ISC"+GetNextByteAsAbs;

        $f0: result := "BEQ"+GetNextByteAsRelative;
        $f1: result := "SBC"+GetNextByteAsInY;
        $f2: result := "KIL";
        $f3: result := "ISC"+GetNextByteAsInY;
        $f4: result := "NOP"+GetNextByteAsZPX;
        $f5: result := "SBC"+GetNextByteAsZPX;
        $f6: result := "INC"+GetNextByteAsZPX;
        $f7: result := "ISC"+GetNextByteAsZPX;
        $f8: result := "SED";
        $f9: result := "SBC"+GetNextByteAsAbsY;
        $fa: result := "NOP";
        $fb: result := "ISC"+GetNextByteAsAbsY;
        $fc: result := "NOP"+GetNextByteAsAbsX;
        $fd: result := "SBC"+GetNextByteAsAbsX;
        $fe: result := "INC"+GetNextByteAsAbsX;
        $ff: result := "ISC"+GetNextByteAsAbsX;
      end;
      //lResult := lResult+GenerateOpcode()+Environment.LineBreak;
    end;

  end;

  UnexpectedEndExcetpion = unit class(Exception)
  end;

end.