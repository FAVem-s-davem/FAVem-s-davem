#pragma once

#include "../player/Player.hpp"
#include "../student/Student.hpp"
#include "SelectionManager.hpp"

#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/classes/input_event_mouse_button.hpp>
#include <godot_cpp/classes/input_event_mouse_motion.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

class PlayerSelectionManager : public Node2D {
    GDCLASS(PlayerSelectionManager, Node2D);

  public:
    void _ready() override;
    void _input(const Ref<InputEvent> &event) override;
    void _draw() override;

  protected:
    static void _bind_methods();

  private:
    Player *owner = nullptr;
    SelectionManager *selection = nullptr;

    bool dragging = false;
    Vector2 drag_start;
    Vector2 drag_end;

    Array get_units_inside(const Rect2 &rect);
};
