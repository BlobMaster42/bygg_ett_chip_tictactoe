library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_tic_tac_toe_linkobing is
    port(
        clk     : in std_logic;
        rstn    : in std_logic;
        swap    : in std_logic;
        sel     : in std_logic;
        data    : out std_logic
    );
end tt_um_tic_tac_toe_linkobing;

architecture Behavioral of tt_um_tic_tac_toe_linkobing is

    -- Signals connecting tictactoe and display
    --signal choose_position : unsigned(3 downto 0);
    --signal player          : unsigned(0 downto 0);
    --signal board           : unsigned(17 downto 0);
    signal color_send      : unsigned(1 downto 0);
    signal ready_bit       : std_logic;

begin

    -- Instantiate TicTacToe module
    game_inst : entity work.tictactoe
        port map (
            clk => clk,
            rstn => rstn,
            swap => swap,
            sel => sel,
            ready_bit => ready_bit,  -- driven by display
            --choose_position => choose_position,
            --player => player,
            --board => board,
            color_send => color_send
        );

    -- Instantiate Display module
    display_inst : entity work.display
        port map (
            clk => clk,
            color => std_logic_vector(color_send),  -- convert unsigned(1 downto 0) to std_logic_vector
            data => data,
            rdy => ready_bit   -- connect display ready signal back to TicTacToe
        );
    

end Behavioral;