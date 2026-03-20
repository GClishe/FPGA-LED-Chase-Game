library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Debounce will use a slow clock, generated via a counter or an LFSR, then it will sample the input
-- on this slow clock. If the input is high (while the last state was low), then it will output high
-- for a number of cycles. 

entity Debounce is 
generic (
    COUNTER_SIZE : integer := 21    -- number of bits in counter. a button press locks out further inputs. a 21 bit counter takes  rouughly 20ms to wrap.
); 
port(
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_bouncy : in std_logic;
    o_debounced : out std_logic
);

end entity Debounce;
architecture RTL of Debounce is
    signal r_counter : unsigned(COUNTER_SIZE-1 downto 0) := (others => '0');    -- others => '0' assigns '0' to every bit in the vector. 
    signal r_out_signal : std_logic := '0';
    signal r_recent_input_pressed: std_logic := '0';
begin

process (i_clk) begin

    o_debounced <= r_out_signal;

    if rising_edge(i_clk) then
        if i_rst = '1' then
                r_counter <= (others => '0');
                r_out_signal <= '0';
                r_recent_input_pressed <= '0';

        elsif r_recent_input_pressed = '0' then
            -- currently waiting for a new press
            if i_bouncy = '1' then
                    r_recent_input_pressed <= '1';
                    r_out_signal <= '1';
                    r_counter <= (others => '0');   -- reset the counter on button press; output will be de-asserted when counter is full, so resetting counter now ensures consistent period of time where out is high
                end if;

        else
            r_counter <= r_counter + 1;
            if r_counter = (r_counter'range => '1') then    -- checking if counter is full of 1s. Will wrap this cycle.               
                r_out_signal <= '0';
                r_recent_input_pressed <= '0';
            end if;
        end if;
    end if;
end process;

end architecture RTL;