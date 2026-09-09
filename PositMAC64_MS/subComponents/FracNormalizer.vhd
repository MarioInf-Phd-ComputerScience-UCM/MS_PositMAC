library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;
use work.config.all;

entity FracNormalizer is
    port(
        AB_f        : in std_logic_vector(121 downto 0);
        AB_ovfExtra : out std_logic;
        AB_ovf      : out std_logic;
        AB_normF    : out std_logic_vector(118 downto 0)
    );
end entity FracNormalizer;


architecture arch of FracNormalizer is

    signal AB_sgn                   : std_logic;
    signal AB_ovfExtra_r            : std_logic;
    signal AB_ovf_r                 : std_logic;
    signal AB_normF_r               : std_logic_vector(118 downto 0);

begin

    AB_sgn <= AB_f(121);
    AB_ovfExtra_r <= NOT(AB_sgn) AND AB_f(120);
    AB_ovf_r <= AB_ovfExtra_r OR (AB_sgn XOR AB_f(119));
    AB_normF_r <= AB_f(118 downto 0) when AB_ovf_r = '1' else (AB_f(117 downto 0) & '0');

    AB_ovfExtra <= AB_ovfExtra_r;
    AB_ovf <= AB_ovf_r;
    AB_normF <= AB_normF_r;

end architecture arch;