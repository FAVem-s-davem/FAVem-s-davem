#pragma once

#include "godot_cpp/classes/area2d.hpp"
#include "godot_cpp/classes/node2d.hpp"
#include "godot_cpp/classes/wrapped.hpp"
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/node.hpp>

#include "Quest.hpp"

using namespace godot;

class Teacher : public CharacterBody2D {
    GDCLASS(Teacher, CharacterBody2D);

  public:
    Teacher();
    ~Teacher();

    void _ready() override;

    Quest quest;

    void set_range(float r);
    float get_range();

    void _draw() override;

  protected:
    static void _bind_methods();

  private:
    float range = 64.0f;

    Area2D *detection_area = nullptr;

    void _on_body_entered(Node2D *body);
};
