library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Lab1_FPGA_RTL is
	 generic (
		  clk_f : integer := 100;
		  pwm_duty_cycle : integer := 50
	 );
	 
    port (
        -- Gloabals
        fpga_clk_50   : in  std_logic;

		  KEY0: in  std_logic;
		  KEY1: in  std_logic;
		  KEY2: in  std_logic;
		  KEY3: in  std_logic;
		  
		  SW: in  std_logic_vector(9 downto 0);

        -- I/Os
        fpga_led_pio  : out std_logic_vector(5 downto 0)
  );
end entity Lab1_FPGA_RTL;

architecture rtl of Lab1_FPGA_RTL is

-- signal
signal blink : std_logic := '0';
signal pwm : std_logic := '0';

signal pwm_on : std_logic := '0';

begin

  process(fpga_clk_50) 
      variable counter : integer range 0 to 25e6 := 0;
      begin
        if (rising_edge(fpga_clk_50)) then
                  if (counter < 1e5* to_integer(unsigned(SW))) then
                      counter := counter + 1;
                  else
                      blink <= not blink;
                      counter := 0;
                  end if;
        end if;
  end process;
  
  
  pwm_pro: process (fpga_clk_50)
		variable ligado  : integer range 0 to pwm_duty_cycle := 0;
		variable desligado : integer range 0 to clk_f - pwm_duty_cycle := 0;
		variable state : integer range 0 to 1 := 1;
		begin 
			if(rising_edge(fpga_clk_50)) then
				if (state = 1) then
					pwm_on <= '1';
					ligado := ligado + 1;
					if (ligado = pwm_duty_cycle) then
						ligado := 0;
						state := 0;
					end if;
				else
					pwm_on <= '0';
					desligado := desligado + 1;
					if (desligado = pwm_duty_cycle) then
						desligado := 0;
						state := 1;
					end if;
				end if;
			end if;
			
	end process;
  
  fpga_led_pio(0) <= not KEY0;
  fpga_led_pio(1) <= not KEY1;
  fpga_led_pio(2) <= not KEY2;
  fpga_led_pio(3) <= not KEY3;
  fpga_led_pio(4) <= pwm_on;
  fpga_led_pio(5) <= blink;

end rtl;