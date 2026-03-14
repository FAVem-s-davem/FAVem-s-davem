#include "Student.hpp"

#include "../player/SelectionManager.hpp"

#include <algorithm> // for std::find
#include <godot_cpp/classes/dir_access.hpp>
#include <godot_cpp/classes/kinematic_collision2d.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

Student::Student() {}
Student::~Student() {}

void Student::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_max_speed", "v"), &Student::set_max_speed);
    ClassDB::bind_method(D_METHOD("get_max_speed"), &Student::get_max_speed);

    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "max_speed"), "set_max_speed", "get_max_speed");
}

void Student::_ready() {
    set_motion_mode(MOTION_MODE_FLOATING);
    add_to_group("selectable_units");

    // Assign random student icon, this whole block is made by ai to just scan the directory
    // and assign a random icon to the student, this will be done differently in future
    // and the student objects will be marked with what type they are etc
    {

        Ref<DirAccess> dir = DirAccess::open("res://assets/student_icons/");
        if (dir != nullptr) {
            dir->list_dir_begin();
            String file_name = dir->get_next();
            std::vector<String> valid_icons;

            while (file_name != "") {
                // We only look for standard imported texture ends, usually .png or .png.import in
                // run-time
                if (file_name.ends_with(".png") || file_name.ends_with(".png.import")) {
                    String clean_name = file_name.replace(".import", "");
                    if (std::find(valid_icons.begin(), valid_icons.end(), clean_name) ==
                        valid_icons.end()) {
                        valid_icons.push_back(clean_name);
                    }
                }
                file_name = dir->get_next();
            }

            if (!valid_icons.empty()) {
                int random_index = UtilityFunctions::randi() % valid_icons.size();
                String chosen_file = valid_icons[random_index];

                Ref<Texture2D> tex = ResourceLoader::get_singleton()->load(
                    "res://assets/student_icons/" + chosen_file);

                auto *sprite = Object::cast_to<Sprite2D>(get_node_or_null("Sprite2D"));
                if (sprite != nullptr && tex.is_valid()) {
                    sprite->set_texture(tex);

                    // Assuming icons are larger, we scale them down to roughly match the old 32x32
                    // gradient
                    float scale_factor =
                        32.0f / (float)std::max(tex->get_width(), tex->get_height());
                    sprite->set_scale(Vector2(scale_factor, scale_factor));
                }
            }
        }
    }
}

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

    Vector2 velocity = get_velocity();

    velocity = velocity.move_toward(target_velocity, acceleration * (float)delta);

    set_velocity(velocity);
    move_and_slide();

    for (int i = 0; i < get_slide_collision_count(); i++) {
        Ref<KinematicCollision2D> collision = get_slide_collision(i);
        CharacterBody2D *collider = Object::cast_to<CharacterBody2D>(collision->get_collider());

        if (collider != nullptr && collider->is_in_group("selectable_units")) {
            Vector2 push_dir = -collision->get_normal();
            // Softer push for students pushing other bodies
            Vector2 their_velocity = collider->get_velocity();
            collider->set_velocity(their_velocity.lerp(push_dir * 100.0f, 0.1f));
        }
    }
}

void Student::Select(Player *p) {
    player = p;
    Highlight();
}

void Student::Deselect() {

    if (player != nullptr) {
        player->get_selection()->Deselect(this);
        player = nullptr;
    }

    UnHighlight();
}

void Student::Highlight() {

    auto *sprite = Object::cast_to<Sprite2D>(get_node_or_null("Sprite2D"));

    if (sprite != nullptr) {
        sprite->set_modulate(Color(1, 0.6, 0.6));
    }
}

void Student::UnHighlight() {

    auto *sprite = Object::cast_to<Sprite2D>(get_node_or_null("Sprite2D"));

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
