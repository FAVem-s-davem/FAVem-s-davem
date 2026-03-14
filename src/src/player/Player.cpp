#include "Player.hpp"
#include "SelectionManager.hpp"

#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/vector2.hpp>

#include <godot_cpp/classes/kinematic_collision2d.hpp>

using namespace godot;

Player::Player() {}
Player::~Player() {}

void Player::_bind_methods() {

    // ClassDB::bind_method(D_METHOD("_physics_process", "delta"), &Player::_physics_process);
    // ClassDB::bind_method(D_METHOD("_draw"), &Player::_draw);

    ClassDB::bind_method(D_METHOD("set_max_speed", "value"), &Player::set_max_speed);
    ClassDB::bind_method(D_METHOD("get_max_speed"), &Player::get_max_speed);

    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "max_speed"), "set_max_speed", "get_max_speed");
}

void Player::_enter_tree() {
    selection = new SelectionManager(this);
    set_physics_process(true);
}

void Player::_ready() {
    set_motion_mode(MOTION_MODE_FLOATING);
    set_physics_process(true);
    UtilityFunctions::print("Player ready");
}

void Player::_physics_process(double delta) {
    Input *input = Input::get_singleton();

    Vector2 dir;

    if (input->is_key_pressed(KEY_W))
        dir.y -= 1;
    if (input->is_key_pressed(KEY_S))
        dir.y += 1;
    if (input->is_key_pressed(KEY_A))
        dir.x -= 1;
    if (input->is_key_pressed(KEY_D))
        dir.x += 1;

    dir = dir.normalized();

    Vector2 target_velocity = dir * max_speed;
    Vector2 velocity = get_velocity();

    velocity = velocity.move_toward(target_velocity, acceleration * (float)delta);

    set_velocity(velocity);
    move_and_slide();

    for (int i = 0; i < get_slide_collision_count(); i++) {
        Ref<KinematicCollision2D> collision = get_slide_collision(i);
        CharacterBody2D *collider = Object::cast_to<CharacterBody2D>(collision->get_collider());

        if (collider != nullptr && collider->is_in_group("selectable_units")) {
            Vector2 push_dir = -collision->get_normal();
            // Give them a gentle, bounded push in the direction instead of continuously adding force
            Vector2 their_velocity = collider->get_velocity();
            collider->set_velocity(their_velocity.lerp(push_dir * 200.0f, 0.2f));
        }
    }
}

void Player::_draw() {

    Vector2 center = Vector2(0, 0);

    draw_circle(center, deselect_ring, Color(0.3, 0.3, 0.3), false, 1.0);
    draw_circle(center, catchup_ring, Color(0.3, 0.3, 0.3), false, 1.0);
    draw_circle(center, stop_ring, Color(0.3, 0.3, 0.3), false, 1.0);
}

void Player::set_max_speed(float v) { max_speed = v; }
float Player::get_max_speed() const { return max_speed; }

void Player::set_acceleration(float v) { acceleration = v; }
float Player::get_acceleration() const { return acceleration; }

void Player::set_friction(float v) { friction = v; }
float Player::get_friction() const { return friction; }

float Player::get_deselect_ring() { return deselect_ring; }
float Player::get_catchup_ring() { return catchup_ring; }
float Player::get_stop_ring() { return stop_ring; }

SelectionManager *Player::get_selection() { return selection; }
