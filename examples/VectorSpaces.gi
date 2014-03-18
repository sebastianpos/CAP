
LoadPackage( "CategoriesForHomalg" );

###################################
##
#! @Types and Representations
##
###################################

DeclareRepresentation( "IsHomalgRationalVectorSpaceRep",
                       IsHomalgCategoryObjectRep,
                       [ ] );

BindGlobal( "TheTypeOfHomalgRationalVectorSpaces",
        NewType( TheFamilyOfHomalgCategoryObjects,
                IsHomalgRationalVectorSpaceRep ) );

DeclareRepresentation( "IsHomalgRationalVectorSpaceMorphismRep",
                       IsHomalgCategoryMorphismRep,
                       [ ] );

BindGlobal( "TheTypeOfHomalgRationalVectorSpaceMorphism",
        NewType( TheFamilyOfHomalgCategoryMorphisms,
                IsHomalgRationalVectorSpaceMorphismRep ) );

###################################
##
#! @Attributes
##
###################################
                
DeclareAttribute( "Dimension",
                  IsHomalgRationalVectorSpaceRep );

#######################################
##
#! @Operations
##
#######################################
                  
DeclareOperation( "QVectorSpace",
                  [ IsInt ] );

DeclareOperation( "VectorSpaceMorphism",
                  [ IsHomalgRationalVectorSpaceRep, IsObject, IsHomalgRationalVectorSpaceRep ] );

                  
vecspaces := CreateHomalgCategory( "VectorSpaces" );

#######################################
##
#! @Categorical Implementations
##
#######################################

##
InstallMethod( QVectorSpace,
               [ IsInt ],
               
  function( dim )
    local space;
    
    space := rec( );
    
    ObjectifyWithAttributes( space, TheTypeOfHomalgRationalVectorSpaces,
                             Dimension, dim 
    );

    # is this the right place?
    Add( vecspaces, space );
    
    return space;
    
end );

##
InstallMethod( VectorSpaceMorphism,
                  [ IsHomalgRationalVectorSpaceRep, IsObject, IsHomalgRationalVectorSpaceRep ],
                  
  function( source, matrix, range )
    local morphism;
    
    morphism := rec( value := matrix );
    
    if IsMatrix( matrix ) and ( Length( matrix ) <> Dimension( source ) or ( Length( matrix ) > 0 and ( Length( matrix[ 1 ] ) <> Dimension( range ) ) ) ) then
        
        Error( "incorrect dimensions" );
        
    elif not( IsMatrix( matrix ) or matrix = 0 ) then
        
        Error( "incorrect input" );
        
    fi;
    
    ObjectifyWithAttributes( morphism, TheTypeOfHomalgRationalVectorSpaceMorphism,
                             Source, source,
                             Range, range 
    );

    Add( vecspaces, morphism );
    
    return morphism;
    
end );

##
AddIdentityMorphism( vecspaces,
                     
  function( obj )
    local id_morphism;
    
    id_morphism := VectorSpaceMorphism( obj, IdentityMat( Dimension( obj ) ), obj );
    
    return id_morphism;
    
end );

##
AddPreCompose( vecspaces,
               
  function( mor_left, mor_right )
    local matr, new_morph;
    
    if mor_left!.value = 0 or mor_right!.value = 0 then
        
        matr := 0;
        
    else
        
        matr :=  mor_left!.value * mor_right!.value;
        
    fi;
    
    new_morph := VectorSpaceMorphism( Source( mor_left ), matr, Range( mor_right ) );
    
    return new_morph;
    
end );

##
AddZeroObject( vecspaces,
               
  function( )
    
    return QVectorSpace( 0 );
    
end );

##
AddMorphismIntoZeroObject( vecspaces,
                           
  function( obj )
    local dim, category, mat, morphism;
    
    dim := Dimension( obj );
    
    morphism := VectorSpaceMorphism( obj, 0, ZeroObject( obj ) );
    
    return morphism;
    
end );

##
AddMorphismFromZeroObject( vecspaces,
                           
  function( obj )
    local dim, mat, morphism;
    
    dim := Dimension( obj );
    
    morphism := VectorSpaceMorphism( ZeroObject( obj ), 0, obj );
    
    return morphism;
    
end );

##
AddMonoAsKernelLift( vecspaces,

  function( monomorphism, test_morphism )

  

end );

##
AddDirectSum_OnObjects( vecspaces,
                        
  function( a, b )
    local dim;
    
    dim := Dimension( a ) + Dimension( b );
    
    return QVectorSpace( dim );
    
end );

##
AddInjectionFromFirstSummand( vecspaces,
                              
  function( sum_obj )
    local dim1, dim2, first_summand, matrix;
    
    first_summand := FirstSummand( sum_obj );
    
    dim1 := Dimension( first_summand );
    
    dim2 := Dimension( SecondSummand( sum_obj ) );
    
    matrix := TransposedMat( Concatenation( IdentityMat( dim1 ), NullMat( dim2, dim2 ) ) );
    
    return VectorSpaceMorphism( first_summand, matrix, sum_obj );
    
end );

#######################################
##
#! @View and Display
##
#######################################

InstallMethod( ViewObj,
               [ IsHomalgRationalVectorSpaceRep ],

  function( obj )

    Print( "<A rational vector space of dimension ", String( Dimension( obj ) ), ">" );

end );

InstallMethod( ViewObj,
               [ IsHomalgRationalVectorSpaceMorphismRep ],

  function( obj )

    Print( "<A rational vector space homomorphism with matrix " );

    Print( String( obj!.value ) );

    Print( ">" );

end );

#######################################
##
#! @Test
##
#######################################

v := QVectorSpace( 3 );

id := IdentityMorphism( v );

x1 := QVectorSpace( 1 );
x2 := QVectorSpace( 1 );
x3 := QVectorSpace( 1 );

x := VectorSpaceMorphism( x1, [[ 2 ]], x2 );
y := VectorSpaceMorphism( x2, [[ 3 ]], x3 );

