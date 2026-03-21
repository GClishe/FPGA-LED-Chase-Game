library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity LFSR_16b_tb is
end entity LFSR_16b_tb;

architecture test of LFSR_16b_tb is
	signal r_clk, r_rst, r_seed_dv : std_logic := '0';
	signal r_seed_val, r_LFSR_val : unsigned(15 downto 0) := (others => '0');
begin
  r_clk <= not r_clk after 5 ns;		-- 10ns period -> 100MHz
  
  DUT : entity work.LFSR_16b
  port map(
  	i_clk => r_clk,
    i_rst => r_rst,
    i_seed_dv => r_seed_dv,
    i_seed_val => r_seed_val,
    o_LFSR_val => r_LFSR_val
  );
  
  process is 
  begin
    --resetting 
    r_rst <= '1';
    wait for 20 ns;
    r_rst <= '0';

    wait until rising_edge(r_clk);
    assert r_LFSR_val = 0
        report "LFSR not zero after reset"
        severity error;

	-- seeding
    r_seed_dv  <= '1';
    r_seed_val <= to_unsigned(42,16);
    wait until rising_edge(r_clk);
    r_seed_dv  <= '0';
    r_seed_val <= (others => '0');

    wait for 1 ns;
    assert r_LFSR_val = to_unsigned(42,16)
        report "Seed load failed"
        severity error;

	-- checking next state
    wait until rising_edge(r_clk);
    wait for 1 ns;
    assert r_LFSR_val = to_unsigned(84,16)		-- after 42, the LFSR should output 84
        report "First LFSR advance incorrect"
        severity error;

    wait for 100 ns;
    finish;
  end process;
  
  
end architecture test;