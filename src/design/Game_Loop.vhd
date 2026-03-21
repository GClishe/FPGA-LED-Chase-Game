library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Game_Loop is 
port (
    i_clk : in std_logic;
    i_btnT : in std_logic;                                          -- reset button
    i_btnC : in std_logic;                                          -- Main player input. Also transitions from START
    o_target_LED: out unsigned(3 downto 0);                         -- idx of the target LED.
    o_LED_arr: out std_logic_vector(15 downto 0)                    -- array representing each LED. All 1's indicate corresponding LED should be on. 
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
    signal r_game_ctr : unsigned(25 downto 0) := (others => '0')        -- 26-bit counter that takes ~0.7s to wrap. This will be used to flash LEDs in start state and also to temporally separate certain state transitions
    signal r_LFSR_out : unsigned(15 downto 0) := (others => '0');       -- intermediate register for taking LFSR output. 
    signal r_seed_dv : std_logic;                                       -- datavalid signal indicating LFSR seed should be loaded
    signal r_curr_state : t_SM_Main := START;
    signal r_target_LED_idx: unsigned(3 downto 0) := "0000";            -- index (0 thru 15 of target LED )
    signal r_LED_arr : std_logic_vector(15 downto 0) := (others => 0);  -- mask representing LEDs that should be on (1) or off (0)
    signal r_cycle_vector : std_logic_vector(15 downto 0) := (others => 0);    -- similar to above, but this vector is specifically for the cycle LEDs NOT the target LED. This allows us to easily left shift the cycle vector without affecting target LED
    signal w_player_input : std_logic_vector := '0';                           -- debounced btnC
begin
    
debounce_btnT : entity work.Debounce
generic map (COUNTER_SIZE = 21)
port map(
    i_clk => i_clk, 
    i_bouncy => i_btnT,     -- debounced btnT acts as reset
    o_debounced => rst
);

debounce_btnC : entity work.Debounce
generic map (COUNTER_SIZE = 21)
port map(
    i_clk => i_clk, 
    i_bouncy => i_btnC,     -- debounced btnT acts as reset
    o_debounced => w_player_input;
);

LFSR : entity work.LFSR_16b
port map(
    i_clk => i_clk,
    i_rst => rst,
    i_seed_dv => r_seed_dv,
    i_seed_val => r_LFSR_seed_ctr,  
    o_LFSR_val => r_LFSR_out
);


process (i_clk) begin
    if rising_edge(i_clk) begin
        if rst begin  -- synchronous reset
            r_curr_state <= START;
            r_game_ctr <= (others => '0');
            o_LED_arr <= (others => '0'); -- all LEDs off upon reset
            r_cycle_vectr <= (others => 0); 

        else
            
        -- state machine logic
            case r_curr_state is
                when START => 
                    r_game_ctr <= r_game_ctr + 1;
                    if r_game_ctr = 0 then
                        r_LED_arr <= not r_LED_arr;         -- in START state, flip all LEDs. Want LEDs to cycle on and off every ~0.7s
                    end if;
                    if i_btnC = '1' then
                        r_LED_arr <= (others => '0');
                        r_game_ctr <= to_unsigned(1,26);    -- when we transition into TARGET_OFF, we remain there for however long it takes for r_game_ctr to wrap. So we reset the counter (to 1) right here
                        r_seed_dv = '1';                    -- we seed the LFSR with whatever is currenctly in the LFSR_seed_ctr. When we transition to TARGET_OFF, we'll turn off the seed dv (to keep from continusously re-seeding)
                        r_curr_state <= TARGET_OFF;
                    else
                        r_curr_state <= START;
                    end if;
                when TARGET_OFF =>
                    -- in this state, we want to compute the target LED for the next round
                    r_LED_arr <= (others => '0');   -- make sure all LEDs are off
                    r_seed_dv <= '0';               -- turn off the seeding. LFSR will continue for many cycles until r_target_LED_idx is determined
                    r_game_ctr <= r_game_ctr + 1;
                    if r_game_ctr = 0 then
                        -- Here, we want to select the target LED
                        -- The 4 LSBs in the LFSR are highly correlated, so to improve RNG behavior I 
                        -- xor them with non-adjacent bits that I chose more or less arbitrarily. Then 
                        -- concatenate them to build 4-bit LED index.
                        r_target_LED_idx <= (
                            r_LFSR_out(0) xor r_LFSR_out(5) &
                            r_LFSR_out(1) xor r_LFSR_out(9) &
                            r_LFSR_out(2) xor r_LFSR_out(13) &
                            r_LFSR_out(3) xor r_LFSR_out(7) 
                        );

                        r_curr_state <= TARGET_ON;                    
                    end if;
                when TARGET_ON =>
                    -- in this state, target LED should light, then we wait for game_ctr to wrap before cycling begins
                    if (r_target_LED_idx = 0) thenS
                        r_LED_arr(1) = '1'          -- we dont want LED 0 to be the target LED ever. 
                    else 
                        r_LED_arr(r_target_LED_idx) = '1';     
                    end if;

                    r_game_ctr <= r_game_ctr + 1;
                    if r_game_ctr = 0 then
                        r_curr_state <= CYCLE; 
                        r_LED_arr = std_logic_vector(to_unsigned(1,16)); -- turning the counter array to 000...001 to light up first LED when we enter CYCLE                   
                    end if;

                when CYCLE =>
                    -- In this state, the LEDs will continuously cycle right to left, waiting for player input. 
                    if r_game_ctr = to_unsigned(30000000, r_game_ctr'length) then   -- on a 100MHz clock, it takes 300ms to count up to this value
                        r_cycle_vector <= r_cycle_vector(14 downto 0) & r_cycle_vector(15); -- this gives a left shift with wraparound behavior
                    end if;

                    if w_player_input = '1' then
                        if r_LED_arr = r_cycle_vector then
                            -- in this scenario, player input was high when the r_LED_arr (which depends on target input) equals the cycle vector. This means the player pressed the button at the right time
                            r_curr_state <= INCR_SCORE;
                        else
                            r_curr_state <= LOSE;

                        end if;
                    end if;
                    r_game_ctr <= r_game_ctr + 1;

                when INCR_SCORE =>
                    -- in this state, we want to increment the player score and either transition to WIN or TARGET_OFF for loading next round. 
                    -- TODO ensure that r_game_ctr resets (to 1) before we move to TARGET_OFF.
                when LOSE =>
                when WIN =>
            end case;
        end if;
        r_LFSR_seed_ctr <= r_LFSR_seed_ctr + 1; 
    end if;
end process


o_target_LED <= r_target_LED_idx;
o_LED_arr <= r_LED_arr or r_cycle_arr;   -- r_led_arr will have target LED illuminated, but we do bitwise OR with the cycle arr so that 

end architecture RTL;