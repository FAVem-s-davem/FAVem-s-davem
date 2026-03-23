#include "Teacher.hpp"
#include "../student/Student.hpp"
#include <godot_cpp/classes/node.hpp>

#include "godot_cpp/classes/circle_shape2d.hpp"
#include "godot_cpp/classes/collision_shape2d.hpp"
#include "godot_cpp/variant/utility_functions.hpp"
#include <godot_cpp/variant/node_path.hpp>

using namespace godot;

Teacher::Teacher() {}
Teacher::~Teacher() {}

void Teacher::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_on_body_entered", "body"), &Teacher::_on_body_entered);

    // 🔥 Expose setter/getter
    ClassDB::bind_method(D_METHOD("set_range", "range"), &Teacher::set_range);
    ClassDB::bind_method(D_METHOD("get_range"), &Teacher::get_range);

    // 🔥 Add property
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "range"), "set_range", "get_range");
}

void Teacher::_ready() {
    detection_area = Object::cast_to<Area2D>(get_node<Area2D>(NodePath("DetectionArea")));
    CollisionShape2D *shape_node = detection_area->get_node<CollisionShape2D>("CollisionShape2D");
    Ref<CircleShape2D> shape = shape_node->get_shape();
    shape->set_radius(range); // your desired range
                              //
    if (detection_area) {
        detection_area->connect("body_entered", Callable(this, "_on_body_entered"));
    } else {
        UtilityFunctions::print("DetectionArea not found!");
    }
}

void Teacher::_on_body_entered(Node2D *body) {
    if (!body) {
        return;
    }

    Student *student = Object::cast_to<Student>(body);
    if (!student) {
        return;
    }

    // Prevent double processing
    if (student->has_meta("collected")) {
        return;
    }
    student->set_meta("collected", true);

    int index = static_cast<int>(student->type);

    if (quest.StudentTypeCounts[index] > 0) {
        quest.StudentTypeCounts[index] -= 1;

        UtilityFunctions::print("Collected type ", index,
                                " remaining: ", quest.StudentTypeCounts[index]);

        student->Deselect();
        student->queue_free();
    } else {
        UtilityFunctions::print("Type not needed!");
        return;
    }

    // 🔥 Check completion AFTER successful collection
    if (quest.IsComplete()) {
        UtilityFunctions::print("Quest complete!");
        queue_free();
    }
}

void Teacher::_draw() {

    Vector2 center = Vector2(0, 0);

    draw_circle(center, range, Color(0.9, 0.9, 0.9), false, 1.0);
}

void Teacher::set_range(float r) { range = r; }

float Teacher::get_range() { return range; }
