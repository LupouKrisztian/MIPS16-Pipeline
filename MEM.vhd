----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.04.2021 10:56:28
-- Design Name: 
-- Module Name: MEM - Behavioral
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

entity MEM is
  Port (clk: in std_logic;
        en: in std_logic;
        MemWrite: in std_logic;	
        ALUResIn: in std_logic_vector(15 downto 0);
        WriteData: in std_logic_vector(15 downto 0);	
        MemData: out std_logic_vector(15 downto 0);
        ALUResOut: out std_logic_vector(15 downto 0) );
end MEM;

architecture Behavioral of MEM is

type mem_type is array (0 to 31) of std_logic_vector(15 downto 0);
signal MEM : mem_type:=(
		X"000A",
		X"000B",
		X"000C",
		X"000D",
		X"000E",
		X"000F",
		X"0009",
		X"0008",
		others =>X"0000");
		
begin

--Data Memory
process(clk) 			
begin
	if rising_edge(clk) then
		if en='1' and MemWrite='1' then
				MEM(conv_integer(ALUResIn(4 downto 0))) <= WriteData;			
		end if;	
	end if;
end process;


MemData <= MEM(conv_integer(ALUResIn(4 downto 0)));
ALUResOut <= ALUResIn;

end Behavioral;
