# Classical Laminate Theory (CLT) Calculator

A MATLAB script that performs full Classical Laminate Theory analysis on a user-defined composite laminate: builds the ABD stiffness matrix, solves for mid-plane strains and curvatures under applied loads/moments, and recovers ply-by-ply stress and strain in both global and material (local) coordinate systems.

Built as a personal tool for solving Mechanics of Solids / Composites coursework assignments faster and more reliably than repeated hand calculation.

## What It Does
Given an arbitrary stack of plies (each with its own material properties, fiber orientation, and thickness) and an applied in-plane force and/or moment resultant, the script:

1. Builds each ply's local stiffness matrix `Q` from engineering constants (`El`, `Et`, `Glt`, `vlt`) and transforms it to global axes (`Qbar`) using the standard rotation transformation for angle `theta`
2. Assembles the laminate `A`, `B`, `D` stiffness matrices by integrating `Qbar` through the laminate thickness
3. Solves `[N;M] = [ABD][ε₀;κ]` for mid-plane strain `ε₀` and curvature `κ`
4. Recovers strain and stress at the top, middle, and bottom of every ply, in both global (x-y) and local (fiber-aligned 1-2) coordinates
5. Computes how much of the applied axial load (`Nx`) each ply carries, and checks whether the laminate is symmetric (`B ≈ 0`)

## Why This Is Useful
Doing this by hand for more than 2-3 plies is slow and error-prone — every ply needs its own coordinate transformation, and the ABD matrix requires careful through-thickness integration. This script generalizes the process to any number of plies, any stacking sequence, and any combination of force/moment loading, which made it practical to check coursework problems quickly and verify hand calculations.

## Verification
I validated the script against a standard textbook benchmark case — a symmetric cross-ply graphite/epoxy laminate **[0°/90°/90°/0°]**, each ply 1 mm thick, under `Nx = 1000 N/m`:

| Check | Result |
|---|---|
| Laminate symmetry | Correctly detected as symmetric (B ≈ 0) |
| Load carried by 0° plies | 47.33% each (94.66% combined) |
| Load carried by 90° plies | 2.67% each (5.34% combined) |
| Load percentages sum to | 100.0% ✓ |

This matches expected composite behavior: since graphite/epoxy is ~17× stiffer along the fiber direction (181 GPa) than transverse to it (10.3 GPa), the 0° plies — aligned with the applied load — carry the overwhelming majority of it. Full output is in [`sample_output_0_90_90_0.txt`](./sample_output_0_90_90_0.txt).

## Usage
Run in MATLAB or GNU Octave:
```
laminates.m
```
The script prompts interactively for:
- Number of plies
- Per ply: `El`, `Et`, `Glt`, `vlt` (Pa, Pa, Pa, unitless), fiber angle `theta` (deg), thickness (m)
- Load type (forces only / moments only / both) and the corresponding `Nx, Ny, Nxy, Mx, My, Mxy` values

Output includes the A/B/D matrices, mid-plane strain/curvature, full ply-by-ply global and local stress/strain tables, per-ply load share, and a symmetry check.

## Repository Structure
```
laminate-clt-tool/
├── README.md
├── laminates.m                       # main script
└── sample_output_0_90_90_0.txt       # verification run, standard cross-ply benchmark
```

## Tools
MATLAB (no toolboxes required — uses only core matrix operations).

## Possible Extensions
- Failure analysis (max stress / Tsai-Wu criteria) per ply using the recovered local stresses
- Thermal/hygral load terms in addition to mechanical `N, M`
- Batch mode (function-based, reading from a config file) instead of interactive prompts, for sweeping stacking sequences
