library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity pau64_qmadd_ms_v1_STAGE2_multiplying is
    generic (
        MULTIPLY_ALGORITHM_SELECTED         : type_multiplyAlgorithm        := UNKNOWN;
        MULTIPLY_ALGORITHM_ADDER_SELECTED   : type_multiplyAlgorithm_Adder  := UNKNOWN
    );
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        enable              : in std_logic;
        A_sgn               : in std_logic;
        A_frac              : in std_logic_vector(58 downto 0);
        B_sgn               : in std_logic;
        B_frac              : in std_logic_vector(58 downto 0);

        AB_frac_out         : out std_logic_vector(121 downto 0);
        ReadyFlag_out       : out std_logic
    );
end entity pau64_qmadd_ms_v1_STAGE2_multiplying;


architecture arch of pau64_qmadd_ms_v1_STAGE2_multiplying is

    component IntMultiplier_F50_uid122 is
        port ( 
            clk     : in std_logic;
            X       : in std_logic_vector(60 downto 0);
            Y       : in std_logic_vector(60 downto 0);
            R       : out std_logic_vector(121 downto 0)   
        );
    end component IntMultiplier_F50_uid122;

    component booth4Mult_61_synth is
        generic(
            MULTIPLY_ALGORITHM_ADDER_SELECTED   : type_multiplyAlgorithm_Adder  := UNKNOWN
        );    
        port(
            X:  in std_logic_vector(60 downto 0);
            Y:  in std_logic_vector(60 downto 0);
            Z:  out std_logic_vector(121 downto 0)
        );
    end component booth4Mult_61_synth;

    component booth8Mult_61_synth is
	    generic(
            MULTIPLY_ALGORITHM_ADDER_SELECTED   : type_multiplyAlgorithm_Adder  := UNKNOWN
	    );
        port(
            X:  in std_logic_vector(60 downto 0);
            Y:  in std_logic_vector(60 downto 0);
            Z:  out std_logic_vector(121 downto 0)
        );
    end component booth8Mult_61_synth;


    signal AA_frac                  : std_logic_vector(60 downto 0);
    signal BB_frac                  : std_logic_vector(60 downto 0);
    signal AB_frac                  : std_logic_vector(121 downto 0);

begin

    -- 1) Sign
    AA_frac <= A_sgn & NOT(A_sgn) & A_frac;
    BB_frac <= B_sgn & NOT(B_sgn) & B_frac;


    -- 2) Multiply A & B
    Gen_FracMultiply_VHDL: if (MULTIPLY_ALGORITHM_SELECTED = VHDL or MULTIPLY_ALGORITHM_SELECTED = UNKNOWN) generate
        Inst_FracMultiplier_VHDL: IntMultiplier_F50_uid122
            port map ( 
                clk => clk,
                X   => AA_frac,
                Y   => BB_frac,
                R   => AB_frac
            );
    end generate Gen_FracMultiply_VHDL;

    Gen_FracMultiply_Booth4: if (MULTIPLY_ALGORITHM_SELECTED = BOOTH_4) generate
        Inst_FracMultiplier_Booth4: booth4Mult_61_synth
            generic map (
                MULTIPLY_ALGORITHM_ADDER_SELECTED => MULTIPLY_ALGORITHM_ADDER_SELECTED
            )
            port map(
                X => AA_frac,
                Y => BB_frac,
                Z => AB_frac
            );
    end generate Gen_FracMultiply_Booth4;

    Gen_FracMultiply_Booth8: if (MULTIPLY_ALGORITHM_SELECTED = BOOTH_8) generate
        Inst_FracMultiplier_Booth8: booth8Mult_61_synth
            generic map (
                MULTIPLY_ALGORITHM_ADDER_SELECTED => MULTIPLY_ALGORITHM_ADDER_SELECTED
            )
            port map(
                X => AA_frac,
                Y => BB_frac,
                Z => AB_frac
            );
    end generate Gen_FracMultiply_Booth8;


    -- 3) Returning output signals
    AB_frac_out     <= AB_frac;
    ReadyFlag_out   <= '1' when (rst = '0') else '0';


end architecture arch;