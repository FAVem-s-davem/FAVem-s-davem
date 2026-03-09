#pragma once

#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/rigid_body2d.hpp>
#include <godot_cpp/variant/vector2.hpp>

using namespace godot;

class SelectionManager; // forward declaration

class Player : public RigidBody2D {
    GDCLASS(Player, RigidBody2D);

  private:
    float max_speed = 300.0f;
    float acceleration = 500.0f;
    float friction = 400.0f;

    float deselect_ring = 300.0f;
    float catchup_ring = 150.0f;
    float stop_ring = 100.0f;

    SelectionManager *selection = nullptr;

  protected:
    static void _bind_methods();

  public:
    Player();
    ~Player();

    void _enter_tree() override;
    void _physics_process(double delta) override;
    void _draw() override;
    void _ready() override;

    void set_max_speed(float v);
    float get_max_speed() const;

    void set_acceleration(float v);
    float get_acceleration() const;

    void set_friction(float v);
    float get_friction() const;

    float get_deselect_ring();
    float get_catchup_ring();
    float get_stop_ring();

    SelectionManager *get_selection();
};
