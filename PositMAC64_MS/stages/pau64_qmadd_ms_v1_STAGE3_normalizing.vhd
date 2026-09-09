library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity pau64_qmadd_ms_v1_STAGE3_normalizing is
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        enable              : in std_logic;
        A_sf                : in std_logic_vector(8 downto 0);
        B_sf                : in std_logic_vector(8 downto 0);
        AB_frac_in          : in std_logic_vector(121 downto 0);

        AB_sfBiased_out     : out std_logic_vector(8 downto 0);
        paddedFrac_out      : out std_logic_vector(615 downto 0);
        neg_sf_out          : out std_logic;
        AB_sgn_out          : out std_logic;
        ReadyFlag_out       : out std_logic
    );
end entity pau64_qmadd_ms_v1_STAGE3_normalizing;


architecture arch of pau64_qmadd_ms_v1_STAGE3_normalizing is

    component FracNormalizer is
        port(
            AB_f        : in std_logic_vector(121 downto 0);
            AB_ovfExtra : out std_logic;
            AB_ovf      : out std_logic;
            AB_normF    : out std_logic_vector(118 downto 0)
        );
    end component FracNormalizer;

    component IntAdder_10_F50_uid445 is
        port ( 
            clk     : in std_logic;
            X       : in std_logic_vector(9 downto 0);
            Y       : in std_logic_vector(9 downto 0);
            Cin     : in std_logic;
            R       : out std_logic_vector(9 downto 0)   
        );
    end component;

    component IntAdder_10_F50_uid448 is
        port ( 
            clk     : in std_logic;
            X       : in std_logic_vector(9 downto 0);
            Y       : in std_logic_vector(9 downto 0);
            Cin     : in std_logic;
            R       : out std_logic_vector(9 downto 0)   
        );
    end component;

    component IntAdder_9_F50_uid450 is
        port ( 
            clk     : in std_logic;
            X       : in std_logic_vector(8 downto 0);
            Y       : in std_logic_vector(8 downto 0);
            Cin     : in std_logic;
            R       : out std_logic_vector(8 downto 0)   
        );
    end component;

    signal AB_sgn                   : std_logic;
    signal AB_ovfExtra              : std_logic;
    signal AB_ovf                   : std_logic;
    signal AB_normF                 : std_logic_vector(118 downto 0);
    signal AA_sf                    : std_logic_vector(9 downto 0);
    signal BB_sf                    : std_logic_vector(9 downto 0);
    signal AB_sf_tmp                : std_logic_vector(9 downto 0);
    signal AB_sf                    : std_logic_vector(9 downto 0);
    signal neg_sf                   : std_logic;
    signal AB_effectiveSF           : std_logic_vector(8 downto 0);
    signal adderInput               : std_logic_vector(8 downto 0);
    signal adderBias                : std_logic_vector(8 downto 0);
    signal ob                       : std_logic;
    signal AB_sfBiased              : std_logic_vector(8 downto 0);
    signal paddedFrac               : std_logic_vector(615 downto 0);

    signal AB_normF_Concat0_496     : std_logic_vector(495 downto 0);
    signal AB_sgn_Concat_119        : std_logic_vector(119 downto 0);
    signal AB_normF_Concat0_276     : std_logic_vector(375 downto 0);

begin

   --1) Normalize
    AB_sgn <= AB_frac_in(121);
    FracNormalizer_ins : FracNormalizer
        port map(
            AB_f        => AB_frac_in,
            AB_ovfExtra => AB_ovfExtra,
            AB_ovf      => AB_ovf,
            AB_normF    => AB_normF
        );


    -- 2) Add the exponent values
    AA_sf <= A_sf(A_sf'high) & A_sf;
    BB_sf <= B_sf(B_sf'high) & B_sf;
    SFAdder: IntAdder_10_F50_uid445
        port map ( 
            clk     => clk,
            Cin     => AB_ovfExtra,
            X       => AA_sf,
            Y       => BB_sf,
            R       => AB_sf_tmp
        );
    RoundingAdder: IntAdder_10_F50_uid448
        port map ( 
            clk     => clk,
            Cin     => AB_ovf,
            X       => AB_sf_tmp,
            Y       => "0000000000",
            R       => AB_sf
        );

        
   -- 3) Shift AB fraction into corresponding quire format 
    neg_sf <= AB_sf(9);
    AB_effectiveSF <= AB_sf(8 downto 0);
    adderInput <= NOT(AB_effectiveSF);
    adderBias <= "111110000" when neg_sf='0' else "111111111";
    ob <= '1';
    BiasedSFAdder: IntAdder_9_F50_uid450
        port map ( 
            clk    => clk,
            Cin    => ob,
            X      => adderInput,
            Y      => adderBias,
            R      => AB_sfBiased
        );
    
    AB_normF_Concat0_496 <= (others => '0');
    AB_normF_Concat0_276 <= (others => '0');
    AB_sgn_Concat_119 <= (others => AB_sgn);
    paddedFrac <= (NOT(AB_sgn) & AB_normF & AB_normF_Concat0_496 ) when neg_sf='0' else (AB_sgn_Concat_119 & NOT(AB_sgn) & AB_normF & AB_normF_Concat0_276 );


    -- 4) Returning output signals
    AB_sfBiased_out <= AB_sfBiased;
    paddedFrac_out  <= paddedFrac;
    neg_sf_out      <= neg_sf;
    AB_sgn_out      <= AB_sgn;
    ReadyFlag_out   <= '1' when (rst = '0') else '0';


end architecture arch;