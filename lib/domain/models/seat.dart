enum Seat {
  top,
  right,
  bottom,
  left;

  Seat get opposite {
    switch (this) {
      case Seat.top:
        return Seat.bottom;
      case Seat.right:
        return Seat.left;
      case Seat.bottom:
        return Seat.top;
      case Seat.left:
        return Seat.right;
    }
  }
}
