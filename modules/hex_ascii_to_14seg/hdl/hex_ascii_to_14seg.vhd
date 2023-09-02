-- hex_ascii_to_14seg.vhd
-- Author: Samuel Sugimoto
-- Date: 

-- Converts either hex or select ascii values to a 14-segment display.
-- Designed for direct control of each of the 14 segments, ala ACPSA04-41SRWA (active low)

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.display_14seg_package.all;

entity hex_ascii_to_14seg is
port (
  i_data    : in  std_logic_vector(6 downto 0);
  i_ascii   : in  std_logic;
  i_dp_en   : in  std_logic;
  o_14_seg  : out std_logic_vector(14 downto 0)
);
end entity hex_ascii_to_14seg;

architecture hex_ascii_to_14seg of hex_ascii_to_14seg is
  signal s_14seg_t : t_14seg;
--  14-segment display layout
--   -----       aaaaa
--  |\ | /|     fg h jb
--  | \|/ |     f ghj b
--  --- ---     ppp kkk
--  | /|\ |     e nml c
--  |/ | \|     en m lc
--   -----       ddddd
begin
  o_14_seg  <= (i_dp_en or s_14seg_t.dp) & convert_14seg(s_14seg_t)(13 downto 0);
  process(all) is
  begin
    if (i_ascii = '1') then
      case i_data is
        when 7x"20" => -- space
          s_14seg_t  <= c_14seg_spce;
        when 7x"30" => -- 0
          s_14seg_t  <= c_14seg_0;
        when 7x"31" => -- 1
          s_14seg_t  <= c_14seg_1;
        when 7x"32" => -- 2
          s_14seg_t  <= c_14seg_2;
        when 7x"33" => -- 3
          s_14seg_t  <= c_14seg_3;
        when 7x"34" => -- 4
          s_14seg_t  <= c_14seg_4;
        when 7x"35" => -- 5
          s_14seg_t  <= c_14seg_5;
        when 7x"36" => -- 6
          s_14seg_t  <= c_14seg_6;
        when 7x"37" => -- 7
          s_14seg_t  <= c_14seg_7;
        when 7x"38" => -- 8
          s_14seg_t  <= c_14seg_8;
        when 7x"39" => -- 9
          s_14seg_t  <= c_14seg_9;
        when 7x"41" => -- A
          s_14seg_t  <= c_14seg_UA;
        when 7x"42" => -- B
          s_14seg_t  <= c_14seg_UB;
        when 7x"43" => -- C
          s_14seg_t  <= c_14seg_UC;
        when 7x"44" => -- D
          s_14seg_t  <= c_14seg_UD;
        when 7x"45" => -- E
          s_14seg_t  <= c_14seg_UE;
        when 7x"46" => -- F
          s_14seg_t  <= c_14seg_UF;
        when 7x"47" => -- G
          s_14seg_t  <= c_14seg_UG;
        when 7x"48" => -- H
          s_14seg_t  <= c_14seg_UH;
        when 7x"49" => -- I
          s_14seg_t  <= c_14seg_UI;
        when 7x"4A" => -- J
          s_14seg_t  <= c_14seg_UJ;
        when 7x"4B" => -- K
          s_14seg_t  <= c_14seg_UK;
        when 7x"4C" => -- L
          s_14seg_t  <= c_14seg_UL;
        when 7x"4D" => -- M
          s_14seg_t  <= c_14seg_UM;
        when 7x"4E" => -- N
          s_14seg_t  <= c_14seg_UN;
        when 7x"4F" => -- O
          s_14seg_t  <= c_14seg_UO;
        when 7x"50" => -- P
          s_14seg_t  <= c_14seg_UP;
        when 7x"51" => -- Q
          s_14seg_t  <= c_14seg_UQ;
        when 7x"52" => -- R
          s_14seg_t  <= c_14seg_UR;
        when 7x"53" => -- S
          s_14seg_t  <= c_14seg_US;
        when 7x"54" => -- T
          s_14seg_t  <= c_14seg_UT;
        when 7x"55" => -- U
          s_14seg_t  <= c_14seg_UU;
        when 7x"56" => -- V
          s_14seg_t  <= c_14seg_UV;
        when 7x"57" => -- W
          s_14seg_t  <= c_14seg_UW;
        when 7x"58" => -- X
          s_14seg_t  <= c_14seg_UX;
        when 7x"59" => -- Y
          s_14seg_t  <= c_14seg_UY;
        when 7x"5A" => -- Z
          s_14seg_t  <= c_14seg_UZ;
        when others => -- default
          s_14seg_t  <= c_14seg_dflt;
      end case;
    else
      case i_data is
        when 7x"0" => -- 0
          s_14seg_t  <= c_14seg_0;
        when 7x"1" => -- 1
          s_14seg_t  <= c_14seg_1;
        when 7x"2" => -- 2
          s_14seg_t  <= c_14seg_2;
        when 7x"3" => -- 3
          s_14seg_t  <= c_14seg_3;
        when 7x"4" => -- 4
          s_14seg_t  <= c_14seg_4;
        when 7x"5" => -- 5
          s_14seg_t  <= c_14seg_5;
        when 7x"6" => -- 6
          s_14seg_t  <= c_14seg_6;
        when 7x"7" => -- 7
          s_14seg_t  <= c_14seg_7;
        when 7x"8" => -- 8
          s_14seg_t  <= c_14seg_8;
        when 7x"9" => -- 9
          s_14seg_t  <= c_14seg_9;
        when 7x"A" => -- A
          s_14seg_t  <= c_14seg_UA;
        when 7x"B" => -- B
          s_14seg_t  <= c_14seg_UB;
        when 7x"C" => -- C
          s_14seg_t  <= c_14seg_UC;
        when 7x"D" => -- D
          s_14seg_t  <= c_14seg_UD;
        when 7x"E" => -- E
          s_14seg_t  <= c_14seg_UE;
        when 7x"F" => -- F
          s_14seg_t  <= c_14seg_UF;
        when others => -- default
          s_14seg_t  <= c_14seg_dflt;
      end case;
    end if;
  end process;
end architecture;
