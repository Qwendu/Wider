foo :: (a : s32, b : s32) -> s32, r_2 : s32
{
	r : s32 = 3 + a;
	return b * r + 1, 0;
} @Widen

main :: ()
{
	a : [4] s32;
	b : [4] s32;
	c : [4] s32 = foo_x4(a, b);
}

