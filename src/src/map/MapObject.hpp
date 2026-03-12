#pragma once

#include <godot_cpp/classes/static_body2d.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <string>

#include "Polygon.hpp"

using namespace godot;

class MapObject : public StaticBody2D {
    GDCLASS(MapObject, StaticBody2D);

  private:
    Polygon polygon;

  protected:
    static void _bind_methods();

  public:
    void Init(const String &poly);

    void _ready() override;
    void _draw() override;

  private:
    void create_walls();
};
