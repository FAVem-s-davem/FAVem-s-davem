#pragma once

#include "godot_cpp/variant/string.hpp"

enum class StudentTypes {
    MATH,
    CS,
    COUNT,
};

inline godot::String StudentTypeToString(StudentTypes type) {
    switch (type) {
    case StudentTypes::MATH:
        return "math";
    case StudentTypes::CS:
        return "cs";
    default:
        return "unknown";
    }
}

constexpr int STUDENT_TYPE_COUNT = static_cast<int>(StudentTypes::COUNT);
