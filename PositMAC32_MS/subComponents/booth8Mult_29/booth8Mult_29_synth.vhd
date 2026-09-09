--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.config.all;

--This module is the top file of an 29x29 msMult;

entity booth8Mult_29_synth is
	generic(
        MULTIPLY_ALGORITHM_ADDER_SELECTED   : type_multiplyAlgorithm_Adder  := UNKNOWN
	);
	port(
		X: in std_logic_vector(28 downto 0);
		Y: in std_logic_vector(28 downto 0);
		Z: out std_logic_vector(57 downto 0)
	);
end booth8Mult_29_synth;

architecture estr of booth8Mult_29_synth is

	--Component declarations
	component booth8Mult_29 is
		generic(
			MULTIPLY_ALGORITHM_ADDER_SELECTED   : type_multiplyAlgorithm_Adder  := UNKNOWN
		);
		port(
			X: in std_logic_vector(28 downto 0);
			Y: in std_logic_vector(28 downto 0);
			Zs: out std_logic_vector(57 downto 0);
			Zc: out std_logic_vector(57 downto 0)
		);
	end component booth8Mult_29;

	component kogge_stone is
		generic(
			N: integer; --Number of stages
			S: integer
		);
		port(
			a: in std_logic_vector((N-1) downto 0);
			b: in std_logic_vector((N-1) downto 0);
			cin: in std_logic;
			z: out std_logic_vector((N-1) downto 0);
			cout: out std_logic
		);
	end component kogge_stone;

	component brent_kung is
		generic(
			N: integer;
			S: integer  --Number of stages=log(N)
		);
		port(
			a: in std_logic_vector((N-1) downto 0);
			b: in std_logic_vector((N-1) downto 0);
			cin: in std_logic;
			z: out std_logic_vector((N-1) downto 0);
			cout: out std_logic
		);
	end component brent_kung;

	component ripple_carry is
		generic(
			N: integer;
			S: integer	--Number of stages=log(N)
		);
		port(
			a: in std_logic_vector((N-1) downto 0);
			b: in std_logic_vector((N-1) downto 0);
			cin: in std_logic;
			z: out std_logic_vector((N-1) downto 0);
			cout: out std_logic
		);
	end component ripple_carry;


	--Signal declarations
	signal cin_z: std_logic;
	signal cout_z: std_logic;
	signal Zs: std_logic_vector(57 downto 0);
	signal Zc: std_logic_vector(57 downto 0);
	signal Zc_aux: std_logic_vector(57 downto 0);

begin

	booth8_mult: booth8Mult_29 
		generic map(MULTIPLY_ALGORITHM_ADDER_SELECTED => MULTIPLY_ALGORITHM_ADDER_SELECTED)
		port map(X,Y,Zs,Zc);

	Zc_aux <= Zc(56 downto 0) & '0';
	cin_z <= '0';

	Gen_AdderKS: if(MULTIPLY_ALGORITHM_ADDER_SELECTED = KS or MULTIPLY_ALGORITHM_ADDER_SELECTED = UNKNOWN) generate
		Inst_AdderKS: kogge_stone 
			generic map(58,6)
			port map(Zs,Zc_aux,cin_z,z,cout_z);
	end generate;

	Gen_AdderBK: if(MULTIPLY_ALGORITHM_ADDER_SELECTED = BK) generate
		Inst_AdderBK: brent_kung
			generic map(58,6)
			port map(Zs,Zc_aux,cin_z,z,cout_z);
	end generate;

	Gen_AdderRCA: if(MULTIPLY_ALGORITHM_ADDER_SELECTED = RCA) generate
		Inst_AdderRCA: ripple_carry
			generic map(58,6)
			port map(Zs,Zc_aux,cin_z,z,cout_z);
	end generate;


end estr;
