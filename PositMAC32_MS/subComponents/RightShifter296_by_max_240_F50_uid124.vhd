--------------------------------------------------------------------------------
--                   RightShifter296_by_max_240_F50_uid124
-- VHDL generated for Kintex7 @ 50MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 1 cycles
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

entity RightShifter296_by_max_240_F50_uid124 is
    port (clk : in std_logic;
          X : in  std_logic_vector(295 downto 0);
          S : in  std_logic_vector(7 downto 0);
          padBit : in  std_logic;
          R : out  std_logic_vector(295 downto 0)   );
end entity;


architecture arch of RightShifter296_by_max_240_F50_uid124 is

   signal ps               :  std_logic_vector(7 downto 0);
   signal level0           :  std_logic_vector(295 downto 0);
   signal level1           :  std_logic_vector(296 downto 0);
   signal level2           :  std_logic_vector(298 downto 0);
   signal level3           :  std_logic_vector(302 downto 0);
   signal level4           :  std_logic_vector(310 downto 0);
   signal level5           :  std_logic_vector(326 downto 0);
   signal level6           :  std_logic_vector(358 downto 0);
   signal level7           :  std_logic_vector(422 downto 0);
   signal level8           :  std_logic_vector(550 downto 0);

   signal concat_val1      : std_logic_vector(0 downto 0);
   signal concat_val2      : std_logic_vector(1 downto 0);
   signal concat_val3      : std_logic_vector(3 downto 0);
   signal concat_val4      : std_logic_vector(7 downto 0);
   signal concat_val5      : std_logic_vector(15 downto 0);
   signal concat_val6      : std_logic_vector(31 downto 0);
   signal concat_val7      : std_logic_vector(63 downto 0);
   signal concat_val8      : std_logic_vector(127 downto 0);

   signal concat0_val1     : std_logic_vector(0 downto 0);
   signal concat0_val2     : std_logic_vector(1 downto 0);
   signal concat0_val3     : std_logic_vector(3 downto 0);
   signal concat0_val4     : std_logic_vector(7 downto 0);
   signal concat0_val5     : std_logic_vector(15 downto 0);
   signal concat0_val6     : std_logic_vector(31 downto 0);
   signal concat0_val7     : std_logic_vector(63 downto 0);
   signal concat0_val8     : std_logic_vector(127 downto 0);


begin

   concat_val1   <= (others => padBit);
   concat_val2   <= (others => padBit);
   concat_val3   <= (others => padBit);
   concat_val4   <= (others => padBit);
   concat_val5   <= (others => padBit);
   concat_val6   <= (others => padBit);
   concat_val7   <= (others => padBit);
   concat_val8   <= (others => padBit);

   concat0_val1   <= (others => '0');
   concat0_val2   <= (others => '0');
   concat0_val3   <= (others => '0');
   concat0_val4   <= (others => '0');
   concat0_val5   <= (others => '0');
   concat0_val6   <= (others => '0');
   concat0_val7   <= (others => '0');
   concat0_val8   <= (others => '0');

   ps<= S;
   level0<= X;

   level1 <=  concat_val1 & level0        when ps(0) = '1'     else    level0 & concat0_val1;
   level2 <=  concat_val2 & level1        when ps(1) = '1'     else    level1 & concat0_val2;
   level3 <=  concat_val3 & level2        when ps(2) = '1'     else    level2 & concat0_val3;
   level4 <=  concat_val4 & level3        when ps(3) = '1'     else    level3 & concat0_val4;
   level5 <=  concat_val5 & level4        when ps(4) = '1'     else    level4 & concat0_val5;
   level6 <=  concat_val6 & level5        when ps(5) = '1'     else    level5 & concat0_val6;
   level7 <=  concat_val7 & level6        when ps(6) = '1'     else    level6 & concat0_val7;
   level8 <=  concat_val8 & level7        when ps(7) = '1'     else    level7 & concat0_val8;

   R <= level8(550 downto 255);

end architecture;



-------------------------------------------------------------------
-- OLD ARCHITECTURE WITH WARNINGS. SAVED TO POSTERIOR CHECKS
-------------------------------------------------------------------

--architecture arch of RightShifter296_by_max_240_F50_uid124 is
--signal ps, ps_d1 :  std_logic_vector(7 downto 0);
--signal level0 :  std_logic_vector(295 downto 0);
--signal level1 :  std_logic_vector(296 downto 0);
--signal level2 :  std_logic_vector(298 downto 0);
--signal level3, level3_d1 :  std_logic_vector(302 downto 0);
--signal level4 :  std_logic_vector(310 downto 0);
--signal level5 :  std_logic_vector(326 downto 0);
--signal level6 :  std_logic_vector(358 downto 0);
--signal level7 :  std_logic_vector(422 downto 0);
--signal level8 :  std_logic_vector(550 downto 0);
--signal padBit_d1 :  std_logic;
--begin
--   process(clk)
--      begin
--         if clk'event and clk = '1' then
--            ps_d1 <=  ps;
--            level3_d1 <=  level3;
--            padBit_d1 <=  padBit;
--         end if;
--      end process;
--   ps<= S;
--   level0<= X;
--   level1 <=  (0 downto 0 => padBit) & level0 when ps(0) = '1' else    level0 & (0 downto 0 => '0');
--   level2 <=  (1 downto 0 => padBit) & level1 when ps(1) = '1' else    level1 & (1 downto 0 => '0');
--   level3 <=  (3 downto 0 => padBit) & level2 when ps(2) = '1' else    level2 & (3 downto 0 => '0');
--   level4 <=  (7 downto 0 => padBit_d1) & level3_d1 when ps_d1(3) = '1' else    level3_d1 & (7 downto 0 => '0');
--   level5 <=  (15 downto 0 => padBit_d1) & level4 when ps_d1(4) = '1' else    level4 & (15 downto 0 => '0');
--   level6 <=  (31 downto 0 => padBit_d1) & level5 when ps_d1(5) = '1' else    level5 & (31 downto 0 => '0');
--   level7 <=  (63 downto 0 => padBit_d1) & level6 when ps_d1(6) = '1' else    level6 & (63 downto 0 => '0');
--   level8 <=  (127 downto 0 => padBit_d1) & level7 when ps_d1(7) = '1' else    level7 & (127 downto 0 => '0');
--   R <= level8(550 downto 255);
--end architecture;