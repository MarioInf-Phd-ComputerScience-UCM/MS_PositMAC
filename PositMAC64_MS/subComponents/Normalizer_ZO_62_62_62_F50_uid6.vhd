--------------------------------------------------------------------------------
--                      Normalizer_ZO_62_62_62_F50_uid6
-- VHDL generated for Kintex7 @ 50MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, (2007-2020)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles
-- Clock period (ns): 20
-- Target frequency (MHz): 50
-- Input signals: X OZb
-- Output signals: Count R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Normalizer_ZO_62_62_62_F50_uid6 is
    port (clk : in std_logic;
          X : in  std_logic_vector(61 downto 0);
          OZb : in  std_logic;
          Count : out  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(61 downto 0)   );
end entity;


architecture arch of Normalizer_ZO_62_62_62_F50_uid6 is

   signal level6        :  std_logic_vector(61 downto 0);
   signal sozb          :  std_logic;
   signal count5        :  std_logic;
   signal level5        :  std_logic_vector(61 downto 0);
   signal count4        :  std_logic;
   signal level4        :  std_logic_vector(61 downto 0);
   signal count3        :  std_logic;
   signal level3        :  std_logic_vector(61 downto 0);
   signal count2        :  std_logic;
   signal level2        :  std_logic_vector(61 downto 0);
   signal count1        :  std_logic;
   signal level1        :  std_logic_vector(61 downto 0);
   signal count0        :  std_logic;
   signal level0        :  std_logic_vector(61 downto 0);
   signal sCount        :  std_logic_vector(5 downto 0);

   signal cmp_val6      : std_logic_vector(61 downto 30);
   signal cmp_val5      : std_logic_vector(61 downto 46);
   signal cmp_val4      : std_logic_vector(61 downto 54);
   signal cmp_val3      : std_logic_vector(61 downto 58);
   signal cmp_val2      : std_logic_vector(61 downto 60);
   signal cmp_val1      : std_logic_vector(61 downto 61);

   signal concat_val6   : std_logic_vector(31 downto 0);
   signal concat_val5   : std_logic_vector(15 downto 0);
   signal concat_val4   : std_logic_vector(7 downto 0);
   signal concat_val3   : std_logic_vector(3 downto 0);
   signal concat_val2   : std_logic_vector(1 downto 0);
   signal concat_val1   : std_logic_vector(0 downto 0);

begin

   level6 <= X ;
   sozb<= OZb;

   cmp_val6 <= (others => sozb);
   cmp_val5 <= (others => sozb);
   cmp_val4 <= (others => sozb);
   cmp_val3 <= (others => sozb);
   cmp_val2 <= (others => sozb);
   cmp_val1 <= (others => sozb);

   concat_val1  <= (others => '0');
   concat_val2  <= (others => '0');
   concat_val3  <= (others => '0');
   concat_val4  <= (others => '0');
   concat_val5  <= (others => '0');
   concat_val6  <= (others => '0');


   count5<= '1' when level6(61 downto 30) = cmp_val6 else '0';
   level5<= level6(61 downto 0) when count5='0' else level6(29 downto 0) & concat_val6;

   count4<= '1' when level5(61 downto 46) = cmp_val5 else '0';
   level4<= level5(61 downto 0) when count4='0' else level5(45 downto 0) & concat_val5;

   count3<= '1' when level4(61 downto 54) = cmp_val4 else '0';
   level3<= level4(61 downto 0) when count3='0' else level4(53 downto 0) & concat_val4;

   count2<= '1' when level3(61 downto 58) = cmp_val3 else '0';
   level2<= level3(61 downto 0) when count2='0' else level3(57 downto 0) & concat_val3;

   count1<= '1' when level2(61 downto 60) = cmp_val2 else '0';
   level1<= level2(61 downto 0) when count1='0' else level2(59 downto 0) & concat_val2;

   count0<= '1' when level1(61 downto 61) = cmp_val1 else '0';
   level0<= level1(61 downto 0) when count0='0' else level1(60 downto 0) & concat_val1;

   R <= level0;
   sCount <= count5 & count4 & count3 & count2 & count1 & count0;
   Count <= sCount;

end architecture;




-------------------------------------------------------------------
-- OLD ARCHITECTURE WITH WARNINGS. SAVED TO POSTERIOR CHECKS
-------------------------------------------------------------------

--architecture arch of Normalizer_ZO_62_62_62_F50_uid6 is
--
--   signal level6 :  std_logic_vector(61 downto 0);
--   signal sozb :  std_logic;
--   signal count5 :  std_logic;
--   signal level5 :  std_logic_vector(61 downto 0);
--   signal count4 :  std_logic;
--   signal level4 :  std_logic_vector(61 downto 0);
--   signal count3 :  std_logic;
--   signal level3 :  std_logic_vector(61 downto 0);
--   signal count2 :  std_logic;
--   signal level2 :  std_logic_vector(61 downto 0);
--   signal count1 :  std_logic;
--   signal level1 :  std_logic_vector(61 downto 0);
--   signal count0 :  std_logic;
--   signal level0 :  std_logic_vector(61 downto 0);
--   signal sCount :  std_logic_vector(5 downto 0);
--
--begin
--
--   level6 <= X ;
--   sozb<= OZb;
--
--   count5<= '1' when level6(61 downto 30) = (61 downto 30=>sozb) else '0';
--   level5<= level6(61 downto 0) when count5='0' else level6(29 downto 0) & (31 downto 0 => '0');
--
--   count4<= '1' when level5(61 downto 46) = (61 downto 46=>sozb) else '0';
--   level4<= level5(61 downto 0) when count4='0' else level5(45 downto 0) & (15 downto 0 => '0');
--
--   count3<= '1' when level4(61 downto 54) = (61 downto 54=>sozb) else '0';
--   level3<= level4(61 downto 0) when count3='0' else level4(53 downto 0) & (7 downto 0 => '0');
--
--   count2<= '1' when level3(61 downto 58) = (61 downto 58=>sozb) else '0';
--   level2<= level3(61 downto 0) when count2='0' else level3(57 downto 0) & (3 downto 0 => '0');
--
--   count1<= '1' when level2(61 downto 60) = (61 downto 60=>sozb) else '0';
--   level1<= level2(61 downto 0) when count1='0' else level2(59 downto 0) & (1 downto 0 => '0');
--
--   count0<= '1' when level1(61 downto 61) = (61 downto 61=>sozb) else '0';
--   level0<= level1(61 downto 0) when count0='0' else level1(60 downto 0) & (0 downto 0 => '0');
--
--   R <= level0;
--   sCount <= count5 & count4 & count3 & count2 & count1 & count0;
--   Count <= sCount;
--
--end architecture;