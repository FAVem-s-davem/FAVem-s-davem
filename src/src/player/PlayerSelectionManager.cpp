#include "PlayerSelectionManager.hpp"

#include <godot_cpp/core/object.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void PlayerSelectionManager::_bind_methods() {}

void PlayerSelectionManager::_ready() {
    owner = Object::cast_to<Player>(get_parent());

    if (owner != nullptr) {
        selection = owner->get_selection();
    }

    set_process_input(true);
}

void PlayerSelectionManager::_input(const Ref<InputEvent> &event) {

    Ref<InputEventMouseButton> mb = event;

    if (mb.is_valid() && mb->get_button_index() == MouseButton::MOUSE_BUTTON_LEFT) {

        if (mb->is_pressed()) {
            dragging = true;
            drag_start = get_global_mouse_position();
        } else {
            dragging = false;
            drag_end = get_global_mouse_position();

            Rect2 rect(drag_start, drag_end - drag_start);
            rect = rect.abs();

            Array units = get_units_inside(rect);

            std::vector<ISelectable *> vec;

            for (int i = 0; i < units.size(); i++) {
                Student *s = Object::cast_to<Student>(units[i]);
                if (s)
                    vec.push_back(s);
            }

            bool shift = Input::get_singleton()->is_key_pressed(KEY_SHIFT);

            if (shift)
                selection->Add(vec);
            else
                selection->Select(vec);

            queue_redraw();
        }
    }

    Ref<InputEventMouseMotion> mm = event;

    if (mm.is_valid() && dragging) {
        drag_end = get_global_mouse_position();
        queue_redraw();
    }
}

void PlayerSelectionManager::_draw() {

    if (!dragging)
        return;

    Vector2 local_start = to_local(drag_start);
    Vector2 local_end = to_local(drag_end);

    Rect2 rect(local_start, local_end - local_start);
    rect = rect.abs();

    draw_rect(rect, Color(0, 1, 0, 0.2), true);
    draw_rect(rect, Color(0, 1, 0), false, 2.0);
}

Array PlayerSelectionManager::get_units_inside(const Rect2 &rect) {

    Array result;

    Array nodes = get_tree()->get_nodes_in_group("selectable_units");

    for (int i = 0; i < nodes.size(); i++) {

        Node *node = Object::cast_to<Node>(nodes[i]);
        Student *student = Object::cast_to<Student>(node);

        if (!student)
            continue;

        if (rect.has_point(student->get_global_position())) {
            result.append(student);
        }
    }

    return result;
}
