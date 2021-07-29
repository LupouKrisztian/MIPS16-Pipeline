----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.04.2021 10:11:44
-- Design Name: 
-- Module Name: EX - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EX is
  Port ( RD1: in std_logic_vector (15 downto 0);
         RD2: in std_logic_vector (15 downto 0);
         Ext_Imm: in std_logic_vector (15 downto 0);
         func: in std_logic_vector (2 downto 0);
         rt: in std_logic_vector (2 downto 0);
         rd: in std_logic_vector (2 downto 0);
         PCplus1: in std_logic_vector (15 downto 0);
         ALUOp: in std_logic_vector (2 downto 0);
         ALUSrc: in std_logic;
         RegDst: in std_logic;
         sa: in std_logic;
         rWA: out std_logic_vector (2 downto 0);
         BranchAddress: out std_logic_vector (15 downto 0);
         ALURes: out std_logic_vector (15 downto 0);
         Zero: out std_logic );
end EX;

architecture Behavioral of EX is

signal ALUCtrl: std_logic_vector(2 downto 0);
signal ALUIn2: STD_LOGIC_VECTOR(15 downto 0);
signal ALUResAux: std_logic_vector(15 downto 0);

begin

--selectia pt. al doilea input al lui ALU 
process(ALUSrc,RD2,Ext_Imm)
begin
     case ALUSrc is
     when '0' => ALUIn2 <= RD2;
     when '1' => ALUIn2 <= Ext_Imm;
     when others => ALUIn2 <= (others => '0');
     end case; 
end process;

--ALU Control
process(ALUOp, func)
begin
case ALUOp is
	when "001" =>-- type R
				 case func is
					 when "000"=> ALUCtrl <= "000"; -- ADD	
					 when "001"=> ALUCtrl <= "001"; -- SUB
					 when "010"=> ALUCtrl <= "010"; -- SLL
					 when "011"=> ALUCtrl <= "011"; -- SRL
					 when "100"=> ALUCtrl <= "100"; -- AND
					 when "101"=> ALUCtrl <= "101"; -- OR
					 when "110"=> ALUCtrl <= "110"; -- XOR
					 when "111"=> ALUCtrl <= "111"; -- SRA
					 when others => ALUCtrl <= (others => 'X'); -- unknown
				 end case;
	when "010" => ALUCtrl <= "000"; -- ADDI, LW, SW
	when "011" => ALUCtrl <= "001"; -- BEQ
	when "100" => ALUCtrl <= "100"; -- ANDI
	when "101" => ALUCtrl <= "101"; -- ORI
	when others => ALUCtrl <= (others => 'X'); -- J	
end case;
end process;

--ALU
process(ALUCtrl, RD1, AluIn2, sa)
begin
case ALUCtrl  is
    when "000" => -- ADD
        ALUResAux <= RD1 + ALUIn2;
    when "001" =>  -- SUB
        ALUResAux <= RD1 - ALUIn2;                                    
    when "010" => -- SLL
        case sa is
            when '1' => ALUResAux <= ALUIn2(14 downto 0) & "0";
            when '0' => ALUResAux <= ALUIn2;
            when others => ALUResAux <= (others => '0');
        end case;
    when "011" => -- SRL
        case sa is
            when '1' => ALUResAux <= "0" & ALUIn2(15 downto 1);
            when '0' => ALUResAux <= ALUIn2;
            when others => ALUResAux <= (others => '0');
        end case;
    when "100" => -- AND
        ALUResAux <= RD1 and ALUIn2;		
    when "101" => -- OR
        ALUResAux <= RD1 or ALUIn2; 
    when "110" => -- XOR
        ALUResAux <= RD1 xor ALUIn2;		
    when "111" => -- SRA
        if sa='1' then 
          ALUResAux <= ALUIn2(15) & ALUIn2(15 downto 1);             
        else
          ALUResAux <= ALUIn2; 
        end if;
    when others => -- unknown
        ALUResAux <= (others => '0');              
end case;
end process;

--detector de zero
process(ALUResAux)
begin
case ALUResAux is
    when X"0000" => Zero <= '1';
    when others => Zero <= '0';
end case;
end process;

--selectie rt/rd
process(RegDst,rt,rd)
begin
     case RegDst is
         when '0' => rWA <= rt;
         when '1' => rWA <= rd;
         when others => rWA <= (others => '0');
     end case;
end process;

--rezultat ALU
ALURes <= ALUResAux;

--adunarea pentru obtinerea adresei pentru branch
BranchAddress <= PCplus1 + Ext_Imm;    

end Behavioral;
