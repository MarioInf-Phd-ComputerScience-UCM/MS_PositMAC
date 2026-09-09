--------------------------------------------------------------------------------
--                          DSPBlock_10x24_F50_uid22
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

entity DSPBlock_10x24_F50_uid22 is
    port (clk : in std_logic;
          X : in  std_logic_vector(9 downto 0);
          Y : in  std_logic_vector(23 downto 0);
          R : out  std_logic_vector(33 downto 0)   );
end entity;

architecture arch of DSPBlock_10x24_F50_uid22 is
signal Mint :  std_logic_vector(34 downto 0);
signal M :  std_logic_vector(33 downto 0);
signal Rtmp :  std_logic_vector(33 downto 0);
begin
   Mint <= std_logic_vector(signed(X) * signed('0' & Y)); -- multiplier
   M <= Mint(33 downto 0);
   Rtmp <= M;
   R <= Rtmp;
end architecture;