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

  function convert_14seg (
    i_14seg_t : in  t_14seg) 
    return std_logic_vector;

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
end package body display_14seg_package;
