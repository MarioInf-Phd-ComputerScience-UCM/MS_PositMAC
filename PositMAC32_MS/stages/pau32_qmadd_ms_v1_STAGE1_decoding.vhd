library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity Pau32_qmadd_ms_v1_STAGE1_decoding is
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        enable              : in std_logic;
        A                   : in std_logic_vector(31 downto 0);
        B                   : in std_logic_vector(31 downto 0);

        A_sgn_out           : out std_logic;
        A_sf_out            : out std_logic_vector(7 downto 0);
        A_frac_out          : out std_logic_vector(26 downto 0);
        A_nzn_out           : out std_logic;
        B_sgn_out           : out std_logic;
        B_sf_out            : out std_logic_vector(7 downto 0);
        B_frac_out          : out std_logic_vector(26 downto 0);
        B_nzn_out           : out std_logic;
        ReadyFlag_out       : out std_logic
    );
end entity Pau32_qmadd_ms_v1_STAGE1_decoding;


architecture arch of Pau32_qmadd_ms_v1_STAGE1_decoding is

    component PositFastDecoder_32_2_F50_uid4 is
        port ( 
            clk     : in std_logic;
            X       : in std_logic_vector(31 downto 0);
            Sign    : out std_logic;
            SF      : out std_logic_vector(7 downto 0);
            Frac    : out std_logic_vector(26 downto 0);
            NZN     : out std_logic
        );
    end component PositFastDecoder_32_2_F50_uid4;

    signal A_sgn_toOut      : std_logic;
    signal A_sf_toOut       : std_logic_vector(7 downto 0);
    signal A_frac_toOut     : std_logic_vector(26 downto 0);
    signal A_nzn_toOut      : std_logic;
    signal B_sgn_toOut      : std_logic;
    signal B_sf_toOut       : std_logic_vector(7 downto 0);
    signal B_frac_toOut     : std_logic_vector(26 downto 0);
    signal B_nzn_toOut      : std_logic;

begin

    -- 1) Decoding A and B
    A_decoder: PositFastDecoder_32_2_F50_uid4
        port map ( 
            clk     => clk,
            X       => A,
            Sign    => A_sgn_toOut,
            SF      => A_sf_toOut,
            Frac    => A_frac_toOut,
            NZN     => A_nzn_toOut
        );
    B_decoder: PositFastDecoder_32_2_F50_uid4
        port map (
            clk     => clk,
            X       => B,
            Sign    => B_sgn_toOut,
            SF      => B_sf_toOut,
            Frac    => B_frac_toOut,
            NZN     => B_nzn_toOut
        );

    -- 2) Returning output signals
    A_sgn_out       <= A_sgn_toOut;
    A_sf_out        <= A_sf_toOut;
    A_frac_out      <= A_frac_toOut;
    A_nzn_out       <= A_nzn_toOut;
    B_sgn_out       <= B_sgn_toOut;
    B_sf_out        <= B_sf_toOut;
    B_frac_out      <= B_frac_toOut;
    B_nzn_out       <= B_nzn_toOut;
    ReadyFlag_out   <= '1' when (rst = '0') else '0';

end architecture arch;