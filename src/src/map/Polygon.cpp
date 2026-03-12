#include "Polygon.hpp"
#include "godot_cpp/classes/node2d.hpp"
#include "godot_cpp/variant/color.hpp"
#include "godot_cpp/variant/vector2.hpp"
#include <regex>
#include <utility>
#include <vector>

using namespace godot;

void Polygon::add_vertex(godot::Vector2 vertex) { this->vertices.push_back(vertex); }

std::vector<godot::Vector2> Polygon::get_vertices() { return this->vertices; }

void Polygon::draw(Node2D *drawer) {
    int size = this->vertices.size();

    for (int i = 0; i < size; i++) {

        drawer->draw_line(this->vertices[i], this->vertices[(i + 1) % size], this->color,
                          this->pen_width);
    }
}

Polygon::Polygon() {
    this->vertices = {};
    this->color = Color("#FFFFFF");
    this->pen_width = 1;
}

Polygon::~Polygon() = default;

Polygon Polygon::from_svg_polygon(std::string svg_tag) {
    Polygon poly;

    std::smatch match;

    // -------- Extract points --------
    std::regex points_regex("points\\s*=\\s*\"([^\"]+)\"");

    if (std::regex_search(svg_tag, match, points_regex)) {

        std::string points_str = match[1];

        std::stringstream ss(points_str);
        std::string pair;

        while (ss >> pair) {

            size_t comma = pair.find(',');

            if (comma != std::string::npos) {

                float x = std::stof(pair.substr(0, comma));
                float y = std::stof(pair.substr(comma + 1));

                poly.add_vertex(Vector2(x, y));
            }
        }
    }

    // -------- Extract stroke color --------
    std::regex stroke_regex("stroke\\s*=\\s*\"([^\"]+)\"");

    if (std::regex_search(svg_tag, match, stroke_regex)) {

        std::string color = match[1];

        if (!color.empty() && color[0] == '#') {

            int r = std::stoi(color.substr(1, 2), nullptr, 16);
            int g = std::stoi(color.substr(3, 2), nullptr, 16);
            int b = std::stoi(color.substr(5, 2), nullptr, 16);

            poly.color = Color(r / 255.0, g / 255.0, b / 255.0);
        }
    }

    // -------- Extract stroke width --------
    std::regex width_regex("stroke-width\\s*=\\s*\"([^\"]+)\"");

    if (std::regex_search(svg_tag, match, width_regex)) {
        poly.pen_width = std::stof(match[1]);
    }

    return poly;
}
