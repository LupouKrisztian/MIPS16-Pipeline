----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.02.2021 10:31:04
-- Design Name: 
-- Module Name: test_env - Behavioral
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

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
  Port (input: in std_logic;
        clk: in std_logic;
        en: out std_logic);
end component;

component SSD is
  Port (clk: in std_logic;
        data: in std_logic_vector(15 downto 0);
        an: out std_logic_vector(3 downto 0);
        cat: out std_logic_vector(6 downto 0));  
end component;

component InstructionFetch is
  Port (clk: in std_logic;
        branchAddr: in std_logic_vector(15 downto 0);
        jumpAddr: in std_logic_vector(15 downto 0);
        Jump: in std_logic; 
        PCSrc: in std_logic;
        pcEn: in std_logic; 
        pcReset: in std_logic; 
        Instruction: out std_logic_vector(15 downto 0);
        nextInstrAddr: out std_logic_vector(15 downto 0));
end component;

component ID is 
  Port( clk: in std_logic;
        RegWrite: in std_logic;
        en: in std_logic;
        ExtOp: in std_logic; 
        Instr: in std_logic_vector(15 downto 0);
        WD: in std_logic_vector(15 downto 0);
        WA: in std_logic_vector(2 downto 0);
        sa: out std_logic;
        func: out std_logic_vector(2 downto 0);
        Ext_imm: out std_logic_vector(15 downto 0);
        RD1: out std_logic_vector(15 downto 0);
        RD2: out std_logic_vector(15 downto 0);
        rt: out std_logic_vector(2 downto 0);
        rd: out std_logic_vector(2 downto 0));
end component;

component ControlUnit is 
  Port( Instr: in std_logic_vector (2 downto 0);
        RegDst: out std_logic;
        ExtOp: out std_logic;
        ALUSrc: out std_logic;
        Branch: out std_logic;
        Jump: out std_logic;
        MemWrite: out std_logic;
        MemToReg: out std_logic;
        RegWrite: out std_logic;
        ALUOp: out std_logic_vector (2 downto 0));
end component;

component EX is
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
end component;

component MEM is 
  Port( clk: in std_logic;
        en: in std_logic;
        MemWrite: in std_logic;	
        ALUResIn: in std_logic_vector(15 downto 0);
        WriteData: in std_logic_vector(15 downto 0);	
        MemData: out std_logic_vector(15 downto 0);
        ALUResOut: out std_logic_vector(15 downto 0));
end component;

--semnale UC
signal RegDst: std_logic;
signal ExtOp: std_logic;
signal ALUSrc: std_logic;
signal Branch: std_logic;
signal Jump: std_logic;
signal MemWrite: std_logic;
signal MemToReg: std_logic;
signal RegWrite: std_logic;
signal ALUOp: std_logic_vector (2 downto 0);


signal WD: std_logic_vector(15 downto 0);
signal sa: std_logic;
signal func: std_logic_vector(2 downto 0);
signal Ext_imm: std_logic_vector(15 downto 0);
signal RD1: std_logic_vector(15 downto 0);
signal RD2: std_logic_vector(15 downto 0);
  
signal Instruction: std_logic_vector(15 downto 0);
signal nextInstrAddr: std_logic_vector(15 downto 0);
signal branchAddr: std_logic_vector(15 downto 0);
signal jumpAddr: std_logic_vector(15 downto 0);
signal PCSrc: std_logic;

signal rWA: std_logic_vector (2 downto 0);
signal ALURes: std_logic_vector(15 downto 0);
signal Zero: std_logic;

signal MemData: std_logic_vector(15 downto 0);
signal ALUResOut: std_logic_vector(15 downto 0);
   
signal en: std_logic;
signal rst: std_logic;
signal DO: std_logic_vector(15 downto 0);

signal rt: std_logic_vector (2 downto 0);          -- Instr(9:7)
signal rd: std_logic_vector (2 downto 0);          -- Instr(6:4)

signal IF_ID: std_logic_vector(31 downto 0);
signal ID_EX: std_logic_vector(82 downto 0);
signal EX_MEM: std_logic_vector(55 downto 0);
signal MEM_WB: std_logic_vector(36 downto 0);

begin

MPGcomp1: MPG port map(input => btn(0), clk => clk, en => en); --butonul din centru -> enable program counter
MPGcomp2: MPG port map(input => btn(1), clk => clk, en => rst); --butonul de sus -> reset program counter
SSDComp: SSD port map(clk => clk, data => DO, an => an, cat => cat);

IFetch: InstructionFetch port map(clk => clk, 
                                  branchAddr =>  EX_MEM(19 downto 4), 
                                  jumpAddr => jumpAddr, 
                                  Jump => Jump,
                                  PCSrc => PCSrc,
                                  pcEn => en,
                                  pcReset => rst,
                                  Instruction => Instruction,
                                  nextInstrAddr => nextInstrAddr );
                                  
IDecode: ID port map(clk => clk,
                     RegWrite => MEM_WB(1),
                     en => en,
                     ExtOp => ExtOp,
                     Instr => IF_ID(15 downto 0),
                     WD => WD,
                     WA => MEM_WB(36 downto 34),
                     sa => sa,
                     func => func,
                     Ext_imm => Ext_imm,
                     RD1 => RD1,
                     RD2 => RD2,
                     rt => rt,
                     rd => rd );       
                             
UC: ControlUnit port map(Instr => IF_ID(15 downto 13), 
                         RegDst => RegDst,
                         ExtOp => ExtOp,
                         ALUSrc => ALUSrc,
                         Branch => Branch,
                         Jump => Jump,
                         MemWrite => MemWrite,
                         MemToReg => MemToReg,
                         RegWrite => RegWrite,
                         ALUOp => ALUOp );

ExUnit: EX port map(RD1 => ID_EX(40 downto 25),
                    RD2 => ID_EX(56 downto 41),
                    Ext_Imm => ID_EX(72 downto 57),
                    func => ID_EX(75 downto 73),
                    rt => ID_EX(79 downto 77),
                    rd => ID_EX(82 downto 80),
                    PCplus1 => ID_EX(24 downto 9),
                    ALUOp  => ID_EX(6 downto 4),
                    ALUSrc => ID_EX(7),
                    RegDst =>  ID_EX(8),
                    sa => ID_EX(76),
                    rWA => rWA,
                    BranchAddress => branchAddr,
                    ALURes => ALURes,
                    Zero => Zero );

Memory: MEM port map(clk => clk,
                     en => en,
                     MemWrite => EX_MEM(2),
                     ALUResIn => EX_MEM(36 downto 21),
                     WriteData => EX_MEM(52 downto 37),
                     MemData => MemData,
                     ALUResOut => ALUResOut );

--IF/ID
process(clk)
begin
if rising_edge(clk) then
  if en = '1' then
    IF_ID(31 downto 16) <= nextInstrAddr;
    IF_ID(15 downto 0) <= Instruction;
  end if;
end if;
end process;

--ID/EX
process(clk)
begin
if rising_edge(clk) then
  if en = '1' then    
    ID_EX(0) <= MemToReg;
    ID_EX(1) <= RegWrite;
    ID_EX(2) <= MemWrite;
    ID_EX(3) <= Branch;
    ID_EX(6 downto 4) <= ALUOp;
    ID_EX(7) <= ALUSrc;
    ID_EX(8) <= RegDst;
    ID_EX(24 downto 9) <= IF_ID(31 downto 16);
    ID_EX(40 downto 25) <= RD1;
    ID_EX(56 downto 41) <= RD2;
    ID_EX(72 downto 57) <= Ext_Imm;
    ID_EX(75 downto 73) <= func;
    ID_EX(76) <= sa;
    ID_EX(79 downto 77) <= rt;
    ID_EX(82 downto 80) <= rd;
  end if;
end if;
end process;

--EX/MEM
process(clk)
begin
if rising_edge(clk) then
  if en = '1' then
    EX_MEM(3 downto 0) <= ID_EX(3 downto 0);
    EX_MEM(19 downto 4) <= branchAddr;
    EX_MEM(20) <= Zero;
    EX_MEM(36 downto 21) <= ALURes;
    EX_MEM(52 downto 37) <= ID_EX(56 downto 41);
    EX_MEM(55 downto 53) <= rWA;
  end if;
end if;
end process;

--MEM/WB
process(clk)
begin
if rising_edge(clk) then
  if en = '1' then
    MEM_WB(1 downto 0) <= EX_MEM(1 downto 0);
    MEM_WB(17 downto 2) <= MemData;
    MEM_WB(33 downto 18) <= ALUResOut;
    MEM_WB(36 downto 34) <= EX_MEM(55 downto 53);
  end if;
end if;
end process;

--unitatea Write Back
process(MEM_WB(0), MEM_WB(17 downto 2), MEM_WB(33 downto 18)) 
begin
case MEM_WB(0) is 
    when '1' => WD <= MEM_WB(17 downto 2);
    when '0' => WD <= MEM_WB(33 downto 18);
    when others => WD <= (others => '0');
end case;
end process;

--logica de branch
PCSrc <= EX_MEM(20) and EX_MEM(3);

--logica de calcul a adresei de jump
jumpAddr <= IF_ID(31 downto 29) & IF_ID(12 downto 0);
    
       
--selectia valorii de afisat
process(Instruction,nextInstrAddr,RD1,RD2,WD,Ext_Imm,sw)
begin
	case sw(7 downto 5) is
		when "000" => DO <= Instruction;			
		when "001" => DO <= nextInstrAddr;			
		when "010" => DO <= RD1;			        
		when "011" => DO <= RD2;		            
		when "100" => DO <= Ext_imm;                    
		when "101" => DO <= ALURes;
		when "110" => DO <= MemData;
		when "111" => DO <= WD;			
		when others => DO <= X"0000";
	end case;
end process;

led(7) <= RegDst;
led(6) <= ExtOp;
led(5) <= ALUSrc;
led(4) <= Branch;
led(3) <= Jump;
led(2) <= MemWrite;
led(1) <= MemToReg;
led(0) <= RegWrite;
led(10 downto 8) <= ALUOp;
led(15 downto 11) <= "00000";

end Behavioral;
