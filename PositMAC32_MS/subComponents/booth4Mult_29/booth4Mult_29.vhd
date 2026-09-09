--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a 29x29 boothMult

entity booth4Mult_29 is
	port(
		X: in std_logic_vector(28 downto 0);
		Y: in std_logic_vector(28 downto 0);
		Zs: out std_logic_vector(57 downto 0);
		Zc: out std_logic_vector(57 downto 0)
	);
end booth4Mult_29;

architecture estr of booth4Mult_29 is

	--Component declarations

	component booth4_29_boothEnc is
		generic(
			N: integer
		);
		port(
			x: in std_logic_vector((N-1) downto 0);
			sel: out std_logic_vector((2*(N/2)+1) downto 0);
			signs: out std_logic_vector((N/2) downto 0)
		);
	end component;

	component booth4_29_mux3to1 is
		generic(
			N: integer
		);
		port(
			x0: in std_logic_vector((N-1) downto 0);
			x1: in std_logic_vector((N-1) downto 0);
			x2: in std_logic_vector((N-1) downto 0);
			ctrl: in std_logic_vector(1 downto 0);
			z: out std_logic_vector((N-1) downto 0)
		);
	end component;

	component booth4_29_compr4to2Tree_16_59 is
		port(
			x0: in std_logic_vector(58 downto 0);
			x1: in std_logic_vector(58 downto 0);
			x2: in std_logic_vector(58 downto 0);
			x3: in std_logic_vector(58 downto 0);
			x4: in std_logic_vector(58 downto 0);
			x5: in std_logic_vector(58 downto 0);
			x6: in std_logic_vector(58 downto 0);
			x7: in std_logic_vector(58 downto 0);
			x8: in std_logic_vector(58 downto 0);
			x9: in std_logic_vector(58 downto 0);
			x10: in std_logic_vector(58 downto 0);
			x11: in std_logic_vector(58 downto 0);
			x12: in std_logic_vector(58 downto 0);
			x13: in std_logic_vector(58 downto 0);
			x14: in std_logic_vector(58 downto 0);
			x15: in std_logic_vector(58 downto 0);
			s: out std_logic_vector(58 downto 0);
			c: out std_logic_vector(58 downto 0)
		);
	end component;

	--Type declarations

	type ppMatrix is array (0 to 15) of std_logic_vector(29 downto 0);--29+1
	type ppMatrix2 is array (0 to 15) of std_logic_vector(58 downto 0);--2*29

	--Signal declarations

	signal zero30: std_logic_vector(29 downto 0);
	signal x1: std_logic_vector(29 downto 0);
	signal doublex1: std_logic_vector(29 downto 0);
	signal sel: std_logic_vector(29 downto 0);
	signal signs: std_logic_vector(14 downto 0);
	signal ext_signs: std_logic_vector(15 downto 0);--For negative multipliers
	signal pp: ppMatrix;
	signal ppAux: ppMatrix;
	signal ppSign: ppMatrix;
	signal pp2: ppMatrix2;
	signal cout: std_logic;
	signal s1: std_logic_vector(58 downto 0);
	signal c1: std_logic_vector(58 downto 0);

begin

	--Booth encoding
	b_enc: booth4_29_boothEnc generic map(29)
		port map(Y,sel,signs);

	--X mantissas
	zero30 <= (OTHERS => '0');
	x1 <= X(28) & X;--1X
	doublex1 <= X & '0';--2X

	--Mux3to1
	muxGen:
	for i in 0 to 14 generate
		muxStage: booth4_29_mux3to1 generic map(30)
			port map(zero30,x1,doublex1,sel((2*i+1) downto (2*i)),ppAux(i));
		ppSign(i) <= (OTHERS => signs(i));
		pp(i) <= ppAux(i) xor ppSign(i);
		ext_signs(i) <= ((signs(i) xnor X(28)) and not(not(sel(2*i+1)) and not(sel(2*i)) and signs(i))) or
			(not(sel(2*i+1)) and not(sel(2*i)) and not(signs(i)));
	end generate muxGen;

	--Complete partial products
	pp2(0)(58 downto 33) <= (OTHERS => '0');
	pp2(0)(32 downto 0) <= ext_signs(0) & not(ext_signs(0)) & not(ext_signs(0)) & pp(0);
	complGen:
	for i in 1 to 15 generate
		ifGenlt14:
		if (i<14) generate
			--MS '0's
			pp2(i)(58 downto (32 + 2*i)) <= (OTHERS => '0');
			--'1's
			pp2(i)(32 + 2*i - 1) <= '1';
		end generate ifGenlt14;
		ifGenlt15:
		if (i<15) generate
			pp2(i)(30 + 2*i) <= ext_signs(i);
			--Copy operand
			pp2(i)((29 + 2*i) downto 2*i) <= pp(i);
		end generate ifGenlt15;
		ifGeneq15:
		if (i=15) generate
			--i=15 ==> just the sign
			pp2(i)(58 downto 30) <= (OTHERS => '0');
		end generate ifGeneq15;
		--'0' and signs
		pp2(i)((2*i-1) downto (2*i-2)) <= '0' & signs(i-1);
		--LS '0's
		ifGengt1:
		if (i>1) generate
			pp2(i)((2*i-3) downto 0) <= (OTHERS => '0');
		end generate ifGengt1;
	end generate complGen;

	--[4:2] tree
	tree: booth4_29_compr4to2Tree_16_59 port map(pp2(0),pp2(1),pp2(2),pp2(3),pp2(4),pp2(5),
			pp2(6),pp2(7),pp2(8),pp2(9),pp2(10),pp2(11),pp2(12),pp2(13),pp2(14),pp2(15),
			s1,c1);

	Zs <= s1(57 downto 0);
	Zc <= c1(57 downto 0);--Beware: carry must be shifted one position to the left

end estr;
