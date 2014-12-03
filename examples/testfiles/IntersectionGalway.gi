INSTALL_FIBER_PRODUCT := true;

LoadPackage( "ModulePresentationsForHomalg" );

LoadPackage( "RingsForHomalg" );

## Initialisation

Q := HomalgFieldOfRationalsInSingular( );

R := Q * "x,y";

# R := R / "y - x - 1";

F := FreeLeftPresentation( 1, R );

alpha1 := PresentationMorphism( F, HomalgMatrix( "[ [ x ] ]", R ), F );

alpha2 := PresentationMorphism( F, HomalgMatrix( "[ [ y ] ]", R ), F );

## Computation

alpha1 := InDeductiveSystem( alpha1 );

alpha2 := InDeductiveSystem( alpha2 );

P := FiberProduct( alpha1, alpha2 );

pi1 := ProjectionInFactor( P, 1 );

composite := PreCompose( pi1, alpha1 );

PrintHistory( composite );