#pragma once

#include <godot_cpp/classes/static_body2d.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>

using namespace godot;

class MapObject : public StaticBody2D {
    GDCLASS(MapObject, StaticBody2D);

  private:
    PackedVector2Array polygon;

  protected:
    static void _bind_methods();

  public:
    void Init(const PackedVector2Array &poly);

    void _ready() override;
    void _draw() override;

  private:
    void create_walls();
};
