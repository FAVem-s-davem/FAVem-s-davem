#include "SelectionManager.hpp"

#include <algorithm>

SelectionManager::SelectionManager(Player *owner) : owner(owner) {}

void SelectionManager::Select(const std::vector<ISelectable *> &students) {
    Clear();

    for (ISelectable *s : students) {
        if (!s)
            continue;

        s->Select(owner);
        selected.push_back(s);
    }
}

void SelectionManager::Clear() {

    // copy because Deselect may modify the vector
    std::vector<ISelectable *> copy = selected;

    for (ISelectable *s : copy) {
        if (s)
            s->Deselect();
    }

    selected.clear();
}

void SelectionManager::Add(const std::vector<ISelectable *> &students) {

    for (ISelectable *s : students) {

        if (!s)
            continue;

        auto it = std::find(selected.begin(), selected.end(), s);

        if (it == selected.end()) {
            s->Select(owner);
            selected.push_back(s);
        }
    }
}

void SelectionManager::Deselect(ISelectable *student) {

    auto it = std::find(selected.begin(), selected.end(), student);

    if (it != selected.end()) {
        selected.erase(it);
    }
}
