-- display_14seg_package.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;

package display_14seg_package is
  --  14-segment display layout
  --   -----       aaaaa
  --  |\ | /|     fg h jb
  --  | \|/ |     f ghj b
  --  --- ---     ppp kkk
  --  | /|\ |     e nml c
  --  |/ | \|     en m lc
  --   -----  .    ddddd  dp

  type t_14seg is record
    a   : std_logic;
    b   : std_logic;
    c   : std_logic;
    d   : std_logic;
    e   : std_logic;
    f   : std_logic;
    g   : std_logic;
    h   : std_logic;
    j   : std_logic;
    k   : std_logic;
    l   : std_logic;
    m   : std_logic;
    n   : std_logic;
    p   : std_logic;
    dp  : std_logic;
  end record t_14seg;

  constant c_14seg_0  : t_14seg   := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --  |    /|     f    jb
                                      c   => '1',           --  |   / |     f   j b
                                      d   => '1',           --                     
                                      e   => '1',           --  | /   |     e n   c
                                      f   => '1',           --  |/    |     en    c
                                      g   => '0',           --   -----       ddddd  
                                      h   => '0',
                                      j   => '1',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '1',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_1    : t_14seg := (a   => '0',           --                    
                                      b   => '1',           --       /|          jb
                                      c   => '1',           --      / |         j b
                                      d   => '0',           --                     
                                      e   => '0',           --        |           c
                                      f   => '0',           --        |           c
                                      g   => '0',           --                      
                                      h   => '0',
                                      j   => '1',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_2    : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --        |     fg h jb
                                      c   => '0',           --        |     f ghj b
                                      d   => '1',           --  --- ---     ppp kkk
                                      e   => '1',           --  |           e nml c
                                      f   => '0',           --  |           en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_3    : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --        |     fg h jb
                                      c   => '1',           --        |     f ghj b
                                      d   => '1',           --      ---     ppp kkk
                                      e   => '0',           --        |     e nml c
                                      f   => '0',           --        |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_4    : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '1',           --  |     |     f ghj b
                                      d   => '0',           --  --- ---     ppp kkk
                                      e   => '0',           --        |     e nml c
                                      f   => '1',           --        |     en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_5    : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '0',           --  |           fg h jb
                                      c   => '1',           --  |           f ghj b
                                      d   => '1',           --  --- ---     ppp kkk
                                      e   => '0',           --        |     e nml c
                                      f   => '1',           --        |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_6    : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '0',           --  |           fg h jb
                                      c   => '1',           --  |           f ghj b
                                      d   => '1',           --  --- ---     ppp kkk
                                      e   => '1',           --  |     |     e nml c
                                      f   => '1',           --  |     |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_7    : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --        |     fg h jb
                                      c   => '1',           --        |     f ghj b
                                      d   => '0',           --              ppp kkk
                                      e   => '0',           --        |     e nml c
                                      f   => '0',           --        |     en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_8    : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '1',           --  |     |     f ghj b
                                      d   => '1',           --  --- ---     ppp kkk
                                      e   => '1',           --  |     |     e nml c
                                      f   => '1',           --  |     |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_9    : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '1',           --  |     |     f ghj b
                                      d   => '1',           --  --- ---     ppp kkk
                                      e   => '0',           --        |     e nml c
                                      f   => '1',           --        |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_UA   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '1',           --  |     |     f ghj b
                                      d   => '0',           --  --- ---     ppp kkk
                                      e   => '1',           --  |     |     e nml c
                                      f   => '1',           --  |     |     en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_UB   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --     |  |     fg h jb
                                      c   => '1',           --     |  |     f ghj b
                                      d   => '1',           --      ---     ppp kkk
                                      e   => '0',           --     |  |     e nml c
                                      f   => '0',           --     |  |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '1',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '1',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UC   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '0',           --  |           fg h jb
                                      c   => '0',           --  |           f ghj b
                                      d   => '1',           --              ppp kkk
                                      e   => '1',           --  |           e nml c
                                      f   => '1',           --  |           en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UD   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --     |  |     fg h jb
                                      c   => '1',           --     |  |     f ghj b
                                      d   => '1',           --              ppp kkk
                                      e   => '0',           --     |  |     e nml c
                                      f   => '0',           --     |  |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '1',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '1',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UE   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '0',           --  |           fg h jb
                                      c   => '0',           --  |           f ghj b
                                      d   => '1',           --  ---         ppp kkk
                                      e   => '1',           --  |           e nml c
                                      f   => '1',           --  |           en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_UF   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '0',           --  |           fg h jb
                                      c   => '0',           --  |           f ghj b
                                      d   => '0',           --  ---         ppp kkk
                                      e   => '1',           --  |           e nml c
                                      f   => '1',           --  |           en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_UG   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '0',           --  |           fg h jb
                                      c   => '1',           --  |           f ghj b
                                      d   => '1',           --      ---     ppp kkk
                                      e   => '1',           --  |     |     e nml c
                                      f   => '1',           --  |     |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UH   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '1',           --  |     |     f ghj b
                                      d   => '0',           --  --- ---     ppp kkk
                                      e   => '1',           --  |     |     e nml c
                                      f   => '1',           --  |     |     en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_UI   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '0',           --     |        fg h jb
                                      c   => '0',           --     |        f ghj b
                                      d   => '1',           --              ppp kkk
                                      e   => '0',           --     |        e nml c
                                      f   => '0',           --     |        en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '1',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '1',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UJ   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '1',           --        |     fg h jb
                                      c   => '1',           --        |     f ghj b
                                      d   => '1',           --              ppp kkk
                                      e   => '1',           --  |     |     e nml c
                                      f   => '0',           --  |     |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UK   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '0',           --  |    /      fg h jb
                                      c   => '0',           --  |   /       f ghj b
                                      d   => '0',           --  ---         ppp kkk
                                      e   => '1',           --  |   \       e nml c
                                      f   => '1',           --  |    \      en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '1',
                                      k   => '0',
                                      l   => '1',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_UL   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '0',           --  |           fg h jb
                                      c   => '0',           --  |           f ghj b
                                      d   => '1',           --              ppp kkk
                                      e   => '1',           --  |           e nml c
                                      f   => '1',           --  |           en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UM   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '1',           --  |\   /|     fg h jb
                                      c   => '1',           --  | \ / |     f ghj b
                                      d   => '0',           --              ppp kkk
                                      e   => '1',           --  |     |     e nml c
                                      f   => '1',           --  |     |     en m lc
                                      g   => '1',           --               ddddd  dp
                                      h   => '0',
                                      j   => '1',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UN   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '1',           --  |\    |     fg h jb
                                      c   => '1',           --  | \   |     f ghj b
                                      d   => '0',           --              ppp kkk
                                      e   => '1',           --  |   \ |     e nml c
                                      f   => '1',           --  |    \|     en m lc
                                      g   => '1',           --               ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '1',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UO   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '1',           --  |     |     f ghj b
                                      d   => '1',           --              ppp kkk
                                      e   => '1',           --  |     |     e nml c
                                      f   => '1',           --  |     |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UP   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '0',           --  |     |     f ghj b
                                      d   => '0',           --  --- ---     ppp kkk
                                      e   => '1',           --  |           e nml c
                                      f   => '1',           --  |           en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_UQ   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '1',           --  |     |     f ghj b
                                      d   => '1',           --              ppp kkk
                                      e   => '1',           --  |   \ |     e nml c
                                      f   => '1',           --  |    \|     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '1',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UR   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '0',           --  |     |     f ghj b
                                      d   => '0',           --  --- ---     ppp kkk
                                      e   => '1',           --  |   \       e nml c
                                      f   => '1',           --  |    \      en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '1',
                                      m   => '0',
                                      n   => '0',
                                      p   => '1',
                                      dp  => '0');
  constant c_14seg_US   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '0',           --   \          fg h jb
                                      c   => '1',           --    \         f ghj b
                                      d   => '1',           --      ---     ppp kkk
                                      e   => '0',           --        |     e nml c
                                      f   => '0',           --        |     en m lc
                                      g   => '1',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '1',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UT   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '0',           --     |        fg h jb
                                      c   => '0',           --     |        f ghj b
                                      d   => '0',           --              ppp kkk
                                      e   => '0',           --     |        e nml c
                                      f   => '0',           --     |        en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '1',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '1',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UU   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '1',           --  |     |     f ghj b
                                      d   => '1',           --              ppp kkk
                                      e   => '1',           --  |     |     e nml c
                                      f   => '1',           --  |     |     en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UV   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '0',           --  |    /      fg h jb
                                      c   => '0',           --  |   /       f ghj b
                                      d   => '0',           --              ppp kkk
                                      e   => '1',           --  | /         e nml c
                                      f   => '1',           --  |/          en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '1',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '1',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UW   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '1',           --  |     |     fg h jb
                                      c   => '1',           --  |     |     f ghj b
                                      d   => '0',           --              ppp kkk
                                      e   => '1',           --  | / \ |     e nml c
                                      f   => '1',           --  |/   \|     en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '1',
                                      m   => '0',
                                      n   => '1',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UX   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '0',           --   \   /      fg h jb
                                      c   => '0',           --    \ /       f ghj b
                                      d   => '0',           --              ppp kkk
                                      e   => '0',           --    / \       e nml c
                                      f   => '0',           --   /   \      en m lc
                                      g   => '1',           --               ddddd  dp
                                      h   => '0',
                                      j   => '1',
                                      k   => '0',
                                      l   => '1',
                                      m   => '0',
                                      n   => '1',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UY   : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '0',           --   \   /      fg h jb
                                      c   => '0',           --    \ /       f ghj b
                                      d   => '0',           --              ppp kkk
                                      e   => '0',           --     |        e nml c
                                      f   => '0',           --     |        en m lc
                                      g   => '1',           --               ddddd  dp
                                      h   => '0',
                                      j   => '1',
                                      k   => '0',
                                      l   => '0',
                                      m   => '1',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_UZ   : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '0',           --       /      fg h jb
                                      c   => '0',           --      /       f ghj b
                                      d   => '1',           --              ppp kkk
                                      e   => '0',           --    /         e nml c
                                      f   => '0',           --   /          en m lc
                                      g   => '0',           --   -----       ddddd  dp
                                      h   => '0',
                                      j   => '1',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '1',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_spce : t_14seg := (a   => '0',           --               aaaaa
                                      b   => '0',           --              fg h jb
                                      c   => '0',           --              f ghj b
                                      d   => '0',           --              ppp kkk
                                      e   => '0',           --              e nml c
                                      f   => '0',           --              en m lc
                                      g   => '0',           --               ddddd  dp
                                      h   => '0',
                                      j   => '0',
                                      k   => '0',
                                      l   => '0',
                                      m   => '0',
                                      n   => '0',
                                      p   => '0',
                                      dp  => '0');
  constant c_14seg_dflt : t_14seg := (a   => '1',           --   -----       aaaaa
                                      b   => '1',           --  |\ | /|     fg h jb
                                      c   => '1',           --  | \|/ |     f ghj b
                                      d   => '1',           --  --- ---     ppp kkk
                                      e   => '1',           --  | /|\ |     e nml c
                                      f   => '1',           --  |/ | \|     en m lc
                                      g   => '1',           --   -----  .    ddddd  dp
                                      h   => '1',
                                      j   => '1',
                                      k   => '1',
                                      l   => '1',
                                      m   => '1',
                                      n   => '1',
                                      p   => '1',
                                      dp  => '1');

  constant c_ascii_space : std_logic_vector(6 downto 0) := 7x"20";

  function convert_14seg (
    i_14seg_t : in  t_14seg
  ) return std_logic_vector;

  function get_ones (
    i_int : in integer
  ) return std_logic_vector;

  function get_tens (
    i_int : in integer
  ) return std_logic_vector;

end package display_14seg_package;

package body display_14seg_package is
  -- Converts 14 segment type to std_logic_vector
  function convert_14seg (
    i_14seg_t : in t_14seg
  ) return std_logic_vector is
    variable v_converted_14seg : std_logic_vector(14 downto 0);
  begin
    v_converted_14seg :=  i_14seg_t.dp  &
                          i_14seg_t.p   &
                          i_14seg_t.n   &
                          i_14seg_t.m   &
                          i_14seg_t.l   &
                          i_14seg_t.k   &
                          i_14seg_t.j   &
                          i_14seg_t.h   &
                          i_14seg_t.g   &
                          i_14seg_t.f   &
                          i_14seg_t.e   &
                          i_14seg_t.d   &
                          i_14seg_t.c   &
                          i_14seg_t.b   &
                          i_14seg_t.a;
    return v_converted_14seg;    
  end;

  function get_ones (
    i_int : in integer
  ) return std_logic_vector is
    variable v_ones : std_logic_vector(6 downto 0);
  begin
    v_ones := 7x"0" when ((i_int = 0) or (i_int = 10) or (i_int = 20) or (i_int = 30) or (i_int = 40) or (i_int = 50) or (i_int = 60) or (i_int = 70) or (i_int = 80) or (i_int = 90)) else
              7x"1" when ((i_int = 1) or (i_int = 11) or (i_int = 21) or (i_int = 31) or (i_int = 41) or (i_int = 51) or (i_int = 61) or (i_int = 71) or (i_int = 81) or (i_int = 91)) else
              7x"2" when ((i_int = 2) or (i_int = 12) or (i_int = 22) or (i_int = 32) or (i_int = 42) or (i_int = 52) or (i_int = 62) or (i_int = 72) or (i_int = 82) or (i_int = 92)) else
              7x"3" when ((i_int = 3) or (i_int = 13) or (i_int = 23) or (i_int = 33) or (i_int = 43) or (i_int = 53) or (i_int = 63) or (i_int = 73) or (i_int = 83) or (i_int = 93)) else
              7x"4" when ((i_int = 4) or (i_int = 14) or (i_int = 24) or (i_int = 34) or (i_int = 44) or (i_int = 54) or (i_int = 64) or (i_int = 74) or (i_int = 84) or (i_int = 94)) else
              7x"5" when ((i_int = 5) or (i_int = 15) or (i_int = 25) or (i_int = 35) or (i_int = 45) or (i_int = 55) or (i_int = 65) or (i_int = 75) or (i_int = 85) or (i_int = 95)) else
              7x"6" when ((i_int = 6) or (i_int = 16) or (i_int = 26) or (i_int = 36) or (i_int = 46) or (i_int = 56) or (i_int = 66) or (i_int = 76) or (i_int = 86) or (i_int = 96)) else
              7x"7" when ((i_int = 7) or (i_int = 17) or (i_int = 27) or (i_int = 37) or (i_int = 47) or (i_int = 57) or (i_int = 67) or (i_int = 77) or (i_int = 87) or (i_int = 97)) else
              7x"8" when ((i_int = 8) or (i_int = 18) or (i_int = 28) or (i_int = 38) or (i_int = 48) or (i_int = 58) or (i_int = 68) or (i_int = 78) or (i_int = 88) or (i_int = 98)) else
              7x"9" when ((i_int = 9) or (i_int = 19) or (i_int = 29) or (i_int = 39) or (i_int = 49) or (i_int = 59) or (i_int = 69) or (i_int = 79) or (i_int = 89) or (i_int = 99)) else
              7x"E";
    return v_ones;
  end;

  function get_tens (
    i_int : in integer
  ) return std_logic_vector is
    variable v_tens : std_logic_vector(6 downto 0);
  begin
    v_tens := 7x"0" when (i_int < 10) else
              7x"1" when (i_int >= 10 and i_int < 20) else
              7x"2" when (i_int >= 20 and i_int < 30) else
              7x"3" when (i_int >= 30 and i_int < 40) else
              7x"4" when (i_int >= 40 and i_int < 50) else
              7x"5" when (i_int >= 50 and i_int < 60) else
              7x"6" when (i_int >= 60 and i_int < 70) else
              7x"7" when (i_int >= 70 and i_int < 80) else
              7x"8" when (i_int >= 80 and i_int < 90) else
              7x"9" when (i_int >= 90 and i_int < 100) else
              7x"E";
    return v_tens;
  end;
end package body display_14seg_package;
