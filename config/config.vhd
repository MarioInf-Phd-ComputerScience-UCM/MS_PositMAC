library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

package config is

    -- POSITMAC AND MSADD CONFIG - START
    type type_multiplyAlgorithm             is (VHDL, BOOTH_4, BOOTH_8, MATLIB, UNKNOWN);
    type type_multiplyAlgorithm_Adder       is (VHDL, KS, BK, RCA, UNKNOWN);
    type type_quireAdder_Algorithm          is (VHDL, KS, BK, RCA, UNKNOWN);
    -- POSITMAC AND MSADD CONFIG - END


    -- ENTRY DATA CONFIG - START
    constant TIME_FRECUENCY                     : time := 10 ns;
    constant LATENCYLEN                         : integer := 4;
    constant OPERATIONCOUNT_LENGTH              : integer := 32;
    constant LATENCY_AB                         : std_logic_vector (3 downto 0) := "0010";

    constant POSIT64LEN                         : integer := 64;
    constant POSIT32LEN                         : integer := 32;
    constant QUIRE64LEN                         : integer := 1024;
    constant QUIRE32LEN                         : integer := 512;

    constant OPTAG_LEN                          : integer := 4;
    constant OPTAG_UNKNOWN                      : std_logic_vector((OPTAG_LEN-1) downto 0) := (others => '0');
    constant OPCODE_LEN                         : integer := 3;
    constant OPCODE_UNKNOWN                     : std_logic_vector((OPCODE_LEN-1) downto 0) := "000";
    constant OPCODE_QCLR                        : std_logic_vector((OPCODE_LEN-1) downto 0) := "001";
    constant OPCODE_QMADD                       : std_logic_vector((OPCODE_LEN-1) downto 0) := "010";
    constant OPCODE_QROUND                      : std_logic_vector((OPCODE_LEN-1) downto 0) := "011";
    constant OPCODE_QNEG                        : std_logic_vector((OPCODE_LEN-1) downto 0) := "100";

    type type_quireOperations                   is (UNKNOWN, QMADD, QMSUB, QCLR, QNEG, QROUND);
    type type_quireOperationsList               is array (natural range <>) of type_quireOperations;
  -- ENTRY DATA CONFIG - END

end package config;


package body config is
end package body config;