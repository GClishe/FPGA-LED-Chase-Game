library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- In order for a "Random" LED to be selected on each round, we use an LFSR that is seeded via
-- a counter that is always running in the background. When the user issues a start command, the
-- current value in that counter is sampled and used to seed an LFSR. 

-- The output of this module will be a random number from 0 to 15. The sampled counter value
-- is taken as an input to this module. 

entity PseudoRNG is 
port (
    i_clk : in std_logic;
    i_seed : in std_logic_vector(15 downto 0);      -- seeds a 16-bit LFSR, so seed is 16 bits wide
    o_random_num : out unsigned(3 downto 0)        -- 15 possible LEDs, so create a 4 bit number
);
end entity PseudoRNG;
architecture RTL of PseudoRNG is 

begin


end architecture RTL;