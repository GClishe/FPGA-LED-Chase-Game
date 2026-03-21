library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Game_Loop is 
port (
    i_clk : in std_logic;
    i_rst : in std_logic;
);
end entity Game_Loop;
architecture RTL of Game_Loop is
    type t_SM_Main is (START,           -- Start state. Wait for reset
                       TARGET_OFF,      -- Between-state. All LEDs off as target is selected
                       TARGET_ON,       -- Target LED turns on. Waits briefly before cycle
                       CYLCE,           -- Main gameplay state. LEDs cycle right-to-left, waiting for player input
                       INCR_SCORE,      -- Player hit btnC when cycle LED matches target LED. Score increments
                       LOSE,            -- Player missed the target LED. Failure. 
                       WIN              -- Player score reached win condition.
                       );

    signal r_LFSR_seed_ctr : unsigned(15 downto 0) := (others => '0');  -- counter used to seed the LFSR
begin

end architecture RTL;