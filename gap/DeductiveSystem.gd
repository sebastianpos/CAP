#############################################################################
##
##                                               CAP package
##
##  Copyright 2014, Sebastian Gutsche, TU Kaiserslautern
##                  Sebastian Posur,   RWTH Aachen
##
#! @Chapter Deduction system
##
#############################################################################

DeclareGlobalVariable( "DEDUCTIVE_SYSTEM_OPTIONS" );

DeclareCategory( "IsDeductiveSystemCell",
                 IsCapCategoryCell );

DeclareCategory( "IsDeductiveSystemObject",
                 IsDeductiveSystemCell and IsCapCategoryObject );

DeclareCategory( "IsDeductiveSystemMorphism",
                 IsDeductiveSystemCell and IsCapCategoryMorphism );

DeclareCategory( "IsDeductiveSystemTwoCell",
                 IsDeductiveSystemCell and IsCapCategoryTwoCell );

DeclareGlobalFunction( "INSTALL_PROPERTIES_FOR_DEDUCTIVE_SYSTEM" );

DeclareGlobalFunction( "ADDS_FOR_DEDUCTIVE_SYSTEM" );

DeclareGlobalFunction( "RESOLVE_HISTORY" );

DeclareGlobalFunction( "RECURSIVE_EVAL" );

DeclareGlobalFunction( "HistoryToString" );

DeclareGlobalFunction( "PRINT_HISTORY_RECURSIVE" );

DeclareGlobalFunction( "PrintHistoryClean" );

DeclareGlobalFunction( "PrintHistory" );

#####################################
##
## Constructor
##
#####################################

DeclareAttribute( "DeductiveSystem",
                  IsCapCategory );

DeclareAttribute( "InDeductiveSystem",
                  IsCapCategoryObject );

DeclareOperation( "DeductiveSystemObject",
                  [ IsCapCategory ] );

DeclareOperation( "DeductiveSystemObject",
                  [ IsString, IsList ] );

DeclareAttribute( "InDeductiveSystem",
                  IsCapCategoryMorphism );

DeclareOperation( "DeductiveSystemMorphism",
                  [ IsDeductiveSystemObject, IsString, IsList, IsDeductiveSystemObject ] );

DeclareOperation( "DeductiveSystemMorphism",
                  [ IsDeductiveSystemObject, IsDeductiveSystemObject ] );

#####################################
##
## Special Add
##
#####################################

#####################################
##
## Attributes
##
#####################################

DeclareAttribute( "History",
                  IsDeductiveSystemCell, "mutable" );

DeclareOperation( "Evaluation",
                  [ IsDeductiveSystemCell ] );

DeclareOperation( "HasEvaluation",
                  [ IsDeductiveSystemCell ] );

DeclareOperation( "SetEvaluation",
                  [ IsDeductiveSystemCell, IsCapCategoryCell ] );

#####################################
##
## Attributes for all cells
##
#####################################

DeclareAttribute( "ChecksFromLogic",
                  IsCapCategoryCell, "mutable" );
