library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;
use work.config.all;

entity FracNormalizer32 is
    port(
        AB_f        : in std_logic_vector(57 downto 0);
        AB_ovfExtra : out std_logic;
        AB_ovf      : out std_logic;
        AB_normF    : out std_logic_vector(54 downto 0)
    );
end entity FracNormalizer32;


architecture arch of FracNormalizer32 is

    signal AB_sgn                   : std_logic;
    signal AB_ovfExtra_r            : std_logic;
    signal AB_ovf_r                 : std_logic;
    signal AB_normF_r               : std_logic_vector(54 downto 0);

begin

    AB_sgn <= AB_f(57);
    AB_ovfExtra_r <= NOT(AB_sgn) AND AB_f(56);
    AB_ovf_r <= AB_ovfExtra_r OR (AB_sgn XOR AB_f(55));
    AB_normF_r <= AB_f(54 downto 0) when AB_ovf_r = '1' else (AB_f(53 downto 0) & '0');

    AB_ovfExtra <= AB_ovfExtra_r;
    AB_ovf <= AB_ovf_r;
    AB_normF <= AB_normF_r;

end architecture arch;