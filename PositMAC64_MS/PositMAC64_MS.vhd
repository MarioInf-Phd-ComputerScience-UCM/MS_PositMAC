--------------------------------------------------------------------------------
--                                  PositMAC64_MS
--                    (PositMAC_64_2_Quire_1024_F50_uid2)
-- Inputs: this FMA computes A*B+C
-- VHDL generated for Kintex7 @ 50MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Raul Murillo (2021) and Mario Alonso (2025)
--------------------------------------------------------------------------------
-- Pipeline depth: 3 cycles
-- Clock period (ns): 20
-- Target frequency (MHz): 50
-- Input signals: A B C
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity PositMAC64_MS is
    generic (
        MULTIPLY_ALGORITHM_SELECTED         : type_multiplyAlgorithm            := UNKNOWN;
        MULTIPLY_ALGORITHM_ADDER_SELECTED   : type_multiplyAlgorithm_Adder      := UNKNOWN;
        QUIRE_ADDER_ALGORITHM_SELECTED      : type_quireAdder_Algorithm         := UNKNOWN;
        N                                   : integer                           := 1024;
        K                                   : integer                           := 32;
        LOG_K                               : integer                           := 5;
        LOG_N_DIV_K                         : integer                           := 5;
        PIPELINE_STAGE_1                    : std_logic                         := '1';
        PIPELINE_STAGE_2                    : std_logic                         := '1';
        PIPELINE_STAGE_3                    : std_logic                         := '1';
        PIPELINE_STAGE_4                    : std_logic                         := '1'
    );
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        enable          : in std_logic;
        newOp           : in std_logic; 
        A               : in std_logic_vector((POSIT64LEN-1) downto 0);
        B               : in std_logic_vector((POSIT64LEN-1) downto 0);
        QA_OpCode       : in std_logic_vector((OPCODE_LEN-1) downto 0);
        QA_OpTag        : in std_logic_vector((OPTAG_LEN-1) downto 0);
        
        Available       : out std_logic;
        QA_Hit          : out std_logic;
        Ready           : out std_logic;
        Ready_OpCode    : out std_logic_vector((OPCODE_LEN-1) downto 0);
        Ready_OpTag     : out std_logic_vector((OPTAG_LEN-1) downto 0);
        R               : out std_logic_vector((QUIRE64LEN-1) downto 0)
    );
end entity;


architecture arch of PositMAC64_MS is

    component pau64_qmadd_ms_v1_STAGE1_decoding is
        port (
            clk                     : in std_logic;
            rst                     : in std_logic;
            enable                  : in std_logic;
            A                       : in std_logic_vector(63 downto 0);
            B                       : in std_logic_vector(63 downto 0);

            A_sgn_out               : out std_logic;
            A_sf_out                : out std_logic_vector(8 downto 0);
            A_frac_out              : out std_logic_vector(58 downto 0);
            A_nzn_out               : out std_logic;
            B_sgn_out               : out std_logic;
            B_sf_out                : out std_logic_vector(8 downto 0);
            B_frac_out              : out std_logic_vector(58 downto 0);
            B_nzn_out               : out std_logic;
            ReadyFlag_out           : out std_logic
        );
    end component pau64_qmadd_ms_v1_STAGE1_decoding;

    component Pau64_qmadd_ms_v1_PSR1 is
        generic (
            PIPELINE                : std_logic := '1'
        );
        port (
            clk                     : in std_logic;
            rst                     : in std_logic;
            enable_in               : in std_logic;
            A_sgn_in                : in std_logic;
            A_sf_in                 : in std_logic_vector(8 downto 0);
            A_frac_in               : in std_logic_vector(58 downto 0);
            A_nzn_in                : in std_logic;
            B_sgn_in                : in std_logic;
            B_sf_in                 : in std_logic_vector(8 downto 0);
            B_frac_in               : in std_logic_vector(58 downto 0);
            B_nzn_in                : in std_logic;
            INFO_newOp_in           : in std_logic;
            INFO_OpCode_in          : in std_logic_vector((OPCODE_LEN-1) downto 0);
            INFO_OpTag_in           : in std_logic_vector((OPTAG_LEN-1) downto 0);
            INFO_ReadyStage_in      : in std_logic;
            INFO_ReadyFeedback_in   : in std_logic;

            enable_out              : out std_logic;
            A_sgn_out               : out std_logic;
            A_sf_out                : out std_logic_vector(8 downto 0);
            A_frac_out              : out std_logic_vector(58 downto 0);
            A_nzn_out               : out std_logic;
            B_sgn_out               : out std_logic;
            B_sf_out                : out std_logic_vector(8 downto 0);
            B_frac_out              : out std_logic_vector(58 downto 0);
            B_nzn_out               : out std_logic;
            INFO_newOp_out          : out std_logic;
            INFO_OpCode_out         : out std_logic_vector((OPCODE_LEN-1) downto 0);
            INFO_OpTag_out          : out std_logic_vector((OPTAG_LEN-1) downto 0);
            INFO_ReadyFeedback_out  : out std_logic
        );
    end component Pau64_qmadd_ms_v1_PSR1;

    component pau64_qmadd_ms_v1_STAGE2_multiplying is
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
    end component pau64_qmadd_ms_v1_STAGE2_multiplying;

    component Pau64_qmadd_ms_v1_PSR2 is
        generic (
            PIPELINE                : std_logic := '1'
        );
        port (
            clk                     : in std_logic;
            rst                     : in std_logic;
            enable_in               : in std_logic;
            A_sgn_in                : in std_logic;
            A_nzn_in                : in std_logic;
            A_sf_in                 : in std_logic_vector(8 downto 0);
            B_sgn_in                : in std_logic;
            B_nzn_in                : in std_logic;
            B_sf_in                 : in std_logic_vector(8 downto 0);
            AB_frac_in              : in std_logic_vector(121 downto 0);
            INFO_newOp_in           : in std_logic;
            INFO_OpCode_in          : in std_logic_vector((OPCODE_LEN-1) downto 0);
            INFO_OpTag_in           : in std_logic_vector((OPTAG_LEN-1) downto 0);
            INFO_ReadyStage_in      : in std_logic;
            INFO_ReadyFeedback_in   : in std_logic;

            enable_out              : out std_logic;
            A_sgn_out               : out std_logic;
            A_nzn_out               : out std_logic;
            A_sf_out                : out std_logic_vector(8 downto 0);
            B_sgn_out               : out std_logic;
            B_nzn_out               : out std_logic;
            B_sf_out                : out std_logic_vector(8 downto 0);
            AB_frac_out             : out std_logic_vector(121 downto 0);
            INFO_newOp_out          : out std_logic;
            INFO_OpCode_out         : out std_logic_vector((OPCODE_LEN-1) downto 0);
            INFO_OpTag_out          : out std_logic_vector((OPTAG_LEN-1) downto 0);
            INFO_ReadyFeedback_out  : out std_logic
        );
    end component Pau64_qmadd_ms_v1_PSR2;

    component pau64_qmadd_ms_v1_STAGE3_normalizing is
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
    end component pau64_qmadd_ms_v1_STAGE3_normalizing;

    component Pau64_qmadd_ms_v1_PSR3 is
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
            AB_sfBiased_in          : in std_logic_vector(8 downto 0);
            paddedFrac_Sin          : in std_logic_vector(615 downto 0);
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
            AB_sfBiased_out         : out std_logic_vector(8 downto 0);
            paddedFrac_out          : out std_logic_vector(615 downto 0);
            neg_sf_out              : out std_logic;
            AB_sgn_out              : out std_logic;
            INFO_newOp_out          : out std_logic;
            INFO_OpCode_out         : out std_logic_vector((OPCODE_LEN-1) downto 0);
            INFO_OpTag_out          : out std_logic_vector((OPTAG_LEN-1) downto 0);
            INFO_ReadyFeedback_out  : out std_logic
        );
    end component Pau64_qmadd_ms_v1_PSR3;

    component pau64_qmadd_ms_v1_STAGE4_shifting is
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
    end component pau64_qmadd_ms_v1_STAGE4_shifting;

    component Pau64_qmadd_ms_v1_PSR4 is
        generic (
            PIPELINE                : std_logic := '1'
        );
        port (
            clk                     : in std_logic;
            rst                     : in std_logic;
            enable_in               : in std_logic;
            AB_nar_in               : in std_logic;
            AB_quire_in             : in std_logic_vector(1023 downto 0);
            INFO_newOp_in           : in std_logic;
            INFO_OpCode_in          : in std_logic_vector((OPCODE_LEN-1) downto 0);
            INFO_OpTag_in           : in std_logic_vector((OPTAG_LEN-1) downto 0);
            INFO_ReadyStage_in      : in std_logic;
            INFO_ReadyFeedback_in   : in std_logic;

            enable_out              : out std_logic;
            AB_nar_out              : out std_logic;
            AB_quire_out            : out std_logic_vector(1023 downto 0);
            INFO_newOp_out          : out std_logic;
            INFO_OpCode_out         : out std_logic_vector((OPCODE_LEN-1) downto 0);
            INFO_OpTag_out          : out std_logic_vector((OPTAG_LEN-1) downto 0);
            INFO_ReadyFeedback_out  : out std_logic
        );
    end component Pau64_qmadd_ms_v1_PSR4;

    component pau64_qmadd_ms_v1_STAGE5_quireAddition is
        generic (
            QUIRE_ADDER_ALGORITHM_SELECTED      : type_quireAdder_Algorithm     := UNKNOWN;
            N                                   : integer                       := 1024;
            K                                   : integer                       := 32;
            LOG_K                               : integer                       := 5;
            LOG_N_DIV_K                         : integer                       := 5
        );
        port (
            clk                 : in std_logic;
            rst                 : in std_logic;
            enable              : in std_logic;
            QA_OpCode           : in std_logic_vector((OPCODE_LEN-1) downto 0);
            QA_OpTag            : in std_logic_vector((OPTAG_LEN-1) downto 0);
            newOp               : in std_logic;
            AB_quire            : in std_logic_vector((QUIRE64LEN-1) downto 0);
            AB_nar              : in std_logic;
            
            QA_Hit_out          : out std_logic;
            Result_out          : out std_logic_vector((QUIRE64LEN-1) downto 0);
            ReadyFlag_out       : out std_logic;
            ReadyFlag_OpCode    : out std_logic_vector((OPCODE_LEN-1) downto 0);
            ReadyFlag_OpTag     : out std_logic_vector((OPTAG_LEN-1) downto 0)
        );
    end component pau64_qmadd_ms_v1_STAGE5_quireAddition;


    -- Stage 1 signals
    signal A_sgn_fromStage1_toPSR1                  : std_logic;
    signal A_sf_fromStage1_toPSR1                   : std_logic_vector(8 downto 0);
    signal A_frac_fromStage1_toPSR1                 : std_logic_vector(58 downto 0);
    signal A_nzn_fromStage1_toPSR1                  : std_logic;
    signal B_sgn_fromStage1_toPSR1                  : std_logic;
    signal B_sf_fromStage1_toPSR1                   : std_logic_vector(8 downto 0);
    signal B_frac_fromStage1_toPSR1                 : std_logic_vector(58 downto 0);
    signal B_nzn_fromStage1_toPSR1                  : std_logic;
    signal Stage1_decoding_readyFlag                : std_logic;

    signal A_sgn_fromPSR1_toStage2                  : std_logic;
    signal A_frac_fromPSR1_toStage2                 : std_logic_vector(58 downto 0);
    signal B_sgn_fromPSR1_toStage2                  : std_logic;
    signal B_frac_fromPSR1_toStage2                 : std_logic_vector(58 downto 0);

    signal enable_fromPSR1_toPSR2                   : std_logic;
    signal A_nzn_fromPSR1_toPSR2                    : std_logic;
    signal A_sf_fromPSR1_toPSR2                     : std_logic_vector(8 downto 0);
    signal B_nzn_fromPSR1_toPSR2                    : std_logic;
    signal B_sf_fromPSR1_toPSR2                     : std_logic_vector(8 downto 0);
    signal INFO_newOp_fromPSR1_toPSR2               : std_logic;
    signal INFO_OpCode_fromPSR1_toPSR2              : std_logic_vector((OPCODE_LEN-1) downto 0);
    signal INFO_OpTag_fromPSR1_toPSR2               : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal INFO_readyStage_fromPSR1_toCtrl          : std_logic;


    -- Stage 2 signals
    signal AB_frac_fromStage2_toPSR2                : std_logic_vector(121 downto 0);  
    signal Stage2_multiplying_readyFlag             : std_logic;

    signal A_sf_fromPSR2_toStage3                   : std_logic_vector(8 downto 0);
    signal B_sf_fromPSR2_toStage3                   : std_logic_vector(8 downto 0);

    signal enable_fromPSR2_toPSR3                   : std_logic;
    signal A_sgn_fromPSR2_toPSR3                    : std_logic;
    signal A_nzn_fromPSR2_toPSR3                    : std_logic;
    signal B_sgn_fromPSR2_toPSR3                    : std_logic;
    signal B_nzn_fromPSR2_toPSR3                    : std_logic;
    signal neg_sf_fromPSR2_toPSR3                   : std_logic;
    signal AB_frac_fromPSR2_toPSR3                  : std_logic_vector(121 downto 0);  
    signal INFO_newOp_fromPSR2_toPSR3               : std_logic;
    signal INFO_OpCode_fromPSR2_toPSR3              : std_logic_vector((OPCODE_LEN-1) downto 0);
    signal INFO_OpTag_fromPSR2_toPSR3               : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal INFO_readyStage_fromPSR2_toCtrl          : std_logic;


    -- Stage 3 signals
    signal AB_sfBiased_fromStage3_toPSR3            : std_logic_vector(8 downto 0);
    signal paddedFrac_fromStage3_toPSR3             : std_logic_vector(615 downto 0);
    signal neg_sf_fromStage3_toPSR3                 : std_logic;
    signal AB_sgn_fromStage3_toPSR3                 : std_logic;
    signal Stage3_normalizing_readyFlag             : std_logic;

    signal A_sgn_fromPSR3_toStage4                  : std_logic;
    signal A_nzn_fromPSR3_toStage4                  : std_logic;
    signal B_sgn_fromPSR3_toStage4                  : std_logic;
    signal B_nzn_fromPSR3_toStage4                  : std_logic;
    signal AB_sfBiased_fromPSR3_toStage4            : std_logic_vector(8 downto 0);
    signal paddedFrac_fromPSR3_toStage4             : std_logic_vector(615 downto 0);
    signal neg_sf_fromPSR3_toStage4                 : std_logic;
    signal AB_sgn_fromPSR3_toStage4                 : std_logic;

    signal enable_fromPSR3_toPSR4                   : std_logic;
    signal INFO_newOp_fromPSR3_toPSR4               : std_logic;
    signal INFO_OpCode_fromPSR3_toPSR4              : std_logic_vector((OPCODE_LEN-1) downto 0);
    signal INFO_OpTag_fromPSR3_toPSR4               : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal INFO_readyStage_fromPSR3_toCtrl          : std_logic;


    -- Stage 4 signals
    signal AB_nar_fromStage4_toPSR4                 : std_logic;
    signal AB_quire_fromStage4_toPSR4               : std_logic_vector(1023 downto 0);
    signal Stage4_shifting_readyFlag                : std_logic;

    signal enable_fromPSR4_toStage5                 : std_logic;
    signal AB_nar_fromPSR4_toStage5                 : std_logic;
    signal AB_quire_fromPSR4_toStage5               : std_logic_vector(1023 downto 0);
    signal INFO_newOp_fromPSR4_toStage5             : std_logic;
    signal INFO_OpCode_fromPSR4_toStage5            : std_logic_vector((OPCODE_LEN-1) downto 0);
    signal INFO_OpTag_fromPSR4_toStage5             : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal INFO_readyStage_fromPSR4_toCtrl          : std_logic;


    -- Stage 5 to output signals
    signal QA_Hit_fromStage5_toOut                  : std_logic;
    signal result_fromStage5_toOut                  : std_logic_vector(1023 downto 0);
    signal Ready_OpCode_fromStage5_toOut            : std_logic_vector((OPCODE_LEN-1) downto 0);
    signal Ready_OpTag_fromStage5_toOut             : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal Stage5_quireAddition_readyFlag           : std_logic;

    signal INFO_newOp_fromPSR4_toOut                : std_logic;
    signal INFO_OpCode_fromPSR4_toOut               : std_logic_vector((OPCODE_LEN-1) downto 0);
    signal INFO_OpTag_fromPSR4_toOut                : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal INFO_readyStage_fromPSR5_toCtrl          : std_logic;


    -- Pipeline control signals
    signal INFO_ReadyStage_fromStage1_toPSR1        : std_logic;
    signal INFO_ReadyStage_fromStage2_toPSR2        : std_logic;
    signal INFO_ReadyStage_fromStage3_toPSR3        : std_logic;
    signal INFO_ReadyStage_fromStage4_toPSR4        : std_logic;
    signal INFO_ReadyStage_fromStage5_toOut         : std_logic;

begin

    -----------------------------------------------------------
    -- STAGE 1 - START: DECODE ENTRY PARAMS
    -----

    stage1_Decoding: pau64_qmadd_ms_v1_STAGE1_decoding
        port map (
            clk                     => clk,
            rst                     => rst,
            A                       => A,
            B                       => B,
            enable                  => enable,

            A_sgn_out               => A_sgn_fromStage1_toPSR1,
            A_sf_out                => A_sf_fromStage1_toPSR1,
            A_frac_out              => A_frac_fromStage1_toPSR1,
            A_nzn_out               => A_nzn_fromStage1_toPSR1,
            B_sgn_out               => B_sgn_fromStage1_toPSR1,
            B_sf_out                => B_sf_fromStage1_toPSR1,
            B_frac_out              => B_frac_fromStage1_toPSR1,
            B_nzn_out               => B_nzn_fromStage1_toPSR1,
            ReadyFlag_out           => Stage1_decoding_readyFlag
        );

    INFO_ReadyStage_fromStage1_toPSR1 <= Stage1_decoding_readyFlag;

    stage1_PSR: Pau64_qmadd_ms_v1_PSR1
        generic map (
            PIPELINE            => PIPELINE_STAGE_1
        )
        port map(
            clk                     => clk,
            rst                     => rst,
            enable_in               => enable,
            A_sgn_in                => A_sgn_fromStage1_toPSR1,
            A_sf_in                 => A_sf_fromStage1_toPSR1,
            A_frac_in               => A_frac_fromStage1_toPSR1,
            A_nzn_in                => A_nzn_fromStage1_toPSR1,
            B_sgn_in                => B_sgn_fromStage1_toPSR1,
            B_sf_in                 => B_sf_fromStage1_toPSR1,
            B_frac_in               => B_frac_fromStage1_toPSR1,
            B_nzn_in                => B_nzn_fromStage1_toPSR1,
            INFO_newOp_in           => newOp,
            INFO_OpCode_in          => QA_OpCode,
            INFO_OpTag_in           => QA_OpTag,
            INFO_ReadyStage_in      => INFO_ReadyStage_fromStage1_toPSR1,
            INFO_ReadyFeedback_in   => INFO_readyStage_fromPSR2_toCtrl,

            enable_out              => enable_fromPSR1_toPSR2,
            A_sgn_out               => A_sgn_fromPSR1_toStage2,
            A_nzn_out               => A_nzn_fromPSR1_toPSR2,
            A_sf_out                => A_sf_fromPSR1_toPSR2,
            A_frac_out              => A_frac_fromPSR1_toStage2,
            B_sgn_out               => B_sgn_fromPSR1_toStage2,
            B_nzn_out               => B_nzn_fromPSR1_toPSR2,
            B_sf_out                => B_sf_fromPSR1_toPSR2,
            B_frac_out              => B_frac_fromPSR1_toStage2,
            INFO_newOp_out          => INFO_newOp_fromPSR1_toPSR2,
            INFO_OpCode_out         => INFO_OpCode_fromPSR1_toPSR2,
            INFO_OpTag_out          => INFO_OpTag_fromPSR1_toPSR2,
            INFO_ReadyFeedback_out  => INFO_readyStage_fromPSR1_toCtrl
        );  

        Available <= INFO_readyStage_fromPSR1_toCtrl;

    -----
    -- STAGE 1 - END: DECODE ENTRY PARAMS
    -----------------------------------------------------------
    -----------------------------------------------------------
    -- STAGE 2 - START: MULTIPLY A & B
    -----

    stage2_multiplying: pau64_qmadd_ms_v1_STAGE2_multiplying
        generic map (
            MULTIPLY_ALGORITHM_SELECTED         => MULTIPLY_ALGORITHM_SELECTED,
            MULTIPLY_ALGORITHM_ADDER_SELECTED   => MULTIPLY_ALGORITHM_ADDER_SELECTED
        )
        port map(
            clk                     => clk,
            rst                     => rst,
            enable                  => enable_fromPSR1_toPSR2,
            A_sgn                   => A_sgn_fromPSR1_toStage2,
            A_frac                  => A_frac_fromPSR1_toStage2,
            B_sgn                   => B_sgn_fromPSR1_toStage2,
            B_frac                  => B_frac_fromPSR1_toStage2,

            AB_frac_out             => AB_frac_fromStage2_toPSR2,
            ReadyFlag_out           => Stage2_multiplying_readyFlag
        );

    INFO_ReadyStage_fromStage2_toPSR2 <= Stage2_multiplying_readyFlag;

    stage2_PSR: Pau64_qmadd_ms_v1_PSR2
        generic map (
            PIPELINE                => PIPELINE_STAGE_2
        )
        port map(
            clk                     => clk,
            rst                     => rst,
            enable_in               => enable_fromPSR1_toPSR2,
            A_sgn_in                => A_sgn_fromPSR1_toStage2,
            A_nzn_in                => A_nzn_fromPSR1_toPSR2,
            A_sf_in                 => A_sf_fromPSR1_toPSR2,
            B_sgn_in                => B_sgn_fromPSR1_toStage2,
            B_nzn_in                => B_nzn_fromPSR1_toPSR2,
            B_sf_in                 => B_sf_fromPSR1_toPSR2,
            AB_frac_in              => AB_frac_fromStage2_toPSR2,
            INFO_newOp_in           => INFO_newOp_fromPSR1_toPSR2,
            INFO_OpCode_in          => INFO_OpCode_fromPSR1_toPSR2,
            INFO_OpTag_in           => INFO_OpTag_fromPSR1_toPSR2,
            INFO_ReadyStage_in      => INFO_ReadyStage_fromStage2_toPSR2,
            INFO_ReadyFeedback_in   => INFO_readyStage_fromPSR3_toCtrl,

            enable_out              => enable_fromPSR2_toPSR3,
            A_sgn_out               => A_sgn_fromPSR2_toPSR3,
            A_sf_out                => A_sf_fromPSR2_toStage3,
            A_nzn_out               => A_nzn_fromPSR2_toPSR3,
            B_sgn_out               => B_sgn_fromPSR2_toPSR3,
            B_sf_out                => B_sf_fromPSR2_toStage3,
            B_nzn_out               => B_nzn_fromPSR2_toPSR3,
            AB_frac_out             => AB_frac_fromPSR2_toPSR3,
            INFO_newOp_out          => INFO_newOp_fromPSR2_toPSR3,
            INFO_OpCode_out         => INFO_OpCode_fromPSR2_toPSR3,
            INFO_OpTag_out          => INFO_OpTag_fromPSR2_toPSR3,
            INFO_ReadyFeedback_out  => INFO_readyStage_fromPSR2_toCtrl
        );

    -----
    -- STAGE 2 - END: MULTIPLY A & B
    -----------------------------------------------------------
    -----------------------------------------------------------
    -- STAGE 3 - START: NORMALIZING
    -----

    stage3_normalizing: pau64_qmadd_ms_v1_STAGE3_normalizing
        port map(
            clk                     => clk,
            rst                     => rst,
            enable                  => enable_fromPSR2_toPSR3,
            A_sf                    => A_sf_fromPSR2_toStage3,
            B_sf                    => B_sf_fromPSR2_toStage3,
            AB_frac_in              => AB_frac_fromPSR2_toPSR3,

            AB_sfBiased_out         => AB_sfBiased_fromStage3_toPSR3,
            paddedFrac_out          => paddedFrac_fromStage3_toPSR3,
            neg_sf_out              => neg_sf_fromStage3_toPSR3,
            AB_sgn_out              => AB_sgn_fromStage3_toPSR3,
            ReadyFlag_out           => Stage3_normalizing_readyFlag
        );

    INFO_ReadyStage_fromStage3_toPSR3 <= Stage3_normalizing_readyFlag;

    stage3_PSR: Pau64_qmadd_ms_v1_PSR3
        generic map (
            PIPELINE                => PIPELINE_STAGE_3
        )
        port map(
            clk                     => clk,
            rst                     => rst,
            enable_in               => enable_fromPSR2_toPSR3,
            A_sgn_in                => A_sgn_fromPSR2_toPSR3,
            A_nzn_in                => A_nzn_fromPSR2_toPSR3,
            B_sgn_in                => B_sgn_fromPSR2_toPSR3,
            B_nzn_in                => B_nzn_fromPSR2_toPSR3,
            AB_sfBiased_in          => AB_sfBiased_fromStage3_toPSR3,
            paddedFrac_Sin          => paddedFrac_fromStage3_toPSR3,
            neg_sf_in               => neg_sf_fromStage3_toPSR3,
            AB_sgn_in               => AB_sgn_fromStage3_toPSR3,
            INFO_newOp_in           => INFO_newOp_fromPSR2_toPSR3,
            INFO_OpCode_in          => INFO_OpCode_fromPSR2_toPSR3,
            INFO_OpTag_in           => INFO_OpTag_fromPSR2_toPSR3,
            INFO_ReadyStage_in      => INFO_ReadyStage_fromStage3_toPSR3,
            INFO_ReadyFeedback_in   => INFO_readyStage_fromPSR4_toCtrl,

            enable_out              => enable_fromPSR3_toPSR4,
            A_sgn_out               => A_sgn_fromPSR3_toStage4,
            A_nzn_out               => A_nzn_fromPSR3_toStage4,
            B_sgn_out               => B_sgn_fromPSR3_toStage4,
            B_nzn_out               => B_nzn_fromPSR3_toStage4,
            AB_sfBiased_out         => AB_sfBiased_fromPSR3_toStage4,
            paddedFrac_out          => paddedFrac_fromPSR3_toStage4,
            neg_sf_out              => neg_sf_fromPSR3_toStage4,
            AB_sgn_out              => AB_sgn_fromPSR3_toStage4,
            INFO_newOp_out          => INFO_newOp_fromPSR3_toPSR4,
            INFO_OpCode_out         => INFO_OpCode_fromPSR3_toPSR4,
            INFO_OpTag_out          => INFO_OpTag_fromPSR3_toPSR4,
            INFO_ReadyFeedback_out  => INFO_readyStage_fromPSR3_toCtrl
        );

    -----
    -- STAGE 3 - START: NORMALIZING
    -----------------------------------------------------------
    -----------------------------------------------------------
    -- STAGE 4 - START: SHIFTING
    -----

    stage4_shifting: pau64_qmadd_ms_v1_STAGE4_shifting
        port map(
            clk                 => clk,
            rst                 => rst,
            enable              => enable_fromPSR3_toPSR4,
            A_sgn               => A_sgn_fromPSR3_toStage4,
            A_nzn               => A_nzn_fromPSR3_toStage4,
            B_sgn               => B_sgn_fromPSR3_toStage4,
            B_nzn               => B_nzn_fromPSR3_toStage4,
            AB_sfBiased         => AB_sfBiased_fromPSR3_toStage4,
            paddedFrac          => paddedFrac_fromPSR3_toStage4,
            neg_sf              => neg_sf_fromPSR3_toStage4,
            AB_sgn              => AB_sgn_fromPSR3_toStage4,
            
            AB_nar_out          => AB_nar_fromStage4_toPSR4,
            AB_quire_out        => AB_quire_fromStage4_toPSR4,
            ReadyFlag_out       => Stage4_shifting_readyFlag
        );

    INFO_ReadyStage_fromStage4_toPSR4 <= Stage4_shifting_readyFlag;

    stage4_PSR: Pau64_qmadd_ms_v1_PSR4
        generic map(
            PIPELINE                => PIPELINE_STAGE_4
        )
        port map(
            clk                     => clk,
            rst                     => rst,
            enable_in               => enable_fromPSR3_toPSR4,
            AB_nar_in               => AB_nar_fromStage4_toPSR4,
            AB_quire_in             => AB_quire_fromStage4_toPSR4,
            INFO_newOp_in           => INFO_newOp_fromPSR3_toPSR4,
            INFO_OpCode_in          => INFO_OpCode_fromPSR3_toPSR4,
            INFO_OpTag_in           => INFO_OpTag_fromPSR3_toPSR4,
            INFO_ReadyStage_in      => INFO_ReadyStage_fromStage4_toPSR4,
            INFO_ReadyFeedback_in   => INFO_ReadyStage_fromStage5_toOut,

            enable_out              => enable_fromPSR4_toStage5,
            AB_nar_out              => AB_nar_fromPSR4_toStage5,
            AB_quire_out            => AB_quire_fromPSR4_toStage5,
            INFO_newOp_out          => INFO_newOp_fromPSR4_toStage5,
            INFO_OpCode_out         => INFO_OpCode_fromPSR4_toStage5,
            INFO_OpTag_out          => INFO_OpTag_fromPSR4_toStage5,
            INFO_ReadyFeedback_out  => INFO_readyStage_fromPSR4_toCtrl
        );

    -----
    -- STAGE 4 - END: SHIFTING
    -----------------------------------------------------------
    -----------------------------------------------------------
    -- STAGE 5 - START: ADD POSIT TO QUIRE
    -----

    stage5_quireAddition: pau64_qmadd_ms_v1_STAGE5_quireAddition
        generic map(
            QUIRE_ADDER_ALGORITHM_SELECTED  => QUIRE_ADDER_ALGORITHM_SELECTED,
            N                               => N,
            K                               => K,
            LOG_K                           => LOG_K,
            LOG_N_DIV_K                     => LOG_N_DIV_K
        )
        port map(
            clk                     => clk,
            rst                     => rst,
            enable                  => enable_fromPSR4_toStage5,
            QA_OpCode               => INFO_OpCode_fromPSR4_toStage5,
            QA_OpTag                => INFO_OpTag_fromPSR4_toStage5,
            newOp                   => INFO_newOp_fromPSR4_toStage5,
            AB_quire                => AB_quire_fromPSR4_toStage5,
            AB_nar                  => AB_nar_fromPSR4_toStage5,

            QA_Hit_out              => QA_Hit_fromStage5_toOut,
            Result_out              => result_fromStage5_toOut,
            ReadyFlag_OpCode        => Ready_OpCode_fromStage5_toOut,
            ReadyFlag_OpTag         => Ready_OpTag_fromStage5_toOut,
            ReadyFlag_out           => Stage5_quireAddition_readyFlag
        );
    INFO_ReadyStage_fromStage5_toOut <= Stage5_quireAddition_readyFlag;
    
    QA_Hit          <= QA_Hit_fromStage5_toOut;
    Ready           <= INFO_ReadyStage_fromStage5_toOut;
    Ready_OpCode    <= Ready_OpCode_fromStage5_toOut;
    Ready_OpTag     <= Ready_OpTag_fromStage5_toOut;
    R               <= result_fromStage5_toOut;

    -----
    -- STAGE 5 - END: ADD POSIT TO QUIRE
    -----------------------------------------------------------

end architecture arch;