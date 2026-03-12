#pragma once

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/packed_scene.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <string>
#include <vector>

using namespace godot;

class GameScene : public Node2D {
    GDCLASS(GameScene, Node2D);

  private:
    Ref<PackedScene> student_scene;
    Ref<PackedScene> player_scene;
    Ref<PackedScene> map_scene;

  protected:
    static void _bind_methods();

  public:
    void _ready() override;

  private:
    void spawn_player();
    void spawn_students(int count);
    void spawn_map();

  public:
    void set_student_scene(const Ref<PackedScene> &scene);
    Ref<PackedScene> get_student_scene() const;

    void set_player_scene(const Ref<PackedScene> &scene);
    Ref<PackedScene> get_player_scene() const;

    void set_map_scene(const Ref<PackedScene> &scene);
    Ref<PackedScene> get_map_scene() const;
};
