#############################################################################
##
##                                               CategoriesForHomalg package
##
##  Copyright 2014, Sebastian Gutsche, TU Kaiserslautern
##                  Sebastian Posur,   RWTH Aachen
##
#! @Chapter Universal Objects
#! NOTE: This text has to updated, since caching is not inevitable due to IsEqualForObjects and IsEqualForMorphisms.
#! Let $I$ and $A$ be categories. A functor $D: I \rightarrow A$ is sometimes also called
#! a diagram with index category $I$.
#! A limit of a diagram $D$ is an object $X$ together with a collection of morphisms
#! $(s_i: X \rightarrow D_i)_{i \in I}$, called a source, such that for every other source
#! $(t_i: T \rightarrow D_i)_{i \in I}$, there exists a unique morphism $u: T \rightarrow X$ such that
#! $s_i \circ u = t_i$ for all $i$. 
#! Dually, a colimit of a diagram $D$ is an object $X$ together with a collection of morphisms
#! $(s_i: D_i \rightarrow X)_{i \in I}$, called a sink, such that for every other sink
#! $(t_i: D_i \rightarrow T)_{i \in I}$, there exists a unique morphism $u: X \rightarrow T$ such that
#! $u \circ s_i = t_i$ for all $i$. 
#! We call such objects universal.
#! For every universal object $X$, there are 5 methods which can be installed:
#! * $D \mapsto X$: Constructor of $X$ with a diagram $D$ (i.e. a list of morphisms and objects) as an input 
#! * $D \mapsto s_i$: Constructor of source/sink data with input $D$
#! * $(D,X) \mapsto s_i$: Constructor of source/sink data with input $D$ and $X$
#! * $(D, t_i) \mapsto u$: Constructor of universal property morphism with input $D$ and a test source/sink $T$
#! * $(D, t_i, X) \mapsto u$: Constructor of universal property morphism with input $D$ and a test source/sink $T$ and $X$
#! The convention in CategoriesForHomalg is: every diagram $D$ should only have one universal object $X$.
#! Thus every computed $X$ will be cached. For example, if you compute the pullback object of a given
#! diagram twice, you will get identical objects (IsIdenticalObj will return true).
#! <Br/>
#! This convention becomes inevitable if you build functors out of universal objects, because 
#! functors are in particular mathematical maps which only allow exactly one output for one given input.
#! <Br/>
#! This convention also clarifies the relevance of the constructors which have $D$ and $X$ as an input:
#! if you have a constructor for $D \mapsto X$, you must also have a constructor
#! for $(D,X) \mapsto s_i$ in order to compute the $s_i$. Because if you first construct $X$
#! from $D$, $X$ is once and for all cached as the universal object of $D$. In particular, the
#! maps $s_i$ must have source/ range identical to $X$. But this can only be guaranteed by
#! having $X$ as part of the input in the constructor of the $s_i$.
#! <Br/>
#! The following combinations of implementations of the above constructors allow a full functionality 
#! of the universal object in question:
#! * implement all constructors
#! * implement $D \mapsto s_i$ and $(D, t_i, X) \mapsto u$
#! * implement $D \mapsto X$, $(D,X) \mapsto s_i$ and $(D, t_i, X) \mapsto u$
#! * implement $D \mapsto X$, $D \mapsto s_i$, $(D,X) \mapsto s_i$ and $(D, t_i, X) \mapsto u$
#! * implement $D \mapsto X$, $(D,X) \mapsto s_i$, $(D, t_i) \mapsto u$ and $(D, t_i, X) \mapsto u$
#! Sometimes, there are even shorter ways: in an abelian category, all you have to implement 
#! for a kernel is:
#! * KernelEmb
#! * MonoAsKernelLift
#! One note: a derived method should never use constructors with given $X$ as an input.
#! The internals of CategoriesForHomalg will take care that no confusion accurs. For example: if you
#! call KernelEmb of a morphism $\alpha$, CategoriesForHomalg works as follows:
#! * Check the cache: is the kernel embedding of $\alpha$ already computed? If yes, return this cached embedding.
#! * Otherwise, check if the kernel object of $\alpha$ is already computed. If yes, call KernelEmbWithGivenKernel( $\alpha$ ). If no, call KernelEmb( $\alpha$ ).
#! 
#! One further note: every universal object stores if it was created as such and therefore can be used to access universal property morphisms (if computable).
#############################################################################

####################################
##
#! @Section Type system
##
####################################

#! Explaination of methods of the form $\texttt{Add}F( f, C )$ for a function name $F$ (e.g. KernelLift, DirectProduct),
#! a function $f$ and a CapCategory $C$:
#! The method $\texttt{Add}F( f, C )$ installs the method with the name $F$ properly such that it can be
#! used within the context of the given category $C$. 
#! Valid types for the (multiple) arguments of $F$ are:
#! * CapCategoryObject
#! * CapCategoryMorphism
#! * List containing only CapCategoryObjects
#! * List containing only CapCategoryMorphisms
#! * Integer
#! Valid types for the output of $F$ are:
#! * CapCategoryObject
#! * CapCategoryMorphism.
#! Note the name convention: If $\texttt{Add}F$ is a method, then so is $F$.


## needed for multiple genesis
DeclareOperation( "AddToGenesis",
                  [ IsCapCategoryCell, IsObject, IsObject ] );

####################################
##
#! @Section Kernel
##
####################################

#! Let $\alpha: A \rightarrow B$ be a morphism. A kernel of $\alpha$ is a morphism
#! $\iota: K \rightarrow A$ such that $\alpha \circ \iota = 0$ and such that for 
#! every test morphism $\tau: T \rightarrow A$ with $\alpha \circ \tau = 0$, there
#! exists a unique morphism $u: T \rightarrow K$ such that $\iota \circ u = \tau$.

## Main Operations and Attributes
#! @Description
#!  Kernel of a given morphism.
#! @Returns IsCapCategoryObject
#! @Arguments alpha
DeclareAttributeWithToDoForIsWellDefined( "KernelObject",
                                          IsCapCategoryMorphism );

#! @Description
#! Embedding of the kernel of a given morphism $\alpha$ into the source of $\alpha$.
#! @Returns IsCapCategoryMorphism
#! @Arguments alpha
DeclareAttributeWithToDoForIsWellDefined( "KernelEmb",
                                          IsCapCategoryMorphism );

#! @Description
#! Kernel embedding of an object which was created as a kernel.
#! @Returns IsCapCategoryMorphism
#! @Arguments K
DeclareAttributeWithToDoForIsWellDefined( "KernelEmb",
                                          IsCapCategoryObject );

#! @Description
#! Embedding of a given kernel $K$ of a given morphism $\alpha$ into the source of $\alpha$.
#! @Returns IsCapCategoryMorphism
#! @Arguments alpha, K
DeclareOperationWithCache( "KernelEmbWithGivenKernel",
                  [ IsCapCategoryMorphism, IsCapCategoryObject ] );

# @Description
#! Given a kernel $K$ of a morphism $\alpha:A \rightarrow B$ and a testmorphism $\tau: T \rightarrow A$ such that $\alpha \circ \tau = 0$, this method
#! returns the unique morphism $u: T \rightarrow K$ such that $\tau = \epsilon \circ u$, where $\epsilon: \mathrm{Kern}(\alpha) \rightarrow A$
#! denotes the kernel embedding.
#! @Returns IsCapCategoryMorphism
#! @Arguments K, tau
DeclareOperation( "KernelLift",
                  [ IsCapCategoryObject, IsCapCategoryMorphism ] );

#! @Description
#! Given a morphism $\alpha: A \rightarrow B$ and a testmorphism $\tau: T \rightarrow A$ such that $\alpha \circ \tau = 0$, this method
#! returns the unique morphism $u: T \rightarrow K$ such that $\tau = \epsilon \circ u$, where $\epsilon: \mathrm{Kern}(\alpha) \rightarrow A$
#! denotes the kernel embedding.
#! @Returns IsCapCategoryMorphism
#! @Arguments alpha, tau
DeclareOperationWithCache( "KernelLift",
                  [ IsCapCategoryMorphism, IsCapCategoryMorphism ] );

#! @Description
#! Given a morphism $\alpha: A \rightarrow B$ with a kernel $K$ and a testmorphism $\tau: T \rightarrow A$ such that $\alpha \circ \tau = 0$, this method
#! returns the unique morphism $u: T \rightarrow K$ such that $\tau = \epsilon \circ u$, where $\epsilon: K \rightarrow A$
#! denotes the kernel embedding.
#! @Returns IsCapCategoryMorphism
#! @Arguments alpha, tau, K
DeclareOperationWithCache( "KernelLiftWithGivenKernel",
                  [ IsCapCategoryMorphism, IsCapCategoryMorphism, IsCapCategoryObject ] );


## Function Attributes
#! @AutoDoc
#! @BeginGroup

#! @Description
#! These attributes store the implementations of the basic algorithms for a kernel. 
DeclareAttribute( "KernelFunction",
                  IsCapCategory );

DeclareAttribute( "KernelEmbFunction",
                  IsCapCategory );

DeclareAttribute( "KernelEmbWithGivenKernelFunction",
                  IsCapCategory );

DeclareAttribute( "KernelLiftFunction",
                  IsCapCategory );

DeclareAttribute( "KernelLiftWithGivenKernelFunction",
                  IsCapCategory );
#! @EndGroup
#! @EndAutoDoc

## Add Operations

#! @Description
#! This operation adds the given function $f: \alpha \mapsto K$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddKernelObject",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: \alpha \mapsto \iota$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddKernelEmb",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (\alpha, K) \mapsto \iota$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddKernelEmbWithGivenKernel",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (\alpha, \tau) \mapsto u$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddKernelLift",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (\alpha, \tau, K) \mapsto u$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddKernelLiftWithGivenKernel",
                  [ IsCapCategory, IsFunction ] );


#! @Section Functorial methods for kernel

#! KernelObject is a functorial operation. This means:
#! for $\mu: A \rightarrow A'$, $\nu: B \rightarrow B'$,
#! $\alpha: A \rightarrow B$, $\alpha': A' \rightarrow B'$ such that $\nu \circ \alpha = \alpha' \circ \mu$,
#! we obtain a morphism $\phi: \mathrm{Kernel}( \alpha ) \rightarrow \mathrm{Kernel}( \alpha' )$.


#! @Description
#! This method takes $L = [ \alpha, [ \mu, \nu ], \alpha' ]$ as an input.
#! @Returns $\phi$
#! @Arguments L
DeclareOperation( "KernelObjectFunctorial",
                  [ IsList ] );

#! @Description
#! For the computation of $\phi$, you do not need $\nu$.
#! @Returns $\phi$
#! @Arguments alpha, mu, alpha_p
DeclareOperation( "KernelObjectFunctorial",
                  [ IsCapCategoryMorphism, IsCapCategoryMorphism, IsCapCategoryMorphism ] );


## WasCreatedAs Filter
#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for a kernel object. 
#! Note that we chose <C>WasCreatedAsKernel</C> to be a filter rather than a property,
#! because by default, a filter is set to false. 
DeclareFilter( "WasCreatedAsKernel" );

#! @Chapter Universal Objects

####################################
##
#!  @Section Cokernel
##
####################################

#! Let $\alpha: A \rightarrow B$ be a morphism. A cokernel of $\alpha$ is a morphism
#! $\epsilon: B \rightarrow C$ such that $\epsilon \circ \alpha = 0$ and such that for 
#! every test morphism $\tau: B \rightarrow T$ with $\tau \circ \alpha = 0$, there
#! exists a unique morphism $u: C \rightarrow T$ such that $u \circ \epsilon  = \tau$.


## Main Operations and Attributes
#! @Description
#!  Cokernel of a given morphism.
#! @Returns IsCapCategoryObject
#! @Arguments alpha
DeclareAttributeWithToDoForIsWellDefined( "Cokernel",
                                          IsCapCategoryMorphism );

#! @Description
#! Projection $B \twoheadrightarrow \mathrm{Coker}(\alpha)$ into the cokernel of a given morphism $\alpha: A \rightarrow B$.
#! @Returns IsCapCategoryMorphism
#! @Arguments alpha
DeclareAttributeWithToDoForIsWellDefined( "CokernelProj",
                                          IsCapCategoryMorphism );

#! @Description
#! Cokernel projection of an object which was created as a cokernel.
#! @Returns IsCapCategoryMorphism
#! @Arguments C
DeclareAttributeWithToDoForIsWellDefined( "CokernelProj",
                                          IsCapCategoryObject );

#! @Description
#! Projection $B \twoheadrightarrow C$ of a given cokernel $C$ of a given morphism $\alpha: A \rightarrow B$.
#! @Returns IsCapCategoryMorphism
#! @Arguments alpha, C
DeclareOperationWithCache( "CokernelProjWithGivenCokernel",
                  [ IsCapCategoryMorphism, IsCapCategoryObject ] );


#! @Description
#! Given a cokernel $C$ of a morphism $\alpha: A \rightarrow B$ and a testmorphism $\tau: B \rightarrow T$ such that $\tau \circ \alpha = 0$, this method
#! returns the unique morphism $u: \mathrm{Coker}(\alpha) \rightarrow T$ such that $\tau = u \circ \epsilon$, where 
#! $\epsilon: B \rightarrow \mathrm{Coker}(\alpha)$ denotes the cokernel projection.
#! @Returns IsCapCategoryMorphism
#! @Arguments C, tau
DeclareOperation( "CokernelColift",
                  [ IsCapCategoryObject, IsCapCategoryMorphism ] );

#! @Description
#! Given a morphism $\alpha: A \rightarrow B$ and a testmorphism $\tau: B \rightarrow T$ such that $\tau \circ \alpha = 0$, this method
#! returns the unique morphism $u: \mathrm{Coker}(\alpha) \rightarrow T$ such that $\tau = u \circ \epsilon$, where 
#! $\epsilon: B \rightarrow \mathrm{Coker}(\alpha)$ denotes the cokernel projection.
#! @Returns IsCapCategoryMorphism
#! @Arguments alpha, tau
DeclareOperationWithCache( "CokernelColift",
                  [ IsCapCategoryMorphism, IsCapCategoryMorphism ] );
#! @Description
#! Given a morphism $\alpha: A \rightarrow B$ with its cokernel $C$ and a testmorphism $\tau: B \rightarrow T$ 
#! such that $\tau \circ \alpha = 0$, this method returns the unique morphism $u: C \rightarrow T$ such that 
#! $\tau = u \circ \epsilon$, where $\epsilon: B \rightarrow C$ denotes the cokernel projection.
#! @Returns IsCapCategoryMorphism
#! @Arguments alpha, tau, C
DeclareOperationWithCache( "CokernelColiftWithGivenCokernel",
                  [ IsCapCategoryMorphism, IsCapCategoryMorphism, IsCapCategoryObject ] );

## Function Attributes
#! @AutoDoc
#! @BeginGroup

#! @Description
#! These attributes store the implementations of the basic algorithms for a cokernel. 
DeclareAttribute( "CokernelFunction",
                  IsCapCategory );

DeclareAttribute( "CokernelProjFunction",
                  IsCapCategory );

DeclareAttribute( "CokernelProjWithGivenCokernelFunction",
                  IsCapCategory );

DeclareAttribute( "CokernelColiftFunction",
                  IsCapCategory );

DeclareAttribute( "CokernelColiftWithGivenCokernelFunction",
                  IsCapCategory );
#! @EndGroup
#! @EndAutoDoc


## Add Operations
#! @Description
#! This operation adds the given function $f: \alpha \mapsto C$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddCokernel",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: \alpha \mapsto \epsilon$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddCokernelProj",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (\alpha, C) \mapsto \epsilon$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddCokernelProjWithGivenCokernel",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (\alpha, \tau) \mapsto u$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddCokernelColift",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (\alpha, \tau, C) \mapsto u$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddCokernelColiftWithGivenCokernel",
                  [ IsCapCategory, IsFunction ] );

#! @Section Functorial methods for cokernel

#! Cokernel is a functorial operation. This means:
#! for $\mu: A \rightarrow A'$, $\nu: B \rightarrow B'$,
#! $\alpha: A \rightarrow B$, $\alpha': A' \rightarrow B'$ such that $\nu \circ \alpha = \alpha' \circ \mu$,
#! we obtain a morphism $\phi: \mathrm{Cokernel}( \alpha ) \rightarrow \mathrm{Cokernel}( \alpha' )$.


#! @Description
#! This method takes $L = [ \alpha, [ \mu, \nu ], \alpha' ]$ as an input.
#! @Returns $\phi$
#! @Arguments L
DeclareOperation( "CokernelFunctorial",
                  [ IsList ] );

#! @Description
#! For the computation of $\phi$, you do not need $\mu$.
#! @Returns $\phi$
#! @Arguments alpha, nu, alpha_p
DeclareOperation( "CokernelFunctorial",
                  [ IsCapCategoryMorphism, IsCapCategoryMorphism, IsCapCategoryMorphism ] );

## WasCreatedAs Filter
#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for a cokernel object. 
#! Note that we chose <C>WasCreatedAsCokernel</C> to be a filter rather than a property,
#! because by default, a filter is set to false. 
DeclareFilter( "WasCreatedAsCokernel" );

#! @Chapter Universal Objects

####################################
##
#! @Section Zero object
##
####################################

#! A zero object of a category $C$ is an object $Z$ which is an initial and a terminal object.

## Main Operations and Attributes

#! @BeginGroup 

#! @Description
#! Zero object of a category $C$
#! @Returns IsCapCategoryObject
#! @Arguments C
DeclareAttribute( "ZeroObject",
                  IsCapCategory );

#! @Description
#! or of a cell $c$ in $C$
#! @Arguments c
DeclareAttribute( "ZeroObject",
                  IsCapCategoryCell );

DeclareAttributeWithToDoForIsWellDefined( "MorphismFromZeroObject",
                                          IsCapCategoryObject );

DeclareAttributeWithToDoForIsWellDefined( "MorphismIntoZeroObject",
                                          IsCapCategoryObject );

#! @EndGroup 


## Function Attributes

#! @BeginGroup

#! @Description
#! These attributes store the implementations of the basic algorithms for a terminal object.
#! @Arguments C
DeclareAttribute( "ZeroObjectFunction",
                  IsCapCategory );

#! @EndGroup

## Add Operations

#! @Description
#! This operation adds the given function $f$: (no argument) $\mapsto Z$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddZeroObject",
                  [ IsCapCategory, IsFunction ] );




## WasCreatedAs Filter

#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for a zero object. 
#! Note that we chose <C>WasCreatedAsZeroObject</C> to be a filter rather than a property,
#! because by default, a filter is set to false.
DeclareFilter( "WasCreatedAsZeroObject" );

DeclareProperty( "IS_IMPLIED_ZERO_OBJECT", 
                 IsCapCategoryObject );
#! @Chapter Universal Objects

####################################
##
#! @Section Terminal object
##
####################################

#! An object $T$ of a category $C$ is called terminal if for every object $A$
#! there exists a unique morphism $u: A \rightarrow T$.

## Main Operations and Attributes

#! @BeginGroup 

#! @Description
#! Terminal object of a category $C$
#! @Returns IsCapCategoryObject
#! @Arguments C
DeclareAttribute( "TerminalObject",
                  IsCapCategory );

#! @Description
#! or of a cell $c$ in $C$
#! @Arguments c
DeclareAttribute( "TerminalObject",
                  IsCapCategoryCell );

#! @EndGroup 

#! @Description
#! Given an object $A$ this method returns the unique morphism $u: A \rightarrow T$ from 
#! $A$ into the terminal object $T$ of the category of $A$
#! @Returns IsCapCategoryMorphism
#! @Arguments A
DeclareAttributeWithToDoForIsWellDefined( "UniversalMorphismIntoTerminalObject",
                                          IsCapCategoryObject );

#! @Description
#! Given an object $A$ and a terminal object $T$ this method returns the unique morphism $u: A \rightarrow T$ from 
#! $A$ to $T$
#! @Returns IsCapCategoryMorphism
#! @Arguments A, T
DeclareOperationWithCache( "UniversalMorphismIntoTerminalObjectWithGivenTerminalObject",
                  [ IsCapCategoryObject, IsCapCategoryObject ] );

## Function Attributes

#! @BeginGroup

#! @AutoDoc
#! @Description
#! These attributes store the implementations of the basic algorithms for a terminal object.
#! @Arguments C
DeclareAttribute( "TerminalObjectFunction",
                  IsCapCategory );

#! @Arguments C
DeclareAttribute( "UniversalMorphismIntoTerminalObjectFunction",
                  IsCapCategory );

#! @Arguments C
DeclareAttribute( "UniversalMorphismIntoTerminalObjectWithGivenTerminalObjectFunction",
                  IsCapCategory );
#! @EndAutoDoc

#! @EndGroup

## Add Operations


#! @Description
#! This operation adds the given function $f$: (no argument) $\mapsto T$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddTerminalObject",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: A \mapsto u$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismIntoTerminalObject",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (A, T) \mapsto u$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismIntoTerminalObjectWithGivenTerminalObject",
                  [ IsCapCategory, IsFunction ] );

#! @Section Functorial methods for terminal object

#! Terminal object is a functorial operation. This means:
#! There exists a unique morphisms $\phi: T \rightarrow T$.


#! @Description
#! This method takes a category $C$ as an input.
#! @Returns $\phi$
#! @Arguments C
DeclareAttribute( "TerminalObjectFunctorial",
                  IsCapCategory );

## WasCreatedAs Filter

#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for a terminal object. 
#! Note that we chose <C>WasCreatedAsTerminalObject</C> to be a filter rather than a property,
#! because by default, a filter is set to false.
DeclareFilter( "WasCreatedAsTerminalObject" );

#! @Chapter Universal Objects

####################################
##
#! @Section Initial Object
##
####################################

#! An object $I$ of a category $C$ is called initial if for every object $A$
#! there exists a unique morphism $u: I \rightarrow A$.

## Main Operations and Attributes

#! @BeginGroup 

#! @Description
#! Initial object of a category $C$
#! @Returns IsCapCategoryObject
#! @Arguments C
DeclareAttribute( "InitialObject",
                  IsCapCategory );

#! @Description
#! or of a cell $c$ in $C$
#! @Arguments c
DeclareAttribute( "InitialObject",
                  IsCapCategoryCell );

#! @EndGroup 

#! @Description
#! Given an object $A$ this method returns the unique morphism $u: I \rightarrow A$
#! from the initial object $I$ of the category of $A$ to $A$.
#! @Returns IsCapCategoryMorphism
#! @Arguments A
DeclareAttributeWithToDoForIsWellDefined( "UniversalMorphismFromInitialObject",
                                          IsCapCategoryObject );

#! @Description
#! Given an object $A$ and an initial object $I$ this method returns the unique morphism $u: I \rightarrow A$ from 
#! $I$ to $A$
#! @Returns IsCapCategoryMorphism
#! @Arguments A, I
DeclareOperationWithCache( "UniversalMorphismFromInitialObjectWithGivenInitialObject",
                  [ IsCapCategoryObject, IsCapCategoryObject ] );

## Function Attributes

#! @BeginGroup

#! @AutoDoc
#! @Description
#! These attributes store the implementations of the basic algorithms for an initial object.
#! @Arguments C
DeclareAttribute( "InitialObjectFunction",
                  IsCapCategory );

#! @Arguments C
DeclareAttribute( "UniversalMorphismFromInitialObjectFunction",
                  IsCapCategory );

#! @Arguments C
DeclareAttribute( "UniversalMorphismFromInitialObjectWithGivenInitialObjectFunction",
                  IsCapCategory );
#! @EndAutoDoc

#! @EndGroup

## Add Operations

#! @AutoDoc
#! @BeginGroup

#! @Description
#! This operation adds the given function $f$: (no argument) $\mapsto I$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddInitialObject",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: A \mapsto u$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismFromInitialObject",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (A, T) \mapsto u$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismFromInitialObjectWithGivenInitialObject",
                  [ IsCapCategory, IsFunction ] );
#! @EndGroup

#! @EndAutoDoc

#! @Section Functorial methods for initial object

#! Terminal object is a functorial operation. This means:
#! There exists a unique morphisms $\phi: I \rightarrow I$.


#! @Description
#! This method takes a category $C$ as an input.
#! @Returns $\phi$
#! @Arguments C
DeclareAttribute( "InitialObjectFunctorial",
                  IsCapCategory );

## WasCreatedAs Filter

#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for an initial object. 
#! Note that we chose <C>WasCreatedAsInitialObject</C> to be a filter rather than a property,
#! because by default, a filter is set to false.
DeclareFilter( "WasCreatedAsInitialObject" );

#! @Chapter Universal Objects

####################################
##
#! @Section Direct sum
##
####################################

#! Let $C$ be an additive category. Let $n \in \mathbb{N}$. Denote by $C^n$ the $n$-th direct product of $C$ with itself. 
#! Now take $(S_1, \dots, S_n) \in C^n$. An object $S$ equipped with morphisms $\pi_i: S \rightarrow S_i$ and
#! $\iota_i: S_i \rightarrow S$ is called direct sum of
#! $(S_1, \dots, S_n)$ if
#! - $\sum_{i = 1}^n (\iota_i \circ \pi_i) = \mathrm{id}_S$,
#! - for all $i,j \in \{ 1 \dots n \}$: $\pi_j\iota_i  = \delta_{ij}\mathrm{id}_{S_i}$, where $\delta_{ij}$ denotes the Kronecker delta.
#! Note: this implies that $S$ is a direct product with respect to the $\pi_i$ and a coproduct with
#! respect to the $\iota_i$.

## Main Operations and Attributes

DeclareOperationWithCache( "DirectSumOp",
                           [ IsList, IsCapCategoryObject ] );

## Function Attributes
#! @AutoDoc
#! @BeginGroup

#! @Description
#! These attributes store the implementations of the basic algorithms for a direct sum. 
DeclareAttribute( "DirectSumFunction",
                  IsCapCategory );
#! @EndGroup
#! @EndAutoDoc

#! @Description
#! This operation adds the given function $f: ( (S_1, \dots, S_n) ) \mapsto S$ to the category $C$,
#! where $(S_1, \dots, S_n)$ is a list of objects in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddDirectSum",
                  [ IsCapCategory, IsFunction ] );

#! @Section Functorial methods for direct sum

#! Direct sum is a functorial operation. This means:
#! For $(\mu_i: S_i \rightarrow S'_i)_{i=1\dots n}$,
#! we obtain a morphism $\phi: \mathrm{DirectSum}( S_1, \dots, S_n ) \rightarrow \mathrm{DirectSum}( S_1', \dots, S_n' )$.


#! @Description
#! This method takes $L = [ \mu_1, \dots, \mu_n ]$ as an input.
#! @Returns $\phi$
#! @Arguments L
DeclareOperation( "DirectSumFunctorial",
                  [ IsList ] );

## WasCreatedAs Filter

#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for a direct sum object. 
#! Note that we chose <C>WasCreatedAsDirectSum</C> to be a filter rather than a property,
#! because by default, a filter is set to false.
DeclareFilter( "WasCreatedAsDirectSum" );

DeclareProperty( "IS_IMPLIED_DIRECT_SUM", 
                 IsCapCategoryObject );

#! @Chapter Universal Objects



####################################
##
#! @Section Coproduct
##
####################################

#! Let $C$ be a category. Let $n \in \mathbb{N}$. Denote by $C^n$ the $n$-th direct product of $C$ with itself. 
#! Now take $(I_1, \dots, I_n) \in C^n$. An object $I$ equipped with morphisms 
#! $(\iota_i: I_i \rightarrow I)_{i = 1 \dots n} \in C^n$ is called a coproduct of
#! $(I_1, \dots, I_n)$ if for every collection of morphisms $( \tau_i: I_i \rightarrow T )_{i = 1 \dots n} \in C^n$
#! there exists a unique morphism $u: I \rightarrow T$ such that $\tau_i = u \circ \iota_i$ for all $i = 1 \dots n$.

## Main Operations and Attributes

DeclareGlobalFunction( "Coproduct" );

DeclareOperationWithCache( "CoproductOp",
                           [ IsList, IsCapCategoryObject ] );

DeclareGlobalFunction( "InjectionOfCofactor" );

DeclareOperation( "InjectionOfCofactorOfCoproduct",
                  [ IsList, IsInt ] );

DeclareOperationWithCache( "InjectionOfCofactorOfCoproductOp",
                  [ IsList, IsInt, IsCapCategoryObject ] );

DeclareOperationWithCache( "InjectionOfCofactorOfCoproductWithGivenCoproduct",
                  [ IsList, IsInt, IsCapCategoryObject ] );

DeclareGlobalFunction( "UniversalMorphismFromCoproduct" );

DeclareOperationWithCache( "UniversalMorphismFromCoproductOp",
                  [ IsList, IsList, IsCapCategoryObject ] );

DeclareOperationWithCache( "UniversalMorphismFromCoproductWithGivenCoproduct",
                  [ IsList, IsList, IsCapCategoryObject ] );

## Function Attributes
#! @AutoDoc
#! @BeginGroup

#! @Description
#! These attributes store the implementations of the basic algorithms for a coproduct. 
DeclareAttribute( "CoproductFunction",
                  IsCapCategory );

DeclareAttribute( "InjectionOfCofactorOfCoproductFunction",
                  IsCapCategory );

DeclareAttribute( "InjectionOfCofactorOfCoproductWithGivenCoproductFunction",
                  IsCapCategory );

DeclareAttribute( "UniversalMorphismFromCoproductFunction",
                  IsCapCategory );

DeclareAttribute( "UniversalMorphismFromCoproductWithGivenCoproductFunction",
                  IsCapCategory );
#! @EndGroup
#! @EndAutoDoc

## Add Operations

#! @Description
#! This operation adds the given function $f: ( (I_1, \dots, I_n) ) \mapsto I$ to the category $C$
#! where $(I_1, \dots, I_n)$ is a list of objects in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddCoproduct",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (I_1, \dots, I_n), i ) \mapsto \iota_i$ to the category $C$
#! where $(I_1, \dots, I_n)$ is a list of objects in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddInjectionOfCofactorOfCoproduct",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (I_1, \dots, I_n), i, I ) \mapsto \iota_i$ to the category $C$
#! where $(I_1, \dots, I_n)$ is a list of objects in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddInjectionOfCofactorOfCoproductWithGivenCoproduct",
                  [ IsCapCategory, IsFunction ] );

#FIXME: it is inconsistent with the convention that the diagram does not have to be given as an input!
#! @Description
#! This operation adds the given function $f: ( ( \tau_i: I_i \rightarrow T )_{i = 1 \dots n}  ) \mapsto u$ to the category $C$
#! where $( \tau_i: I_i \rightarrow T )_{i = 1 \dots n}$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismFromCoproduct",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( ( \tau_i: I_i \rightarrow T )_{i = 1 \dots n}, I  ) \mapsto u$ to the category $C$
#! where $( \tau_i: I_i \rightarrow T )_{i = 1 \dots n}$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismFromCoproductWithGivenCoproduct",
                  [ IsCapCategory, IsFunction ] );

#! @Section Functorial methods for coproduct

#! Coproduct is a functorial operation. This means:
#! For $(\mu_i: I_i \rightarrow I'_i)_{i=1\dots n}$,
#! we obtain a morphism $\phi: \mathrm{Coproduct}( I_1, \dots, I_n ) \rightarrow \mathrm{Coproduct}( I_1', \dots, I_n' )$.


#! @Description
#! This method takes $L = [ \mu_1, \dots, \mu_n ]$ as an input.
#! @Returns $\phi$
#! @Arguments L
DeclareOperation( "CoproductFunctorial",
                  [ IsList ] );

DeclareOperation( "CoproductFunctorialOp",
                  [ IsList, IsCapCategoryMorphism ] );



## WasCreatedAs Filter

#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for a coproduct object. 
#! Note that we chose <C>WasCreatedAsCoprodcut</C> to be a filter rather than a property,
#! because by default, a filter is set to false.
DeclareFilter( "WasCreatedAsCoproduct" );
#! @Chapter Universal Objects


####################################
##
#! @Section Direct Product
##
####################################

#! Let $C$ be a category. Let $n \in \mathbb{N}$. Denote by $C^n$ the $n$-th direct product of $C$ with itself. 
#! Now take $(P_1, \dots, P_n) \in C^n$. An object $P$ equipped with morphisms 
#! $(\pi_i: P \rightarrow P_i)_{i = 1 \dots n} \in C^n$ is called a direct product of
#! $(P_1, \dots, P_n)$ if for every collection of morphisms $( \tau_i: T \rightarrow P_i )_{i = 1 \dots n} \in C^n$
#! there exists a unique morphism $u: T \rightarrow P$ such that $\tau_i = \pi_i \circ u $ for all $i = 1 \dots n$.


## Main Operations and Attributes
# the first argument (diagram) is an object of the product category. This is superior to a list of objects
# because:
# *IsWellDefined will be handled properly
# *no caching issues?


## Main Operations and Attributes
#! @Description
#! Direct product of a given diagram $D$, where $D$ is a list of objects.
#! The second argument $M$ is an object needed for the method
#! selection.
#! @Returns IsCapCategoryObject
#! @Arguments D, M
DeclareOperationWithCache( "DirectProductOp",
                           [ IsList, IsCapCategoryObject ] );

#! @Description
#! Projection in the $i$-th factor of the direct product given by $D$.
#! $D$ can either be an object created as a direct product or a list
#! of objects $D = (A_i)$ representing a diagram.
#! @Returns IsCapCategoryMorphism
#! @Arguments D, i
DeclareGlobalFunction( "ProjectionInFactor" );

DeclareOperation( "ProjectionInFactorOfDirectProduct",
                  [ IsList, IsInt ] );
#! @Description
#! Projection in the $i$-th factor of the direct product given by $D$.
#! $D$ can either be an object created as a direct product or a list
#! of objects representing a diagram. The third argument $M$
#! is an object needed for the method selection.
#! @Returns IsCapCategoryMorphism
#! @Arguments D, i, M
DeclareOperationWithCache( "ProjectionInFactorOfDirectProductOp",
                  [ IsList, IsInt, IsCapCategoryObject ] );

#! @Description
#! Projection in the $i$-th factor of the direct product $P = \prod_j A_j$ 
#! given by a list of objects $D = (A_j)$.
#! @Returns IsCapCategoryMorphism
#! @Arguments D, i, P
DeclareOperation( "ProjectionInFactorOfDirectProductWithGivenDirectProduct",
                  [ IsList, IsInt, IsCapCategoryObject ] );

#! @Description
#! Given finitely many morphisms $\alpha_i: A \rightarrow B_i$ this method
#! returns the unique morphism $\alpha: A \rightarrow \prod_j B_j$ such that
#! $\pi_i \circ \alpha = \alpha_i$, where $\pi_i$ denotes the $i$-th projection
#! $\prod_j B_j \rightarrow B_i$.
#! @Returns IsCapCategoryMorphism
#! @Arguments alpha_i
DeclareGlobalFunction( "UniversalMorphismIntoDirectProduct" );

# TODO: Fix this documentation (new argument)
# @Description
# Given finitely many morphisms $D = (\alpha_i: A \rightarrow B_i)$ as a
# list of objects, this method
# returns a unique morphism $\alpha: A \rightarrow \prod_j B_j$ such that
# $\pi_i \circ \alpha = \alpha_i$, where $\pi_i$ denotes the $i$-th projection
# $\prod_j B_j \rightarrow B_i$. The second argument $M$ is needed for the method selection.
# @Returns IsCapCategoryMorphism
# @Arguments D, M
DeclareOperationWithCache( "UniversalMorphismIntoDirectProductOp",
                  [ IsList, IsList, IsCapCategoryObject ] );

# TODO: Fix this documentation (new argument)
#! @Description
#! Given finitely many morphisms $D = (\alpha_i: A \rightarrow B_i)$ as a
#! list of objects, and given the direct product $P = \prod_j B_j$, this method
#! returns the unique morphism $\alpha: A \rightarrow P$ such that
#! $\pi_i \circ \alpha = \alpha_i$, where $\pi_i$ denotes the $i$-th projection
#! $P \rightarrow B_i$.
#! @Returns IsCapCategoryMorphism
#! @Arguments D, P
DeclareOperationWithCache( "UniversalMorphismIntoDirectProductWithGivenDirectProduct",
                  [ IsList, IsList, IsCapCategoryObject ] );

## Function Attributes
#! @AutoDoc
#! @BeginGroup

#! @Description
#! These attributes store the implementations of the basic algorithms for a direct product. 
DeclareAttribute( "DirectProductFunction",
                  IsCapCategory );

DeclareAttribute( "ProjectionInFactorOfDirectProductFunction",
                  IsCapCategory );

DeclareAttribute( "ProjectionInFactorOfDirectProductWithGivenDirectProductFunction",
                  IsCapCategory );

DeclareAttribute( "UniversalMorphismIntoDirectProductFunction",
                  IsCapCategory );

DeclareAttribute( "UniversalMorphismIntoDirectProductWithGivenDirectProductFunction",
                  IsCapCategory );
#! @EndGroup
#! @EndAutoDoc

## Add Operations

#! @Description
#! This operation adds the given function $f: ( (P_1, \dots, P_n) ) \mapsto P$ to the category $C$
#! where $(P_1, \dots, P_n)$ is a list of objects in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddDirectProduct",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (P_1, \dots, P_n), i ) \mapsto \pi_i$ to the category $C$
#! where $(P_1, \dots, P_n)$ is a list of objects in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddProjectionInFactorOfDirectProduct",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (P_1, \dots, P_n), i, P ) \mapsto \pi_i$ to the category $C$
#! where $(P_1, \dots, P_n)$ is a list of objects in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddProjectionInFactorOfDirectProductWithGivenDirectProduct",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( ( \tau_i: T \rightarrow P_i )_{i = 1 \dots n} ) \mapsto u$ to the category $C$
#! where $( \tau_i: T \rightarrow P_i )_{i = 1 \dots n}$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismIntoDirectProduct",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( ( \tau_i: T \rightarrow P_i )_{i = 1 \dots n}, P ) \mapsto u$ to the category $C$
#! where $( \tau_i: T \rightarrow P_i )_{i = 1 \dots n}$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismIntoDirectProductWithGivenDirectProduct",
                  [ IsCapCategory, IsFunction ] );

#! @Section Functorial methods for direct product

#! DirectProduct is a functorial operation. This means:
#! For $(\mu_i: P_i \rightarrow P'_i)_{i=1\dots n}$,
#! we obtain a morphism $\phi: \mathrm{DirectProduct}( P_1, \dots, P_n ) \rightarrow \mathrm{DirectProduct}( P_1', \dots, P_n' )$.


#! @Description
#! This method takes $L = [ \mu_1, \dots, \mu_n ]$ as an input.
#! @Returns $\phi$
#! @Arguments L
DeclareOperation( "DirectProductFunctorial",
                  [ IsList ] );

DeclareOperation( "DirectProductFunctorialOp",
                  [ IsList, IsCapCategoryMorphism ] );


## WasCreatedAs Filter

#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for a terminal object. 
#! Note that we chose <C>WasCreatedAsDirectProduct</C> to be a filter rather than a property,
#! because by default, a filter is set to false.
DeclareFilter( "WasCreatedAsDirectProduct" );

#! @Chapter Universal Objects

####################################
##
#! @Section Pullback
##
####################################

#! Let $C$ be a category. Let $n \in \mathbb{N}$. Denote by $C^n$ the $n$-th direct product of $C$ with itself. 
#! Now take $(\beta_i: P_i \rightarrow B)_{i = 1 \dots n} \in C^n$. An object $P$ equipped with morphisms 
#! $(\pi_i: P \rightarrow P_i)_{i = 1 \dots n} \in C^n$ is called a pullback of
#! $(\beta_i)_{i = 1 \dots n}$ if for every collection of morphisms $( \tau_i: T \rightarrow P_i )_{i = 1 \dots n} \in C^n$
#! with the property $\beta_i \circ \tau_i = \beta_j \circ \tau_j$ for all $i,j = 1, \dots, n$,
#! there exists a unique morphism $u: T \rightarrow P$ such that $\tau_i = \pi_i \circ u $ for all $i = 1 \dots n$.

## Main Operations and Attributes

# FIXME:
# Declared as an operation in MatricesForHomalg!
# DeclareGlobalFunction( "Pullback" );
DeclareGlobalFunction( "FiberProduct" );

DeclareOperationWithCache( "PullbackOp",
                           [ IsList, IsCapCategoryMorphism ] );

DeclareOperation( "ProjectionInFactorOfPullback",
                  [ IsList, IsInt ] );

DeclareOperationWithCache( "ProjectionInFactorOfPullbackOp",
                  [ IsList, IsInt, IsCapCategoryMorphism ] );

DeclareOperationWithCache( "ProjectionInFactorOfPullbackWithGivenPullback",
                  [ IsList, IsInt, IsCapCategoryObject ] );

DeclareGlobalFunction( "UniversalMorphismIntoPullback" );

DeclareOperationWithCache( "UniversalMorphismIntoPullbackOp",
                  [ IsList, IsList, IsCapCategoryMorphism ] );

DeclareOperationWithCache( "UniversalMorphismIntoPullbackWithGivenPullback",
                  [ IsList, IsList, IsCapCategoryObject ] );

## Function Attributes
#! @AutoDoc
#! @BeginGroup

#! @Description
#! These attributes store the implementations of the basic algorithms for a pullback. 
DeclareAttribute( "PullbackFunction",
                  IsCapCategory );

DeclareAttribute( "ProjectionInFactorOfPullbackFunction",
                  IsCapCategory );

DeclareAttribute( "ProjectionInFactorOfPullbackWithGivenPullbackFunction",
                  IsCapCategory );

DeclareAttribute( "UniversalMorphismIntoPullbackFunction",
                  IsCapCategory );

DeclareAttribute( "UniversalMorphismIntoPullbackWithGivenPullbackFunction",
                  IsCapCategory );
#! @EndGroup
#! @EndAutoDoc

## Add Operations


#! @Description
#! This operation adds the given function $f: ( (\beta_i: P_i \rightarrow B)_{i = 1 \dots n} ) \mapsto P$ to the category $C$
#! where $(\beta_i: P_i \rightarrow B)_{i = 1 \dots n}$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddFiberProduct",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (\beta_i: P_i \rightarrow B)_{i = 1 \dots n}, i ) \mapsto \pi_i$ to the category $C$
#! where $(\beta_i: P_i \rightarrow B)_{i = 1 \dots n}$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddProjectionInFactorOfPullback",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (\beta_i: P_i \rightarrow B)_{i = 1 \dots n}, i, P ) \mapsto \pi_i$ to the category $C$
#! where $(\beta_i: P_i \rightarrow B)_{i = 1 \dots n}$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddProjectionInFactorOfPullbackWithGivenPullback",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (\beta_i: P_i \rightarrow B)_{i = 1 \dots n}, ( \tau_i: T \rightarrow P_i )_{i = 1 \dots n}  ) \mapsto u$ 
#! to the category $C$
#! where $(\beta_i: P_i \rightarrow B)_{i = 1 \dots n}$ and $( \tau_i: T \rightarrow P_i )_{i = 1 \dots n}$ are lists of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismIntoPullback",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (\beta_i: P_i \rightarrow B)_{i = 1 \dots n}, ( \tau_i: T \rightarrow P_i )_{i = 1 \dots n}, P ) \mapsto u$ 
#! to the category $C$
#! where $(\beta_i: P_i \rightarrow B)_{i = 1 \dots n}$ and $( \tau_i: T \rightarrow P_i )_{i = 1 \dots n}$ are lists of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismIntoPullbackWithGivenPullback",
                  [ IsCapCategory, IsFunction ] );

#! @Section Functorial methods for pullback

#! Pullback is a functorial operation. This means:
#! For a second diagram $\beta_i': P_i' \rightarrow B'$ and a natural morphism
#! between pullback diagrams (i.e., a collection of morphisms
#! $(\mu_i: P_i \rightarrow P'_i)_{i=1\dots n}$ and $\beta: B \rightarrow B'$
#! such that $\beta_i' \circ \mu_i = \beta \circ \beta_i$ for $i = 1, \dots n$)
#! we obtain a morphism $\phi: \mathrm{FiberProduct}( \beta_1, \dots, \beta_n ) \rightarrow \mathrm{FiberProduct}( \beta_1', \dots, \beta_n' )$.


#! @Description
#! This method takes $L = [ [ \beta_1, \mu_1, \beta_1' ], \dots, [ \beta_n, \mu_n, \beta_n' ] ]$ as an input.
#! Note that $\beta$ is not needed for the computation of $\phi$.
#! @Returns $\phi$
#! @Arguments L
DeclareOperation( "PullbackFunctorial",
                  [ IsList ] );


#! This method takes $L = [ [ \beta_1, \mu_1, \beta_1' ], \dots, [ \beta_n, \mu_n, \beta_n' ] ]$ 
#! and $\beta$ as an input.
#! @Returns $\phi$
#! @Arguments L, beta
DeclareOperation( "PullbackFunctorialOp",
                  [ IsList, IsCapCategoryMorphism ] );

## WasCreatedAs Filter

#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for a pullback. 
#! Note that we chose <C>WasCreatedAsPullback</C> to be a filter rather than a property,
#! because by default, a filter is set to false.
DeclareFilter( "WasCreatedAsPullback" );

#! @Chapter Universal Objects

####################################
##
#! @Section Pushout
##
####################################

#! Let $C$ be a category. Let $n \in \mathbb{N}$. Denote by $C^n$ the $n$-th direct product of $C$ with itself. 
#! Now take $(\beta_i: B \rightarrow I_i)_{i = 1 \dots n} \in C^n$. An object $I$ equipped with morphisms 
#! $(\iota_i: I_i \rightarrow I)_{i = 1 \dots n} \in C^n$ is called a pushout of
#! $(\beta_i)_{i = 1 \dots n}$ if for every collection of morphisms $( \tau_i: I_i \rightarrow T )_{i = 1 \dots n} \in C^n$
#! with the property $\tau_i \circ \beta_i  = \tau_j \circ \beta_j $ for all $i,j = 1, \dots, n$,
#! there exists a unique morphism $u: I \rightarrow T$ such that $\tau_i = u \circ \iota_i$ for all $i = 1 \dots n$.


## Main Operations and Attributes

DeclareGlobalFunction( "Pushout" );

DeclareOperationWithCache( "PushoutOp",
                           [ IsList, IsCapCategoryMorphism ] );

## DeclareGlobalFunction( "InjectionOfCofactor" ); to be adjusted

DeclareOperation( "InjectionOfCofactorOfPushout",
                  [ IsList, IsInt ] );

DeclareOperationWithCache( "InjectionOfCofactorOfPushoutOp",
                  [ IsList, IsInt, IsCapCategoryMorphism ] );

DeclareOperationWithCache( "InjectionOfCofactorOfPushoutWithGivenPushout",
                  [ IsList, IsInt, IsCapCategoryObject ] );

DeclareGlobalFunction( "UniversalMorphismFromPushout" );

DeclareOperationWithCache( "UniversalMorphismFromPushoutOp",
                  [ IsList, IsList, IsCapCategoryMorphism ] );

DeclareOperationWithCache( "UniversalMorphismFromPushoutWithGivenPushout",
                  [ IsList, IsList, IsCapCategoryObject ] );

## Function Attributes
#! @AutoDoc
#! @BeginGroup

#! @Description
#! These attributes store the implementations of the basic algorithms for a pushout. 
DeclareAttribute( "PushoutFunction",
                  IsCapCategory );

DeclareAttribute( "InjectionOfCofactorOfPushoutFunction",
                  IsCapCategory );

DeclareAttribute( "InjectionOfCofactorOfPushoutWithGivenPushoutFunction",
                  IsCapCategory );

DeclareAttribute( "UniversalMorphismFromPushoutFunction",
                  IsCapCategory );

DeclareAttribute( "UniversalMorphismFromPushoutWithGivenPushoutFunction",
                  IsCapCategory );
#! @EndGroup
#! @EndAutoDoc

## Add Operations


#! @Description
#! This operation adds the given function $f: ( (\beta_i: B \rightarrow I_i)_{i = 1 \dots n} ) \mapsto I$ to the category $C$
#! where $(\beta_i: B \rightarrow I_i)_{i = 1 \dots n}$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddPushout",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (\beta_i: B \rightarrow I_i)_{i = 1 \dots n}, i ) \mapsto \iota_i$ to the category $C$
#! where $(\beta_i: B \rightarrow I_i)_{i = 1 \dots n}$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddInjectionOfCofactorOfPushout",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (\beta_i: B \rightarrow I_i)_{i = 1 \dots n}, i, I ) \mapsto \iota_i$ to the category $C$
#! where $(\beta_i: B \rightarrow I_i)_{i = 1 \dots n}$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddInjectionOfCofactorOfPushoutWithGivenPushout",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (\beta_i: B \rightarrow I_i)_{i = 1 \dots n}, ( \tau_i: I_i \rightarrow T )_{i = 1 \dots n} ) \mapsto u$ 
#! to the category $C$ where $(\beta_i: B \rightarrow I_i)_{i = 1 \dots n}$ and $( \tau_i: I_i \rightarrow T )_{i = 1 \dots n}$ are lists of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismFromPushout",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: ( (\beta_i: B \rightarrow I_i)_{i = 1 \dots n}, ( \tau_i: I_i \rightarrow T )_{i = 1 \dots n}, I ) \mapsto u$ 
#! to the category $C$ where $(\beta_i: B \rightarrow I_i)_{i = 1 \dots n}$ and $( \tau_i: I_i \rightarrow T )_{i = 1 \dots n}$ are lists of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismFromPushoutWithGivenPushout",
                  [ IsCapCategory, IsFunction ] );

#! @Section Functorial methods for pushout

#! Pullback is a functorial operation. This means:
#! For a second diagram $\beta_i': B' \rightarrow I_i'$ and a natural morphism
#! between pushout diagrams (i.e., a collection of morphisms
#! $(\mu_i: I_i \rightarrow I'_i)_{i=1\dots n}$ and $\beta: B \rightarrow B'$
#! such that $\beta_i' \circ \beta = \mu_i \circ \beta_i$ for $i = 1, \dots n$)
#! we obtain a morphism $\phi: \mathrm{Pushout}( \beta_1, \dots, \beta_n ) \rightarrow \mathrm{Pushout}( \beta_1', \dots, \beta_n' )$.


#! @Description
#! This method takes $L = [ [ \beta_1, \mu_1, \beta_1' ], \dots, [ \beta_n, \mu_n, \beta_n' ] ]$ as an input.
#! Note that $\beta$ is not needed for the computation of $\phi$.
#! @Returns $\phi$
#! @Arguments L
DeclareOperation( "PushoutFunctorial",
                  [ IsList ] );


#! This method takes $L = [ [ \beta_1, \mu_1, \beta_1' ], \dots, [ \beta_n, \mu_n, \beta_n' ] ]$ 
#! and $\beta$ as an input.
#! @Returns $\phi$
#! @Arguments L, beta
DeclareOperation( "PushoutFunctorialOp",
                  [ IsList, IsCapCategoryMorphism ] );


## WasCreatedAs Filter

#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for a pushout. 
#! Note that we chose <C>WasCreatedAsPushout</C> to be a filter rather than a property,
#! because by default, a filter is set to false.
DeclareFilter( "WasCreatedAsPushout" );

#! @Chapter Universal Objects

####################################
##
#! @Section Image
##
####################################

#! Let $\alpha: A \rightarrow B$ be a morphism. The image of $\alpha$ is
#! the smallest monomorphism $\iota: I \hookrightarrow B$ through which $\alpha$ factors, i.e.,
#! such that there exists a morphism $c: A \rightarrow I$ with $\iota \circ c = \alpha$.
#! Smallest in this context means that for every other factorization of $\alpha = \tau_2 \circ \tau_1$
#! with $\tau_1: A \rightarrow T, \tau_2: T \rightarrow B$
#! where $\tau_2$ is a monomorphism, there exists a unique morphism $u: I \rightarrow T$
#! such that $\iota = \tau_2 \circ u$ and $\tau_1 = u \circ c$.

## Main Operations and Attributes

## FIXME: Image is a function (rename: ImageObject -> Image)
DeclareAttributeWithToDoForIsWellDefined( "ImageObject",
                                          IsCapCategoryMorphism );

#convenience function
DeclareAttributeWithToDoForIsWellDefined( "ImageEmbedding",
                                          IsCapCategoryObject );

DeclareAttributeWithToDoForIsWellDefined( "ImageEmbedding",
                                          IsCapCategoryMorphism );

#convenience function
DeclareAttributeWithToDoForIsWellDefined( "CoastrictionToImage",
                                          IsCapCategoryObject );

DeclareAttributeWithToDoForIsWellDefined( "CoastrictionToImage",
                                          IsCapCategoryMorphism );

DeclareOperationWithCache( "ImageEmbeddingWithGivenImage",
                  [ IsCapCategoryMorphism, IsCapCategoryObject ] );

DeclareOperationWithCache( "CoastrictionToImageWithGivenImage",
                  [ IsCapCategoryMorphism, IsCapCategoryObject ] );

DeclareOperationWithCache( "UniversalMorphismFromImage",
                  [ IsCapCategoryMorphism, IsList ] );

DeclareOperationWithCache( "UniversalMorphismFromImageWithGivenImage",
                  [ IsCapCategoryMorphism, IsList, IsCapCategoryObject ] );

## Function Attributes
#! @AutoDoc
#! @BeginGroup

#! @Description
#! These attributes store the implementations of the basic algorithms for an image. 
DeclareAttribute( "ImageFunction",
                  IsCapCategory );

DeclareAttribute( "ImageEmbeddingFunction",
                  IsCapCategory );

DeclareAttribute( "ImageEmbeddingWithGivenImageFunction",
                  IsCapCategory );

DeclareAttribute( "CoastrictionToImageFunction",
                  IsCapCategory );

DeclareAttribute( "CoastrictionToImageWithGivenImageFunction",
                  IsCapCategory );

DeclareAttribute( "UniversalMorphismFromImageFunction",
                  IsCapCategory );

DeclareAttribute( "UniversalMorphismFromImageWithGivenImageFunction",
                  IsCapCategory );


#! @EndGroup
#! @EndAutoDoc

## Add Operations

#! @Description
#! This operation adds the given function $f: \alpha \mapsto I$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddImageObject",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: \alpha \mapsto \iota$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddImageEmbedding",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (\alpha, I) \mapsto \iota$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddImageEmbeddingWithGivenImage",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: \alpha \mapsto c$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddCoastrictionToImage",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (\alpha, I) \mapsto c$ to the category $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddCoastrictionToImageWithGivenImage",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (\alpha, [\tau_1, \tau_2]) \mapsto u$ to the category $C$.
#! Note that $[\tau_1, \tau_2]$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismFromImage",
                  [ IsCapCategory, IsFunction ] );

#! @Description
#! This operation adds the given function $f: (\alpha, [\tau_1, \tau_2], I) \mapsto u$ to the category $C$.
#! Note that $[\tau_1, \tau_2]$ is a list of morphisms in $C$.
#! @Returns nothing
#! @Arguments C, f
DeclareOperation( "AddUniversalMorphismFromImageWithGivenImage",
                  [ IsCapCategory, IsFunction ] );

## WasCreatedAs Filter

#! @Chapter Technical Details

#! @Section Universal Objects

#! @Description 
#! When created, this filter is set to true for an image. 
#! Note that we chose <C>WasCreatedAsImage</C> to be a filter rather than a property,
#! because by default, a filter is set to false.
DeclareFilter( "WasCreatedAsImage" );
#! @Chapter Universal Objects



####################################
##
## Scheme for Universal Object
##
####################################

## Main Operations and Attributes

## Function Attributes

## Add Operations

## WasCreatedAs Filter
