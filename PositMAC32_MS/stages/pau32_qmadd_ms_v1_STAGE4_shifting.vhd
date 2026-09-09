library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity Pau32_qmadd_ms_v1_STAGE4_shifting is
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        enable              : in std_logic;
        A_nzn               : in std_logic;
        A_sgn               : in std_logic;
        B_nzn               : in std_logic;
        B_sgn               : in std_logic;
        AB_sfBiased         : in std_logic_vector(7 downto 0);
        paddedFrac          : in std_logic_vector(295 downto 0);
        neg_sf              : in std_logic;
        AB_sgn              : in std_logic;
        
        AB_nar_out          : out std_logic;
        AB_quire_out        : out std_logic_vector(511 downto 0);
        ReadyFlag_out       : out std_logic
    );
end entity Pau32_qmadd_ms_v1_STAGE4_shifting;


architecture arch of Pau32_qmadd_ms_v1_STAGE4_shifting is

    component RightShifter296_by_max_240_F50_uid124 is
        port ( 
            clk     : in std_logic;
            X       : in std_logic_vector(295 downto 0);
            S       : in std_logic_vector(7 downto 0);
            padBit  : in std_logic;
            R       : out std_logic_vector(295 downto 0)   
        );
    end component RightShifter296_by_max_240_F50_uid124;

    signal fixedPosit               : std_logic_vector(295 downto 0);
    signal quirePosit               : std_logic_vector(480 downto 0);
    signal AB_quire                 : std_logic_vector(511 downto 0);
    signal AB_nzn                   : std_logic;
    signal AB_nar                   : std_logic;

    signal fixedPosit_Concat0_185   : std_logic_vector(184 downto 0);
    signal AB_sgnd3_Concat_480_296  : std_logic_vector(480 downto 296);
    signal AB_sgnd3_Concat_511_481  : std_logic_vector(511 downto 481);
    signal AB_quire_Concat0_510_0   : std_logic_vector(510 downto 0);

begin

    -- 1) Shifting
    Frac_RightShifter: RightShifter296_by_max_240_F50_uid124
        port map ( 
            clk    => clk,
            S      => AB_sfBiased,
            X      => paddedFrac,
            padBit => AB_sgn,
            R      => fixedPosit
        );
    
    AB_nzn <= A_nzn AND B_nzn;                                      --Added
    AB_nar <= (A_sgn AND NOT(A_nzn)) OR (B_sgn AND NOT(B_nzn));     --Added

    fixedPosit_Concat0_185 <= (others => '0');
    AB_sgnd3_Concat_480_296 <= (others => AB_sgn);
    quirePosit <= (fixedPosit & fixedPosit_Concat0_185) when neg_sf='0' else (AB_sgnd3_Concat_480_296 & fixedPosit);
        
    AB_quire_Concat0_510_0 <= (others => '0');
    AB_sgnd3_Concat_511_481 <= (others => AB_sgn);
    AB_quire <= (AB_sgnd3_Concat_511_481 & quirePosit) when AB_nzn='1' else AB_nar & AB_quire_Concat0_510_0;

    -- 2) Returning stage signals
    AB_nar_out      <= AB_nar;
    AB_quire_out    <= AB_quire;
    ReadyFlag_out   <= '1' when (rst = '0') else '0';

end architecture arch;