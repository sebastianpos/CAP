#############################################################################
##
##                                               CAP package
##
##  Copyright 2014, Sebastian Gutsche, TU Kaiserslautern
##                  Sebastian Posur,   RWTH Aachen
##
#############################################################################

#####################################
##
## Reps for object and morphism
##
#####################################

DeclareRepresentation( "IsHomalgTerminalCategoryObjectRep",
                       IsAttributeStoringRep and IsCapCategoryObjectRep,
                       [ ] );

DeclareRepresentation( "IsHomalgTerminalCategoryMorphismRep",
                       IsAttributeStoringRep and IsCapCategoryMorphismRep,
                       [ ] );

BindGlobal( "TheTypeOfHomalgTerminalCategoryObject",
        NewType( TheFamilyOfCapCategoryObjects,
                IsHomalgTerminalCategoryObjectRep ) );

BindGlobal( "TheTypeOfHomalgTerminalCategoryMorphism",
        NewType( TheFamilyOfCapCategoryMorphisms,
                IsHomalgTerminalCategoryMorphismRep ) );

#####################################
##
## Constructor
##
#####################################

InstallValue( CAP_INTERNAL_TERMINAL_CATEGORY,
              
              CreateCapCategory( "TerminalCategory" ) );

SetFilterObj( CAP_INTERNAL_TERMINAL_CATEGORY, IsTerminalCategory );

InstallValue( CAP_INTERNAL_TERMINAL_CATEGORY_AS_CAT_OBJECT,
              
              AsCatObject( CAP_INTERNAL_TERMINAL_CATEGORY ) );

##
InstallMethod( UniqueObject,
               [ IsCapCategory and IsTerminalCategory ],
               
  function( category )
    local object;
    
    object := rec( );
    
    ObjectifyWithAttributes( object, TheTypeOfHomalgTerminalCategoryObject,
                             IsZero, true );
    
    Add( CAP_INTERNAL_TERMINAL_CATEGORY, object );
    
    SetIsWellDefined( object, true );
    
    SetIsZero( object, true );
    
    return object;
    
end );

##
InstallMethod( UniqueMorphism,
               [ IsCapCategory and IsTerminalCategory ],
               
  function( category )
    local morphism, object;
    
    morphism := rec( );
    
    object := Object( CAP_INTERNAL_TERMINAL_CATEGORY );
    
    ObjectifyWithAttributes( morphism, TheTypeOfHomalgTerminalCategoryMorphism,
                             Source, object,
                             Range, object,
                             IsOne, true );
    
    Add( CAP_INTERNAL_TERMINAL_CATEGORY, morphism );
    
    SetIsWellDefined( morphism, true );
    
    return morphism;
    
end );

################################
##
## Category functions
##
################################

##
BindGlobal( "INSTALL_TERMINAL_CATEGORY_FUNCTIONS",
            
  function( )
    local obj_function_list, obj_func, morphism_function_list, morphism_function, i;
    
    obj_function_list := [ AddZeroObject,
                           AddKernelObject,
                           AddCokernel,
                           AddDirectProduct ];
    
    obj_func := function( arg ) return UniqueObject( CAP_INTERNAL_TERMINAL_CATEGORY ); end;
    
    for i in obj_function_list do
        
        i( CAP_INTERNAL_TERMINAL_CATEGORY, obj_func );
        
    od;
    
    morphism_function_list := [ AddIdentityMorphism,
                                AddPreCompose,
                                AddMonoAsKernelLift,
                                AddEpiAsCokernelColift,
                                AddInverse,
                                AddKernelEmb,
                                AddKernelEmbWithGivenKernelObject,
                                AddKernelLiftWithGivenKernelObject,
                                AddCokernelProj,
                                AddCokernelProjWithGivenCokernel,
                                AddCokernelColift,
                                AddCokernelColiftWithGivenCokernel,
                                AddProjectionInFactorOfDirectProduct,
                                AddProjectionInFactorOfDirectProductWithGivenDirectProduct,
                                AddUniversalMorphismIntoDirectProduct,
                                AddUniversalMorphismIntoDirectProductWithGivenDirectProduct ];
    
    morphism_function := function( arg ) return UniqueMorphism( CAP_INTERNAL_TERMINAL_CATEGORY ); end;
    
    for i in morphism_function_list do
        
        i( CAP_INTERNAL_TERMINAL_CATEGORY, morphism_function );
        
    od;
    
end );

INSTALL_TERMINAL_CATEGORY_FUNCTIONS( );

################################
##
## Functor constructors
##
################################

##
InstallMethod( FunctorFromTerminalCategory,
               [ IsCapCategoryObject and CanComputeIdentityMorphism ],
               
  function( object )
    local functor;
    
    functor := CapFunctor( Concatenation( "InjectionInto", Name( CapCategory( object ) ) ), CAP_INTERNAL_TERMINAL_CATEGORY, CapCategory( object ) );
    
    functor!.terminal_object_functor_object := object;
    
    AddObjectFunction( functor,
                       
      function( arg )
        
        return functor!.terminal_object_functor_object;
        
    end );
    
    AddMorphismFunction( functor,
                         
      function( arg )
        
        return IdentityMorphism( functor!.terminal_object_functor_object );
        
    end );
    
    return functor;
    
end );

##
InstallMethod( FunctorFromTerminalCategory,
               [ IsCapCategoryMorphism and IsOne ],
               
  morphism -> FunctorFromTerminalCategory( Source( morphism ) )
  
);
