library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display is
    generic (
        RED : unsigned(23 downto 0) := "000000001111111100000000";
        YELLOW : unsigned(23 downto 0) := "111111111111111100000000";
        BLUE : unsigned(23 downto 0) := "000000000000000011111111"
    );
    
    port(
        clk : in std_logic;
        color : in std_logic_vector(1 downto 0);
        data : out std_logic;
        rdy : out std_logic
    );
end display;

architecture Driver of display is
    signal count: unsigned(5 downto 0) := (others => '0');
    signal bit_count : unsigned(4 downto 0) := (others => '0');
    signal data_reg : std_logic := '0';
    signal rdy_reg : std_logic := '0';
    
begin

data <= data_reg;
rdy <= rdy_reg;

process (clk)
    variable current_color : unsigned(23 downto 0);
begin
    if rising_edge(clk) then
        case color is
            when "01" => current_color := RED;
            when "10" => current_color := BLUE;
            when "11" => current_color := YELLOW;
            when others => current_color := (others => '0');
        end case;

        if to_integer(count) = 63 then
            if to_integer(bit_count) = 23 then
                rdy_reg <= '1';
                bit_count <= (others => '0');
            else
                bit_count <= bit_count + 1;
            end if;
                count <= (others => '0');
        elsif current_color(to_integer(bit_count)) = '0' then
            if count = 0 then
                data_reg <= '1';
                count <= count + 1;
            elsif count = 20 then
                data_reg <= '0';
                count <= count + 1;
            else
                count <= count + 1;
            end if;
        elsif current_color(to_integer(bit_count)) = '1' then
            if count = 0 then
                data_reg <= '1';
                count <= count + 1;
            elsif count = 40 then
                data_reg <= '0';
                count <= count + 1;
            else
                count <= count + 1;
            end if;
        end if;

    end if;
end process;
end Driver;