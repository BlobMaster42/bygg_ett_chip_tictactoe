library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity tictactoe is 
    port(
        clk     : in std_logic;
        rstn    : in std_logic;
        swap    : in std_logic;
        sel     : in std_logic;
        ready_bit:in std_logic;
        --choose_position: out unsigned(3 downto 0);  -- a 3x3 board as a value for id 
        --player  : out unsigned(0 downto 0);                            -- blue is 1, red is 0
        --board   : out unsigned(17 downto 0);         -- a sort of 3x3 board but there is 2 bits per "pixel" 
        color_send : out unsigned(1 downto 0)
    );

end tictactoe;


architecture Behavioral of tictactoe is 
    signal i_choose_position    : unsigned(3 downto 0) := (others => '0');
    signal i_board              : unsigned(17 downto 0) := (others => '0');
    signal i_player             : unsigned(0 downto 0) := (others => '0');
    signal cntr                 : unsigned(3 downto 0) := (others => '0');
begin 
    select_space : process (clk,rstn)
        variable pos : integer;
    begin 
        if rising_edge(clk) then

            if rstn = '1' then 
                i_choose_position <= (others => '0');
                i_player <= "0";
                i_board <= (others => '0');
            end if;

            if swap = '1' then 
                if i_choose_position < 9 then
                    i_choose_position <= i_choose_position + 1;
                else 
                    i_choose_position <= "0000";
                end if;
            end if;

            if sel = '1' then 
                pos := to_integer(i_choose_position(2 downto 0) & '0' + i_player);
                i_board(pos) <= '1';
                --i_board <= (board_mask or resize(shift_left(1,i_choose_position(2 downto 0) & '0' + i_player),17)) or i_board; -- takes pos from selection and adapts for board and color
                i_player <= not i_player;
            else -- send 10 for select yellow
                pos := to_integer(i_choose_position(2 downto 0) & '0');
                i_board(pos+1 downto pos) <= "11";
                --i_board <= (board_mask or resize(shift_left(1,i_choose_position(2 downto 0) & '0'),17)) or i_board;
            end if;

        end if;

    end process;

    send_color : process (ready_bit)
    begin 
        if rising_edge(clk) then
            if rstn = '1' then
                color_send <= "00";
                cntr <= 0;
            elsif ready_bit = '1' then
                if cntr < 18 then
                    color_send <= i_board(cntr+1 downto cntr);
                    cntr <= cntr + 2;
                else
                    color_send <= "00";
                    cntr <= 0;
                end if;
            end if;
        end if;
    end process;




--choose_position <= i_choose_position;
--board <= i_board;
--player <= i_player;

end Behavioral;







