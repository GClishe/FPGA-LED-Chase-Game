library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This is a 16-bit LFSR. Upon reset, it enters state of all zeros, so remains idle at 0 until seed is 
-- supplied. If 0 is supplied as a seed, it is replaced with 1. 

entity LFSR_16b is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_seed_dv : in std_logic;                -- indicates seed is valid
        i_seed_val : in unsigned(15 downto 0);   -- seed value
        o_LFSR_val : out unsigned(15 downto 0)   -- result value
    );
end entity LFSR_16b;
architecture RTL of LFSR_16b is
    signal r_LFSR : std_logic_vector(15 downto 0) := (others => '0');   -- note that the LFSR will contain all 0s until it is seeded with a nonzero value
    signal w_XOR : std_logic;  -- wire that carries r_LFSR(15) xor r_LFSR(13) xor r_LFSR(12) xor r_LFSR(10)
begin

    process (i_clk) begin
        if rising_edge(i_clk) then
            if (i_rst = '1') then
                r_LFSR <= (others => '0');  -- will result in LFSR sitting idle until seed is given
            elsif i_seed_dv = '1' then
                if i_seed_val = 0 then
                    r_LFSR <= std_logic_vector(to_unsigned(1,16));    -- if seed is given as 0, replace with 1 to avoid locking up
                else
                    r_LFSR <= std_logic_vector(i_seed_val); -- seeding the LFSR
                end if;
            else
                r_LFSR <= r_LFSR(14 downto 0) & w_XOR;
            end if; 
        end if;
    end process;

    o_LFSR_val <= unsigned(r_LFSR);
    w_XOR <= r_LFSR(15) xor r_LFSR(13) xor r_LFSR(12) xor r_LFSR(10);

end architecture RTL;