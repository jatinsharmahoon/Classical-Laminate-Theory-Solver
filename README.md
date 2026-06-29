# Classical Laminate Theory (CLT) Composite Structural Engine

A comprehensive MATLAB structural solver executing multi-layer **Classical Laminate Theory (CLT)** equations for composite laminates. The script models compliance and stiffness transformations, generates the composite extensional/coupling/bending stiffness matrices (**ABD Matrices**), maps localized global/local stress-strain states across ply thickness paths, and performs structural load-share verifications under combined force-moment tensors.

---

## Mechanical Engineering Framework & Governing Equations

When multiple orthotropic ply directions are stacked to build a structural shell laminate, the mechanical response is deeply coupled. This application evaluates laminate constitutive relationships mapping applied force ($\mathbf{N}$) and moment ($\mathbf{M}$) matrices directly to mid-plane strains ($\mathbf{\varepsilon^0}$) and laminate curvatures ($\mathbf{\kappa}$):

$$\begin{bmatrix} \mathbf{N} \\ \mathbf{M} \end{bmatrix} = \begin{bmatrix} \mathbf{A} & \mathbf{B} \\ \mathbf{B} & \mathbf{D} \end{bmatrix} \begin{bmatrix} \mathbf{\varepsilon^0} \\ \mathbf{\kappa} \end{bmatrix}$$

The script iterates sequentially through the laminate stack to solve these distinct core sub-matrices:

### 1. Extensional Stiffness Matrix ($A_{ij}$)
Tracks total membrane stiffness across layer boundaries ($z_k$):
$$A_{ij} = \sum_{k=1}^{n} (\bar{Q}_{ij})_k (z_k - z_{k-1})$$

### 2. Coupling Stiffness Matrix ($B_{ij}$)
Measures coupling interaction linking in-plane forces directly to out-of-plane bending deformations. The script evaluates this matrix to confirm laminate geometric parameters:
$$B_{ij} = \frac{1}{2} \sum_{k=1}^{n} (\bar{Q}_{ij})_k (z_k^2 - z_{k-1}^2)$$
* *Note: The code dynamically screens this threshold, classifying the structure as **Symmetric** if $B_{ij} \approx 0$.*

### 3. Bending Stiffness Matrix ($D_{ij}$)
Defines the total out-of-plane flexural rigidity of the stack:
$$D_{ij} = \frac{1}{3} \sum_{k=1}^{n} (\bar{Q}_{ij})_k (z_k^3 - z_{k-1}^3)$$

---

## Software Engine Architecture & Data Flows

1. **Constitutive Compliance Loops:** Builds individual ply compliance tensors ($S$) using longitudinal/transverse parameters, converting them to local stiffness matrices ($Q = S^{-1}$).
2. **Coordinate Matrix Transforms:** Rotates properties into the global coordinate reference system using transformation matrices ($T_1, T_2$), yielding the transformed reduced stiffness matrix:
$$\bar{Q} = T_1^{-1} Q T_2$$
3. **Through-Thickness Profiler:** Tracks structural stresses and strains across three key nodal positions per ply (**Top, Middle, Bottom**) to accurately capture the linear stress gradients caused by curvature bending.
4. **Load-Sharing Verification Loop:** Integrates internal longitudinal ply stress profiles to identify exact individual load-carrying percentages across distinct fiber layups:
$$\text{Load Share \%} = \left(\frac{N_{x,\text{ply}}}{N_{x,\text{total}}}\right) \times 100$$

---

## Execution Guide & Interactive Options

### How to Run
Open `jatin_23bme050_laminates.m` inside **MATLAB** and execute. The command interface will guide you through initializing the structure:

1. **Specify Ply Configurations:** Enter the total number of plies, individual elastic moduli ($E_L, E_T, G_{LT}, \nu_{LT}$), thickness ($t$), and orientation angles ($\theta$).
2. **Define Loading Conditions:** Select your structural load state from three built-in boundary cases:
   * `1` $\rightarrow$ Pure Membrane Forces ($N_x, N_y, N_{xy}$ in $\text{N/m}$)
   * `2` $\rightarrow$ Pure Bending/Torsional Moments ($M_x, M_y, M_{xy}$)
   * `3` $\rightarrow$ Combined Multi-Axial Loading State
## Sample Input Data & Verification Case

To verify the code execution, use the standard material properties for a high-performance **Glass/Epoxy Uni-directional Lamina**:

### Input Prompts:
* **Longitudinal Modulus EL (GPa):** `38.6`
* **Transverse Modulus ET (GPa):** `8.27`
* **Shear Modulus GLT (GPa):** `4.14`
* **Poisson Ratio VLT:** `0.26`

### Expected Mathematical Bounds for Verification:
When the script finishes execution, your generated plots should accurately reflect the following boundary constraints at principal orientations:
* At $\theta = 0^\circ$: $E_x = E_L = 38.6\text{ GPa}$, $E_y = E_T = 8.27\text{ GPa}$
* At $\theta = 90^\circ$: $E_x = E_T = 8.27\text{ GPa}$, $E_y = E_L = 38.6\text{ GPa}$
* Peak Shear Modulus ($G_{xy}$) occurs exactly at $\theta = 45^\circ$.


### Real-Time Reporting Outputs
The solver calculates and displays structured diagnostic tables directly in the command window:
* Complete numerical array printouts for the **A, B, and D Matrices**.
* Transformed Global Stress/Strain records ($\sigma_x, \sigma_y, \tau_{xy}$ / $\varepsilon_x, \varepsilon_y, \gamma_{xy}$).
* Principal Material Local Stress/Strain evaluations ($\sigma_1, \sigma_2, \tau_{12}$ / $\varepsilon_1, \varepsilon_2, \gamma_{12}$).

## Verification Case Study (Sample Input Pipeline)

You can benchmark the numerical integrity of this Classical Laminate Theory engine using a standard **Symmetric Carbon/Epoxy Cross-Ply Laminate $[0^\circ / 90^\circ]_s$** subjected to pure tensile loading.

### Phase 1: Ply Architecture Definitions
* **Number of plies:** `4`

#### For Plies 1 and 4 (Outer Skin Layers at $0^\circ$):
* $E_L$: `181e9` (Pa) | $E_T$: `10.3e9` (Pa) | $G_{LT}$:`7.17e9` (Pa) | $\nu_{LT}$: `0.28` | **Theta**: `0` | **Thickness**: `0.005` (m)

#### For Plies 2 and 3 (Core Core Layers at $90^\circ$):
* $E_L$: `181e9` (Pa) | $E_T$: `10.3e9` (Pa) | $G_{LT}$:`7.17e9` (Pa) | $\nu_{LT}$: `0.28` | **Theta**: `90` | **Thickness**: `0.005` (m)

### Phase 2: Load Selection
* **Load Input Type Choice:** `1` (Only Forces)
* **Nx (N/m):** `1e6` (1 MN/m tensile load)
* **Ny / Nxy (N/m):** `0`

### Expected Output Verification Matrix:
Because this stacking sequence is completely symmetrical relative to the mid-plane geometric axis, your command window output matrix should explicitly confirm:
1. **Coupling Matrix Verification:** The printed `B MATRIX` elements must drop securely to zero ($B_{ij} \approx 0$), triggers the terminal log reading: `Laminate is SYMMETRIC (B ≈ 0)`.
2. **Global Strain Field:** Zero out-of-plane curvature values ($\kappa_x = \kappa_y = \kappa_{xy} = 0$).
