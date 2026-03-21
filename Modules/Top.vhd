library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Top is
    port(
        i_clk : in std_logic;
        i_btnC : in std_logic;
        i_btnT : in std_logic;
        o_led : out std_logic_vector(15 downto 0)
    );
end entity Top;

architecture RTL of Top is
    signal w_debounced_btnT : std_logic;
begin

    BtnT_Debounce_Inst : entity work.Debounce
        generic map(
            COUNTER_SIZE => 21
        );
        port map(
            i_clk => i_clk;
            i_bouncy => i_btnT;
            o_debounced => w_debounced_btnT
        );
    
    o_LED(0) <= w_debounced_btnT;

end architecture RTL;