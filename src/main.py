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
tsm = metafor.getTimeStepManager()
mim = metafor.getMechanicalIterationManager()

# Archiving - Save the desired quantities in .ascii files.
# http://metafor.ltas.ulg.ac.be/dokuwiki/doc/user/results/courbes_res
values_manager = metafor.getValuesManager()

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

    def build_geometry(self, center, inner_radius, outer_radius):
        self.x  = center[0]
        self.y  = center[1]
        self.ri = inner_radius
        self.ro = outer_radius

        # Inner ring points
        point_1 = pointset.define(Ring.id_point+0, self.x-self.ri, self.y)
        point_2 = pointset.define(Ring.id_point+1, self.x,         self.y+self.ri)
        point_3 = pointset.define(Ring.id_point+2, self.x+self.ri, self.y)
        point_4 = pointset.define(Ring.id_point+3, self.x,         self.y-self.ri)
        # Outer ring points
        point_5 = pointset.define(Ring.id_point+4, self.x-self.ro, self.y)
        point_6 = pointset.define(Ring.id_point+5, self.x,         self.y+self.ro)
        point_7 = pointset.define(Ring.id_point+6, self.x+self.ro, self.y)
        point_8 = pointset.define(Ring.id_point+7, self.x,         self.y-self.ro)

        # Half inner rings
        curve_1 = curveset.add(Arc(Ring.id_curve,   point_1, point_2, point_3))
        curve_2 = curveset.add(Arc(Ring.id_curve+1, point_3, point_4, point_1))
        # Half outer rings
        curve_3 = curveset.add(Arc(Ring.id_curve+2, point_5, point_6, point_7))
        curve_4 = curveset.add(Arc(Ring.id_curve+3, point_7, point_8, point_5))
        # Cutting lines
        curve_5 = curveset.add(Line(Ring.id_curve+4, point_5, point_1))
        curve_6 = curveset.add(Line(Ring.id_curve+5, point_3, point_7))

        # Upper half ring
        wire_1 = wireset.add(Wire(Ring.id_wire,   [curve_5, curve_1, curve_6, curve_3]))
        # Lower half ring
        wire_2 = wireset.add(Wire(Ring.id_wire+1, [curve_5, curve_4, curve_6, curve_2]))

        # Upper half ring
        side_1 = sideset.add(Side(Ring.id_side,   [wire_1]))
        # Lower half ring
        side_2 = sideset.add(Side(Ring.id_side+1, [wire_2]))

        # Plane-strain problem, in the (O,x,y) plane.
        geometry.setDimPlaneStrain(1.0)

        # Update the geometry objects indexes  TODO: not really robust
        Ring.id_point += 8
        Ring.id_curve += 6
        Ring.id_wire  += 2
        Ring.id_side  += 2

        # Keep geometry elements callable
        self.curve_1 = curve_1
        self.curve_2 = curve_2
        self.curve_3 = curve_3
        self.curve_4 = curve_4
        self.curve_5 = curve_5
        self.curve_6 = curve_6
        self.side_1 = side_1
        self.side_2 = side_2

    def build_mesh(self, nelem_radial=5, nelem_contour=80):
        # Meshing the Curve objects
        SimpleMesher1D(self.curve_1).execute(nelem_contour)
        SimpleMesher1D(self.curve_2).execute(nelem_contour)
        SimpleMesher1D(self.curve_3).execute(nelem_contour)
        SimpleMesher1D(self.curve_4).execute(nelem_contour)
        SimpleMesher1D(self.curve_5).execute(nelem_radial)
        SimpleMesher1D(self.curve_6).execute(nelem_radial)

        # Meshing the Side objects
        TransfiniteMesher2D(self.side_1).execute(True)
        TransfiniteMesher2D(self.side_2).execute(True)

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
        elem_prop.put(CAUCHYMECHVOLINTMETH, VES_CMVIM_SRIPR)

        # Build the continuum of elements
        field_app = FieldApplicator(self.id_field)
        field_app.push(self.side_1)
        field_app.push(self.side_2)
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

        contact_11.push(self.curve_1)
        contact_11.addProperty(self.contact_elem)

        contact_22.push(self.curve_2)
        contact_22.addProperty(self.contact_elem)

        contact_12.setTool(self.curve_1)
        contact_12.push(self.curve_2)
        contact_12.addProperty(self.contact_elem)

        domain.getInteractionSet().add(contact_11)
        domain.getInteractionSet().add(contact_22)
        domain.getInteractionSet().add(contact_12)

        Ring.id_interaction += 3

# 3. CREATE THE THREE RINGS {{{1

# Instantiate the three main Ring objects
ring_1 = Ring()
ring_2 = Ring()
ring_3 = Ring()

# Build the geometries
# INFO: reference paper values:
# - center       = (-7.9, 8.5) | (7.9, -8.5) | (0, 0)
# - inner_radius = 8           | 10          | 26
# - outer_radius = 10          | 12          | 30
ring_1.build_geometry(center=(-7.9,  8.5), inner_radius=8,  outer_radius=10)
ring_2.build_geometry(center=( 7.9, -8.5), inner_radius=10, outer_radius=12)
ring_3.build_geometry(center=( 0,    0),   inner_radius=26, outer_radius=30)

# Build the meshes
ring_1.build_mesh(nelem_radial=3, nelem_contour=30)
ring_2.build_mesh(nelem_radial=3, nelem_contour=30)
ring_3.build_mesh(nelem_radial=3, nelem_contour=80)

# Build the constitutive materials
# INFO: reference paper values:
# - constitutive_material = ElastHypoMaterial,
# - mass_density          = 1e-7  | 1e-8 | 1e-6
# - elastic_modulus       = 10E3  | 2250 | 288E3
# - poisson_ratio         = 0.125 | 0.125| 0.125
ring_1.build_constitutive_material(
    constitutive_material = ElastHypoMaterial,
    mass_density          = 1e-7,
    elastic_modulus       = 10E3,
    poisson_ratio         = 0.125
)
ring_2.build_constitutive_material(
    constitutive_material = ElastHypoMaterial,
    mass_density          = 1e-8,
    elastic_modulus       = 2250,
    poisson_ratio         = 0.125
)
ring_3.build_constitutive_material(
    constitutive_material = ElastHypoMaterial,
    mass_density          = 1e-6,
    elastic_modulus       = 288E3,
    poisson_ratio         = 0.125
)

# Build the element types and fields
ring_1.build_element(elem_type=Volume2DElement)
ring_2.build_element(elem_type=Volume2DElement)
ring_3.build_element(elem_type=Volume2DElement)

# Build the contact laws (and associated materials)
# INFO: reference paper value: coef_frot = 0.3
ring_1.build_coulomb_contact(
    pen_normale   = 1E6,
    pen_tangent   = 1E6,
    prof_cont     = (ring_1.ro-ring_1.ri)/4,
    coef_frot_dyn = 0.3,
    coef_frot_sta = 0.3
)
ring_2.build_coulomb_contact(
    pen_normale   = 1E6,
    pen_tangent   = 1E6,
    prof_cont     = (ring_2.ro-ring_2.ri)/4,
    coef_frot_dyn = 0.3,
    coef_frot_sta = 0.3
)
ring_3.build_coulomb_contact(
    pen_normale   = 1E6,
    pen_tangent   = 1E6,
    prof_cont     = (ring_3.ro-ring_3.ri)/4,
    coef_frot_dyn = 0.3,
    coef_frot_sta = 0.3
)

# 4. CONTACT INTERACTIONS {{{1

def build_outer_outer_contact(r1: Ring, r2: Ring):
    contact_33 = DdContactInteraction(Ring.id_interaction)
    contact_44 = DdContactInteraction(Ring.id_interaction+1)
    contact_34 = DdContactInteraction(Ring.id_interaction+2)
    contact_43 = DdContactInteraction(Ring.id_interaction+3)

    contact_33.setTool(r1.curve_3)
    contact_33.push(r2.curve_3)
    contact_33.addProperty(r1.contact_elem)

    contact_44.setTool(r1.curve_4)
    contact_44.push(r2.curve_4)
    contact_44.addProperty(r1.contact_elem)

    contact_34.setTool(r1.curve_3)
    contact_34.push(r2.curve_4)
    contact_34.addProperty(r1.contact_elem)

    contact_43.setTool(r1.curve_4)
    contact_43.push(r2.curve_3)
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

    contact_13.setTool(outer.curve_1)
    contact_13.push(inner.curve_3)
    contact_13.addProperty(inner.contact_elem)

    contact_24.setTool(outer.curve_2)
    contact_24.push(inner.curve_4)
    contact_24.addProperty(inner.contact_elem)

    contact_14.setTool(outer.curve_1)
    contact_14.push(inner.curve_4)
    contact_14.addProperty(inner.contact_elem)

    contact_23.setTool(outer.curve_2)
    contact_23.push(inner.curve_3)
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
domain.getLoadingSet().define(ring_3.curve_3, Field1D(TX, RE), 0.0)
domain.getLoadingSet().define(ring_3.curve_3, Field1D(TY, RE), 0.0)
domain.getLoadingSet().define(ring_3.curve_4, Field1D(TX, RE), 0.0)
domain.getLoadingSet().define(ring_3.curve_4, Field1D(TY, RE), 0.0)

def set_initial_speed(ring: Ring, v0_x, v0_y):
    initial_conditions.define(ring.side_1, Field1D(TX, GV), v0_x)
    initial_conditions.define(ring.side_1, Field1D(TY, GV), v0_y)
    initial_conditions.define(ring.side_2, Field1D(TX, GV), v0_x)
    initial_conditions.define(ring.side_2, Field1D(TY, GV), v0_y)

# Give initial speed to the inner ring 1.
# INFO: reference paper values: (30mm/ms, -30mm/ms)
set_initial_speed(ring_1, 30E3, -30E3)

# 6. TIME INTEGRATION {{{1

ti = AlphaGeneralizedTimeIntegration(metafor)
metafor.setTimeIntegration(ti)

# Initial time and time step
initial_time = 0.0
# WARN: boman: make this relative to the impact speed. Explain in report.
time_step = 1E-5
tsm.setInitialTime(initial_time, time_step)

# Intermediate and/or final time
final_time = 5E-4
# WARN:
# Low enough to make sure that the rings ne se traversent pas.
# Lier ça à la vitesse d'impact. Lier à la profondeur de contact, pour bien faire.
max_time_step = 1E-4
n_intermediate = 5
tsm.setNextTime(final_time, n_intermediate, max_time_step)

# Set the residual tolerance
res_tol = 1E-4  # default is 1E-4 (chap. 11)
mim.setResidualTolerance(res_tol)

# 7. ARCHIVING {{{1

# Time
values_manager.add(1, MiscValueExtractor(metafor, EXT_T), 'time')

# Position of the nodes
value_extractor = DbNodalValueExtractor(ring_1.curve_1, Field1D(TX, RE), sOp=SortByKsi0(ring_1.curve_1), maxV=-1)
values_manager.add(2, value_extractor, 'TX_r1_curve1')

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
