-- Defines extend type based on instruction
ARCHITECTURE studentVersion OF instrDecoder IS
BEGIN

  decode : process(op)
  begin
    case op is
      when "0010011"  => immSrc <= "00";       -- I-Type
      when "0100011"  => immSrc <= "01";       -- S-Type
      when "1100011"  => immSrc <= "10";       -- B-Type
      when "1101111"  => immSrc <= "11";       -- J-Type
      when "1100111"  => immSrc <= "00";       -- J-Type (Jalr) 
      when "0000011"  => immSrc <= "00";       -- Lw-Type
      when others     => immSrc <= "--";          -- Others
    end case;
  end process decode;

END ARCHITECTURE studentVersion;
