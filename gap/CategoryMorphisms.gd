#############################################################################
##
##                                               CategoriesForHomalg package
##
##  Copyright 2013, Sebastian Gutsche, TU Kaiserslautern
##                  Sebastian Posur,   RWTH Aachen
##
#! @Chapter Category morphism
#!  Any GAP object which is IsHomalgCategoryMorphism can be added to a category
#!  and then becomes a morphism in this category.
#!  Any morphism can belong to one or no category.
#!  After a GAP object is added to the category, it knows which things can be
#!  computed in its category and to which category it belongs.
#!  It knows categorial properties and attributes, and the functions for existential quantifiers
#!  can be applied to the morphism.
#!  If an GAP object in the category was constructed by a categorial construction
#!  it knows its Genesis.
##
#############################################################################

###################################
##
#! @Section Categories
##
###################################

## Moved to CategoriesForHomalg.gd

###################################
##
#! @Section Functions for all objects
##
###################################

#! @Group Category getter
DeclareAttribute( "HomalgCategory",
                  IsHomalgCategoryMorphism );

DeclareAttribute( "Source",
                  IsHomalgCategoryMorphism );

DeclareAttribute( "Range",
                  IsHomalgCategoryMorphism );

DeclareAttribute( "UnderlyingObject",
                  IsHomalgCategoryMorphism );

# this attribute is also an implied operation

DeclareOperation( "InverseOp",
                  [ IsHomalgCategoryMorphism ] );

###################################
##
#! @Section Technical stuff
##
###################################

DeclareGlobalFunction( "CATEGORIES_FOR_HOMALG_CREATE_MORPHISM_PRINT" );

DeclareGlobalFunction( "INSTALL_TODO_LIST_ENTRIES_FOR_MORPHISM" );

DeclareGlobalFunction( "INSTALL_TODO_LIST_FOR_EQUAL_MORPHISMS" );

DeclareGlobalVariable( "PROPAGATION_LIST_FOR_EQUAL_MORPHISMS" );

###################################
##
## Properties
##
###################################

DeclareFamilyProperty( "IsMonomorphism",
                       IsHomalgCategoryMorphism, "morphism" : reinstall := false );

DeclareOperation( "AddIsMonomorphism",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "IsMonomorphismFunction",
                  IsHomalgCategory );

DeclareSynonymAttr( "IsSubobject",
                    IsMonomorphism );

DeclareFamilyProperty( "IsEpimorphism",
                       IsHomalgCategoryMorphism, "morphism" : reinstall := false );

DeclareOperation( "AddIsEpimorphism",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "IsEpimorphismFunction",
                  IsHomalgCategory );

DeclareSynonymAttr( "IsFactorobject",
                    IsEpimorphism );

DeclareFamilyProperty( "IsIsomorphism",
                       IsHomalgCategoryMorphism, "morphism" : reinstall := false );

DeclareOperation( "AddIsIsomorphism",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "IsIsomorphismFunction",
                  IsHomalgCategory );

DeclareFamilyProperty( "IsEndomorphism",
                       IsHomalgCategoryMorphism, "morphism" : reinstall := false );

DeclareFamilyProperty( "IsAutomorphism",
                       IsHomalgCategoryMorphism, "morphism" : reinstall := false );

DeclareFamilyProperty( "IsSplitMonomorphism",
                       IsHomalgCategoryMorphism, "morphism" : reinstall := false );

DeclareFamilyProperty( "IsSplitEpimorphism",
                       IsHomalgCategoryMorphism, "morphism" : reinstall := false );

## TODO: IsIdentity
DeclareFamilyProperty( "IsOne",
                       IsHomalgCategoryMorphism, "morphism" : reinstall := false );

DeclareFamilyProperty( "IsIdempotent",
                       IsHomalgCategoryMorphism, "morphism" : reinstall := false );

###################################
##
#! @Section Morphism add functions
##
###################################

DeclareOperation( "Add",
                  [ IsHomalgCategory, IsHomalgCategoryMorphism ] );

###################################
##
#! @Section Constructive Hom-sets functions
##
###################################

DeclareOperation( "AddIsEqualForMorphisms",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "MorphismEqualityFunction",
                  IsHomalgCategory );

DeclareOperation( "IsEqualForMorphisms",
                  [ IsHomalgCategoryMorphism, IsHomalgCategoryMorphism ] );

DeclareOperation( "AddPropertyToMatchAtIsEqualForMorphisms",
                  [ IsHomalgCategory, IsString ] );

DeclareOperation( "AddIsZeroForMorphisms",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "IsZeroForMorphismsFunction",
                  IsHomalgCategory );

DeclareOperation( "AddAdditionForMorphisms",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "AdditionForMorphismsFunction",
                  IsHomalgCategory );

DeclareOperation( "AddAdditiveInverseForMorphisms",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "AdditiveInverseForMorphismsFunction",
                  IsHomalgCategory );

DeclareOperation( "AddZeroMorphism",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "ZeroMorphismFunction",
                  IsHomalgCategory );

DeclareOperation( "TransportHom",
                  [ IsHomalgCategoryMorphism, IsHomalgCategoryMorphism, IsHomalgCategoryMorphism ] );

###################################
##
#! @Section Subobject functions
##
###################################

DeclareOperation( "IsEqualAsSubobject",
                  [ IsHomalgCategoryMorphism, IsHomalgCategoryMorphism ] );

DeclareOperation( "IsEqualAsFactorobject",
                  [ IsHomalgCategoryMorphism, IsHomalgCategoryMorphism ] );

DeclareOperation( "Dominates",
                  [ IsHomalgCategoryMorphism, IsHomalgCategoryMorphism ] );

DeclareOperation( "AddDominates",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "DominatesFunction",
                  IsHomalgCategory );

DeclareOperation( "Codominates",
                  [ IsHomalgCategoryMorphism, IsHomalgCategoryMorphism ] );

DeclareOperation( "AddCodominates",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "CodominatesFunction",
                  IsHomalgCategory );

###################################
##
#! @Section Morphism functions
##
###################################

DeclareOperation( "PreCompose",
                  [ IsHomalgCategoryMorphism, IsHomalgCategoryMorphism ] );

DeclareAttributeWithToDoForIsWellDefined( "EpiMonoFactorization",
                                          IsHomalgCategoryMorphism );

###################################
##
## IsWellDefined
##
###################################

DeclareOperation( "AddIsWellDefinedForMorphisms",
                  [ IsHomalgCategory, IsFunction ] );

DeclareAttribute( "IsWellDefinedForMorphismsFunction",
                  IsHomalgCategory );

###################################
##
## Monomorphism as kernel lift
##
###################################

#! @Description
#! This operation takes a monomorphism $\iota: K \rightarrow A$
#! and a test morphism $\tau: T \rightarrow A$ and tries
#! to compute a lift $u: T \rightarrow K$ such that
#! $\iota \circ u = \tau$. If this is not possible the method 
#! will return fail.
#! @Returns $u$
#! @Arguments monomorphism, test_morphism
DeclareOperation( "MonoAsKernelLift",
                  [ IsHomalgCategoryMorphism, IsHomalgCategoryMorphism ] );

####################################
##
## Epismorphism as cokernel lift
##
####################################

#! @Description
#! This operation takes an epimorphism $\epsilon: A \rightarrow C$
#! and a test morphism $\tau: A \rightarrow T$ and tries
#! to compute a colift $u: T \rightarrow K$ such that
#! $u \circ \epsilon = \tau$. If this is not possible the method 
#! will return fail.
#! @Returns $u$
#! @Arguments epimorphism, test_morphism
DeclareOperation( "EpiAsCokernelColift",
                  [ IsHomalgCategoryMorphism, IsHomalgCategoryMorphism ] );


###################################
##
#! @Section Implied operations
##
###################################


DeclareOperation( "PostCompose",
                  [ IsHomalgCategoryMorphism, IsHomalgCategoryMorphism ] );
