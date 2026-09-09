--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg is
   generic(N: integer);
	port(
	  rst: in std_logic;
	  clk: in std_logic;
	  load: in std_logic;
		d: in std_logic_vector((N-1) downto 0);
		q: out std_logic_vector((N-1) downto 0)
	);
end reg;

architecture beh of reg is
begin
    process(rst,clk)
    begin
        if (rst='1') then
            q <= (others => '0');
        else
            --wait until clk'event and clk='1';
            if (clk='1' and clk'event) then
              if (load='1') then
                 q <= d;
              end if;
            end if;
        end if;
    end process;
end beh;

