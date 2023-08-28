# Widening Scalar procedures to operate on arbitrarily wide datasets
Obviously look at the assembly to confirm that the widened procedure actually gets compiled into SIMD instructions and that llvm doesnt do a 
```c++
for(int i = 0; i < width; i++0)
{
	//scalar instructions
}
```

# DO NOT USE FOR PRODUCTION
this code has been written over a lunch break, because WHY does LLVM not widen my functions like this? Argh.

Proof of concept.
