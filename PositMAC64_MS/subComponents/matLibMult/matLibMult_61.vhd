--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config.all;

--This module is the top file of an 61x61 msMult;

entity matLibMult_61 is
	port(
		X: in std_logic_vector(60 downto 0);
		Y: in std_logic_vector(60 downto 0);
		Z: out std_logic_vector(121 downto 0)
	);
end matLibMult_61;

architecture estr of matLibMult_61 is
begin

    Z <= std_logic_vector(signed(X) * signed(Y));

end estr;
