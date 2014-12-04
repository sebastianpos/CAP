INSTALL_FIBER_PRODUCT := false;

LoadPackage( "ModulePresentationsForHomalg" );

LoadPackage( "RingsForHomalg" );

Q := HomalgFieldOfRationalsInSingular( );

R := Q * "x,y";

F := FreeLeftPresentation( 1, R );

alpha1 := PresentationMorphism( F, HomalgMatrix( "[ [ x ] ]", R ), F );

alpha2 := PresentationMorphism( F, HomalgMatrix( "[ [ y ] ]", R ), F );

alpha1 := InDeductiveSystem( alpha1 );

alpha2 := InDeductiveSystem( alpha2 );

P := FiberProduct( alpha1, alpha2 );

pi1 := ProjectionInFactor( P, 1 );

composite := PreCompose( pi1, alpha1 );

PrintHistory( composite );