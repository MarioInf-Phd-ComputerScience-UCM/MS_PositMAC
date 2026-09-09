library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity Pau32_qmadd_ms_v1_PSR3 is
    generic (
        PIPELINE            : std_logic := '1'
    );
    port (
        clk                     : in std_logic;
        rst                     : in std_logic;
        enable_in               : in std_logic;
        A_sgn_in                : in std_logic;
        A_nzn_in                : in std_logic;
        B_sgn_in                : in std_logic;
        B_nzn_in                : in std_logic;
        AB_sfBiased_in          : in std_logic_vector(7 downto 0);
        paddedFrac_Sin          : in std_logic_vector(295 downto 0);
        neg_sf_in               : in std_logic;
        AB_sgn_in               : in std_logic;
        INFO_newOp_in           : in std_logic;
        INFO_OpCode_in          : in std_logic_vector((OPCODE_LEN-1) downto 0);
        INFO_OpTag_in           : in std_logic_vector((OPTAG_LEN-1) downto 0);
        INFO_ReadyStage_in      : in std_logic;
        INFO_ReadyFeedback_in   : in std_logic;

        enable_out              : out std_logic;
        A_sgn_out               : out std_logic;
        A_nzn_out               : out std_logic;
        B_sgn_out               : out std_logic;
        B_nzn_out               : out std_logic;
        AB_sfBiased_out         : out std_logic_vector(7 downto 0);
        paddedFrac_out          : out std_logic_vector(295 downto 0);
        neg_sf_out              : out std_logic;
        AB_sgn_out              : out std_logic;
        INFO_newOp_out          : out std_logic;
        INFO_OpCode_out         : out std_logic_vector((OPCODE_LEN-1) downto 0);
        INFO_OpTag_out          : out std_logic_vector((OPTAG_LEN-1) downto 0);
        INFO_ReadyFeedback_out  : out std_logic
    );
end Pau32_qmadd_ms_v1_PSR3;


architecture arch of Pau32_qmadd_ms_v1_PSR3 is

    signal stateReady       : std_logic;
    signal enable_reg       : std_logic;
    signal INFO_newOp_reg   : std_logic;

begin

    stateReady <= '1' when (INFO_ReadyStage_in = '1' and INFO_ReadyFeedback_in = '1') else '0';
    INFO_ReadyFeedback_out <= stateReady;

    gen_pipeline: if (PIPELINE = '1') generate
        process(clk)
        begin
            if (clk'event and clk = '1') then
                if (rst = '1') then
                    enable_out          <= '0';
                    A_sgn_out           <= '0';
                    A_nzn_out           <= '0';
                    B_sgn_out           <= '0';
                    B_nzn_out           <= '0';
                    AB_sfBiased_out     <= (others => '0');
                    paddedFrac_out      <= (others => '0');
                    neg_sf_out          <= '0';
                    AB_sgn_out          <= '0';
                    INFO_newOp_out      <= '0';
                    INFO_OpCode_out     <= (others => '0');
                    INFO_OpTag_out      <= (others => '0');
                    enable_reg          <= '0';
                    INFO_newOp_reg      <= '0';                        
                else

                    if (enable_in = '1') then
                        enable_reg <= '1';
                    end if;
                    if (INFO_newOp_in = '1') then
                        INFO_newOp_reg <= '1';
                    end if;

                    if (stateReady = '1') then
                        enable_out          <= (enable_reg or enable_in);
                        A_sgn_out           <= A_sgn_in;
                        A_nzn_out           <= A_nzn_in;
                        B_sgn_out           <= B_sgn_in;
                        B_nzn_out           <= B_nzn_in;
                        AB_sfBiased_out     <= AB_sfBiased_in;
                        paddedFrac_out      <= paddedFrac_Sin;
                        neg_sf_out          <= neg_sf_in;
                        AB_sgn_out          <= AB_sgn_in;
                        INFO_newOp_out      <= (INFO_newOp_reg or INFO_newOp_in);
                        INFO_OpCode_out     <= INFO_OpCode_in;
                        INFO_OpTag_out      <= INFO_OpTag_in;
                        enable_reg          <= '0';
                        INFO_newOp_reg      <= '0';                            
                    else
                        enable_out          <= '0';
                        INFO_newOp_out      <= '0';
                    end if;
                end if;
            end if;
        end process;

    end generate gen_pipeline;

    gen_combinatorial: if (PIPELINE = '0') generate
        enable_out          <= enable_in;
        A_sgn_out           <= A_sgn_in;
        A_nzn_out           <= A_nzn_in;
        B_sgn_out           <= B_sgn_in;
        B_nzn_out           <= B_nzn_in;
        AB_sfBiased_out     <= AB_sfBiased_in;
        paddedFrac_out      <= paddedFrac_Sin;
        neg_sf_out          <= neg_sf_in;
        AB_sgn_out          <= AB_sgn_in;
        INFO_newOp_out      <= INFO_newOp_in;
        INFO_OpCode_out     <= INFO_OpCode_in;
        INFO_OpTag_out      <= INFO_OpTag_in;
    end generate gen_combinatorial;

end architecture arch;