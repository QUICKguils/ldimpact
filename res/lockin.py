"""
Highlight the lock-in effect that appears when using
the standard integration scheme with a quasi-incompressible material.
"""

import math

from wrap import *

# Instantiate the main Metafor and Domain objects
metafor = Metafor()
domain = metafor.getDomain()

# The python file aims to return the main Metafor object through this function.
# The rest of this file implement the Metafor object, which can thus be seen as
# a data structure containing all the FE problem description.
def getMetafor(p={}):
    return metafor

# WARN:
# In this python description file, choice has been made to specify geometric
# lengths in millimeters. Other units have to be consistent with that choice:
# Length  -> [mm]
# Force   -> [N]
# Mass    -> [t]
# Time    -> [s]
# Stress  -> [MPa]
# Energy  -> [mJ]
# Density -> [t/mm³]

# 1. INSTANTIATE THE METAFOR OBJECTS {{{1

# Geometry
geometry = domain.getGeometry()
pointset = geometry.getPointSet()
curveset = geometry.getCurveSet()
wireset  = geometry.getWireSet()
sideset  = geometry.getSideSet()

# Material
# http://metafor.ltas.ulg.ac.be/dokuwiki/doc/user/elements/volumes/iso_hypo_materials
materials = domain.getMaterialSet()

# Constitutive law
# http://metafor.ltas.ulg.ac.be/dokuwiki/doc/user/elements/volumes/yield_stress
laws = domain.getMaterialLawSet()

# Initial conditions
initial_conditions = metafor.getInitialConditionSet()

# Time integration
# http://metafor.ltas.ulg.ac.be/dokuwiki/doc/user/integration/general/time_step
tsm = metafor.getTimeStepManager()
mim = metafor.getMechanicalIterationManager()

# Archiving - Save the desired quantities in .ascii files.
# http://metafor.ltas.ulg.ac.be/dokuwiki/doc/user/results/courbes_res
values_manager = metafor.getValuesManager()
fac_values_manager = metafor.getFacValuesManager()

# Use Metafor multiprocessing capabilities
StrVectorBase.useTBB()
StrMatrixBase.useTBB()
ContactInteraction.useTBB()

# 2. DEFINE AND IMPLEMENT THE RING CLASS {{{1

# INFO:
# It is advised to refer to the schematic in the report that shows the
# notations and conventions used to define the metafor Ring class.

class Ring():
    """Ring -- Implement a 2D ring.

        The bare Ring class initializes a Ring object by assigning it a unique
        identification label.

        Several methods can then be used to build the related metafor object,
        such as the geometry, the mesh, the material, etc.
    """

    # Keep track of numeric labels assigned to the Metafor elements
    id_ring        = 1
    id_point       = 1
    id_curve       = 1
    id_wire        = 1
    id_side        = 1
    id_material    = 1
    id_interaction = 1  # FieldApplicator and Interaction

    def __init__(self):
        self.id = Ring.id_ring
        Ring.id_ring += 1

    def build_geometry(self, center, inner_radius, outer_radius, alpha=180, theta=0):
        self.ri = inner_radius
        self.ro = outer_radius
        self.thickness = self.ro - self.ri

        _point = [(0, 0)] * 9
        point = [None] * 9

        sina, cosa = math.sin(math.radians(alpha/2)), math.cos(math.radians(alpha/2))
        sint, cost = math.sin(math.radians(theta)), math.cos(math.radians(theta))

        # Apply the side delimitation, specified by the aperture angle alpha
        _point[1] = (-self.ri*sina, -self.ri*cosa)
        _point[3] = (+self.ri*sina, -self.ri*cosa)
        _point[5] = (-self.ro*sina, -self.ro*cosa)
        _point[7] = (+self.ro*sina, -self.ro*cosa)

        # Ohter four points, at midway of each arc segments
        _point[2] = (0, +self.ri)
        _point[4] = (0, -self.ri)
        _point[6] = (0, +self.ro)
        _point[8] = (0, -self.ro)

        # Apply the rotation, specified by the rotation angle theta
        for idx, pt in enumerate(_point):
            _point[idx] = (cost*pt[0] - sint*pt[1], sint*pt[0] + cost*pt[1])

        # Apply the translation, specified by the ring center
        for idx, pt in enumerate(_point):
            _point[idx] = (pt[0]+center[0], pt[1]+center[1])

        # Define the computed points in Metafor
        point[1] = pointset.define(Ring.id_point+0, *_point[1])
        point[2] = pointset.define(Ring.id_point+1, *_point[2])
        point[3] = pointset.define(Ring.id_point+2, *_point[3])
        point[4] = pointset.define(Ring.id_point+3, *_point[4])
        point[5] = pointset.define(Ring.id_point+4, *_point[5])
        point[6] = pointset.define(Ring.id_point+5, *_point[6])
        point[7] = pointset.define(Ring.id_point+6, *_point[7])
        point[8] = pointset.define(Ring.id_point+7, *_point[8])

        curve = [None] * 7

        # Half inner rings
        curve[1] = curveset.add(Arc(Ring.id_curve,   point[1], point[2], point[3]))
        curve[2] = curveset.add(Arc(Ring.id_curve+1, point[3], point[4], point[1]))
        # Half outer rings
        curve[3] = curveset.add(Arc(Ring.id_curve+2, point[5], point[6], point[7]))
        curve[4] = curveset.add(Arc(Ring.id_curve+3, point[7], point[8], point[5]))
        # Cutting lines
        curve[5] = curveset.add(Line(Ring.id_curve+4, point[5], point[1]))
        curve[6] = curveset.add(Line(Ring.id_curve+5, point[3], point[7]))

        wire = [None] * 3

        # Upper half ring
        wire[1] = wireset.add(Wire(Ring.id_wire,   [curve[5], curve[1], curve[6], curve[3]]))
        # Lower half ring
        wire[2] = wireset.add(Wire(Ring.id_wire+1, [curve[5], curve[4], curve[6], curve[2]]))

        side = [None] * 3

        # Upper half ring
        side[1] = sideset.add(Side(Ring.id_side,   [wire[1]]))
        # Lower half ring
        side[2] = sideset.add(Side(Ring.id_side+1, [wire[2]]))

        # Plane-strain problem, in the (O,x,y) plane.
        geometry.setDimPlaneStrain(1.0)

        # Update the geometry objects indexes  TODO: not really robust
        Ring.id_point += 8
        Ring.id_curve += 6
        Ring.id_wire  += 2
        Ring.id_side  += 2

        # Keep geometry elements callable
        self.point = point
        self.curve = curve
        self.wire = wire
        self.side = side

    def build_mesh(self, nelem_radial=5, nelem_contour_coarse=40, nelem_contour_fine=40):
        # Meshing the Curve objects
        SimpleMesher1D(self.curve[1]).execute(nelem_contour_coarse)
        SimpleMesher1D(self.curve[2]).execute(nelem_contour_fine)
        SimpleMesher1D(self.curve[3]).execute(nelem_contour_coarse)
        SimpleMesher1D(self.curve[4]).execute(nelem_contour_fine)
        SimpleMesher1D(self.curve[5]).execute(nelem_radial)
        SimpleMesher1D(self.curve[6]).execute(nelem_radial)

        # Meshing the Side objects
        TransfiniteMesher2D(self.side[1]).execute(True)
        TransfiniteMesher2D(self.side[2]).execute(True)

    def build_constitutive_material(
            self, constitutive_material,
            mass_density, elastic_modulus, poisson_ratio):
        self.id_constitutive_material = Ring.id_material

        materials.define(self.id_constitutive_material, constitutive_material)
        self.material = materials(self.id_constitutive_material)
        self.material.put(MASS_DENSITY,    mass_density)
        self.material.put(ELASTIC_MODULUS, elastic_modulus)
        self.material.put(POISSON_RATIO,   poisson_ratio)

        Ring.id_material += 1

    def build_element(self, elem_type):
        self.id_field = Ring.id_interaction

        # Properties of the finite elements
        elem_prop = ElementProperties(elem_type)
        elem_prop.put(MATERIAL, self.id_constitutive_material)
        elem_prop.put(CAUCHYMECHVOLINTMETH, VES_CMVIM_STD)

        # Build the continuum of elements
        field_app = FieldApplicator(self.id_field)
        field_app.push(self.side[1])
        field_app.push(self.side[2])
        field_app.addProperty(elem_prop)
        domain.getInteractionSet().add(field_app)

        Ring.id_interaction += 1

    def build_frictionless_contact(self):
        self.id_contact_material = Ring.id_material
        # TODO: implement that if needed
        Ring.id_material += 1

    def build_coulomb_contact(
            self, pen_normale, pen_tangent,
            prof_cont, coef_frot_dyn, coef_frot_sta):
        self.id_contact_material = Ring.id_material

        materials.define(self.id_contact_material, CoulombContactMaterial)

        materials(self.id_contact_material).put(PEN_NORMALE,   pen_normale)
        materials(self.id_contact_material).put(PEN_TANGENT,   pen_tangent)
        materials(self.id_contact_material).put(PROF_CONT,     prof_cont)
        materials(self.id_contact_material).put(COEF_FROT_DYN, coef_frot_dyn)
        materials(self.id_contact_material).put(COEF_FROT_STA, coef_frot_sta)

        self.contact_elem = ElementProperties(Contact2DElement)
        self.contact_elem.put(MATERIAL, self.id_contact_material)
        self.contact_elem.put(AREAINCONTACT, AIC_ONCE)  # Maybe the default anyways

        Ring.id_material += 1

    def build_self_contact(self):
        contact_11 = ScContactInteraction(Ring.id_interaction)
        contact_22 = ScContactInteraction(Ring.id_interaction+1)
        contact_12 = DdContactInteraction(Ring.id_interaction+2)

        contact_11.push(self.curve[1])
        contact_11.addProperty(self.contact_elem)

        contact_22.push(self.curve[2])
        contact_22.addProperty(self.contact_elem)

        contact_12.setTool(self.curve[1])
        contact_12.push(self.curve[2])
        contact_12.addProperty(self.contact_elem)

        domain.getInteractionSet().add(contact_11)
        domain.getInteractionSet().add(contact_22)
        domain.getInteractionSet().add(contact_12)

        Ring.id_interaction += 3

# 3. CREATE THE THREE RINGS {{{1

# 3.1. Instantiate the three main Ring objects

ring_1 = Ring()
ring_2 = Ring()
ring_3 = Ring()

# 3.2. Build the geometries
#
# INFO: reference paper values:
# - center       = (-7.9, 8.5) | (7.9, -8.5) | (0, 0)
# - inner_radius = 8           | 10          | 26
# - outer_radius = 10          | 12          | 30

ring_1.build_geometry(center=(-7.9,  8.5), inner_radius=8,  outer_radius=10, alpha=180, theta=45)
ring_2.build_geometry(center=( 7.9, -8.5), inner_radius=10, outer_radius=12, alpha=180, theta=0)
ring_3.build_geometry(center=( 0,    0),   inner_radius=26, outer_radius=30, alpha=90, theta=45)

# 3.3. Build the meshes

# Mesh multiplication factor, to globally
# increase or decrease the number of elements.
mesh_mult = 3

ring_1.build_mesh(
    nelem_radial=1*mesh_mult,
    nelem_contour_coarse=4*mesh_mult,
    nelem_contour_fine=12*mesh_mult
)
ring_2.build_mesh(
    nelem_radial=1*mesh_mult,
    nelem_contour_coarse=12*mesh_mult,
    nelem_contour_fine=12*mesh_mult
)
ring_3.build_mesh(
    nelem_radial=1*mesh_mult,
    nelem_contour_coarse=10*mesh_mult,
    nelem_contour_fine=12*mesh_mult
)

# 3.4. Build the constitutive materials
#
# INFO: reference paper values:
# - constitutive_material = ElastHypoMaterial,
# - mass_density          = 1e-7  | 1e-8 | 1e-6
# - elastic_modulus       = 10E3  | 2250 | 288E3
# - poisson_ratio         = 0.125 | 0.125| 0.125

ring_1.build_constitutive_material(
    constitutive_material = ElastHypoMaterial,
    mass_density          = 1e-7,
    elastic_modulus       = 288E3,
    poisson_ratio         = 0.4995
)
ring_2.build_constitutive_material(
    constitutive_material = ElastHypoMaterial,
    mass_density          = 1e-8,
    elastic_modulus       = 2250,
    poisson_ratio         = 0.4995
)
ring_3.build_constitutive_material(
    constitutive_material = ElastHypoMaterial,
    mass_density          = 1e-6,
    elastic_modulus       = 288E3,
    poisson_ratio         = 0.4995
)

# 3.5. Build the element types and fields

ring_1.build_element(elem_type=Volume2DElement)
ring_2.build_element(elem_type=Volume2DElement)
ring_3.build_element(elem_type=Volume2DElement)

# 3.6. Build the contact laws (and associated materials)
#
# INFO: reference paper value: coef_frot = 0.3

# Fraction of the ring tickness that should be used for the contact depth
prof_contact_fraction = 1/4

# Minimal depth of contact that is defined
# Useful to dynamically set the time integration step
min_prof_cont = min(ring_1.thickness, ring_2.thickness, ring_3.thickness) * prof_contact_fraction

ring_1.build_coulomb_contact(
    pen_normale   = 1E6,
    pen_tangent   = 1E6,
    prof_cont     = ring_1.thickness * prof_contact_fraction,
    coef_frot_dyn = 0.3,
    coef_frot_sta = 0.3
)
ring_2.build_coulomb_contact(
    pen_normale   = 1E6,
    pen_tangent   = 1E6,
    prof_cont     = ring_2.thickness * prof_contact_fraction,
    coef_frot_dyn = 0.3,
    coef_frot_sta = 0.3
)
ring_3.build_coulomb_contact(
    pen_normale   = 1E6,
    pen_tangent   = 1E6,
    prof_cont     = ring_3.thickness * prof_contact_fraction,
    coef_frot_dyn = 0.3,
    coef_frot_sta = 0.3
)

# 4. CONTACT INTERACTIONS {{{1

def build_outer_outer_contact(r1: Ring, r2: Ring):
    contact_33 = DdContactInteraction(Ring.id_interaction)
    contact_44 = DdContactInteraction(Ring.id_interaction+1)
    contact_34 = DdContactInteraction(Ring.id_interaction+2)
    contact_43 = DdContactInteraction(Ring.id_interaction+3)

    contact_33.setTool(r1.curve[3])
    contact_33.push(r2.curve[3])
    contact_33.addProperty(r1.contact_elem)

    contact_44.setTool(r1.curve[4])
    contact_44.push(r2.curve[4])
    contact_44.addProperty(r1.contact_elem)

    contact_34.setTool(r1.curve[3])
    contact_34.push(r2.curve[4])
    contact_34.addProperty(r1.contact_elem)

    contact_43.setTool(r1.curve[4])
    contact_43.push(r2.curve[3])
    contact_43.addProperty(r1.contact_elem)

    domain.getInteractionSet().add(contact_33)
    domain.getInteractionSet().add(contact_44)
    domain.getInteractionSet().add(contact_34)
    domain.getInteractionSet().add(contact_43)

    Ring.id_interaction += 4

def build_outer_inner_contact(outer: Ring, inner: Ring):
    contact_13 = DdContactInteraction(Ring.id_interaction)
    contact_24 = DdContactInteraction(Ring.id_interaction+1)
    contact_14 = DdContactInteraction(Ring.id_interaction+2)
    contact_23 = DdContactInteraction(Ring.id_interaction+3)

    contact_13.setTool(outer.curve[1])
    contact_13.push(inner.curve[3])
    contact_13.addProperty(inner.contact_elem)

    contact_24.setTool(outer.curve[2])
    contact_24.push(inner.curve[4])
    contact_24.addProperty(inner.contact_elem)

    contact_14.setTool(outer.curve[1])
    contact_14.push(inner.curve[4])
    contact_14.addProperty(inner.contact_elem)

    contact_23.setTool(outer.curve[2])
    contact_23.push(inner.curve[3])
    contact_23.addProperty(inner.contact_elem)

    domain.getInteractionSet().add(contact_13)
    domain.getInteractionSet().add(contact_24)
    domain.getInteractionSet().add(contact_14)
    domain.getInteractionSet().add(contact_23)

    Ring.id_interaction += 4

build_outer_inner_contact(ring_3, ring_1)
build_outer_inner_contact(ring_3, ring_2)
build_outer_outer_contact(ring_1, ring_2)

ring_1.build_self_contact()
ring_2.build_self_contact()
ring_3.build_self_contact()

# 5. BOUNDARY CONDITIONS AND INITIAL CONDITIONS {{{1

# Dirichlet condition on outer side of ring_3
domain.getLoadingSet().define(ring_3.curve[3], Field1D(TX, RE), 0.0)
domain.getLoadingSet().define(ring_3.curve[3], Field1D(TY, RE), 0.0)
domain.getLoadingSet().define(ring_3.curve[4], Field1D(TX, RE), 0.0)
domain.getLoadingSet().define(ring_3.curve[4], Field1D(TY, RE), 0.0)

def set_initial_speed(ring: Ring, v0_x, v0_y):
    initial_conditions.define(ring.side[1], Field1D(TX, GV), v0_x)
    initial_conditions.define(ring.side[1], Field1D(TY, GV), v0_y)
    initial_conditions.define(ring.side[2], Field1D(TX, GV), v0_x)
    initial_conditions.define(ring.side[2], Field1D(TY, GV), v0_y)

# Give initial speed to the inner ring 1.
# INFO: reference paper values: (30mm/ms, -30mm/ms)
init_speed = (30E3, -30E3)
init_speed_magnitude = math.sqrt(init_speed[0]**2 + init_speed[1]**2)
set_initial_speed(ring_1, *init_speed)

# 6. TIME INTEGRATION {{{1

ti = AlphaGeneralizedTimeIntegration(metafor)
metafor.setTimeIntegration(ti)

# Initial time
initial_time = 0.0

# Initial time step.
# Should be small enough so that the nodes of ring_1 do not jump over
# the contact detection area of ring_2 between two time step.
time_step = min_prof_cont / init_speed_magnitude
tsm.setInitialTime(initial_time, time_step)

# Intermediate and/or final time.
final_time = 8E-4

# Maximimum time step allowed.
# As for the initial time step, the maximum time step
# is chosen low enough to make sure that the ring nodes
# will never jump over the contact detection area.
max_time_step = min_prof_cont / init_speed_magnitude

# Number of intemediate simulation state to save.
# Those are saved in compressed bfac.gz files.
n_intermediate = 149

# Here, next specified time is just the final time
tsm.setNextTime(final_time, n_intermediate, max_time_step)

# Set the residual tolerance
res_tol = 1E-4  # default is 1E-4 (chap. 11)
mim.setResidualTolerance(res_tol)

# 7. ARCHIVING {{{1

# NOTE:
# more gentel for the disk to save or like 200 FAC steps throught the fac_values_manager
# than to save every time step through the values_manager.

# Keep track of the number of values managers
# and fac values managers that are instantiated
id_fac = 1

# Time sample of the simulation recordings
fac_values_manager.add(id_fac, MiscValueExtractor(metafor, EXT_T), 'tSample')
id_fac += 1

# Dict gathering the nodal fields to archive
# over the entire problem geometry.
dbnodal_fields = {
    "AB_TX":  Field1D(TX, AB),
    "AB_TY":  Field1D(TY, AB),
    "RE_TX":  Field1D(TX, RE),
    "RE_TY":  Field1D(TY, RE),
    "GV_TX":  Field1D(TX,GV),
    "GV_TY":  Field1D(TY,GV),
    "GF1_TX": Field1D(TX,GF1),
    "GF1_TY": Field1D(TY,GF1),
    "GF2_TX": Field1D(TX,GF2),
    "GF2_TY": Field1D(TY,GF2),
}

# Save the desired nodal fields for the whole geometry
for id_field, field in dbnodal_fields.items():
    for id_ring, ring in enumerate([ring_1, ring_2, ring_3]):
        for id_curve, curve in enumerate(ring.curve[1:]):
            extractor = DbNodalValueExtractor(curve, field, sOp=SortByKsi0(curve), maxV=-1)
            id_extractor = f'{id_field}_curve{id_curve+1}_ring{id_ring+1}'
            fac_values_manager.add(id_fac, extractor, id_extractor)
            id_fac += 1

# DEBUG OPTIONS {{{1

# Set here what has to be debugged.
debug = {
    'geometry': False,
    'mesh': False,
}

if debug['geometry']:
    win = VizWin()
    win.add(pointset)
    win.add(curveset)
    win.open()
    input()
if debug['mesh']:
    win = VizWin()
    win.add(geometry.getMesh().getPointSet())
    win.add(geometry.getMesh().getCurveSet())
    win.open()
    input()
