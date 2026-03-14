library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display is
    generic (
        RED : unsigned(23 downto 0) := "000000011111110000000";
        YELLOW : unsigned(23 downto 0) := "111111111111110000000";
        BLUE : unsigned(23 downto 0) := "000000000000001111111"
    );
    
    port(
        clk : in std_logic;
        color : in std_logic_vector(1 downto 0);
        data : out std_logic;
        rdy : out std_logic
    );
end display;

architecture Driver of display is
    signal count: unsigned(5 downto 0);
    signal data_bit: std_logic;
    signal write_bit: std_logic;
    signal bit_count : unsigned(4 downto 0);
begin
    
shift_function : process(write_bit)

begin
    if falling_edge(write_bit) then
        if color = "00" then
            data_bit <= '0';
            bit_count <= bit_count + 1;
        elsif color = "01" then
            data_bit <= RED(bit_count);
            bit_count <= bit_count + 1;
        elsif color = "10" then
            data_bit <= YELLOW(bit_count);
            bit_count <= bit_count + 1;
        else
            data_bit <= BLUE(bit_count);
            bit_count <= bit_count + 1;
        end if;
        if bit_count = 24 then
            bit_count <= 0;
            rdy <= '1';
        end if;
    end if;
end process;

send_zero : process(clk, data_bit)
begin
    if rising_edge (clk) and not (data_bit) then
        if count = 0 then
            write_bit <= '1';
            data <= '1';
            count <= count + 1;
        elsif count = 20 then
            data <= '0';
            count <= count + 1;
        elsif count = 63 then
            count <= (others => '0');
            write_bit <= '0';
        else
            count <= count + 1;
        end if;
    end if;
end process;  

send_one : process(clk, data_bit)
begin
    if rising_edge (clk) and (data_bit) then
        if count = 0 then
            data <= '1';
            count <= count + 1;
        elsif count = 40 then
            data <= '0';
            count <= count + 1;
        elsif count = 63 then
            count <= (others => '0');
            count <= count + 1;
        else
            count <= count + 1;
        end if;
    end if;
end process; 
end Driver;