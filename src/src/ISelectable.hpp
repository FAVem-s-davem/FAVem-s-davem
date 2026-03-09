#pragma once

class Player;

class ISelectable {
  public:
    virtual ~ISelectable(); // declaration

    virtual void Select(Player *player) = 0;
    virtual void Deselect() = 0;
};
