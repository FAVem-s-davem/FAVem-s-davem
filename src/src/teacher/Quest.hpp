#pragma once

#include "../student/StudentTypes.hpp"
#include "godot_cpp/variant/utility_functions.hpp"
#include <array>
#include <random>

struct Quest {
    std::array<int, STUDENT_TYPE_COUNT> StudentTypeCounts;

    Quest() {
        static std::random_device rd;
        static std::mt19937 gen(rd());
        std::uniform_int_distribution<int> dist(0, 2); // range: 0–10

        for (auto &count : StudentTypeCounts) {
            count = dist(gen);
            godot::UtilityFunctions::print("Quest count: ", count);
        }
    }

    bool IsComplete() {
        for (int type : StudentTypeCounts) {
            if (type > 0) {
                return false;
            }
        }
        return true;
    }
};
