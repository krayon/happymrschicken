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

const FRAME_MCLC   = 0;
const FRAME_MOLC   = 1;
const FRAME_MCLO   = 2;
const FRAME_MOLO   = 3;
const FRAME_OFF_LO = 2; # Number to add to frame for legs open
const FRAME_COUNT  = 2; # Number of frames total (not counting legs open)

const TIME_ANIM = 0.6;
const TIME_MOVE = 1.0;
const TIME_LAY  = 0.6;

var _lastmove   = 0.0;
var _lastanim   = 0.0;
var _donelaying = 0.0;

var laying = false;

func _ready(): #{
    self.z_index = 1;
    $AnimatedSprite.set_frame(FRAME_MCLC);
#}

func _process(delta): #{
    # Called every frame. Delta is time since last frame.
    # Update game logic here.

    if (_donelaying > 0.0): #{
        _donelaying -= delta;
        $AnimatedSprite.set_position(Vector2(0, -(TIME_LAY - _donelaying) * ($Area2D/CollisionShape2D.shape.get_extents()[1] *2)));
        if (_donelaying <= 0.0): #{
            # We'll do this on next move instead
            #self.z_index = 0;
            #$AnimatedSprite.set_position(Vector2(0, 0));
            laying = false;
            _lastmove = TIME_MOVE;
            _animate_frame_rand();
        #}
    #}

    if (_lastanim < TIME_ANIM): #{
        _lastanim += delta;

    else: #} {
        # Animate
        _lastanim -= TIME_ANIM;
        _animate_frame_rand();
    #}

    if (!laying): #{
        if (_lastmove < TIME_MOVE): #{
            _lastmove += delta;

        else: #} {
            # Move

            # Now always 1
            #self.z_index = 0;

            $AnimatedSprite.set_position(Vector2(0, 0));
            _move_to_loc_rand();
        #}
    #}
#}

func _animate_frame_rand(): #{
    var from = $AnimatedSprite.frame;
    var to   = (randi() % FRAME_COUNT);
    if (to % 2 == 1): #{
        if (!$squark.playing): $squark.play();
    #}
    if (laying): to += FRAME_OFF_LO;
    $AnimatedSprite.set_frame(to);
    var now  = $AnimatedSprite.frame;

    if (OS.is_debug_build()): print("ANIMATE: ", from, " --> ", to, " --> ", now);
#}

func lay(): #{
    if (laying): return;

    laying = true;
    # Now always 1
    #self.z_index = 1;
    _animate_frame_rand();
    _donelaying = TIME_LAY;
    $AnimatedSprite.set_position(Vector2(0, -(TIME_LAY - _donelaying) * ($Area2D/CollisionShape2D.shape.get_extents()[1])));

    #    if (OS.is_debug_build()): print(node.get_node("Area2D/CollisionShape2D"));
    #    sprite_extends = node.get_node("Area2D/CollisionShape2D").shape.get_extents();

    var egg = get_tree().get_root().get_node("root/egg").duplicate();
    get_tree().get_root().add_child(egg);
    if (egg.lay(self, self.global_position)): #{
        # Layed
        if (OS.is_debug_build()): print("LAYED");
        get_tree().get_root().get_node("root").score += 1;
    #}
#}

func move_to_loc(location): #{
    _lastmove -= TIME_MOVE;
    self.set_position(location);
#}

func _move_to_loc_rand(): #{
    _lastmove -= TIME_MOVE;
    self.get_parent().move_to_loc_rand(self);
#}
