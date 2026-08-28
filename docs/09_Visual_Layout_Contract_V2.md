# TamTam V2 — Visual Layout Contract

**Document revision:** 2.1

## Board source canvas

- Width: **1080 px**
- Height: **1080 px**
- Resolution metadata: **72 pixels/inch**
- Aspect ratio: 1:1

## Reserved margin

- Top: 50 px
- Right: 50 px
- Bottom: 50 px
- Left: 50 px

The margin is reserved for board frame and visual decoration. It is not gameplay space.

## Logical game area

- Origin: `(50, 50)`
- Size: **980×980 px**
- End: `(1030, 1030)`

## Logical cells

5 columns × 5 rows.

Each cell:

- width: **196 px**
- height: **196 px**

Cell centers:

- columns: 148, 344, 540, 736, 932
- rows: 148, 344, 540, 736, 932

Therefore C3 is centered at `(540, 540)`.

These logical centers are authoritative for piece positioning and movement animation.

## Finish presentation

C3 remains logically 196×196.

The Finish artwork may be visually enlarged beyond C3, as in the approved larger-center direction.

This enlargement must be presentation/overlay only.

It must not:

- resize logical row 3 or column C
- move neighboring logical cell centers
- alter route geometry
- alter piece movement coordinates

Finish is divided visually:

- top triangle: Green
- right triangle: Blue
- bottom triangle: Yellow
- left triangle: Red

Finished pieces are displayed in their triangle and do not count as active C3 occupancy.

## Active piece positioning

A single active piece is centered on its logical cell.

For multiple active pieces on the same cell, the whole visual cluster remains centered on the same logical cell.

### Scale

- occupancy 1: 100%
- occupancy 2: 50% each
- occupancy 3: 33.33% each
- occupancy 4: 25% each
- occupancy 5: 20% each
- occupancy >5: still 20% each

For occupancy >5, overlap additional pieces rather than shrinking below the 5-piece size.

Exact overlap offsets are presentation details and may be tuned without domain changes.

## Finished-piece display

Classic/Rapid can show 0–4 finished pieces in each player triangle.

Finished-piece visual slots may be designed/tuned independently, but gameplay must only supply player identity and finished state/count.

The center artwork itself must not determine who has finished.

## Skin principle

Layout owns geometry. Skins fill the layout.

Board artwork may decorate margins, frame, cells, and Finish overlay.

Artwork must never define logical coordinates.
