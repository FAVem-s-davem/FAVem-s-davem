#include "GameScene.hpp"

#include "../map/MapObject.hpp"
#include "../player/Player.hpp"
#include "../student/Student.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/object.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_key.hpp>

using namespace godot;

void GameScene::_bind_methods() {

    ClassDB::bind_method(D_METHOD("set_student_scene", "scene"), &GameScene::set_student_scene);
    ClassDB::bind_method(D_METHOD("get_student_scene"), &GameScene::get_student_scene);

    ClassDB::bind_method(D_METHOD("set_player_scene", "scene"), &GameScene::set_player_scene);
    ClassDB::bind_method(D_METHOD("get_player_scene"), &GameScene::get_player_scene);

    ClassDB::bind_method(D_METHOD("set_map_scene", "scene"), &GameScene::set_map_scene);
    ClassDB::bind_method(D_METHOD("get_map_scene"), &GameScene::get_map_scene);

    ADD_PROPERTY(
        PropertyInfo(Variant::OBJECT, "StudentScene", PROPERTY_HINT_RESOURCE_TYPE, "PackedScene"),
        "set_student_scene", "get_student_scene");

    ADD_PROPERTY(
        PropertyInfo(Variant::OBJECT, "PlayerScene", PROPERTY_HINT_RESOURCE_TYPE, "PackedScene"),
        "set_player_scene", "get_player_scene");

    ADD_PROPERTY(
        PropertyInfo(Variant::OBJECT, "MapScene", PROPERTY_HINT_RESOURCE_TYPE, "PackedScene"),
        "set_map_scene", "get_map_scene");
}

void GameScene::_input(const Ref<InputEvent> &event){

    Ref<InputEventKey> key_event = event;
    if (key_event.is_valid() && key_event->is_pressed() && !key_event->is_echo() && key_event->get_keycode() == KEY_G) {
        Node *node = student_scene->instantiate();
        Student *student = Object::cast_to<Student>(node);

        student->set_global_position(get_global_mouse_position());
        add_child(student);
    }
}

void GameScene::_ready() {

    if (student_scene.is_null()) {
        UtilityFunctions::print("StudentScene not assigned");
        return;
    }

    if (player_scene.is_null()) {
        UtilityFunctions::print("PlayerScene not assigned");
        return;
    }

    if (map_scene.is_null()) {
        UtilityFunctions::print("MapScene not assigned");
        return;
    }

    spawn_students(10);
    spawn_player();

    Node *node = map_scene->instantiate();
    MapObject *map = Object::cast_to<MapObject>(node);

    if (!map) {
        UtilityFunctions::print("MapScene root is not MapObject");
        return;
    }

    PackedVector2Array poly;
    poly.push_back(Vector2(0, 0));
    poly.push_back(Vector2(700, 0));
    poly.push_back(Vector2(700, 200));
    poly.push_back(Vector2(500, 200));
    poly.push_back(Vector2(500, 500));
    poly.push_back(Vector2(700, 500));
    poly.push_back(Vector2(700, 700));
    poly.push_back(Vector2(0, 700));

    map->Init(poly);
    add_child(map);

    Node *node2 = map_scene->instantiate();
    MapObject *map2 = Object::cast_to<MapObject>(node2);

    if (!map2) {
        UtilityFunctions::print("MapScene root is not MapObject");
        return;
    }

    PackedVector2Array poly2;
    poly2.push_back(Vector2(100, 100));
    poly2.push_back(Vector2(200, 100));
    poly2.push_back(Vector2(200, 200));
    poly2.push_back(Vector2(100, 200));

    map2->Init(poly2);
    add_child(map2);
}

void GameScene::spawn_player() {

    Node *node = player_scene->instantiate();
    Player *player = Object::cast_to<Player>(node);

    if (!player) {
        UtilityFunctions::print("PlayerScene root is not Player");
        return;
    }

    player->set_global_position(Vector2(100, 100));
    add_child(player);
}

void GameScene::spawn_students(int count) {

    for (int i = 0; i < count; i++) {

        Node *node = student_scene->instantiate();
        Student *student = Object::cast_to<Student>(node);

        if (!student) {
            UtilityFunctions::print("StudentScene root is not Student");
            return;
        }

        student->set_global_position(
            Vector2(UtilityFunctions::randf_range(0, 1100), UtilityFunctions::randf_range(0, 600)));

        add_child(student);
    }
}

void GameScene::set_student_scene(const Ref<PackedScene> &scene) { student_scene = scene; }
Ref<PackedScene> GameScene::get_student_scene() const { return student_scene; }

void GameScene::set_player_scene(const Ref<PackedScene> &scene) { player_scene = scene; }
Ref<PackedScene> GameScene::get_player_scene() const { return player_scene; }

void GameScene::set_map_scene(const Ref<PackedScene> &scene) { map_scene = scene; }
Ref<PackedScene> GameScene::get_map_scene() const { return map_scene; }
