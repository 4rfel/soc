--
-- Rafael C.
-- ref:
--   - https://www.intel.com/content/www/us/en/programmable/quartushelp/13.0/mergedProjects/hdl/vhdl/vhdl_pro_state_machines.htm
--   - https://www.allaboutcircuits.com/technical-articles/implementing-a-finite-state-machine-in-vhdl/
--   - https://www.digikey.com/eewiki/pages/viewpage.action?pageId=4096117

library IEEE;
use IEEE.std_logic_1164.all;

entity Entrega_1 is
	generic (
		quant_steps : integer := 1000
	);

	port (
		-- Globals
		clk   : in  std_logic;

		-- controls
		en      : in std_logic;                     -- 1 on/ 0 of
		dir     : in std_logic;                     -- 1 clock wise
		vel     : in std_logic_vector(1 downto 0);  -- 00: low / 11: fast

		-- I/Os
		phases  : out std_logic_vector(3 downto 0)
	);
end entity Entrega_1;

architecture rtl of Entrega_1 is

	type state_type is (s0, s1, s2, s3);
	signal state  : state_type := s0;
	signal enable : std_logic  := '0';
	
	signal topCounter : integer range 0 to 50e6;

	begin

		state_changer: process(clk)
			variable current_quant_steps : integer range 0 to quant_steps := 0;
			variable has_finished_steps : integer  := 0;
			begin
				if (rising_edge(clk)) then
					if (en = '1' and has_finished_steps = 0) then
						if (dir = '1') then
							case state is
								when s0=>
									if (enable = '1') then
										state <= s1;
										current_quant_steps := current_quant_steps + 1;
									end if;
								when s1=>
									if (enable = '1') then
										state <= s2;
									end if;
								when s2=>
									if (enable = '1') then
										state <= s3;
									end if;
								when s3=>
									if (enable = '1') then
										state <= s0;
									end if;
								when others=>
									state <= s0;
							end case;
						else
							case state is
								when s0=>
									if (enable = '1') then
										state <= s3;
										current_quant_steps := current_quant_steps + 1;
									end if;
								when s1=>
									if (enable = '1') then
										state <= s0;
									end if;
								when s2=>
									if (enable = '1') then
										state <= s1;
									end if;
								when s3=>
									if (enable = '1') then
										state <= s2;
									end if;
								when others=>
									state <= s0;
							end case;
						end if;
					end if;
					if (current_quant_steps > quant_steps) then
						has_finished_steps := 1;
					end if;
				end if;
		end process;

			
			
		phase_activator: process (state)
			begin
				case state is
					when s0 =>
						phases <= "0001";
					when s1 =>
						phases <= "0010";
					when s2 =>
						phases <= "0100";
					when s3 =>
						phases <= "1000";
					when others =>
						phases <= "0000";
				end case;
		end process;


		topCounter <= 20e4 when vel = "00" else
					  30e4 when vel = "01" else
					  50e4 when vel = "10" else
					  70e4 when vel = "11" else
					  10e4;


		vel_counter: process( clk )
			variable counter : integer range 0 to 50e6 := 0;
			variable reducer : integer range 0 to 50e6 := 0;
			variable old_vel : std_logic_vector(1 downto 0) := "00";
			begin
				if (rising_edge(clk)) then
					if (counter < topCounter - reducer) then
						counter := counter + 1;
						enable  <= '0';
					else
						counter := 0;
						enable  <= '1';
					end if;
					if (old_vel /= vel) then
						old_vel := vel;
						reducer := 0;
					end if;
					if (reducer < topCounter / 2 ) then
						reducer := reducer + 1000;
					end if;
				end if;
		end process;

end rtl;