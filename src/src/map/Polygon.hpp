#include "godot_cpp/classes/node2d.hpp"
#include "godot_cpp/variant/color.hpp"
#include "godot_cpp/variant/vector2.hpp"
#include <string>
#include <vector>
class Polygon {
  public:
    static Polygon from_svg_polygon(std::string svg_tag);
    // static Polygon from_svg_circle(std::string svg_tag);
    // static Polygon from_svg_path(std::string svg_tag);

    Polygon();
    ~Polygon();

    void add_vertex(godot::Vector2 vertex);

    std::vector<godot::Vector2> get_vertices();

    void draw(godot::Node2D *drawer);

    void set_color(godot::Color color);

    void set_pen_width(int width);

  private:
    std::vector<godot::Vector2> vertices;

    godot::Color color;

    int pen_width;
};
