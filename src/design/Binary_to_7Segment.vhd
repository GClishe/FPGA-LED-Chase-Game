-- All credit for this module given to Russel Merrick. The code for this module was found in his
-- "Getting Started with FPGAs". I momentarily thought of writing my own 7-seg display module, but
-- I felt that there was not much utility in doing so when I very recently read this book and recalled
-- this module.

-- This module converts a 4-bit binary number to an 7-bit code, where each bit represents the state
-- of a segment on a 7-seg display. The 4-bit binary number represents the decimal number (0 thru 9) that 
-- is meant to be displayed. 

library ieee;
use ieee.std_logic_1164.all;

entity Binary_To_7Segment is
port (
    i_Clk : in std_logic;
    i_Binary_Num : in std_logic_vector(3 downto 0); 
    o_Segment_A : out std_logic;
    o_Segment_B : out std_logic;
    o_Segment_C : out std_logic;
    o_Segment_D : out std_logic;
    o_Segment_E : out std_logic;
    o_Segment_F : out std_logic;
    o_Segment_G : out std_logic
);
end entity Binary_To_7Segment;

architecture RTL of Binary_To_7Segment is
    signal r_Hex_Encoding : std_logic_vector(6 downto 0);
begin
    process (i_Clk) is 
    begin 
        if rising_edge(i_Clk) then 
            case i_Binary_Num is 
                when "0000" =>
                    r_Hex_Encoding <= "1111110"; -- 0x7E
                when "0001" =>
                    r_Hex_Encoding <= "0110000"; -- 0x30
                when "0010" =>
                    r_Hex_Encoding <= "1101101"; -- 0x6D
                when "0011" =>
                    r_Hex_Encoding <= "1111001"; -- 0x79
                when "0100" =>
                    r_Hex_Encoding <= "0110011"; -- 0x33
                when "0101" =>
                    r_Hex_Encoding <= "1011011"; -- 0x5B
                when "0110" =>
                    r_Hex_Encoding <= "1011111"; -- 0x5F
                when "0111" =>
                    r_Hex_Encoding <= "1110000"; -- 0x70
                when "1000" =>
                    r_Hex_Encoding <= "1111111"; -- 0x7F
                when "1001" =>
                    r_Hex_Encoding <= "1111011"; -- 0x7B
                when "1010" =>
                    r_Hex_Encoding <= "1110111"; -- 0x77
                when "1011" =>
                    r_Hex_Encoding <= "0011111"; -- 0x1F
                when "1100" =>
                    r_Hex_Encoding <= "1001110"; -- 0x4E
                when "1101" =>
                    r_Hex_Encoding <= "0111101"; -- 0x3D
                when "1110" =>
                    r_Hex_Encoding <= "1001111"; -- 0x4F
                when "1111" =>
                    r_Hex_Encoding <= "1000111"; -- 0x47
                when others =>
                    r_Hex_Encoding <= "0000000"; -- 0x00
            end case;
        end if; 
    end process;

    o_Segment_A <= not r_Hex_Encoding(6);
    o_Segment_B <= not r_Hex_Encoding(5);
    o_Segment_C <= not r_Hex_Encoding(4);
    o_Segment_D <= not r_Hex_Encoding(3);
    o_Segment_E <= not r_Hex_Encoding(2);
    o_Segment_F <= not r_Hex_Encoding(1);
    o_Segment_G <= not r_Hex_Encoding(0);

end RTL;