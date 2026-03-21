library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Game_Loop is 
port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    o_LED_sel: out unsigned(3 downto 0) := (others => '0');         -- LED selector. Asynchronously tied to 4 LSBs of r_LFSR_out
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
    signal r_LFSR_out : unsigned(15 downto 0) := (others => '0');       -- intermediate register for taking LFSR output. 
    signal r_seed_dv : std_logic;                                       -- datavalid signal indicating LFSR seed should be loaded
begin

LFSR : entity work.LFSR_16b
  port map(
  	i_clk => i_clk,
    i_rst => i_rst,
    i_seed_dv => r_seed_dv,
    i_seed_val => r_LFSR_seed_ctr,  
    o_LFSR_val => r_LFSR_out
  );

process (i_clk) begin









    
end process

-- The 4 LSBs in the LFSR are highly correlated, so to improve RNG behavior I 
-- xor them with non-adjacent bits that I chose more or less arbitrarily. Then 
-- concatenate them to build 4-bit LED select.
o_LED_sel <= (
    r_LFSR_out(0) xor r_LFSR_out(5) &
    r_LFSR_out(1) xor r_LFSR_out(9) &
    r_LFSR_out(2) xor r_LFSR_out(13) &
    r_LFSR_out(3) xor r_LFSR_out(7) 
);

end architecture RTL;