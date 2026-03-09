#include "Student.hpp"

#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

Student::Student() {}
Student::~Student() {}

void Student::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_max_speed", "v"), &Student::set_max_speed);
    ClassDB::bind_method(D_METHOD("get_max_speed"), &Student::get_max_speed);

    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "max_speed"), "set_max_speed", "get_max_speed");
}

void Student::_ready() { add_to_group("selectable_units"); }

void Student::_physics_process(double delta) {

    Vector2 input_direction;

    if (player != nullptr) {

        Vector2 to_player = player->get_global_position() - get_global_position();
        float dist = to_player.length();

        if (dist > player->get_deselect_ring()) {
            Deselect();
        } else if (dist > player->get_stop_ring()) {

            input_direction = to_player.normalized();

            if (dist > player->get_catchup_ring()) {
                input_direction *= 1.5;
            }
        } else if (dist < player->get_stop_ring()) {

            input_direction = -1.5 * (1 - dist / player->get_stop_ring()) * to_player.normalized();
        }
    }

    Vector2 target_velocity = input_direction * max_speed;

    Vector2 velocity = get_linear_velocity();

    velocity = velocity.move_toward(target_velocity, acceleration * (float)delta);

    set_linear_velocity(velocity);
}

void Student::Select(Player *p) {
    player = p;
    Highlight();
}

void Student::Deselect() {

    if (player != nullptr) {
        // player->get_selection()->Deselect(this);
        player = nullptr;
    }

    UnHighlight();
}

void Student::Highlight() {

    auto *sprite = Object::cast_to<Sprite2D>(get_node_or_null("StudentSprite"));

    if (sprite != nullptr) {
        sprite->set_modulate(Color(1, 0.6, 0.6));
    }
}

void Student::UnHighlight() {

    auto *sprite = Object::cast_to<Sprite2D>(get_node_or_null("StudentSprite"));

    if (sprite != nullptr) {
        sprite->set_modulate(Color(1, 1, 1));
    }
}

void Student::set_max_speed(float v) { max_speed = v; }
float Student::get_max_speed() const { return max_speed; }

void Student::set_acceleration(float v) { acceleration = v; }
float Student::get_acceleration() const { return acceleration; }

void Student::set_friction(float v) { friction = v; }
float Student::get_friction() const { return friction; }
