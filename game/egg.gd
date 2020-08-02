# vim:ts=4:et:tw=80:sw=4:ai:si
#/**********************************************************************
#    Happy Mrs Chicken
#    Copyright (C) 2019-2020 Todd Harbour (Krayon)
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License
#    version 2 ONLY, as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program, in the file COPYING or COPYING.txt; if
#    not, see http://www.gnu.org/licenses/ , or write to:
#      The Free Software Foundation, Inc.,
#      51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# **********************************************************************/

extends Node2D;

var mummy = null;
var dead  = true;

func _ready(): #{
    # Called when the node is added to the scene for the first time.
    # Initialization here
    pass;
#}

func _process(delta): #{
    # Called every frame. Delta is time since last frame.
    # Update game logic here.

    if (dead): return;
#}

func lay(owner, pos): #{
    if (dead == false): return false;
    dead = false;

    # Egg is lay(ed/ing), find an audio stream
    get_tree().get_root().get_node("root").play_lay_sound_at_loc(pos);

    self.mummy = owner;
    self.visible = true;
    self.position = pos;

    return true;
#}
