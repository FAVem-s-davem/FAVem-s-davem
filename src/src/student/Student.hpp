#pragma once

#include "../ISelectable.hpp"
#include "../player/Player.hpp"

#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

class Student : public CharacterBody2D, public ISelectable {
    GDCLASS(Student, CharacterBody2D);

  public:
    Student();
    ~Student();

    void _ready() override;
    void _physics_process(double delta) override;

    void Select(Player *player) override;
    void Deselect() override;

  protected:
    static void _bind_methods();

  private:
    Player *player = nullptr;

    float max_speed = 200.0f;
    float acceleration = 500.0f;
    float friction = 100.0f;

    void Highlight();
    void UnHighlight();

  public:

    void set_max_speed(float v);
    float get_max_speed() const;

    void set_acceleration(float v);
    float get_acceleration() const;

    void set_friction(float v);
    float get_friction() const;
};
