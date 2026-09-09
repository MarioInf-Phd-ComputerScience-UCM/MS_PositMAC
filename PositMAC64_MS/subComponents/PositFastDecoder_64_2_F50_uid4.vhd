--------------------------------------------------------------------------------
--                       PositFastDecoder_64_2_F50_uid4
-- VHDL generated for Kintex7 @ 50MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Raul Murillo (2021)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles
-- Clock period (ns): 20
-- Target frequency (MHz): 50
-- Input signals: X
-- Output signals: Sign SF Frac NZN

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity PositFastDecoder_64_2_F50_uid4 is
    port (clk : in std_logic;
          X : in  std_logic_vector(63 downto 0);
          Sign : out  std_logic;
          SF : out  std_logic_vector(8 downto 0);
          Frac : out  std_logic_vector(58 downto 0);
          NZN : out  std_logic   );
end entity;


architecture arch of PositFastDecoder_64_2_F50_uid4 is

   component Normalizer_ZO_62_62_62_F50_uid6 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(61 downto 0);
             OZb : in  std_logic;
             Count : out  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(61 downto 0)   );
   end component;

   signal sgn :  std_logic;
   signal pNZN :  std_logic;
   signal rc :  std_logic;
   signal regPosit :  std_logic_vector(61 downto 0);
   signal regLength :  std_logic_vector(5 downto 0);
   signal shiftedPosit :  std_logic_vector(61 downto 0);
   signal k :  std_logic_vector(6 downto 0);
   signal sgnVect :  std_logic_vector(1 downto 0);
   signal exp :  std_logic_vector(1 downto 0);
   signal pSF :  std_logic_vector(8 downto 0);
   signal pFrac :  std_logic_vector(58 downto 0);

begin

   --------------------------- Sign bit & special cases ---------------------------
      sgn <= X(63);
      pNZN <= '0' when (X(62 downto 0) = "000000000000000000000000000000000000000000000000000000000000000") else '1';
   
   -------------- Count leading zeros/ones of regime & shift it out --------------
      rc <= X(62);
      regPosit <= X(61 downto 0);
      RegimeCounter: Normalizer_ZO_62_62_62_F50_uid6
         port map (  clk      => clk,
                     OZb      => rc,
                     X        => regPosit,
                     Count    => regLength,
                     R        => shiftedPosit);
   
   ----------------- Determine the scaling factor - regime & exp -----------------
      k <= "0" & regLength when rc /= sgn else "1" & NOT(regLength);
      sgnVect <= (others => sgn);
      exp <= shiftedPosit(60 downto 59) XOR sgnVect;
      pSF <= k & exp;
   
   ------------------------------- Extract fraction -------------------------------
      pFrac <= shiftedPosit(58 downto 0);
      Sign <= sgn;
      SF <= pSF;
      Frac <= pFrac;
      NZN <= pNZN;

end architecture;