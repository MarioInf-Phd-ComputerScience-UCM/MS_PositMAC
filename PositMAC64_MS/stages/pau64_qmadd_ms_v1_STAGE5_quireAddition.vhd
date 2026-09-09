--------------------------------------------------------------------------------
-- Quire Adder instruction guide:
    -- OpCode = "000" -> UNKNOWN
    -- OpCode = "001" -> QCLEAR
    -- OpCode = "010" -> QMADD/QMSUB
    -- OpCode = "011" -> QROUND
    -- OpCode = "100" -> QNEG
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity pau64_qmadd_ms_v1_STAGE5_quireAddition is
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
end entity pau64_qmadd_ms_v1_STAGE5_quireAddition;


architecture arch of pau64_qmadd_ms_v1_STAGE5_quireAddition is

    component msAdd_gp is
        generic(
            ADDER_ALGORITHM : type_quireAdder_Algorithm  := UNKNOWN;
            N               : integer;
            K               : integer;
            LOG_K           : integer;
            LOG_N_DIV_K     : integer
        );
        port(
            rst             : in std_logic;
            clk             : in std_logic;
            a               : in std_logic_vector((N-1) downto 0);
            b               : in std_logic_vector((N-1) downto 0);
            cin             : in std_logic;
            enHit           : in std_logic;
            z               : out std_logic_vector((N-1) downto 0);
            G               : out std_logic_vector((N/K) downto 0);
            P               : out std_logic_vector((N/K) downto 0);
            hit             : out std_logic
        );
    end component msAdd_gp;

    signal ABC_add                  : std_logic_vector(1023 downto 0);
    signal zeros                    : std_logic_vector(1022 downto 0);
    signal C_nar                    : std_logic;
    signal ABC_nar                  : std_logic;
    signal B_negMask                : std_logic_vector((N-1) downto 0);

    signal QA_OpUNKNOWN             : std_logic;
    signal QA_OpQCLR                : std_logic;
    signal QA_OpQMADD               : std_logic;
    signal QA_OpQROUND              : std_logic;
    signal QA_OpQNEG                : std_logic;

    signal A_quireIncrement_UNKNOWN : std_logic_vector((N-1) downto 0);
    signal A_quireIncrement_QCLR    : std_logic_vector((N-1) downto 0);
    signal A_quireIncrement_QMADD   : std_logic_vector((N-1) downto 0);
    signal A_quireIncrement_QROUND  : std_logic_vector((N-1) downto 0);
    signal A_quireIncrement_QNEG    : std_logic_vector((N-1) downto 0);

    signal B_feedback               : std_logic_vector((N-1) downto 0);
    signal B_feedback_UNKNOWN       : std_logic_vector((N-1) downto 0);
    signal B_feedback_QCLR          : std_logic_vector((N-1) downto 0);
    signal B_feedback_QMADD         : std_logic_vector((N-1) downto 0);
    signal B_feedback_QROUND        : std_logic_vector((N-1) downto 0);
    signal B_feedback_QNEG          : std_logic_vector((N-1) downto 0);
    
    signal QA1024_enHit_i           : std_logic;
    signal QA1024_A_i               : std_logic_vector((N-1) downto 0);
    signal QA1024_B_i               : std_logic_vector((N-1) downto 0);
    signal QA1024_cin_i             : std_logic;
    signal QA1024_G_o               : std_logic_vector((N/K) downto 0);
    signal QA1024_P_o               : std_logic_vector((N/K) downto 0);
    signal QA1024_hit_o             : std_logic;
    signal QA1024_hit_o_reg         : std_logic;

    signal roundCtrl_end            : std_logic;

    signal negCtrl_ReadyRecv        : std_logic;
    signal negCtrl_cin              : std_logic;    -- Control signal for QuireAdder carry-in in QNEG operation (negCtrl_cin = 1 for QNEG, negCtrl_cin = 0 for non-QNEG)
    signal negCtrl_cin_d1           : std_logic;
    signal negCtrl_enHit            : std_logic;    -- Forces the QuireAdder speculation when QNEG operation needs to realize a initial rounding
    signal negCtrl_RoundDone        : std_logic;    -- Indicates when the QNEG operation is realizing the initial rounding
    signal negCtrl_RoundDone_d1     : std_logic;
    signal negCtrl_NegDone          : std_logic;
    
    signal Ready_UNKNOWN            : std_logic;
    signal Ready_QCLR               : std_logic;
    signal Ready_QMADD              : std_logic;
    signal Ready_QROUND             : std_logic;
    signal Ready_QNEG               : std_logic;
    signal Ready_QNEG_d1            : std_logic;

    signal Ready_opTag_UNKNOWN      : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal Ready_opTag_QCLR         : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal Ready_opTag_QMADD        : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal Ready_opTag_QROUND       : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal Ready_opTag_QNEG         : std_logic_vector((OPTAG_LEN-1) downto 0);
    signal Ready_opTag_QNEG_d1      : std_logic_vector((OPTAG_LEN-1) downto 0);

    signal result                   : std_logic_vector(1023 downto 0);

begin

    -- process to B_feedback Control
    process (clk)
    begin
        if (clk'event and clk = '1') then
            QA1024_B_i              <= B_feedback;
            negCtrl_RoundDone_d1    <= negCtrl_RoundDone;
            negCtrl_cin_d1          <= negCtrl_cin;
            Ready_QNEG_d1           <= Ready_QNEG;
            Ready_opTag_QNEG_d1     <= Ready_opTag_QNEG;
            QA1024_hit_o_reg        <= QA1024_hit_o;
        end if;
    end process;

    -- UNKNOWN control - START
    A_quireIncrement_UNKNOWN    <= (others => '0');
    B_feedback_UNKNOWN          <= (others => '0') when (rst = '1') else ABC_add;
    Ready_UNKNOWN               <= '1';
    Ready_opTag_UNKNOWN         <= (others => '0');
    -- UNKNOWN control - START

    -- QCLR control - START
    A_quireIncrement_QCLR <= 
        (others => '0')     when (rst = '1') else                                          -- Reset
        (others => '0')     when (QA_OpQCLR = '0') else                                    -- Executing different instruction
        (others => '0')     when (QA_OpQCLR = '1' and newOp = '1' and enable = '0') else   -- New QCLR stall instruction
        (others => '0')     when (QA_OpQCLR = '1' and enable = '0') else                   -- QCLR stall instruction
        (others => '0')     when (QA_OpQCLR = '1' and enable = '1') else                   -- QCLR instruction execution
        (others => '0');                                                                   -- Others

    B_feedback_QCLR <= 
        (others => '0')     when (rst = '1') else
        (others => '0')     when (QA_OpQCLR = '0') else
        (others => '0')     when (QA_OpQCLR = '1' and newOp = '1' and enable = '0') else
        (others => '0')     when (QA_OpQCLR = '1' and enable = '0') else
        (others => '0')     when (QA_OpQCLR = '1' and enable = '1') else
        (others => '0');

    Ready_QCLR <= 
        '0'                 when (rst = '1') else
        '0'                 when (QA_OpQCLR = '0') else
        '0'                 when (QA_OpQCLR = '1' and newOp = '1' and enable = '0') else
        '1'                 when (QA_OpQCLR = '1' and enable = '1');

    Ready_opTag_QCLR <= 
        (others => '0')     when (rst = '1') else
        (others => '0')     when (QA_OpQCLR = '0') else
        (others => '0')     when (QA_OpQCLR = '1' and newOp = '1' and enable = '0') else
        QA_OpTag            when (QA_OpQCLR = '1' and enable = '1');
    -- QCLR control - END


    -- QMADD control - START
    A_quireIncrement_QMADD <= 
        (others => '0')     when (rst = '1') else                                          -- Reset
        (others => '0')     when (QA_OpQMADD = '0') else                                   -- Executing different instruction
        (others => '0')     when (QA_OpQMADD = '1' and newOp = '1' and enable = '0') else  -- New QMADD stall instruction
        (others => '0')     when (QA_OpQMADD = '1' and enable = '0') else                  -- QMADD instruction stall
        AB_quire            when (QA_OpQMADD = '1' and enable = '1') else                  -- QMADD instruction execution
        (others => '0');                                                                   -- Others

    B_feedback_QMADD <= 
        (others => '0')     when (rst = '1') else
        ABC_add             when (QA_OpQMADD = '0') else
        ABC_add             when (QA_OpQMADD = '1' and newOp = '1' and enable = '0') else 
        ABC_add             when (QA_OpQMADD = '1' and enable = '0') else
        ABC_add             when (QA_OpQMADD = '1' and enable = '1') else
        ABC_add;

    Ready_QMADD <= 
        '0'                 when (rst = '1') else
        '0'                 when (QA_OpQMADD = '0') else
        '0'                 when (QA_OpQMADD = '1' and newOp = '1' and enable = '0') else 
        '1'                 when (QA_OpQMADD = '1' and enable = '1');

    Ready_opTag_QMADD <= 
        (others => '0')     when (rst = '1') else
        (others => '0')     when (QA_OpQMADD = '0') else
        (others => '0')     when (QA_OpQMADD = '1' and newOp = '1' and enable = '0') else 
        QA_OpTag            when (QA_OpQMADD = '1' and enable = '1');
    -- QMADD control - END


    -- QROUND control - START
    A_quireIncrement_QROUND <= 
        (others => '0')     when (rst = '1') else 
        (others => '0')     when (QA_OpQROUND = '0') else                                   -- Executing different instruction
        (others => '0')     when (QA_OpQROUND = '1' and newOp = '1' and enable = '0') else  -- New QROUND stall instruction
        (others => '0')     when (QA_OpQROUND = '1' and enable = '0') else                  -- QROUND instruction stall
        (others => '0')     when (QA_OpQROUND = '1' and enable = '1') else                  -- QROUND instruction execution
        (others => '0');                                                                    -- Others

    B_feedback_QROUND <= 
        (others => '0')     when (rst = '1') else
        ABC_add             when (QA_OpQROUND = '0') else                                   
        ABC_add             when (QA_OpQROUND = '1' and newOp = '1' and enable = '0') else   
        ABC_add             when (QA_OpQROUND = '1' and enable = '0') else                  
        ABC_add             when (QA_OpQROUND = '1' and enable = '1') else
        ABC_add;                

    roundCtrl_end <=        
        '0'                 when (rst = '1') else
        '0'                 when (QA_OpQROUND = '0') else
        '0'                 when (QA_OpQROUND = '1' and newOp = '1' and enable = '0') else
        '1'                 when (QA_OpQROUND = '1' and enable = '1');

    Ready_QROUND <= 
        '0'                 when (rst = '1') else
        '0'                 when (QA_OpQROUND = '0') else
        '0'                 when (QA_OpQROUND = '1' and newOp = '1' and enable = '0') else 
        '0'                 when (QA_OpQROUND = '1' and enable = '1') else
        '0'                 when (QA_OpQROUND = '1' and QA1024_hit_o_reg = '0' and roundCtrl_end = '1') else       
        '1'                 when (QA_OpQROUND = '1' and QA1024_hit_o_reg = '1' and roundCtrl_end = '1');

    Ready_opTag_QROUND <= 
        (others => '0')     when (rst = '1') else
        (others => '0')     when (QA_OpQROUND = '0') else
        (others => '0')     when (QA_OpQROUND = '1' and newOp = '1' and enable = '0') else 
        (others => '0')     when (QA_OpQROUND = '1' and enable = '1') else
        (others => '0')     when (QA_OpQROUND = '1' and QA1024_hit_o_reg = '0' and roundCtrl_end = '1') else
        QA_OpTag            when (QA_OpQROUND = '1' and QA1024_hit_o_reg = '1' and roundCtrl_end = '1');
    -- QROUND control - END


    -- QNEG control - START
    A_quireIncrement_QNEG <= 
        (others => '0')         when (rst = '1') else
        (others => '0')         when (QA_OpQNEG = '0') else
        (others => '0')         when (QA_OpQNEG = '1' and negCtrl_RoundDone_d1 = '1' and negCtrl_RoundDone = '1') else
        (others => '0')         when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_RoundDone = '1') else 
        (others => '0')         when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_RoundDone = '0') else
        (others => '0');

    B_feedback_QNEG <= 
        (others => '0')         when (rst = '1') else
        ABC_add                 when (QA_OpQNEG = '0') else
        ABC_add                 when (QA_OpQNEG = '1' and negCtrl_RoundDone_d1 = '1' and negCtrl_RoundDone = '1') else
        ABC_add                 when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_RoundDone = '0') else
        (B_negMask xor ABC_add) when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_RoundDone = '1') else
        ABC_add;

    negCtrl_cin <=
        '0'                     when (rst = '1') else
        '0'                     when (QA_OpQNEG = '0') else
        '0'                     when (QA_OpQNEG = '1' and negCtrl_RoundDone_d1 = '1' and negCtrl_RoundDone = '1') else
        '0'                     when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_RoundDone = '0') else
        '1'                     when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_RoundDone = '1');

    negCtrl_ReadyRecv <=
        '0'                     when (rst = '1') else
        '0'                     when (QA_OpQNEG = '0') else
        '0'                     when (QA_OpQNEG = '1' and enable = '0' and newOp = '1') else
        '1'                     when (QA_OpQNEG = '1' and enable = '1');

    negCtrl_RoundDone <=
        '0'                     when (rst = '1') else
        '0'                     when (QA_OpQNEG = '0') else
        '0'                     when (QA_OpQNEG = '1' and newOp = '1') else
        '1'                     when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_enHit = '1' and QA1024_hit_o_reg = '1');

    negCtrl_NegDone <=
        '0'                     when (rst = '1') else
        '0'                     when (QA_OpQNEG = '0') else
        '0'                     when (QA_OpQNEG = '1' and newOp = '1') else
        '1'                     when (QA_OpQNEG = '1' and negCtrl_RoundDone_d1 = '1');

    negCtrl_enHit <=
        '0'                     when (rst = '1') else
        '0'                     when (QA_OpQNEG = '0') else
        '1'                     when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_NegDone = '0') else
        '0'                     when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_NegDone = '1');

    Ready_QNEG <= 
        '0'                     when (rst = '1') else
        '0'                     when (QA_OpQNEG = '0') else
        '0'                     when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_RoundDone = '0') else
        '1'                     when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_RoundDone = '1');

    Ready_opTag_QNEG <= 
        (others => '0')         when (rst = '1') else
        (others => '0')         when (QA_OpQNEG = '0') else
        (others => '0')         when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_RoundDone = '0') else
        QA_OpTag                when (QA_OpQNEG = '1' and negCtrl_ReadyRecv = '1' and negCtrl_RoundDone = '1');  
    -- QNEG control - END


    QA_OpUNKNOWN    <= '1' when QA_OpCode = "000" else '0';
    QA_OpQCLR       <= '1' when QA_OpCode = "001" else '0';
    QA_OpQMADD      <= '1' when QA_OpCode = "010" else '0';
    QA_OpQROUND     <= '1' when QA_OpCode = "011" else '0';
    QA_OpQNEG       <= '1' when QA_OpCode = "100" else '0';
    
    QA1024_A_i <=   A_quireIncrement_QCLR when QA_OpQCLR = '1' else
                    A_quireIncrement_QMADD when QA_OpQMADD = '1' else
                    A_quireIncrement_QROUND when QA_OpQROUND = '1' else
                    A_quireIncrement_QNEG when QA_OpQNEG = '1' else
                    A_quireIncrement_UNKNOWN when QA_OpUNKNOWN = '1'else
                    A_quireIncrement_UNKNOWN;

    B_feedback <=   B_feedback_QCLR when QA_OpQCLR = '1' else
                    B_feedback_QMADD when QA_OpQMADD = '1' else
                    B_feedback_QROUND when QA_OpQROUND = '1' else
                    B_feedback_QNEG when QA_OpQNEG = '1' else
                    B_feedback_UNKNOWN when QA_OpUNKNOWN = '1'else
                    B_feedback_UNKNOWN;


    -- 1) Add quires
    B_negMask <= (others => '1');
    QA1024_cin_i <= negCtrl_cin_d1;
    QA1024_enHit_i <= QA_OpQROUND or negCtrl_enHit;

    QuireAdder: msAdd_gp
        generic map(
            ADDER_ALGORITHM     => QUIRE_ADDER_ALGORITHM_SELECTED,
            N                   => N,
            K                   => K,
            LOG_K               => LOG_K,
            LOG_N_DIV_K         => LOG_N_DIV_K      
        )
        port map(
            rst         => rst,
            clk         => clk,
            a           => QA1024_A_i,
            b           => QA1024_B_i,
            cin         => QA1024_cin_i,
            enHit       => QA1024_enHit_i,
            z           => ABC_add,
            G           => QA1024_G_o,
            P           => QA1024_P_o,
            hit         => QA1024_hit_o
        );


    zeros <= (others => '0');
    C_nar <= ABC_add(1023) when ((ABC_add(1022 downto 0) = zeros) and (QA1024_hit_o_reg = '1')) else '0';
    --C_nar <= C(1023) when (C(1022 downto 0) = zeros) else '0';
    ABC_nar <= AB_nar OR C_nar;
    result <= ABC_add when ABC_nar='0' else ('1' & zeros);


    -- 2) Returning output signals
    QA_Hit_out <= QA1024_hit_o_reg;
    ReadyFlag_out <=   
        Ready_QCLR          when QA_OpQCLR = '1' else
        Ready_QMADD         when QA_OpQMADD = '1' else
        Ready_QROUND        when QA_OpQROUND = '1' else
        Ready_QNEG_d1       when QA_OpQNEG = '1' else
        Ready_UNKNOWN       when QA_OpUNKNOWN = '1';

    ReadyFlag_OpTag <=  
        Ready_opTag_QCLR    when QA_OpQCLR = '1' else
        Ready_opTag_QMADD   when QA_OpQMADD = '1' else
        Ready_opTag_QROUND  when QA_OpQROUND = '1' else
        Ready_opTag_QNEG_d1 when QA_OpQNEG = '1' else
        Ready_opTag_UNKNOWN when QA_OpUNKNOWN = '1';

    ReadyFlag_OpCode    <= QA_OpCode;
    result_out          <= result;

end architecture arch;