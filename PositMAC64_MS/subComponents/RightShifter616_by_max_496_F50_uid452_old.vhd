--------------------------------------------------------------------------------
--                   RightShifter616_by_max_496_F50_uid452_old
-- VHDL generated for Kintex7 @ 50MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 3 cycles
-- Clock period (ns): 20
-- Target frequency (MHz): 50
-- Input signals: X S padBit
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity RightShifter616_by_max_496_F50_uid452_old is
    port (clk     : in std_logic;
          X       : in  std_logic_vector(615 downto 0);
          S       : in  std_logic_vector(8 downto 0);
          padBit  : in  std_logic;
          R       : out  std_logic_vector(615 downto 0)   );
end entity;


architecture arch of RightShifter616_by_max_496_F50_uid452_old is

   signal ps, ps_d1, ps_d2, ps_d3         :  std_logic_vector(8 downto 0);
   signal level0                          :  std_logic_vector(615 downto 0);
   signal level1, level1_d1               :  std_logic_vector(616 downto 0);
   signal level2                          :  std_logic_vector(618 downto 0);
   signal level3                          :  std_logic_vector(622 downto 0);
   signal level4                          :  std_logic_vector(630 downto 0);
   signal level5, level5_d1               :  std_logic_vector(646 downto 0);
   signal level6                          :  std_logic_vector(678 downto 0);
   signal level7, level7_d1               :  std_logic_vector(742 downto 0);
   signal level8                          :  std_logic_vector(870 downto 0);
   signal level9                          :  std_logic_vector(1126 downto 0);
   signal padBit_d1, padBit_d2, padBit_d3 :  std_logic;

   signal concat_val1      : std_logic_vector(0 downto 0);
   signal concat_val2      : std_logic_vector(1 downto 0);
   signal concat_val3      : std_logic_vector(3 downto 0);
   signal concat_val4      : std_logic_vector(7 downto 0);
   signal concat_val5      : std_logic_vector(15 downto 0);
   signal concat_val6      : std_logic_vector(31 downto 0);
   signal concat_val7      : std_logic_vector(63 downto 0);
   signal concat_val8      : std_logic_vector(127 downto 0);
   signal concat_val9      : std_logic_vector(255 downto 0);

   signal concat0_val1     : std_logic_vector(0 downto 0);
   signal concat0_val2     : std_logic_vector(1 downto 0);
   signal concat0_val3     : std_logic_vector(3 downto 0);
   signal concat0_val4     : std_logic_vector(7 downto 0);
   signal concat0_val5     : std_logic_vector(15 downto 0);
   signal concat0_val6     : std_logic_vector(31 downto 0);
   signal concat0_val7     : std_logic_vector(63 downto 0);
   signal concat0_val8     : std_logic_vector(127 downto 0);
   signal concat0_val9     : std_logic_vector(255 downto 0);

begin

   process(clk)
      begin
         if (clk'event and clk = '1') then
            ps_d1       <=  ps;
            ps_d2       <=  ps_d1;
            ps_d3       <=  ps_d2;
            level1_d1   <=  level1;
            level5_d1   <=  level5;
            level7_d1   <=  level7;
            padBit_d1   <=  padBit;
            padBit_d2   <=  padBit_d1;
            padBit_d3   <=  padBit_d2;
         end if;
      end process;


   concat_val1   <= (others => padBit);
   concat_val2   <= (others => padBit_d1);
   concat_val3   <= (others => padBit_d1);
   concat_val4   <= (others => padBit_d1);
   concat_val5   <= (others => padBit_d1);
   concat_val6   <= (others => padBit_d2);
   concat_val7   <= (others => padBit_d2);
   concat_val8   <= (others => padBit_d3);
   concat_val9   <= (others => padBit_d3);

   concat0_val1   <= (others => '0');
   concat0_val2   <= (others => '0');
   concat0_val3   <= (others => '0');
   concat0_val4   <= (others => '0');
   concat0_val5   <= (others => '0');
   concat0_val6   <= (others => '0');
   concat0_val7   <= (others => '0');
   concat0_val8   <= (others => '0');
   concat0_val9   <= (others => '0');

   ps<= S;
   level0<= X;

   level1 <=  concat_val1 & level0        when ps(0) = '1'        else    level0 & concat0_val1;
   level2 <=  concat_val2 & level1_d1     when ps_d1(1) = '1'     else    level1_d1 & concat0_val2;
   level3 <=  concat_val3 & level2        when ps_d1(2) = '1'     else    level2 & concat0_val3;
   level4 <=  concat_val4 & level3        when ps_d1(3) = '1'     else    level3 & concat0_val4;
   level5 <=  concat_val5 & level4        when ps_d1(4) = '1'     else    level4 &  concat0_val5;
   level6 <=  concat_val6 & level5_d1     when ps_d2(5) = '1'     else    level5_d1 &  concat0_val6;
   level7 <=  concat_val7 & level6        when ps_d2(6) = '1'     else    level6 &  concat0_val7;
   level8 <=  concat_val8 & level7_d1     when ps_d3(7) = '1'     else    level7_d1 & concat0_val8;
   level9 <=  concat_val9 & level8        when ps_d3(8) = '1'     else    level8 & concat0_val9;

   R <= level9(1126 downto 511);

end architecture;