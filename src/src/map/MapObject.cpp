#include "MapObject.hpp"

#include <godot_cpp/classes/collision_shape2d.hpp>
#include <godot_cpp/classes/segment_shape2d.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void MapObject::_bind_methods() {
    ClassDB::bind_method(D_METHOD("Init", "polygon"), &MapObject::Init);
}

void MapObject::Init(const String &poly) {
    polygon = Polygon::from_svg_polygon(poly.utf8().get_data());
}

void MapObject::_ready() {

    create_walls();
    queue_redraw();
}

void MapObject::create_walls() {
    auto vertices = polygon.get_vertices();

    int size = vertices.size();

    for (int i = 0; i < size; i++) {

        Vector2 a = vertices[i];
        Vector2 b = vertices[(i + 1) % size];

        SegmentShape2D *shape = memnew(SegmentShape2D);
        shape->set_a(a);
        shape->set_b(b);

        CollisionShape2D *collision = memnew(CollisionShape2D);
        collision->set_shape(shape);

        add_child(collision);
    }
}

void MapObject::_draw() { polygon.draw(this); }
