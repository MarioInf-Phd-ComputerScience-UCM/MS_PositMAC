--------------------------------------------------------------------------------
--                          DSPBlock_17x13_F50_uid32
-- VHDL generated for Kintex7 @ 50MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: 
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles
-- Clock period (ns): 20
-- Target frequency (MHz): 50
-- Input signals: X Y
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
library work;

entity DSPBlock_17x13_F50_uid32 is
    port (clk : in std_logic;
          X : in  std_logic_vector(16 downto 0);
          Y : in  std_logic_vector(12 downto 0);
          R : out  std_logic_vector(29 downto 0)   );
end entity;

architecture arch of DSPBlock_17x13_F50_uid32 is
signal Mint :  std_logic_vector(30 downto 0);
signal M :  std_logic_vector(29 downto 0);
signal Rtmp :  std_logic_vector(29 downto 0);
begin
   Mint <= std_logic_vector(signed('0' & X) * signed(Y)); -- multiplier
   M <= Mint(29 downto 0);
   Rtmp <= M;
   R <= Rtmp;
end architecture;