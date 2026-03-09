#include "MapObject.hpp"

#include <godot_cpp/classes/collision_shape2d.hpp>
#include <godot_cpp/classes/segment_shape2d.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void MapObject::_bind_methods() {
    ClassDB::bind_method(D_METHOD("Init", "polygon"), &MapObject::Init);
}

void MapObject::Init(const PackedVector2Array &poly) { polygon = poly; }

void MapObject::_ready() {
    if (polygon.is_empty())
        return;

    create_walls();
    queue_redraw();
}

void MapObject::create_walls() {

    int size = polygon.size();

    for (int i = 0; i < size; i++) {

        Vector2 a = polygon[i];
        Vector2 b = polygon[(i + 1) % size];

        SegmentShape2D *shape = memnew(SegmentShape2D);
        shape->set_a(a);
        shape->set_b(b);

        CollisionShape2D *collision = memnew(CollisionShape2D);
        collision->set_shape(shape);

        add_child(collision);
    }
}

void MapObject::_draw() {

    if (polygon.is_empty())
        return;

    int size = polygon.size();

    for (int i = 0; i < size; i++) {

        draw_line(polygon[i], polygon[(i + 1) % size], Color(1, 0, 0), 5);
    }
}
