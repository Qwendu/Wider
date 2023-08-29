foo :: (a : s32, b : s32) -> s32, r_2 : s32
{
	r : s32 = 3 + a;
	return b * r + 1, 0;
} @Widen @Disassemble

main :: ()
{
	{
		a : [4] s32 = .[0,1,2,3];
		b : [4] s32 = .[1,1,1,1];
		c : [4] s32 = foo_x4(a, b);
		log("c x4 = %", c);
	}
	
	{
		a : [8] s32 = .[0,1,2,3,4,5,6,7];
		b : [8] s32 = .[1,1,1,1,1,1,1,1];
		c : [8] s32 = foo_x8(a, b);
		log("c x8 = %", c);
	}

}


#import "Basic";
