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
	signal alt_operation_status : integer := 1;
	signal display_status : integer := 0;
	signal operation_result : integer := 0;
	signal digit5_segmentcode : integer range 0 to 20 := 20;
	signal digit4_segmentcode : integer range 0 to 20 := 20;
	signal digit3_segmentcode : integer range 0 to 20 := 20;
	signal digit2_segmentcode : integer range 0 to 20 := 20;
	signal digit1_segmentcode : integer range 0 to 20 := 20;
	signal digit0_segmentcode : integer range 0 to 20 := 0;

	signal entered_operator : integer := 4;
	signal entering_operator : integer := 4;

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
						when 0 => operation_result <= operation_result + memorized_value; -- Add('+')
						when 1 => operation_result <= operation_result - memorized_value; -- Subtraction('-')
						when 2 => operation_result <= operation_result * memorized_value; -- Multiplication('*')
						when 3 => -- Division('/')
							if (memorized_value /= 0) then
								operation_result <= operation_result / memorized_value;
							elsif (memorized_value = 0 and alt_operation_status /= 2) then -- If dividing by 0
								operation_result <= 2147483647;
							end if;
						when 4 => operation_result <= operation_result mod memorized_value; -- Modulus('%', as '+/')
						when others => operation_result <= memorized_value;
					end case;

					if (entering_operator = 5) then
						operation_status <= 2;
					else
						operation_status <= 0;
						memorized_value <= 0;
						display_status <= 1;
					end if;
				elsif (operation_status = 2) then
					status <= INITIAL;
					operation_result <= operation_result;
					operation_status <= 0;
					memorized_value <= operation_result;
					display_status <= 1;
					alt_operation_status <= 1;
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
								memorized_value <= 0;
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
								memorized_value <= 0;
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
								memorized_value <= 0;
							else null;
							end if;

						-- Pressed button [/]
						when X"0008" => 
							if (status = INITIAL and alt_operation_status /= 0) then
								status <= ERROR;
								digit5_segmentcode <= 20;
								digit4_segmentcode <= 16;
								digit3_segmentcode <= 17;
								digit2_segmentcode <= 17;
								digit1_segmentcode <= 0;
								digit0_segmentcode <= 17;
								memorized_value <= 0;
							elsif (status = INITIAL and alt_operation_status = 0) then
								status <= INITIAL;
								operation_status <= 1;
								entered_operator <= entering_operator;
								entering_operator <= 4;
								alt_operation_status <= 1;
							else 
								status <= INITIAL;
								operation_status <= 1;
								entered_operator <= entering_operator;
								entering_operator <= 3;
								alt_operation_status <= 2;
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
								memorized_value <= 0;
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
								memorized_value <= 0;
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
								memorized_value <= 0;
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
								memorized_value <= 0;
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
								memorized_value <= 0;
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
								memorized_value <= 0;
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
								memorized_value <= 0;
							else null;
							end if;

						-- Pressed button [-]
						when X"0800" => 
							if (status = INITIAL and alt_operation_status /= 0) then
								status <= ERROR;
								digit5_segmentcode <= 20;
								digit4_segmentcode <= 16;
								digit3_segmentcode <= 17;
								digit2_segmentcode <= 17;
								digit1_segmentcode <= 0;
								digit0_segmentcode <= 17;
								memorized_value <= 0;
							elsif (status = INITIAL and alt_operation_status = 0) then
								status <= INITIAL;
								operation_status <= 1; 
								alt_operation_status <= 1;
								memorized_value <= memorized_value - 1; 
								entered_operator <= entering_operator;
								entering_operator <= 5;
							else 
								status <= INITIAL;
								operation_status <= 1;
								alt_operation_status <= 0;
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
								memorized_value <= 0;
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
							operation_status <= 0;
							display_status <= 0;
							entered_operator <= 5;
							entering_operator <= 5;
							alt_operation_status <= 1;

						-- Pressed button [=]
						when X"4000" => 
							if (status = INITIAL) then
								digit5_segmentcode <= 20;
								digit4_segmentcode <= 20;
								digit3_segmentcode <= 20;
								digit2_segmentcode <= 20;
								digit1_segmentcode <= 20;
								digit0_segmentcode <= 0;
							elsif (status = ERROR) then null;
							else
								status <= INITIAL;
								operation_status <= 1;
								entered_operator <= entering_operator;
								entering_operator <= 5;
							end if;
									
						-- Pressed button [+]
						when X"8000" => 
							if (status = INITIAL and alt_operation_status /= 0) then
								status <= ERROR;
								digit5_segmentcode <= 20;
								digit4_segmentcode <= 16;
								digit3_segmentcode <= 17;
								digit2_segmentcode <= 17;
								digit1_segmentcode <= 0;
								digit0_segmentcode <= 17;
								memorized_value <= 0;
							elsif (status = INITIAL and alt_operation_status = 0) then
								status <= INITIAL;
								operation_status <= 1; 
								alt_operation_status <= 1;
								memorized_value <= memorized_value + 1; 
								entered_operator <= entering_operator;
								entering_operator <= 5;
							else 
								status <= INITIAL;
								operation_status <= 1;
								alt_operation_status <= 0;
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
		case digit5_segmentcode is
			when 0 => digit5_segment <= B"0111111";
			when 1 => digit5_segment <= B"0000110";
			when 2 => digit5_segment <= B"1011011";
			when 3 => digit5_segment <= B"1001111";
			when 4 => digit5_segment <= B"1100110";
			when 5 => digit5_segment <= B"1101101";
			when 6 => digit5_segment <= B"1111101";
			when 7 => digit5_segment <= B"0000111";
			when 8 => digit5_segment <= B"1111111";
			when 9 => digit5_segment <= B"1100111";
			when 10 => digit5_segment <= B"0111111";
			when 11 => digit5_segment <= B"1110011";
			when 12 => digit5_segment <= B"1110111";
			when 13 => digit5_segment <= B"1111100";
			when 14 => digit5_segment <= B"0111001";
			when 15 => digit5_segment <= B"1011110";
			when 16 => digit5_segment <= B"1111001";
			when 17 => digit5_segment <= B"1010000";
			when 18 => digit5_segment <= B"1000000";
			when 19 => digit5_segment <= B"1010100";
			when others => digit5_segment <= B"0000000";
		end case;

		case digit4_segmentcode is
			when 0 => digit4_segment <= B"0111111";
			when 1 => digit4_segment <= B"0000110";
			when 2 => digit4_segment <= B"1011011";
			when 3 => digit4_segment <= B"1001111";
			when 4 => digit4_segment <= B"1100110";
			when 5 => digit4_segment <= B"1101101";
			when 6 => digit4_segment <= B"1111101";
			when 7 => digit4_segment <= B"0000111";
			when 8 => digit4_segment <= B"1111111";
			when 9 => digit4_segment <= B"1100111";
			when 10 => digit4_segment <= B"0111111";
			when 11 => digit4_segment <= B"1110011";
			when 12 => digit4_segment <= B"1110111";
			when 13 => digit4_segment <= B"1111100";
			when 14 => digit4_segment <= B"0111001";
			when 15 => digit4_segment <= B"1011110";
			when 16 => digit4_segment <= B"1111001";
			when 17 => digit4_segment <= B"1010000";
			when 18 => digit4_segment <= B"1000000";
			when 19 => digit4_segment <= B"1010100";
			when others => digit4_segment <= B"0000000";
		end case;

		case digit3_segmentcode is
			when 0 => digit3_segment <= B"0111111";
			when 1 => digit3_segment <= B"0000110";
			when 2 => digit3_segment <= B"1011011";
			when 3 => digit3_segment <= B"1001111";
			when 4 => digit3_segment <= B"1100110";
			when 5 => digit3_segment <= B"1101101";
			when 6 => digit3_segment <= B"1111101";
			when 7 => digit3_segment <= B"0000111";
			when 8 => digit3_segment <= B"1111111";
			when 9 => digit3_segment <= B"1100111";
			when 10 => digit3_segment <= B"0111111";
			when 11 => digit3_segment <= B"1110011";
			when 12 => digit3_segment <= B"1110111";
			when 13 => digit3_segment <= B"1111100";
			when 14 => digit3_segment <= B"0111001";
			when 15 => digit3_segment <= B"1011110";
			when 16 => digit3_segment <= B"1111001";
			when 17 => digit3_segment <= B"1010000";
			when 18 => digit3_segment <= B"1000000";
			when 19 => digit3_segment <= B"1010100";
			when others => digit3_segment <= B"0000000";
		end case;

		case digit2_segmentcode is
			when 0 => digit2_segment <= B"0111111";
			when 1 => digit2_segment <= B"0000110";
			when 2 => digit2_segment <= B"1011011";
			when 3 => digit2_segment <= B"1001111";
			when 4 => digit2_segment <= B"1100110";
			when 5 => digit2_segment <= B"1101101";
			when 6 => digit2_segment <= B"1111101";
			when 7 => digit2_segment <= B"0000111";
			when 8 => digit2_segment <= B"1111111";
			when 9 => digit2_segment <= B"1100111";
			when 10 => digit2_segment <= B"0111111";
			when 11 => digit2_segment <= B"1110011";
			when 12 => digit2_segment <= B"1110111";
			when 13 => digit2_segment <= B"1111100";
			when 14 => digit2_segment <= B"0111001";
			when 15 => digit2_segment <= B"1011110";
			when 16 => digit2_segment <= B"1111001";
			when 17 => digit2_segment <= B"1010000";
			when 18 => digit2_segment <= B"1000000";
			when 19 => digit2_segment <= B"1010100";
			when others => digit2_segment <= B"0000000";
		end case;

		case digit1_segmentcode is
			when 0 => digit1_segment <= B"0111111";
			when 1 => digit1_segment <= B"0000110";
			when 2 => digit1_segment <= B"1011011";
			when 3 => digit1_segment <= B"1001111";
			when 4 => digit1_segment <= B"1100110";
			when 5 => digit1_segment <= B"1101101";
			when 6 => digit1_segment <= B"1111101";
			when 7 => digit1_segment <= B"0000111";
			when 8 => digit1_segment <= B"1111111";
			when 9 => digit1_segment <= B"1100111";
			when 10 => digit1_segment <= B"0111111";
			when 11 => digit1_segment <= B"1110011";
			when 12 => digit1_segment <= B"1110111";
			when 13 => digit1_segment <= B"1111100";
			when 14 => digit1_segment <= B"0111001";
			when 15 => digit1_segment <= B"1011110";
			when 16 => digit1_segment <= B"1111001";
			when 17 => digit1_segment <= B"1010000";
			when 18 => digit1_segment <= B"1000000";
			when 19 => digit1_segment <= B"1010100";
			when others => digit1_segment <= B"0000000";
		end case;

		case digit0_segmentcode is
			when 0 => digit0_segment <= B"0111111";
			when 1 => digit0_segment <= B"0000110";
			when 2 => digit0_segment <= B"1011011";
			when 3 => digit0_segment <= B"1001111";
			when 4 => digit0_segment <= B"1100110";
			when 5 => digit0_segment <= B"1101101";
			when 6 => digit0_segment <= B"1111101";
			when 7 => digit0_segment <= B"0000111";
			when 8 => digit0_segment <= B"1111111";
			when 9 => digit0_segment <= B"1100111";
			when 10 => digit0_segment <= B"0111111";
			when 11 => digit0_segment <= B"1110011";
			when 12 => digit0_segment <= B"1110111";
			when 13 => digit0_segment <= B"1111100";
			when 14 => digit0_segment <= B"0111001";
			when 15 => digit0_segment <= B"1011110";
			when 16 => digit0_segment <= B"1111001";
			when 17 => digit0_segment <= B"1010000";
			when 18 => digit0_segment <= B"1000000";
			when 19 => digit0_segment <= B"1010100";
			when others => digit0_segment <= B"0000000";
		end case;
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