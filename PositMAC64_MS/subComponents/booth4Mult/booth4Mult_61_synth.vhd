--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.config.all;

--This module is the top file of an 61x61 msMult;

entity booth4Mult_61_synth is
	generic(
        MULTIPLY_ALGORITHM_ADDER_SELECTED   : type_multiplyAlgorithm_Adder  := UNKNOWN
	);
	port(
		X: in std_logic_vector(60 downto 0);
		Y: in std_logic_vector(60 downto 0);
		Z: out std_logic_vector(121 downto 0)
	);
end booth4Mult_61_synth;

architecture estr of booth4Mult_61_synth is

	--Component declarations
	component booth4Mult_61 is
		port(
			X: in std_logic_vector(60 downto 0);
			Y: in std_logic_vector(60 downto 0);
			Zs: out std_logic_vector(121 downto 0);
			Zc: out std_logic_vector(121 downto 0)
		);
	end component;

	component kogge_stone is
		generic(
			N: integer;
			S: integer);--Number of stages
		port(
			a: in std_logic_vector((N-1) downto 0);
			b: in std_logic_vector((N-1) downto 0);
			cin: in std_logic;
			z: out std_logic_vector((N-1) downto 0);
			cout: out std_logic
		);
	end component;

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
	signal Zs: std_logic_vector(121 downto 0);
	signal Zc: std_logic_vector(121 downto 0);
	signal Zc_aux: std_logic_vector(121 downto 0);

begin

	booth_mult: booth4Mult_61
		port map(X,Y,Zs,Zc);

	Zc_aux <= Zc(120 downto 0) & '0';
	cin_z <= '0';

	Gen_AdderKS: if(MULTIPLY_ALGORITHM_ADDER_SELECTED = KS or MULTIPLY_ALGORITHM_ADDER_SELECTED = UNKNOWN) generate
		Inst_AdderKS: kogge_stone 
			generic map(122,7)
			port map(Zs,Zc_aux,cin_z,z,cout_z);
	end generate;

	Gen_AdderBK: if(MULTIPLY_ALGORITHM_ADDER_SELECTED = BK) generate
		Inst_AdderBK: brent_kung
			generic map(122,7)
			port map(Zs,Zc_aux,cin_z,z,cout_z);
	end generate;

	Gen_AdderRCA: if(MULTIPLY_ALGORITHM_ADDER_SELECTED = RCA) generate
		Inst_AdderRCA: ripple_carry
			generic map(122,7)
			port map(Zs,Zc_aux,cin_z,z,cout_z);
	end generate;

end estr;
