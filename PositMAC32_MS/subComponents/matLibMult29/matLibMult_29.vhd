--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config.all;

--This module is the top file of an 29x29 msMult;

entity matLibMult_29 is
	port(
		X: in std_logic_vector(28 downto 0);
		Y: in std_logic_vector(28 downto 0);
		Z: out std_logic_vector(57 downto 0)
	);
end matLibMult_29;

architecture estr of matLibMult_29 is
begin

    Z <= std_logic_vector(signed(X) * signed(Y));

end estr;
