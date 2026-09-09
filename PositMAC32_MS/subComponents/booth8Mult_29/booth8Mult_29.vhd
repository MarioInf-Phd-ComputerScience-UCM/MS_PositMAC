--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.config.all;

--This module implements a 29x29 boothMult

entity booth8Mult_29 is
	generic(
        MULTIPLY_ALGORITHM_ADDER_SELECTED   : type_multiplyAlgorithm_Adder  := UNKNOWN
	);
	port(
		X: in std_logic_vector(28 downto 0);
		Y: in std_logic_vector(28 downto 0);
		Zs: out std_logic_vector(57 downto 0);
		Zc: out std_logic_vector(57 downto 0)
	);
end booth8Mult_29;

architecture estr of booth8Mult_29 is

	--Component declarations

	component booth8_29_Enc is
		generic(
			N: integer
		);
		port(
			x: in std_logic_vector((N-1) downto 0);
			sel: out std_logic_vector((3*(N/3)+2) downto 0);
			signs: out std_logic_vector((N/3) downto 0)
		);
	end component booth8_29_Enc;

	component booth8_29_mux5to1 is
		generic(
			N: integer
		);
		port(
			x0: in std_logic_vector((N-1) downto 0);
			x1: in std_logic_vector((N-1) downto 0);
			x2: in std_logic_vector((N-1) downto 0);
			x3: in std_logic_vector((N-1) downto 0);
			x4: in std_logic_vector((N-1) downto 0);
			ctrl: in std_logic_vector(2 downto 0);
			z: out std_logic_vector((N-1) downto 0)
		);
	end component booth8_29_mux5to1;

	component kogge_stone is
		generic(
			N: integer;
			S: integer --Number of stages=log(N)
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

	component booth8_29_compr4to2Tree_11_58 is
		port(
			x0: in std_logic_vector(57 downto 0);
			x1: in std_logic_vector(57 downto 0);
			x2: in std_logic_vector(57 downto 0);
			x3: in std_logic_vector(57 downto 0);
			x4: in std_logic_vector(57 downto 0);
			x5: in std_logic_vector(57 downto 0);
			x6: in std_logic_vector(57 downto 0);
			x7: in std_logic_vector(57 downto 0);
			x8: in std_logic_vector(57 downto 0);
			x9: in std_logic_vector(57 downto 0);
			x10: in std_logic_vector(57 downto 0);
			s: out std_logic_vector(57 downto 0);
			c: out std_logic_vector(57 downto 0)
		);
	end component booth8_29_compr4to2Tree_11_58;

	--Type declarations

	type ppMatrix is array (0 to 9) of std_logic_vector(30 downto 0);--29+2
	type ppMatrix2 is array (0 to 10) of std_logic_vector(57 downto 0);--Math.ceil((29+1)/3)

	--Signal declarations

	signal zero31: std_logic_vector(30 downto 0);
	signal x1: std_logic_vector(30 downto 0);
	signal doublex1: std_logic_vector(30 downto 0);
	signal threex1: std_logic_vector(30 downto 0);
	signal quadx1: std_logic_vector(30 downto 0);
	signal cin_thr: std_logic;
	signal cout_thr: std_logic;
	signal sel: std_logic_vector(29 downto 0);
	signal signs: std_logic_vector(9 downto 0);
	signal ext_signs: std_logic_vector(9 downto 0);--For negative multipliers
	signal pp: ppMatrix;
	signal ppAux: ppMatrix;
	signal ppSign: ppMatrix;
	signal pp2: ppMatrix2;
	signal cout: std_logic;
	signal s1: std_logic_vector(57 downto 0);
	signal c1: std_logic_vector(57 downto 0);

begin

	--Booth encoding
	b_enc: booth8_29_Enc generic map(29)
		port map(Y,sel,signs);

	--X mantissas
	zero31 <= (OTHERS => '0');
	x1 <= X(28) & X(28) & X;--In order to make doublex1 >=0 and minusDoublex1 <0
	doublex1 <= x1(29 downto 0) & '0';
	quadx1 <= X & "00";

	cin_thr <= '0';
	
	Gen_ThrAdderKS: if(MULTIPLY_ALGORITHM_ADDER_SELECTED = KS or MULTIPLY_ALGORITHM_ADDER_SELECTED = UNKNOWN) generate
		Inst_ThrAdderKS: kogge_stone 
			generic map(31,5)
			port map(x1,doublex1,cin_thr,threex1,cout_thr);
	end generate;

	Gen_ThrAdderBK: if(MULTIPLY_ALGORITHM_ADDER_SELECTED = BK) generate
		Inst_ThrAdderBK: brent_kung
			generic map(31,5)
			port map(x1,doublex1,cin_thr,threex1,cout_thr);
	end generate;

	Gen_ThrAdderRCA: if(MULTIPLY_ALGORITHM_ADDER_SELECTED = RCA) generate
		Inst_ThrAdderRCA: ripple_carry
			generic map(31,5)
			port map(x1,doublex1,cin_thr,threex1,cout_thr);
	end generate;



	--Mux5to1
	muxGen:
	for i in 0 to 9 generate
		muxStage: booth8_29_mux5to1 generic map(31)
			port map(zero31,x1,doublex1,threex1,quadx1,sel((3*i+2) downto (3*i)),ppAux(i));
		ppSign(i) <= (OTHERS => signs(i));
		pp(i) <= ppAux(i) xor ppSign(i);
		ext_signs(i) <= ((signs(i) xnor X(28)) and 
			not(not(sel(3*i+2)) and not(sel(3*i+1)) and not(sel(3*i)) and signs(i))) or 
			(not(sel(3*i+2)) and not(sel(3*i+1)) and not(sel(3*i)) and not(signs(i)));
	end generate muxGen;

	--Complete partial products
	pp2(0)(57 downto 35) <= (OTHERS => '0');
	pp2(0)(34 downto 0) <= ext_signs(0) & not(ext_signs(0)) & not(ext_signs(0)) & not(ext_signs(0)) & pp(0);
	complGen:
	for i in 1 to 9 generate
		ifGenlt8:
		if (i<8) generate
		--MS '0's
		pp2(i)(57 downto (31 + 3*i + 3)) <= (OTHERS => '0');
		--Hot 1's
			pp2(i)(31 + 3*i + 2) <= '1';
		end generate ifGenlt8;
		--not(signs)
		ifGenlt9:
		if (i<9) generate
			pp2(i)((31 + 3*i + 1) downto (31 + 3*i)) <= '1' & ext_signs(i);
			--Copy operand
			pp2(i)((31 + 3*i - 1) downto (3*i)) <= pp(i);
		end generate ifGenlt9;
		ifGeneq9:
		if (i=9) generate
			--i=9 ==> overflow
			--Copy operand
			pp2(i)((31 + 3*i-2) downto (3*i)) <= pp(i)(29 downto 0);
		end generate ifGeneq9;
		--'0' and signs
		pp2(i)((3*i-1) downto (3*i-3)) <= "00" & signs(i-1);
		--LS '0's
		ifGengt1:
		if (i>1) generate
			pp2(i)((3*i-4) downto 0) <= (OTHERS => '0');
		end generate ifGengt1;
	end generate complGen;

	--Completing antepenultimate and penultimate rows
	pp2(8)(57) <= '1';--Hot one
	pp2(9)(57) <= pp(9)(30);--pp last bit

	pp2(10) <= "000000000000000000000000000000" & signs(9) & "000000000000000000000000000";

	--[4:2] tree
	tree: booth8_29_compr4to2Tree_11_58 port map(pp2(0),pp2(1),pp2(2),pp2(3),pp2(4),pp2(5),
			pp2(6),pp2(7),pp2(8),pp2(9),pp2(10),s1,c1);

	Zs <= s1;
	Zc <= c1;--Beware: carry must be shifted one position to the left

end estr;
