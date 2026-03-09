#pragma once

#include "../ISelectable.hpp"
#include "Player.hpp"

#include <vector>

class SelectionManager {
  public:
    explicit SelectionManager(Player *owner);

    void Select(const std::vector<ISelectable *> &students);
    void Add(const std::vector<ISelectable *> &students);
    void Clear();
    void Deselect(ISelectable *student);

  private:
    Player *owner;
    std::vector<ISelectable *> selected;
};
