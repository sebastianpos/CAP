DeclareRepresentation( "IsDerivationRep",
                       IsAttributeStoringRep and IsDerivation,
                       [] );
DeclareRepresentation( "IsDerivationGraphRep",
                       IsAttributeStoringRep and IsDerivationGraph,
                       [] );
DeclareRepresentation( "IsOperationWeightListRep",
                       IsComponentObjectRep and IsOperationWeightList,
                       [] );

BindGlobal( "TheFamilyOfDerivations",
            NewFamily( "TheFamilyOfDerivations" ) );
BindGlobal( "TheFamilyOfDerivationGraphs",
            NewFamily( "TheFamilyOfDerivationGraphs" ) );
BindGlobal( "TheFamilyOfOperationWeightLists",
            NewFamily( "TheFamilyOfOperationWeightLists" ) );

InstallMethod( MakeDerivation,
               [ IsString, IsFunction, IsDenseList,
                 IsPosInt, IsFunction ],
function( name, target_op, used_ops_with_multiples,
          weight, implementation )
  local d, used_ops, used_op_multiples;
  d := rec();
  used_ops := List( used_ops_with_multiples,
                    l -> NameFunction( l[ 1 ] ) );
  used_op_multiples := List( used_ops_with_multiples, l -> l[ 2 ] );
  ObjectifyWithAttributes
    ( d,
      NewType( TheFamilyOfDerivations, IsDerivationRep ),
      DerivationName, name,
      DerivationWeight, weight,
      DerivationFunction, implementation,
      TargetOperation, NameFunction( target_op ),
      UsedOperations, used_ops,
      UsedOperationMultiples, used_op_multiples );
  # TODO options
  return d;
end );

InstallMethod( InstallDerivationForCategory,
               [ IsDerivation, IsPosInt, IsCapCategory ],
function( d, weight, C )
  Print( "install(", weight, ") ", TargetOperation( d ),
         ": ", DerivationName( d ), "\n" );
  # TODO actual installation
end );

InstallMethod( DerivationResultWeight,
               [ IsDerivation, IsDenseList ],
function( d, op_weights )
  local w, used_op_multiples, i, op_w, mult;
  w := DerivationWeight( d );
  used_op_multiples := UsedOperationMultiples( d );
  for i in [ 1 .. Length( used_op_multiples ) ] do
    op_w := op_weights[ i ];
    mult := used_op_multiples[ i ];
    if op_w = infinity then
      return infinity;
    fi;
    w := w + op_w * mult;
  od;
  return w;
end );

InstallMethod( MakeDerivationGraph,
               [ IsDenseList ],
function( operations )
  local G, op_name;
  G := rec( derivations_by_target := rec(),
              derivations_by_used_ops := rec() );
  ObjectifyWithAttributes
    ( G,
      NewType( TheFamilyOfDerivationGraphs,
               IsDerivationGraphRep ),
      Operations, operations );
  for op_name in operations do
    G!.derivations_by_target.( op_name ) := [];
    G!.derivations_by_used_ops.( op_name ) := [];
  od;
  return G;
end );

InstallMethod( AddDerivation,
               [ IsDerivationGraphRep, IsDerivation ],
function( G, d )
  local op_name;
  Add( G!.derivations_by_target.( TargetOperation( d ) ), d );
  for op_name in UsedOperations( d ) do
    Add( G!.derivations_by_used_ops.( op_name ), d );
  od;
end );

InstallMethod( DerivationsUsingOperation,
               [ IsDerivationGraphRep, IsString ],
function( G, op_name )
  return G!.derivations_by_used_ops.( op_name );
end );

InstallMethod( DerivationsOfOperation,
               [ IsDerivationGraphRep, IsString ],
function( G, op_name )
  return G!.derivations_by_target.( op_name );
end );

InstallMethod( MakeOperationWeightList,
               [ IsCapCategory, IsDerivationGraph ],
function( C, G )
  local owl, op_name;
  owl := Objectify( NewType( TheFamilyOfOperationWeightLists,
                             IsOperationWeightListRep ),
                    rec( category := C,
                         graph := G,
                         operation_weights := rec(),
                         operation_derivations := rec() ) );
  for op_name in Operations( G ) do
    owl!.operation_weights.( op_name ) := infinity;
    owl!.operation_derivations.( op_name ) := fail;
  od;
  return owl;
end );

InstallMethod( CurrentOperationWeight,
               [ IsOperationWeightListRep, IsString ],
function( owl, op_name )
  return owl!.operation_weights.( op_name );
end );

InstallMethod( OperationWeightUsingDerivation,
               [ IsOperationWeightListRep, IsDerivation ],
function( owl, d )
  return DerivationResultWeight
         ( d, List( UsedOperations( d ),
                    op_name -> CurrentOperationWeight( owl, op_name ) ) );
end );

InstallMethod( DerivationOfOperation,
               [ IsOperationWeightListRep, IsString ],
function( owl, op_name )
  return owl!.operation_derivations.( op_name );
end );

InstallMethod( InstallDerivationsUsingOperation,
               [ IsOperationWeightListRep, IsString ],
function( owl, op_name )
  local Q, node, weight, d, new_weight, max_weight,
        target, new_node;
  Q := StringMinHeap();
  Add( Q, op_name, 0 );
  while not IsEmptyHeap( Q ) do
    node := ExtractMin( Q );
    op_name := node[ 1 ];
    weight := node[ 2 ];
    for d in DerivationsUsingOperation( owl!.graph, op_name ) do
      new_weight := OperationWeightUsingDerivation( owl, d );
      target := TargetOperation( d );
      if new_weight < CurrentOperationWeight( owl, target ) then
        InstallDerivationForCategory( d, new_weight, owl!.category );
        if Contains( Q, target ) then
          DecreaseKey( Q, target, new_weight );
        else
          Add( Q, target, new_weight );
        fi;
        owl!.operation_weights.( target ) := new_weight;
        owl!.operation_derivations.( target ) := d;
      fi;
    od;
  od;
end );  

InstallMethod( AddPrimitiveOperation,
               [ IsOperationWeightListRep, IsString, IsInt ],
function( owl, op_name, weight )
  owl!.operation_weights.( op_name ) := weight;
  InstallDerivationsUsingOperation( owl, op_name );
end );




DeclareRepresentation( "IsStringMinHeapRep",
                       IsComponentObjectRep and IsStringMinHeap,
                       [] );

BindGlobal( "TheFamilyOfStringMinHeaps",
            NewFamily( "TheFamilyOfStringMinHeaps" ) );

InstallGlobalFunction( StringMinHeap,
function()
  return Objectify( NewType( TheFamilyOfStringMinHeaps,
                             IsStringMinHeapRep ),
                    rec( key := function(n) return n[2]; end,
                         str := function(n) return n[1]; end,
                         array := [],
                         node_indices := rec() ) );
end );

InstallMethod( HeapSize,
               [ IsStringMinHeapRep ],
function( H )
  return Length( H!.array );
end );

InstallMethod( Add,
               [ IsStringMinHeapRep, IsString, IsInt ],
function( H, string, key )
  local array, i;
  array := H!.array;
  i := Length( array ) + 1;
  H!.node_indices.( string ) := i;
  array[ i ] := [ string, key ];
  DecreaseKey( H, string, key );
end );

InstallMethod( IsEmptyHeap,
               [ IsStringMinHeapRep ],
function( H )
  return IsEmpty( H!.array );
end );

InstallMethod( ExtractMin,
               [ IsStringMinHeapRep ],
function( H )
  local array, node;
  array := H!.array;
  node := array[ 1 ];
  Swap( H, 1, Length( array ) );
  Unbind( array[ Length( array ) ] );
  Unbind( H!.node_indices.( H!.str( node ) ) );
  if not IsEmpty( array ) then
    Heapify( H, 1 );
  fi;
  return node;
end );

InstallMethod( DecreaseKey,
               [ IsStringMinHeapRep, IsString, IsInt ],
function( H, string, key )
  local array, i, parent;
  array := H!.array;
  i := H!.node_indices.( string );
  array[ i ][ 2 ] := key;
  parent := Int( i / 2 );
  while parent > 0 and H!.key( array[ i ] ) < H!.key( array[ parent ] ) do
    Swap( H, i, parent );
    i := parent;
    parent := Int( i / 2 );
  od;
end );

InstallMethod( Swap,
               [ IsStringMinHeapRep, IsPosInt, IsPosInt ],
function( H, i, j )
  local tmp, array, node_indices, str;
  array := H!.array;
  node_indices := H!.node_indices;
  str := H!.str;
  tmp := array[ i ];
  array[ i ] := array[ j ];
  array[ j ] := tmp;
  node_indices.( str( array[ i ] ) ) := i;
  node_indices.( str( array[ j ] ) ) := j;
end );

InstallMethod( Contains,
               [ IsStringMinHeapRep, IsString ],
function( H, string )
  return IsBound( H!.node_indices.( string ) );
end );

InstallMethod( Heapify,
               [ IsStringMinHeapRep, IsPosInt ],
function( H, i )
  local key, array, left, right, smallest;
  key := H!.key;
  array := H!.array;
  left := 2 * i;
  right := 2 * i + 1;
  smallest := i;
  if left <= HeapSize( H ) and key( array[ left ] ) < key( array[ smallest ] ) then
    smallest := left;
  fi;
  if right <= HeapSize( H ) and key( array[ right ] ) < key( array[ smallest ] ) then
    smallest := right;
  fi;
  if smallest <> i then
    Swap( H, i, smallest );
    Heapify( H, smallest );
  fi;
end );
