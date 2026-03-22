library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Top is
    port(
        i_clk : in std_logic;
        i_btnC : in std_logic;
        i_btnT : in std_logic;
        o_led : out std_logic_vector(15 downto 0);
        o_seg : out std_logic_vector(6 downto 0)    -- 7 segments of the display 
    );
end entity Top;

architecture RTL of Top is
    signal w_display_val : std_logic_vector(3 downto 0);
begin

Game_Loop_Inst : entity work.Game_Loop
generic map (WIN_SCORE => 5)
port map(
    i_clk => i_clk,
    i_btnT => i_btnT,   -- debouncing occurs within Game_Loop. btnT is reset button, btnC is player input        
    i_btnC => i_btnC,     
    o_LED_arr => o_led,
    o_display_val => w_display_val
);
Binary_to_7Segment_inst : entity work.Binary_To_7Segment
port map(
    i_Clk => i_clk,
    i_Binary_Num => w_display_val,
    o_Segment_A => o_seg(0),
    o_Segment_B => o_seg(1),
    o_Segment_C => o_seg(2),
    o_Segment_D => o_seg(3),
    o_Segment_E => o_seg(4),
    o_Segment_F => o_seg(5),
    o_Segment_G => o_seg(6)
);

end architecture RTL;