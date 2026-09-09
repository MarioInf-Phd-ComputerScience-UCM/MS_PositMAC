--------------------------------------------------------------------------------
--                          IntAdder_1024_F50_uid454_old
-- VHDL generated for Kintex7 @ 50MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2016)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles
-- Clock period (ns): 20
-- Target frequency (MHz): 50
-- Input signals: X Y Cin
-- Output signals: R


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity IntAdder_1024_F50_uid454_old is
	generic(
		QUIRE_ADDER_ALGORITHM               : type_quireAdder_Algorithm  := UNKNOWN
	);
	port (
		clk : in std_logic;
		X : in  std_logic_vector(1023 downto 0);
		Y : in  std_logic_vector(1023 downto 0);
		Cin : in  std_logic;
		R : out  std_logic_vector(1023 downto 0)
	);
end entity;

architecture arch of IntAdder_1024_F50_uid454_old is

	component gp_kogge_stone is
	  generic(N : integer;
			   S : integer           --Number of stages=log(N)
	  );
	  port(
			a     : in std_logic_vector((N-1) downto 0);
			b     : in std_logic_vector((N-1) downto 0);
			cin   : in std_logic;
			G     : out std_logic;    --Group generate signal
			P     : out std_logic;    --Group propagate signal
			z     : out std_logic_vector((N-1) downto 0);
			cout  : out std_logic
	  );
  end component;

  component gp_brent_kung is
	generic(N : integer;
			S : integer);--Number of stages=log(N)
	  port(
			a     : in std_logic_vector((N-1) downto 0);
			b     : in std_logic_vector((N-1) downto 0);
			cin   : in std_logic;
			G     : out std_logic;    --Group generate signal
			P     : out std_logic;    --Group propagate signal
			z     : out std_logic_vector((N-1) downto 0);
			cout  : out std_logic
	  );
  end component;

	component gp_rca is
		generic(N : integer;
				S : integer);--Number of stages=log(N)
		port(
			a     : in std_logic_vector((N-1) downto 0);
			b     : in std_logic_vector((N-1) downto 0);
			cin   : in std_logic;
			G     : out std_logic;    --Group generate signal
			P     : out std_logic;    --Group propagate signal
			z     : out std_logic_vector((N-1) downto 0);
			cout  : out std_logic
		);
	end component;

	signal Rtmp :  std_logic_vector(1023 downto 0);
	signal Y_d1, Y_d2, Y_d3 :  std_logic_vector(1023 downto 0);
	signal Cin_d1, Cin_d2, Cin_d3 :  std_logic;
	signal G_out, P_out, C_out :  std_logic;

begin

	process(clk)
		begin
			if clk'event and clk = '1' then
				Y_d1 <=  Y;
				Y_d2 <=  Y_d1;
				Y_d3 <=  Y_d2;
				Cin_d1 <=  Cin;
				Cin_d2 <=  Cin_d1;
				Cin_d3 <=  Cin_d2;
			end if;
		end process;

	if_VHDL : if (QUIRE_ADDER_ALGORITHM = VHDL or QUIRE_ADDER_ALGORITHM = UNKNOWN) generate  --VHDL DEFAULT SELECTION
		Rtmp <= X + Y_d3 + Cin_d3;
	end generate;

	if_KS: if (QUIRE_ADDER_ALGORITHM = KS) generate        --KOGGE-STONE SELECTION
		KS: gp_kogge_stone generic
				map (1024, 10)
				port map(X, Y_d3, Cin_d3, G_out, P_out, Rtmp, C_out);
	end generate;

	if_BK: if (QUIRE_ADDER_ALGORITHM = BK) generate        --BRENT-KUNG SELECTION
		BK: gp_brent_kung generic
				map(1024, 10)
				port map(X, Y_d3, Cin_d3, G_out, P_out, Rtmp, C_out);
	end generate;

	if_RCA: if (QUIRE_ADDER_ALGORITHM = RCA) generate      --RCA SELECTION
		RCA: gp_rca generic
				map(1024, 10)
				port map(X, Y_d3, Cin_d3, G_out, P_out, Rtmp, C_out);
	end generate;

	R <= Rtmp;
end architecture;