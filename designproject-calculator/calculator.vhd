library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity calculator is
	port (
		clock_50mhz :in std_logic;
		is_keypad_pressed : in std_logic_vector(16 downto 1);
		sevensegment_selection : out std_logic_vector(5 downto 0);
		sevensegment_databus : out std_logic_vector(7 downto 0)
	);
end calculator;

architecture behavior of calculator is
	type state is (
		INITIAL,
		OPERAND_1DIGIT_ENTERED,
		OPERAND_2DIGITS_ENTERED,
		OPERAND_3DIGITS_ENTERED,
		OPERAND_4DIGITS_ENTERED,
		OPERAND_5DIGITS_ENTERED,
		OPERAND_6DIGITS_ENTERED,
		OPERATOR_ENTERED,
		RESULT,
		ERROR
	);

	signal status : state := INITIAL;
	signal program_counter : std_logic_vector(31 downto 0) := X"00000000";
	signal clock : std_logic;
	signal keypad_toggle : std_logic := '0';

	signal is_keypad_multiple_input : std_logic := '0';
	signal isnot_keypad_pressed : std_logic_vector(16 downto 1) := X"0000";
	signal keypad_status_primary : std_logic_vector(16 downto 1) := X"0000";
	signal keypad_status_secondary : std_logic_vector(16 downto 1) := X"0000";

	signal memorized_value : integer := 0;
	signal operation_status : integer := 0;
	signal display_status : integer := 0;
	signal operation_result : integer := 0;
	signal digit5_segmentcode : integer range 0 to 20 := 20;
	signal digit4_segmentcode : integer range 0 to 20 := 20;
	signal digit3_segmentcode : integer range 0 to 20 := 20;
	signal digit2_segmentcode : integer range 0 to 20 := 20;
	signal digit1_segmentcode : integer range 0 to 20 := 20;
	signal digit0_segmentcode : integer range 0 to 20 := 0;

	signal entered_operator : integer range 0 to 4 := 4;
	signal entering_operator : integer range 0 to 4 := 4;

	signal sevensegment_clock : std_logic;
	signal sevensegment_counter : integer range 5 downto 0;
	signal digit5_segment : std_logic_vector(6 downto 0) := "0000000";
	signal digit4_segment : std_logic_vector(6 downto 0) := "0000000";
	signal digit3_segment : std_logic_vector(6 downto 0) := "0000000";
	signal digit2_segment : std_logic_vector(6 downto 0) := "0000000";
	signal digit1_segment : std_logic_vector(6 downto 0) := "0000000";
	signal digit0_segment : std_logic_vector(6 downto 0) := "0000000";
	
	begin
		isnot_keypad_pressed <= not is_keypad_pressed;
        
        -- Clocking process
		process (clock_50mhz) begin
			if rising_edge(clock_50mhz) then
				program_counter <= program_counter + 1;
			end if;
		end process;
		
		clock <= program_counter(20);
		sevensegment_clock <= program_counter(16);
        
        -- Keypad input process
		process (
			clock,
			isnot_keypad_pressed,
			keypad_status_primary,
			keypad_status_secondary,
			keypad_toggle
		) begin
			if rising_edge(clock) then
				keypad_status_secondary <= keypad_status_primary;
				keypad_status_primary <= isnot_keypad_pressed;
			
				if (keypad_status_secondary = X"0000" and keypad_status_primary /= keypad_status_secondary) then
					keypad_toggle <= '1';
				elsif (operation_status = 1) then
					case entered_operator is
						when 0 => operation_result <= operation_result + memorized_value;
						when 1 => operation_result <= operation_result - memorized_value;
						when 2 => operation_result <= operation_result * memorized_value;
						when 3 =>
							if (memorized_value /= 0) then
								operation_result <= operation_result / memorized_value;
							else -- If dividing by 0
								operation_result <= 2147483647;
							end if;
						when others => operation_result <= memorized_value;
					end case;

					if (entering_operator = 4) then
						operation_status <= 2;
					else
						operation_status <= 0;
						memorized_value <= 0;
						display_status <= 1;
					end if;
				elsif (operation_status = 2) then
					operation_result <= operation_result;
					operation_status <= 0;
					memorized_value <= 0;
					display_status <= 1;

				elsif (display_status = 1) then
					display_status <= 0;
					
					if (operation_result > -10 and operation_result < 0) then
						operation_result <= abs operation_result;
						digit5_segmentcode <= 20;
						digit4_segmentcode <= 20;
						digit3_segmentcode <= 20;
						digit2_segmentcode <= 20;
						digit1_segmentcode <= 18;
						digit0_segmentcode <= 10 - operation_result mod 10;
					elsif (operation_result > -100 and operation_result <= -10) then
						operation_result <= abs operation_result;
						digit5_segmentcode <= 20;
						digit4_segmentcode <= 20;
						digit3_segmentcode <= 20;
						digit2_segmentcode <= 18;
						digit1_segmentcode <= 10 - operation_result mod 100 / 10;
						digit0_segmentcode <= 10 - operation_result mod 10;
					elsif (operation_result > -1000 and operation_result <= -100) then
						operation_result <= abs operation_result;
						digit5_segmentcode <= 20;
						digit4_segmentcode <= 20;
						digit3_segmentcode <= 18;
						digit2_segmentcode <= 10 - operation_result mod 1000 / 100;
						digit1_segmentcode <= 10 - operation_result mod 100 / 10;
						digit0_segmentcode <= 10 - operation_result mod 10;
					elsif (operation_result > -10000 and operation_result <= -1000) then
						operation_result <= abs operation_result;
						digit5_segmentcode <= 20;
						digit4_segmentcode <= 18;
						digit3_segmentcode <= 10 - operation_result mod 10000 / 1000;
						digit2_segmentcode <= 10 - operation_result mod 1000 / 100;
						digit1_segmentcode <= 10 - operation_result mod 100 / 10;
						digit0_segmentcode <= 10 - operation_result mod 10;
					elsif (operation_result > -100000 and operation_result <= -10000) then
						operation_result <= abs operation_result;
						digit5_segmentcode <= 18;
						digit4_segmentcode <= 10 - operation_result mod 100000 / 10000;
						digit3_segmentcode <= 10 - operation_result mod 10000 / 1000;
						digit2_segmentcode <= 10 - operation_result mod 1000 / 100;
						digit1_segmentcode <= 10 - operation_result mod 100 / 10;
						digit0_segmentcode <= 10 - operation_result mod 10;
					elsif (operation_result >= 0 and operation_result < 10) then
						digit5_segmentcode <= 20;
						digit4_segmentcode <= 20;
						digit3_segmentcode <= 20;
						digit2_segmentcode <= 20;
						digit1_segmentcode <= 20;
						digit0_segmentcode <= operation_result;
					elsif (operation_result >= 10 and operation_result < 100) then
						digit5_segmentcode <= 20;
						digit4_segmentcode <= 20;
						digit3_segmentcode <= 20;
						digit2_segmentcode <= 20;
						digit1_segmentcode <= operation_result / 10;
						digit0_segmentcode <= operation_result mod 10;
					elsif (operation_result >= 100 and operation_result < 1000) then
						digit5_segmentcode <= 20;
						digit4_segmentcode <= 20;
						digit3_segmentcode <= 20;
						digit2_segmentcode <= operation_result / 100;
						digit1_segmentcode <= operation_result mod 100 / 10;
						digit0_segmentcode <= operation_result mod 10;	
					elsif (operation_result >= 1000 and operation_result < 10000) then
						digit5_segmentcode <= 20;
						digit4_segmentcode <= 20;
						digit3_segmentcode <= operation_result / 1000;
						digit2_segmentcode <= operation_result mod 1000 / 100;
						digit1_segmentcode <= operation_result mod 100 / 10;
						digit0_segmentcode <= operation_result mod 10;
					elsif (operation_result >= 10000 and operation_result < 100000) then
						digit5_segmentcode <= 20;
						digit4_segmentcode <= operation_result / 10000;
						digit3_segmentcode <= operation_result mod 10000 / 1000;
						digit2_segmentcode <= operation_result mod 1000 / 100;
						digit1_segmentcode <= operation_result mod 100 / 10;
						digit0_segmentcode <= operation_result mod 10;
					elsif (operation_result >= 100000 and operation_result < 1000000) then
						digit5_segmentcode <= operation_result / 100000;
						digit4_segmentcode <= operation_result mod 100000 / 10000;
						digit3_segmentcode <= operation_result mod 10000 / 1000;
						digit2_segmentcode <= operation_result mod 1000 / 100;
						digit1_segmentcode <= operation_result mod 100 / 10;
						digit0_segmentcode <= operation_result mod 10;
					else
						digit5_segmentcode <= 20;
						digit4_segmentcode <= 16;
						digit3_segmentcode <= 17;
						digit2_segmentcode <= 17;
						digit1_segmentcode <= 0;
						digit0_segmentcode <= 17;
					end if;
				end if;
			if (keypad_toggle = '1' and keypad_status_primary = keypad_status_secondary) then
                keypad_toggle <= '0';
                
                -- [7][8][9][/]
                -- [4][5][6][*]
                -- [1][2][3][-]
                -- [0][C][=][+]
                case keypad_status_primary is
                    -- Pressed button [7]
					when X"0001" => 
						if (status = INITIAL or status = ERROR) then
							status <= OPERAND_1DIGIT_ENTERED;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 7;
							memorized_value <= 7;
						elsif (status = OPERAND_1DIGIT_ENTERED) then
							status <= OPERAND_2DIGITS_ENTERED;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 7;
							memorized_value <= digit0_segmentcode * 10 + 7;
						elsif (status = OPERAND_2DIGITS_ENTERED) then
							status <= OPERAND_3DIGITS_ENTERED;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 7;
							memorized_value <= digit1_segmentcode * 100 + digit0_segmentcode * 10 + 7;
						elsif (status = OPERAND_3DIGITS_ENTERED) then
							status <= OPERAND_4DIGITS_ENTERED;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 7;
							memorized_value <= digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 7;
						elsif (status = OPERAND_4DIGITS_ENTERED) then
							status <= OPERAND_5DIGITS_ENTERED;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 7;
							memorized_value <= digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 7;
						elsif (status = OPERAND_5DIGITS_ENTERED) then
							status <= OPERAND_6DIGITS_ENTERED;
							digit5_segmentcode <= digit4_segmentcode;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 7;
							memorized_value <= digit4_segmentcode * 100000
								+ digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 7;
						elsif (status = OPERAND_6DIGITS_ENTERED) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else null;
                        end if;
                    -- Pressed button [8]
					when X"0002" => 
						if (status = INITIAL or status = ERROR) then
							status <= OPERAND_1DIGIT_ENTERED;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 8;
							memorized_value <= 8;
						elsif (status = OPERAND_1DIGIT_ENTERED) then
							status <= OPERAND_2DIGITS_ENTERED;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 8;
							memorized_value <= digit0_segmentcode * 10 + 8;
						elsif (status = OPERAND_2DIGITS_ENTERED) then
							status <= OPERAND_3DIGITS_ENTERED;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 8;
							memorized_value <= digit1_segmentcode * 100 + digit0_segmentcode * 10 + 8;
						elsif (status = OPERAND_3DIGITS_ENTERED) then
							status <= OPERAND_4DIGITS_ENTERED;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 8;
							memorized_value <= digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 8;
						elsif (status = OPERAND_4DIGITS_ENTERED) then
							status <= OPERAND_5DIGITS_ENTERED;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 8;
							memorized_value <= digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 8;
						elsif (status = OPERAND_5DIGITS_ENTERED) then
							status <= OPERAND_6DIGITS_ENTERED;
							digit5_segmentcode <= digit4_segmentcode;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 8;
							memorized_value <= digit4_segmentcode * 100000
								+ digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 8;
						elsif (status = OPERAND_6DIGITS_ENTERED) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else null;
                        end if;
                    -- Pressed button [9]
					when X"0004" => 
						if (status = INITIAL or status = ERROR) then
							status <= OPERAND_1DIGIT_ENTERED;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 9;
							memorized_value <= 9;
						elsif (status = OPERAND_1DIGIT_ENTERED) then
							status <= OPERAND_2DIGITS_ENTERED;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 9;
							memorized_value <= digit0_segmentcode * 10 + 9;
						elsif (status = OPERAND_2DIGITS_ENTERED) then
							status <= OPERAND_3DIGITS_ENTERED;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 9;
							memorized_value <= digit1_segmentcode * 100 + digit0_segmentcode * 10 + 9;
						elsif (status = OPERAND_3DIGITS_ENTERED) then
							status <= OPERAND_4DIGITS_ENTERED;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 9;
							memorized_value <= digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 9;
						elsif (status = OPERAND_4DIGITS_ENTERED) then
							status <= OPERAND_5DIGITS_ENTERED;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 9;
							memorized_value <= digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 9;
						elsif (status = OPERAND_5DIGITS_ENTERED) then
							status <= OPERAND_6DIGITS_ENTERED;
							digit5_segmentcode <= digit4_segmentcode;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 9;
							memorized_value <= digit4_segmentcode * 100000
								+ digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 9;
						elsif (status = OPERAND_6DIGITS_ENTERED) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else null;
                        end if;
                    -- Pressed button [/]
					when X"0008" => 
						if (status = INITIAL) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else 
							status <= INITIAL;
							operation_status <= 1;
							entered_operator <= entering_operator;
							entering_operator <= 3;
                        end if;
                    -- Pressed button [4]
					when X"0010" => 
						if (status = INITIAL or status = ERROR) then
							status <= OPERAND_1DIGIT_ENTERED;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 4;
							memorized_value <= 4;
						elsif (status = OPERAND_1DIGIT_ENTERED) then
							status <= OPERAND_2DIGITS_ENTERED;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 4;
							memorized_value <= digit0_segmentcode * 10 + 4;
						elsif (status = OPERAND_2DIGITS_ENTERED) then
							status <= OPERAND_3DIGITS_ENTERED;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 4;
							memorized_value <= digit1_segmentcode * 100 + digit0_segmentcode * 10 + 4;
						elsif (status = OPERAND_3DIGITS_ENTERED) then
							status <= OPERAND_4DIGITS_ENTERED;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 4;
							memorized_value <= digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 4;
						elsif (status = OPERAND_4DIGITS_ENTERED) then
							status <= OPERAND_5DIGITS_ENTERED;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 4;
							memorized_value <= digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 4;
						elsif (status = OPERAND_5DIGITS_ENTERED) then
							status <= OPERAND_6DIGITS_ENTERED;
							digit5_segmentcode <= digit4_segmentcode;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 4;
							memorized_value <= digit4_segmentcode * 100000
								+ digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 4;
						elsif (status = OPERAND_6DIGITS_ENTERED) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else null;
                        end if;
                    -- Pressed button [5]
					when X"0020" => 
						if (status = INITIAL or status = ERROR) then
							status <= OPERAND_1DIGIT_ENTERED;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 5;
							memorized_value <= 5;
						elsif (status = OPERAND_1DIGIT_ENTERED) then
							status <= OPERAND_2DIGITS_ENTERED;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 5;
							memorized_value <= digit0_segmentcode * 10 + 5;
						elsif (status = OPERAND_2DIGITS_ENTERED) then
							status <= OPERAND_3DIGITS_ENTERED;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 5;
							memorized_value <= digit1_segmentcode * 100 + digit0_segmentcode * 10 + 5;
						elsif (status = OPERAND_3DIGITS_ENTERED) then
							status <= OPERAND_4DIGITS_ENTERED;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 5;
							memorized_value <= digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 5;
						elsif (status = OPERAND_4DIGITS_ENTERED) then
							status <= OPERAND_5DIGITS_ENTERED;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 5;
							memorized_value <= digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 5;
						elsif (status = OPERAND_5DIGITS_ENTERED) then
							status <= OPERAND_6DIGITS_ENTERED;
							digit5_segmentcode <= digit4_segmentcode;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 5;
							memorized_value <= digit4_segmentcode * 100000
								+ digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 5;
						elsif (status = OPERAND_6DIGITS_ENTERED) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else null;
                        end if;
                    -- Pressed button [6]
					when X"0040" => 
						if (status = INITIAL or status = ERROR) then
							status <= OPERAND_1DIGIT_ENTERED;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 6;
							memorized_value <= 6;
						elsif (status = OPERAND_1DIGIT_ENTERED) then
							status <= OPERAND_2DIGITS_ENTERED;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 6;
							memorized_value <= digit0_segmentcode * 10 + 6;
						elsif (status = OPERAND_2DIGITS_ENTERED) then
							status <= OPERAND_3DIGITS_ENTERED;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 6;
							memorized_value <= digit1_segmentcode * 100 + digit0_segmentcode * 10 + 6;
						elsif (status = OPERAND_3DIGITS_ENTERED) then
							status <= OPERAND_4DIGITS_ENTERED;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 6;
							memorized_value <= digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 6;
						elsif (status = OPERAND_4DIGITS_ENTERED) then
							status <= OPERAND_5DIGITS_ENTERED;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 6;
							memorized_value <= digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 6;
						elsif (status = OPERAND_5DIGITS_ENTERED) then
							status <= OPERAND_6DIGITS_ENTERED;
							digit5_segmentcode <= digit4_segmentcode;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 6;
							memorized_value <= digit4_segmentcode * 100000
								+ digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 6;
						elsif (status = OPERAND_6DIGITS_ENTERED) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else null;
                        end if;
                    -- Pressed button [*]
					when X"0080" => 
						if (status = INITIAL) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else 
							status <= INITIAL;
							operation_status <= 1;
							entered_operator <= entering_operator;
							entering_operator <= 2;
                        end if;
                    -- Pressed button [1]
					when X"0100" => 
						if (status = INITIAL or status = ERROR) then
							status <= OPERAND_1DIGIT_ENTERED;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 1;
							memorized_value <= 1;
						elsif (status = OPERAND_1DIGIT_ENTERED) then
							status <= OPERAND_2DIGITS_ENTERED;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 1;
							memorized_value <= digit0_segmentcode * 10 + 1;
						elsif (status = OPERAND_2DIGITS_ENTERED) then
							status <= OPERAND_3DIGITS_ENTERED;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 1;
							memorized_value <= digit1_segmentcode * 100 + digit0_segmentcode * 10 + 1;
						elsif (status = OPERAND_3DIGITS_ENTERED) then
							status <= OPERAND_4DIGITS_ENTERED;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 1;
							memorized_value <= digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 1;
						elsif (status = OPERAND_4DIGITS_ENTERED) then
							status <= OPERAND_5DIGITS_ENTERED;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 1;
							memorized_value <= digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 1;
						elsif (status = OPERAND_5DIGITS_ENTERED) then
							status <= OPERAND_6DIGITS_ENTERED;
							digit5_segmentcode <= digit4_segmentcode;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 1;
							memorized_value <= digit4_segmentcode * 100000
								+ digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 1;
						elsif (status = OPERAND_6DIGITS_ENTERED) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else null;
                        end if;
                    -- Pressed button [2]
					when X"0200" => 
						if (status = INITIAL or status = ERROR) then
							status <= OPERAND_1DIGIT_ENTERED;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 2;
							memorized_value <= 2;
						elsif (status = OPERAND_1DIGIT_ENTERED) then
							status <= OPERAND_2DIGITS_ENTERED;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 2;
							memorized_value <= digit0_segmentcode * 10 + 2;
						elsif (status = OPERAND_2DIGITS_ENTERED) then
							status <= OPERAND_3DIGITS_ENTERED;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 2;
							memorized_value <= digit1_segmentcode * 100 + digit0_segmentcode * 10 + 2;
						elsif (status = OPERAND_3DIGITS_ENTERED) then
							status <= OPERAND_4DIGITS_ENTERED;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 2;
							memorized_value <= digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 2;
						elsif (status = OPERAND_4DIGITS_ENTERED) then
							status <= OPERAND_5DIGITS_ENTERED;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 2;
							memorized_value <= digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 2;
						elsif (status = OPERAND_5DIGITS_ENTERED) then
							status <= OPERAND_6DIGITS_ENTERED;
							digit5_segmentcode <= digit4_segmentcode;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 2;
							memorized_value <= digit4_segmentcode * 100000
								+ digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 2;
						elsif (status = OPERAND_6DIGITS_ENTERED) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else null;
                        end if;
                    -- Pressed button [3]
					when X"0400" => 
						if (status = INITIAL or status = ERROR) then
							status <= OPERAND_1DIGIT_ENTERED;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 3;
							memorized_value <= 3;
						elsif (status = OPERAND_1DIGIT_ENTERED) then
							status <= OPERAND_2DIGITS_ENTERED;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 3;
							memorized_value <= digit0_segmentcode * 10 + 3;
						elsif (status = OPERAND_2DIGITS_ENTERED) then
							status <= OPERAND_3DIGITS_ENTERED;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 3;
							memorized_value <= digit1_segmentcode * 100 + digit0_segmentcode * 10 + 3;
						elsif (status = OPERAND_3DIGITS_ENTERED) then
							status <= OPERAND_4DIGITS_ENTERED;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 3;
							memorized_value <= digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 3;
						elsif (status = OPERAND_4DIGITS_ENTERED) then
							status <= OPERAND_5DIGITS_ENTERED;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 3;
							memorized_value <= digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 3;
						elsif (status = OPERAND_5DIGITS_ENTERED) then
							status <= OPERAND_6DIGITS_ENTERED;
							digit5_segmentcode <= digit4_segmentcode;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 3;
							memorized_value <= digit4_segmentcode * 100000
								+ digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10
								+ 3;
						elsif (status = OPERAND_6DIGITS_ENTERED) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else null;
                        end if;
                    -- Pressed button [-]
					when X"0800" => 
						if (status = INITIAL) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else 
							status <= INITIAL;
							operation_status <= 1;
							entered_operator <= entering_operator;
							entering_operator <= 1;
                        end if;
                    -- Pressed button [0]
					when X"1000" => 
						if (status = INITIAL or status = ERROR) then
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 0;
							memorized_value <= 0;
						elsif (status = OPERAND_1DIGIT_ENTERED) then
							status <= OPERAND_2DIGITS_ENTERED;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 0;
							memorized_value <= digit0_segmentcode * 10;
						elsif (status = OPERAND_2DIGITS_ENTERED) then
							status <= OPERAND_3DIGITS_ENTERED;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 0;
							memorized_value <= digit1_segmentcode * 100 + digit0_segmentcode * 10;
						elsif (status = OPERAND_3DIGITS_ENTERED) then
							status <= OPERAND_4DIGITS_ENTERED;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 0;
							memorized_value <= digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10;
						elsif (status = OPERAND_4DIGITS_ENTERED) then
							status <= OPERAND_5DIGITS_ENTERED;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 0;
							memorized_value <= digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10;
						elsif (status = OPERAND_5DIGITS_ENTERED) then
							status <= OPERAND_6DIGITS_ENTERED;
							digit5_segmentcode <= digit4_segmentcode;
							digit4_segmentcode <= digit3_segmentcode;
							digit3_segmentcode <= digit2_segmentcode;
							digit2_segmentcode <= digit1_segmentcode;
							digit1_segmentcode <= digit0_segmentcode;
							digit0_segmentcode <= 0;
							memorized_value <= digit4_segmentcode * 100000
								+ digit3_segmentcode * 10000
								+ digit2_segmentcode * 1000
								+ digit1_segmentcode * 100
								+ digit0_segmentcode * 10;
						elsif (status = OPERAND_6DIGITS_ENTERED) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else null;
                        end if;
                    -- Pressed button [C]
					when X"2000" => 
						status <= INITIAL;
						digit5_segmentcode <= 20;
						digit4_segmentcode <= 20;
						digit3_segmentcode <= 20;
						digit2_segmentcode <= 20;
						digit1_segmentcode <= 20;
						digit0_segmentcode <= 0;
						operation_result <= 0;
                        memorized_value <= 0;
                    -- Pressed button [=]
					when X"4000" => 
						if (status = INITIAL) then
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 20;
							digit3_segmentcode <= 20;
							digit2_segmentcode <= 20;
							digit1_segmentcode <= 20;
							digit0_segmentcode <= 0;
						end if;

						status <= INITIAL;
                        operation_status <= 1;
                        memorized_value <= 0;
						entered_operator <= entering_operator;
                        entering_operator <= 4;
                    -- Pressed button [+]
					when X"8000" => 
						if (status = INITIAL) then
							status <= ERROR;
							digit5_segmentcode <= 20;
							digit4_segmentcode <= 16;
							digit3_segmentcode <= 17;
							digit2_segmentcode <= 17;
							digit1_segmentcode <= 0;
							digit0_segmentcode <= 17;
						else 
							status <= INITIAL;
							operation_status <= 1;
							entered_operator <= entering_operator;
							entering_operator <= 0;
						end if;
					when others => null;
				end case;
			end if;
		end if;
	end process;
    
    -- Segment code conversion process
	process (
		digit5_segmentcode,
		digit4_segmentcode,
		digit3_segmentcode,
		digit2_segmentcode,
		digit1_segmentcode,
		digit0_segmentcode
    ) begin   
        --   -a-
        -- f|   |b
        --   -g-
        -- e|   |c
        --   -d-
        -- for B"gfedcba"
        -- TODO case digit5_segmentcode is
		if (digit5_segmentcode = 0) then
			digit5_segment <= B"0111111";	
		elsif (digit5_segmentcode = 1) then
			digit5_segment <= B"0000110";
		elsif (digit5_segmentcode = 2) then
			digit5_segment <= B"1011011";
		elsif (digit5_segmentcode = 3) then
			digit5_segment <= B"1001111";
		elsif (digit5_segmentcode = 4) then
			digit5_segment <= B"1100110";
		elsif (digit5_segmentcode = 5) then
			digit5_segment <= B"1101101";
		elsif (digit5_segmentcode = 6) then
			digit5_segment <= B"1111101";
		elsif (digit5_segmentcode = 7) then
			digit5_segment <= B"0000111";
		elsif (digit5_segmentcode = 8) then
			digit5_segment <= B"1111111";
		elsif (digit5_segmentcode = 9) then
			digit5_segment <= B"1100111";
		elsif (digit5_segmentcode = 10) then
			digit5_segment <= B"0111111";
		elsif (digit5_segmentcode = 11) then
			digit5_segment <= B"1110011";
		elsif (digit5_segmentcode = 12) then
			digit5_segment <= B"1110111";
		elsif (digit5_segmentcode = 13) then
			digit5_segment <= B"1111100";
		elsif (digit5_segmentcode = 14) then
			digit5_segment <= B"0111001";
		elsif (digit5_segmentcode = 15) then
			digit5_segment <= B"1011110";
		elsif (digit5_segmentcode = 16) then
			digit5_segment <= B"1111001";
		elsif (digit5_segmentcode = 17) then
			digit5_segment <= B"1010000";
		elsif (digit5_segmentcode = 18) then
			digit5_segment <= B"1000000";
		elsif (digit5_segmentcode = 19) then
			digit5_segment <= B"1010100";
		elsif (digit0_segmentcode = 21) then
			digit5_segment <= B"1000000";
		else digit5_segment <= B"0000000";
		end if;
		
		if (digit4_segmentcode = 0) then
			digit4_segment <= B"0111111";
		elsif (digit4_segmentcode = 1) then
			digit4_segment <= B"0000110";
		elsif (digit4_segmentcode = 2) then
			digit4_segment <= B"1011011";
		elsif (digit4_segmentcode = 3) then
			digit4_segment <= B"1001111";
		elsif (digit4_segmentcode = 4) then
			digit4_segment <= B"1100110";
		elsif (digit4_segmentcode = 5) then
			digit4_segment <= B"1101101";
		elsif (digit4_segmentcode = 6) then
			digit4_segment <= B"1111101";
		elsif (digit4_segmentcode = 7) then
			digit4_segment <= B"0000111";
		elsif (digit4_segmentcode = 8) then
			digit4_segment <= B"1111111";
		elsif (digit4_segmentcode = 9) then
			digit4_segment <= B"1100111";
		elsif (digit4_segmentcode = 10) then
			digit4_segment <= B"0111111";
		elsif (digit4_segmentcode = 11) then
			digit4_segment <= B"1110011";
		elsif (digit4_segmentcode = 12) then
			digit4_segment <= B"1110111";
		elsif (digit4_segmentcode = 13) then
			digit4_segment <= B"1111100";
		elsif (digit4_segmentcode = 14) then
			digit4_segment <= B"0111001";
		elsif (digit4_segmentcode = 15) then
			digit4_segment <= B"1011110";
		elsif (digit4_segmentcode = 16) then
			digit4_segment <= B"1111001";
		elsif (digit4_segmentcode = 17) then
			digit4_segment <= B"1010000";
		elsif (digit4_segmentcode = 18) then
			digit4_segment <= B"1000000";
		elsif (digit4_segmentcode = 19) then
			digit4_segment <= B"1010100";
		elsif (digit0_segmentcode = 21) then
			digit4_segment <= B"1000000";
		else digit4_segment <= B"0000000";
		end if;

		if (digit3_segmentcode = 0) then
			digit3_segment <= B"0111111";
		elsif (digit3_segmentcode = 1) then
			digit3_segment <= B"0000110";
		elsif (digit3_segmentcode = 2) then
			digit3_segment <= B"1011011";
		elsif (digit3_segmentcode = 3) then
			digit3_segment <= B"1001111";
		elsif (digit3_segmentcode = 4) then
			digit3_segment <= B"1100110";
		elsif (digit3_segmentcode = 5) then
			digit3_segment <= B"1101101";
		elsif (digit3_segmentcode = 6) then
			digit3_segment <= B"1111101";
		elsif (digit3_segmentcode = 7) then
			digit3_segment <= B"0000111";
		elsif (digit3_segmentcode = 8) then
			digit3_segment <= B"1111111";
		elsif (digit3_segmentcode = 9) then
			digit3_segment <= B"1100111";
		elsif (digit3_segmentcode = 10) then
			digit3_segment <= B"0111111";
		elsif (digit3_segmentcode = 11) then
			digit3_segment <= B"1110011";
		elsif (digit3_segmentcode = 12) then
			digit3_segment <= B"1110111";
		elsif (digit3_segmentcode = 13) then
			digit3_segment <= B"1111100";
		elsif (digit3_segmentcode = 14) then
			digit3_segment <= B"0111001";
		elsif (digit3_segmentcode = 15) then
			digit3_segment <= B"1011110";
		elsif (digit3_segmentcode = 16) then
			digit3_segment <= B"1111001";
		elsif (digit3_segmentcode = 17) then
			digit3_segment <= B"1010000";
		elsif (digit3_segmentcode = 18) then
			digit3_segment <= B"1000000";
		elsif (digit3_segmentcode = 19) then
			digit3_segment <= B"1010100";
		elsif (digit0_segmentcode = 21) then
			digit3_segment <= B"1000000";
		else digit3_segment <= B"0000000";
		end if;

		if (digit2_segmentcode = 0) then
			digit2_segment <= B"0111111";
		elsif (digit2_segmentcode = 1) then
			digit2_segment <= B"0000110";
		elsif (digit2_segmentcode = 2) then
			digit2_segment <= B"1011011";
		elsif (digit2_segmentcode = 3) then
			digit2_segment <= B"1001111";
		elsif (digit2_segmentcode = 4) then
			digit2_segment <= B"1100110";
		elsif (digit2_segmentcode = 5) then
			digit2_segment <= B"1101101";
		elsif (digit2_segmentcode = 6) then
			digit2_segment <= B"1111101";
		elsif (digit2_segmentcode = 7) then
			digit2_segment <= B"0000111";
		elsif (digit2_segmentcode = 8) then
			digit2_segment <= B"1111111";
		elsif (digit2_segmentcode = 9) then
			digit2_segment <= B"1100111";
		elsif (digit2_segmentcode = 10) then
			digit2_segment <= B"0111111";
		elsif (digit2_segmentcode = 11) then
			digit2_segment <= B"1110011";
		elsif (digit2_segmentcode = 12) then
			digit2_segment <= B"1110111";
		elsif (digit2_segmentcode = 13) then
			digit2_segment <= B"1111100";
		elsif (digit2_segmentcode = 14) then
			digit2_segment <= B"0111001";
		elsif (digit2_segmentcode = 15) then
			digit2_segment <= B"1011110";
		elsif (digit2_segmentcode = 16) then
			digit2_segment <= B"1111001";
		elsif (digit2_segmentcode = 17) then
			digit2_segment <= B"1010000";
		elsif (digit2_segmentcode = 18) then
			digit2_segment <= B"1000000";
		elsif (digit2_segmentcode = 19) then
			digit2_segment <= B"1010100";
		elsif (digit0_segmentcode = 21) then
			digit2_segment <= B"1000000";
		else digit2_segment <= B"0000000";
		end if;

		if (digit1_segmentcode = 0) then
			digit1_segment <= B"0111111";
		elsif (digit1_segmentcode = 1) then
			digit1_segment <= B"0000110";
		elsif (digit1_segmentcode = 2) then
			digit1_segment <= B"1011011";
		elsif (digit1_segmentcode = 3) then
			digit1_segment <= B"1001111";
		elsif (digit1_segmentcode = 4) then
			digit1_segment <= B"1100110";
		elsif (digit1_segmentcode = 5) then
			digit1_segment <= B"1101101";
		elsif (digit1_segmentcode = 6) then
			digit1_segment <= B"1111101";
		elsif (digit1_segmentcode = 7) then
			digit1_segment <= B"0000111";
		elsif (digit1_segmentcode = 8) then
			digit1_segment <= B"1111111";
		elsif (digit1_segmentcode = 9) then
			digit1_segment <= B"1100111";
		elsif (digit1_segmentcode = 10) then
			digit1_segment <= B"0111111";
		elsif (digit1_segmentcode = 11) then
			digit1_segment <= B"1110011";
		elsif (digit1_segmentcode = 12) then
			digit1_segment <= B"1110111";
		elsif (digit1_segmentcode = 13) then
			digit1_segment <= B"1111100";
		elsif (digit1_segmentcode = 14) then
			digit1_segment <= B"0111001";
		elsif (digit1_segmentcode = 15) then
			digit1_segment <= B"1011110";
		elsif (digit1_segmentcode = 16) then
			digit1_segment <= B"1111001";
		elsif (digit1_segmentcode = 17) then
			digit1_segment <= B"1010000";
		elsif (digit1_segmentcode = 18) then
			digit1_segment <= B"1000000";
		elsif (digit1_segmentcode = 19) then
			digit1_segment <= B"1010100";
		elsif (digit0_segmentcode = 21) then
			digit1_segment <= B"1000000";
		else digit1_segment <= B"0000000";
		end if;

		if (digit0_segmentcode = 0) then
			digit0_segment <= B"0111111";
		elsif (digit0_segmentcode = 1) then
			digit0_segment <= B"0000110";
		elsif (digit0_segmentcode = 2) then
			digit0_segment <= B"1011011";
		elsif (digit0_segmentcode = 3) then
			digit0_segment <= B"1001111";
		elsif (digit0_segmentcode = 4) then
			digit0_segment <= B"1100110";
		elsif (digit0_segmentcode = 5) then
			digit0_segment <= B"1101101";
		elsif (digit0_segmentcode = 6) then
			digit0_segment <= B"1111101";
		elsif (digit0_segmentcode = 7) then
			digit0_segment <= B"0000111";
		elsif (digit0_segmentcode = 8) then
			digit0_segment <= B"1111111";
		elsif (digit0_segmentcode = 9) then
			digit0_segment <= B"1100111";
		elsif (digit0_segmentcode = 10) then
			digit0_segment <= B"0111111";
		elsif (digit0_segmentcode = 11) then
			digit0_segment <= B"1110011";
		elsif (digit0_segmentcode = 12) then
			digit0_segment <= B"1110111";
		elsif (digit0_segmentcode = 13) then
			digit0_segment <= B"1111100";
		elsif (digit0_segmentcode = 14) then
			digit0_segment <= B"0111001";
		elsif (digit0_segmentcode = 15) then
			digit0_segment <= B"1011110";
		elsif (digit0_segmentcode = 16) then
			digit0_segment <= B"1111001";
		elsif (digit0_segmentcode = 17) then
			digit0_segment <= B"1010000";
		elsif (digit0_segmentcode = 18) then
			digit0_segment <= B"1000000";
		elsif (digit0_segmentcode = 19) then
			digit0_segment <= B"1010100";
		else digit0_segment <= B"0000000";
		end if;
    end process;
    
    -- Segment output process
	process(sevensegment_clock, sevensegment_counter) begin
		if rising_edge(sevensegment_clock) then
			case sevensegment_counter is 
				when 5 => 
					sevensegment_databus <= '0' & digit5_segment;
					sevensegment_counter <= 4;
				when 4 => 
					sevensegment_databus <= '0' & digit4_segment;
					sevensegment_counter <= 3;
				when 3 => 
					sevensegment_databus <= '0' & digit3_segment;
					sevensegment_counter <= 2;
				when 2 => 
					sevensegment_databus <= '0' & digit2_segment;
					sevensegment_counter <= 1;
				when 1 => 
					sevensegment_databus <= '0' & digit1_segment;
					sevensegment_counter <= 0;
				when 0 => 
					sevensegment_databus <= '0' & digit0_segment;
					sevensegment_counter <= 5;
				when others => null;
			end case;

			if (sevensegment_counter = 5) then
				sevensegment_selection(5) <= '0';
			else 
				sevensegment_selection(5) <= '1';
			end if;

			if (sevensegment_counter = 4) then
				sevensegment_selection(4) <= '0';
			else 
				sevensegment_selection(4) <= '1';
			end if;

			if (sevensegment_counter = 3) then
				sevensegment_selection(3) <= '0';
			else 
				sevensegment_selection(3) <= '1';
			end if;

			if (sevensegment_counter = 2) then
				sevensegment_selection(2) <= '0';
			else 
				sevensegment_selection(2) <= '1';
			end if;

			if (sevensegment_counter = 1) then
				sevensegment_selection(1) <= '0';
			else 
				sevensegment_selection(1) <= '1';
			end if;

			if (sevensegment_counter = 0) then
				sevensegment_selection(0) <= '0';
			else 
				sevensegment_selection(0) <= '1';
			end if;
		end if;
	end process;
end behavior;