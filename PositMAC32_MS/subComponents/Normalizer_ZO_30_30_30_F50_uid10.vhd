--------------------------------------------------------------------------------
--                      Normalizer_ZO_30_30_30_F50_uid10
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

entity Normalizer_ZO_30_30_30_F50_uid10 is
    port (clk : in std_logic;
          X : in  std_logic_vector(29 downto 0);
          OZb : in  std_logic;
          Count : out  std_logic_vector(4 downto 0);
          R : out  std_logic_vector(29 downto 0)   );
end entity;

architecture arch of Normalizer_ZO_30_30_30_F50_uid10 is

   signal level5 :  std_logic_vector(29 downto 0);
   signal sozb :  std_logic;
   signal count4 :  std_logic;
   signal level4 :  std_logic_vector(29 downto 0);
   signal count3 :  std_logic;
   signal level3 :  std_logic_vector(29 downto 0);
   signal count2 :  std_logic;
   signal level2 :  std_logic_vector(29 downto 0);
   signal count1 :  std_logic;
   signal level1 :  std_logic_vector(29 downto 0);
   signal count0 :  std_logic;
   signal level0 :  std_logic_vector(29 downto 0);
   signal sCount :  std_logic_vector(4 downto 0);

   signal cmp_val5      : std_logic_vector(29 downto 14);
   signal cmp_val4      : std_logic_vector(29 downto 22);
   signal cmp_val3      : std_logic_vector(29 downto 26);
   signal cmp_val2      : std_logic_vector(29 downto 28);
   signal cmp_val1      : std_logic_vector(29 downto 29);

   signal concat_val5   : std_logic_vector(15 downto 0);
   signal concat_val4   : std_logic_vector(7 downto 0);
   signal concat_val3   : std_logic_vector(3 downto 0);
   signal concat_val2   : std_logic_vector(1 downto 0);
   signal concat_val1   : std_logic_vector(0 downto 0);

begin

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

   level5 <= X ;
   sozb<= OZb;

   count4<= '1' when level5(29 downto 14) = cmp_val5 else '0';
   level4<= level5(29 downto 0) when count4='0' else level5(13 downto 0) & concat_val5;

   count3<= '1' when level4(29 downto 22) = cmp_val4 else '0';
   level3<= level4(29 downto 0) when count3='0' else level4(21 downto 0) & concat_val4;

   count2<= '1' when level3(29 downto 26) = cmp_val3 else '0';
   level2<= level3(29 downto 0) when count2='0' else level3(25 downto 0) & concat_val3;

   count1<= '1' when level2(29 downto 28) = cmp_val2 else '0';
   level1<= level2(29 downto 0) when count1='0' else level2(27 downto 0) & concat_val2;

   count0<= '1' when level1(29 downto 29) = cmp_val1 else '0';
   level0<= level1(29 downto 0) when count0='0' else level1(28 downto 0) & concat_val1;

   R <= level0;
   sCount <= count4 & count3 & count2 & count1 & count0;
   Count <= sCount;

end architecture;



-------------------------------------------------------------------
-- OLD ARCHITECTURE WITH WARNINGS. SAVED TO POSTERIOR CHECKS
-------------------------------------------------------------------

--entity Normalizer_ZO_30_30_30_F50_uid10 is
--    port (clk : in std_logic;
--          X : in  std_logic_vector(29 downto 0);
--          OZb : in  std_logic;
--          Count : out  std_logic_vector(4 downto 0);
--          R : out  std_logic_vector(29 downto 0)   );
--end entity;
--
--architecture arch of Normalizer_ZO_30_30_30_F50_uid10 is
--signal level5 :  std_logic_vector(29 downto 0);
--signal sozb :  std_logic;
--signal count4 :  std_logic;
--signal level4 :  std_logic_vector(29 downto 0);
--signal count3 :  std_logic;
--signal level3 :  std_logic_vector(29 downto 0);
--signal count2 :  std_logic;
--signal level2 :  std_logic_vector(29 downto 0);
--signal count1 :  std_logic;
--signal level1 :  std_logic_vector(29 downto 0);
--signal count0 :  std_logic;
--signal level0 :  std_logic_vector(29 downto 0);
--signal sCount :  std_logic_vector(4 downto 0);
--begin
--   level5 <= X ;
--   sozb<= OZb;
--   count4<= '1' when level5(29 downto 14) = (29 downto 14=>sozb) else '0';
--   level4<= level5(29 downto 0) when count4='0' else level5(13 downto 0) & (15 downto 0 => '0');
--
--   count3<= '1' when level4(29 downto 22) = (29 downto 22=>sozb) else '0';
--   level3<= level4(29 downto 0) when count3='0' else level4(21 downto 0) & (7 downto 0 => '0');
--
--   count2<= '1' when level3(29 downto 26) = (29 downto 26=>sozb) else '0';
--   level2<= level3(29 downto 0) when count2='0' else level3(25 downto 0) & (3 downto 0 => '0');
--
--   count1<= '1' when level2(29 downto 28) = (29 downto 28=>sozb) else '0';
--   level1<= level2(29 downto 0) when count1='0' else level2(27 downto 0) & (1 downto 0 => '0');
--
--   count0<= '1' when level1(29 downto 29) = (29 downto 29=>sozb) else '0';
--   level0<= level1(29 downto 0) when count0='0' else level1(28 downto 0) & (0 downto 0 => '0');
--
--   R <= level0;
--   sCount <= count4 & count3 & count2 & count1 & count0;
--   Count <= sCount;
--end architecture;