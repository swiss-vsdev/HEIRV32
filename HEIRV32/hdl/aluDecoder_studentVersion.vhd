-- Setup ALU operation based on instruction
ARCHITECTURE studentVersion OF aluDecoder IS
BEGIN

  decode : process(op, funct3, funct7, ALUOp)
  begin
    case ALUOp is
      when "00" => ALUControl <= "000";
	  when "01" => ALUControl <= "001";
      when others =>
        if (funct3 = "000" and op = '1' and funct7 = '1') then
          ALUControl <= "001";
		elsif (funct3 = "000") then
		  ALUControl <= "000";
        elsif (funct3 = "101" and funct7 = '0') then
          ALUControl <= "111";
		elsif (funct3 = "001") then
		  ALUControl <= "110";
		elsif (funct3 = "010") then
		  ALUControl <= "101";
		elsif (funct3 = "100") then
		  ALUControl <= "100";
		elsif (funct3 = "110") then
		  ALUControl <= "011";
		elsif (funct3 = "111") then
		  ALUControl <= "010";
		else
		  ALUControl <= "000";
        end if;
    end case;
  end process decode;

END ARCHITECTURE studentVersion;
