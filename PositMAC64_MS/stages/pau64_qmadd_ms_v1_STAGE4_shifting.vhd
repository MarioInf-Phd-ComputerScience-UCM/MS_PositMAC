library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity pau64_qmadd_ms_v1_STAGE4_shifting is
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        enable              : in std_logic;
        A_nzn               : in std_logic;
        A_sgn               : in std_logic;
        B_nzn               : in std_logic;
        B_sgn               : in std_logic;
        AB_sfBiased         : in std_logic_vector(8 downto 0);
        paddedFrac          : in std_logic_vector(615 downto 0);
        neg_sf              : in std_logic;
        AB_sgn              : in std_logic;
        
        AB_nar_out          : out std_logic;
        AB_quire_out        : out std_logic_vector(1023 downto 0);
        ReadyFlag_out       : out std_logic
    );
end entity pau64_qmadd_ms_v1_STAGE4_shifting;


architecture arch of pau64_qmadd_ms_v1_STAGE4_shifting is

    component RightShifter616_by_max_496_F50_uid452 is
        port (
            clk     : in std_logic;
            X       : in  std_logic_vector(615 downto 0);
            S       : in  std_logic_vector(8 downto 0);
            padBit  : in  std_logic;
            R       : out  std_logic_vector(615 downto 0)   
        );
    end component RightShifter616_by_max_496_F50_uid452;

    signal AB_sgn_Concat_376        : std_logic_vector(376 downto 0);
    signal fixedPosit_Concat0_377   : std_logic_vector(376 downto 0);
    signal AB_sgn_Concat_30         : std_logic_vector(30 downto 0);
    signal AB_quire_Concat0_1022    : std_logic_vector(1022 downto 0);
    signal fixedPosit               : std_logic_vector(615 downto 0);
    signal quirePosit               : std_logic_vector(992 downto 0);
    signal AB_quire                 : std_logic_vector(1023 downto 0);
    signal AB_nzn                   : std_logic;
    signal AB_nar                   : std_logic;

begin

    -- 1) Shifting
    Frac_RightShifter: RightShifter616_by_max_496_F50_uid452
        port map ( 
            clk    => clk,
            S      => AB_sfBiased,
            X      => paddedFrac,
            padBit => AB_sgn,
            R      => fixedPosit
        );

    
    AB_nzn <= A_nzn AND B_nzn;                                      --Added
    AB_nar <= (A_sgn AND NOT(A_nzn)) OR (B_sgn AND NOT(B_nzn));     --Added

    AB_sgn_Concat_376 <= (others => AB_sgn);
    fixedPosit_Concat0_377 <= (others => '0');
    quirePosit <= (fixedPosit & fixedPosit_Concat0_377) when neg_sf='0' else (AB_sgn_Concat_376 & fixedPosit);
        
    AB_quire_Concat0_1022 <= (others => '0');
    AB_sgn_Concat_30 <= (others => AB_sgn);
    AB_quire <= (AB_sgn_Concat_30 & quirePosit) when AB_nzn='1' else AB_nar & AB_quire_Concat0_1022;

    -- 2) Returning stage signals
    AB_nar_out      <= AB_nar;
    AB_quire_out    <= AB_quire;
    ReadyFlag_out   <= '1' when (rst = '0') else '0';

end architecture arch;