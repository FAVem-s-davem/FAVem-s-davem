#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/godot.hpp>

#include "gameScene/GameScene.hpp"
#include "map/MapObject.hpp"
#include "player/Player.hpp"
#include "player/PlayerSelectionManager.hpp"
#include "player/SelectionManager.hpp"
#include "student/Student.hpp"

using namespace godot;

void initialize_player_module(ModuleInitializationLevel level) {
    if (level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    ClassDB::register_class<Player>();
    ClassDB::register_class<PlayerSelectionManager>();
    ClassDB::register_class<Student>();
    ClassDB::register_class<MapObject>();
    ClassDB::register_class<GameScene>();
}

void uninitialize_player_module(ModuleInitializationLevel level) {
    if (level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

extern "C" {

GDExtensionBool GDE_EXPORT example_library_init(GDExtensionInterfaceGetProcAddress addr,
                                                GDExtensionClassLibraryPtr library,
                                                GDExtensionInitialization *init) {
    GDExtensionBinding::InitObject init_obj(addr, library, init);

    init_obj.register_initializer(initialize_player_module);
    init_obj.register_terminator(uninitialize_player_module);
    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}
}
