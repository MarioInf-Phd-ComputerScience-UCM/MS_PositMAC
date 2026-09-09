--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.config.all;

--This module implements a 61x61 boothMult

entity booth4Mult_61 is
	port(
		X: in std_logic_vector(60 downto 0);
		Y: in std_logic_vector(60 downto 0);
		Zs: out std_logic_vector(121 downto 0);
		Zc: out std_logic_vector(121 downto 0)
	);
end booth4Mult_61;

architecture estr of booth4Mult_61 is

	--Component declarations

	component booth4_boothEnc is
		generic(
			N: integer
		);
		port(
			x: in std_logic_vector((N-1) downto 0);
			sel: out std_logic_vector((2*(N/2)+1) downto 0);
			signs: out std_logic_vector((N/2) downto 0)
		);
	end component;

	component booth4_mux3to1 is
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

	component booth4_compr4to2Tree_32_123 is
		port(
			x0: in std_logic_vector(122 downto 0);
			x1: in std_logic_vector(122 downto 0);
			x2: in std_logic_vector(122 downto 0);
			x3: in std_logic_vector(122 downto 0);
			x4: in std_logic_vector(122 downto 0);
			x5: in std_logic_vector(122 downto 0);
			x6: in std_logic_vector(122 downto 0);
			x7: in std_logic_vector(122 downto 0);
			x8: in std_logic_vector(122 downto 0);
			x9: in std_logic_vector(122 downto 0);
			x10: in std_logic_vector(122 downto 0);
			x11: in std_logic_vector(122 downto 0);
			x12: in std_logic_vector(122 downto 0);
			x13: in std_logic_vector(122 downto 0);
			x14: in std_logic_vector(122 downto 0);
			x15: in std_logic_vector(122 downto 0);
			x16: in std_logic_vector(122 downto 0);
			x17: in std_logic_vector(122 downto 0);
			x18: in std_logic_vector(122 downto 0);
			x19: in std_logic_vector(122 downto 0);
			x20: in std_logic_vector(122 downto 0);
			x21: in std_logic_vector(122 downto 0);
			x22: in std_logic_vector(122 downto 0);
			x23: in std_logic_vector(122 downto 0);
			x24: in std_logic_vector(122 downto 0);
			x25: in std_logic_vector(122 downto 0);
			x26: in std_logic_vector(122 downto 0);
			x27: in std_logic_vector(122 downto 0);
			x28: in std_logic_vector(122 downto 0);
			x29: in std_logic_vector(122 downto 0);
			x30: in std_logic_vector(122 downto 0);
			x31: in std_logic_vector(122 downto 0);
			s: out std_logic_vector(122 downto 0);
			c: out std_logic_vector(122 downto 0)
		);
	end component;

	--Type declarations

	type ppMatrix is array (0 to 31) of std_logic_vector(61 downto 0);--61+1
	type ppMatrix2 is array (0 to 31) of std_logic_vector(122 downto 0);--2*61

	--Signal declarations

	signal zero62: std_logic_vector(61 downto 0);
	signal x1: std_logic_vector(61 downto 0);
	signal doublex1: std_logic_vector(61 downto 0);
	signal sel: std_logic_vector(61 downto 0);
	signal signs: std_logic_vector(30 downto 0);
	signal ext_signs: std_logic_vector(31 downto 0);--For negative multipliers
	signal pp: ppMatrix;
	signal ppAux: ppMatrix;
	signal ppSign: ppMatrix;
	signal pp2: ppMatrix2;
	signal cout: std_logic;
	signal s1: std_logic_vector(122 downto 0);
	signal c1: std_logic_vector(122 downto 0);

begin

	--Booth encoding
	b_enc: booth4_boothEnc generic map(61)
		port map(Y,sel,signs);

	--X mantissas
	zero62 <= (OTHERS => '0');
	x1 <= X(60) & X;--1X
	doublex1 <= X & '0';--2X

	--Mux3to1
	muxGen:
	for i in 0 to 30 generate
		muxStage: booth4_mux3to1 generic map(62)
			port map(zero62,x1,doublex1,sel((2*i+1) downto (2*i)),ppAux(i));
		ppSign(i) <= (OTHERS => signs(i));
		pp(i) <= ppAux(i) xor ppSign(i);
		ext_signs(i) <= ((signs(i) xnor X(60)) and not(not(sel(2*i+1)) and not(sel(2*i)) and signs(i))) or
			(not(sel(2*i+1)) and not(sel(2*i)) and not(signs(i)));
	end generate muxGen;

	--Complete partial products
	pp2(0)(122 downto 65) <= (OTHERS => '0');
	pp2(0)(64 downto 0) <= ext_signs(0) & not(ext_signs(0)) & not(ext_signs(0)) & pp(0);
	complGen:
	for i in 1 to 31 generate
		ifGenlt30:
		if (i<30) generate
			--MS '0's
			pp2(i)(122 downto (64 + 2*i)) <= (OTHERS => '0');
			--'1's
			pp2(i)(64 + 2*i - 1) <= '1';
		end generate ifGenlt30;
		ifGenlt31:
		if (i<31) generate
			pp2(i)(62 + 2*i) <= ext_signs(i);
			--Copy operand
			pp2(i)((61 + 2*i) downto 2*i) <= pp(i);
		end generate ifGenlt31;
		ifGeneq31:
		if (i=31) generate
			--i=31 ==> just the sign
			pp2(i)(122 downto 62) <= (OTHERS => '0');
		end generate ifGeneq31;
		--'0' and signs
		pp2(i)((2*i-1) downto (2*i-2)) <= '0' & signs(i-1);
		--LS '0's
		ifGengt1:
		if (i>1) generate
			pp2(i)((2*i-3) downto 0) <= (OTHERS => '0');
		end generate ifGengt1;
	end generate complGen;

	--[4:2] tree
	tree: booth4_compr4to2Tree_32_123 port map(pp2(0),pp2(1),pp2(2),pp2(3),pp2(4),pp2(5),
			pp2(6),pp2(7),pp2(8),pp2(9),pp2(10),pp2(11),pp2(12),pp2(13),pp2(14),pp2(15),
			pp2(16),pp2(17),pp2(18),pp2(19),pp2(20),pp2(21),pp2(22),pp2(23),pp2(24),pp2(25),
			pp2(26),pp2(27),pp2(28),pp2(29),pp2(30),pp2(31),s1,c1);

	Zs <= s1(121 downto 0);
	Zc <= c1(121 downto 0);--Beware: carry must be shifted one position to the left

end estr;
