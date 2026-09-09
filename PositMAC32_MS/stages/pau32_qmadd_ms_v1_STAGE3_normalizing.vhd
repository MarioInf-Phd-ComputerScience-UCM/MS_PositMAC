library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity Pau32_qmadd_ms_v1_STAGE3_normalizing is
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        enable              : in std_logic;
        A_sf                : in std_logic_vector(7 downto 0);
        B_sf                : in std_logic_vector(7 downto 0);
        AB_frac_in          : in std_logic_vector(57 downto 0);

        AB_sfBiased_out     : out std_logic_vector(7 downto 0);
        paddedFrac_out      : out std_logic_vector(295 downto 0);
        neg_sf_out          : out std_logic;
        AB_sgn_out          : out std_logic;
        ReadyFlag_out       : out std_logic
    );
end entity Pau32_qmadd_ms_v1_STAGE3_normalizing;


architecture arch of Pau32_qmadd_ms_v1_STAGE3_normalizing is

    component FracNormalizer32 is
        port(
            AB_f        : in std_logic_vector(57 downto 0);
            AB_ovfExtra : out std_logic;
            AB_ovf      : out std_logic;
            AB_normF    : out std_logic_vector(54 downto 0)
        );
    end component FracNormalizer32;

   component IntAdder_9_F50_uid117 is
        port ( 
            clk     : in std_logic;
            X       : in std_logic_vector(8 downto 0);
            Y       : in std_logic_vector(8 downto 0);
            Cin     : in std_logic;
            R       : out std_logic_vector(8 downto 0)   
        );
   end component IntAdder_9_F50_uid117;

    component IntAdder_9_F50_uid120 is
        port ( 
            clk     : in std_logic;
            X       : in std_logic_vector(8 downto 0);
            Y       : in std_logic_vector(8 downto 0);
            Cin     : in std_logic;
            R       : out std_logic_vector(8 downto 0)   
        );
    end component IntAdder_9_F50_uid120;

    component IntAdder_8_F50_uid122 is
        port ( 
            clk     : in std_logic;
            X       : in std_logic_vector(7 downto 0);
            Y       : in std_logic_vector(7 downto 0);
            Cin     : in std_logic;
            R       : out std_logic_vector(7 downto 0)   
        );
    end component IntAdder_8_F50_uid122;

    signal AB_sgn                   : std_logic;
    signal AB_ovfExtra              : std_logic;
    signal AB_ovf                   : std_logic;
    signal AB_normF                 : std_logic_vector(54 downto 0);
    signal AA_sf                    : std_logic_vector(8 downto 0);
    signal BB_sf                    : std_logic_vector(8 downto 0);
    signal AB_sf_tmp                : std_logic_vector(8 downto 0);
    signal AB_sf                    : std_logic_vector(8 downto 0);
    signal neg_sf                   : std_logic;
    signal AB_effectiveSF           : std_logic_vector(7 downto 0);
    signal adderInput               : std_logic_vector(7 downto 0);
    signal adderBias                : std_logic_vector(7 downto 0);
    signal ob                       : std_logic;
    signal AB_sfBiased              : std_logic_vector(7 downto 0);
    signal paddedFrac               : std_logic_vector(295 downto 0);

    signal AB_normF_Concat0_240     : std_logic_vector(239 downto 0);
    signal AB_normF_Concat0_184     : std_logic_vector(183 downto 0);
    signal AB_sgn_Concat_295_240    : std_logic_vector(295 downto 240);

begin

   --1) Normalize
    AB_sgn <= AB_frac_in(57);
    FracNormalizer32_ins : FracNormalizer32
        port map(
            AB_f        => AB_frac_in,
            AB_ovfExtra => AB_ovfExtra,
            AB_ovf      => AB_ovf,
            AB_normF    => AB_normF
        );


    -- 2) Add the exponent values
    AA_sf <= A_sf(A_sf'high) & A_sf;
    BB_sf <= B_sf(B_sf'high) & B_sf;

    SFAdder: IntAdder_9_F50_uid117
        port map ( 
            clk     => clk,
            Cin     => AB_ovfExtra,
            X       => AA_sf,
            Y       => BB_sf,
            R       => AB_sf_tmp
        );
    
    RoundingAdder: IntAdder_9_F50_uid120
        port map ( 
            clk     => clk,
            Cin     => AB_ovf,
            X       => AB_sf_tmp,
            Y       => "000000000",
            R       => AB_sf
        );

        
   -- 3) Shift AB fraction into corresponding quire format 
    neg_sf           <= AB_sf(8);
    AB_effectiveSF   <= AB_sf(7 downto 0);
    adderInput       <= NOT(AB_effectiveSF);
    adderBias        <= "11110000" when neg_sf='0' else "11111111";
    ob               <= '1';

    BiasedSFAdder: IntAdder_8_F50_uid122
        port map ( 
            clk    => clk,
            Cin    => ob,
            X      => adderInput,
            Y      => adderBias,
            R      => AB_sfBiased
        );
    
    AB_normF_Concat0_240 <= (others => '0');
    AB_normF_Concat0_184 <= (others => '0');
    AB_sgn_Concat_295_240 <= (others => AB_sgn);
    paddedFrac <= (NOT(AB_sgn) & AB_normF & AB_normF_Concat0_240 ) when neg_sf='0' else (AB_sgn_Concat_295_240 & NOT(AB_sgn) & AB_normF & AB_normF_Concat0_184 );


    -- 4) Returning output signals
    AB_sfBiased_out <= AB_sfBiased;
    paddedFrac_out  <= paddedFrac;
    neg_sf_out      <= neg_sf;
    AB_sgn_out      <= AB_sgn;
    ReadyFlag_out   <= '1' when (rst = '0') else '0';


end architecture arch;