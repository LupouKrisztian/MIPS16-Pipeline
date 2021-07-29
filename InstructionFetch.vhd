----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.03.2021 11:30:42
-- Design Name: 
-- Module Name: InstructionFetch - Behavioral
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

entity InstructionFetch is
  Port (clk: in std_logic;
        branchAddr: in std_logic_vector(15 downto 0);
        jumpAddr: in std_logic_vector(15 downto 0);
        Jump: in std_logic; 
        PCSrc: in std_logic;
        pcEn: in std_logic; 
        pcReset: in std_logic; 
        Instruction: out std_logic_vector(15 downto 0);
        nextInstrAddr: out std_logic_vector(15 downto 0));
end InstructionFetch;

architecture Behavioral of InstructionFetch is

--suma numerelor impare in bucla pentru primele 6 numere
--in RF(7) se retine rezultatul
type mem is array(0 to 31) of std_logic_vector(15 downto 0);
signal M: mem :=( B"001_000_001_0000010",     --0   X"2082"  addi $1,$0,2    initializeaza R1 cu 2
                  B"001_000_010_0000001",     --1   X"2101"  addi $2,$0,1    initializeaza R2 cu 1
                  B"001_000_011_0000011",     --2   X"2183"  addi $3,$0,3    initializeaza R3 cu 3
                  B"001_000_100_0000101",     --3   X"2205"  addi $4,$0,5    initializeaza R4 cu 5
                  B"011_010_010_0000000",     --4   X"6900"  sw $2,0($2)     stocheaza in memorie la adresa R2 valoarea din R2
                  B"011_001_011_0000000",     --5   X"6580"  sw $3,0($1)     stocheaza in memorie la adresa R1 valoarea din R3
                  B"010_001_101_0000000",     --6   X"4680"  lw $5,0($1)     incarca din memorie valorea de la adresa R1 in R5
                  B"010_010_110_0000000",     --7   X"4B00"  lw $6,0($2)     incarca din memorie valorea de la adresa R2 in R6
                  B"000_000_000_000_0_000",   --8   NoOp
                  B"000_000_000_000_0_000",   --9   NoOp
                  B"000_101_110_111_0_000",   --10  X"1770"  add $7,$5,$6    pune in R7 valoarea din R5 + valoarea din R6
                  B"001_000_110_0000001",     --11  X"2301"  addi $6,$0,1    pune in R6 valoarea 1
                  B"000_011_001_101_0_000",   --12  X"0CD0"  add $5,$3,$1    pune in R5 valoarea din R3 + valoarea din R1
                  B"000_000_000_000_0_000",   --13  NoOp
                  B"000_000_000_000_0_000",   --14  NoOp
                  B"000_111_101_111_0_000",   --15  X"1EF0"  add $7,$7,$5    pune in R7 valoarea din R7 + valoarea din R5
                  B"001_101_011_0000000",     --16  X"3580"  addi $3,$5,0    pune in R3 valoarea din R5
                  B"001_110_110_0000001",     --17  X"3B01"  addi $6,$6,1    pune in R6 valoarea din R6 + 1
                  B"000_000_000_000_0_000",   --18  NoOp
                  B"000_000_000_000_0_000",   --19  NoOp
                  B"100_110_100_0000100",     --20  X"9A04"  beq $6,$4,4     compara R6 cu R4, sunt egale, se sare peste o instructiune
                  B"000_000_000_000_0_000",   --21  NoOp
                  B"000_000_000_000_0_000",   --22  NoOp
                  B"000_000_000_000_0_000",   --23  NoOp
                  B"111_0000000001100",       --24  X"E00C"  j 12            salt la instructiunea cu indexul 12
                  B"000_000_000_000_0_000",   --25  NoOp
                  others=>x"0000");

signal pc: std_logic_vector(15 downto 0) := (others=>'0');
signal adderOut: std_logic_vector(15 downto 0) := (others=>'0');
signal muxBranch: std_logic_vector(15 downto 0) := (others=>'0');
signal nextAddr: std_logic_vector(15 downto 0) := (others=>'0');
                      
begin

--registrul PC
process(clk, pcReset)
begin 
    if pcReset = '1' then
         pc <= X"0000";
    elsif rising_edge(clk) and pcEn ='1'  then
         pc <= nextAddr;
    end if;
end process;
     
--ROM
Instruction <= M(conv_integer(pc(4 downto 0)));

--PC + 1
adderOut <= pc + 1;   

--iesirea PC + 1
nextInstrAddr <= adderOut; 

--MUX branch
process(PCSrc, adderOut, branchAddr)
begin
  case PCSrc is
      when '0' => muxBranch <= adderOut;
      when '1' => muxBranch <= branchAddr;
      when others => muxBranch <= X"0000";
  end case;
end process;

--Mux jump
process(Jump, jumpAddr, muxBranch)
begin
  case Jump is
      when '0' => nextAddr <= muxBranch;
      when '1' => nextAddr <= jumpAddr;
      when others => nextAddr <= X"0000";
  end case;
end process;

end Behavioral;
