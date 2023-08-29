foo :: (a : s32, b : s32) -> s32, r_2 : s32
{
	r : s32 = 3 + a;
	return b * r + 1, 0;
} @Widen @Disassemble

foo_wide4 := foo_x4;

main :: ()
{
	s := cast(s32)to_milliseconds(current_time_monotonic());
	{
		a : [4] s32 = .[s % 2, s % 3, s % 5, s % 7];
		b : [4] s32 = .[s %11, s% 13, s % 17, s % 4];
		c : [4] s32 = foo_wide4(a, b);
		log("c x4 = %", c);
	}
	
	{
		a : [8] s32 = .[s % 2, s % 3, s % 5, s % 7,s %11, s% 13, s % 17, s % 4];
		b : [8] s32 = .[1,1,1,1,1,1,1,1];
		c : [8] s32 = foo_x8(a, b);
		log("c x8 = %", c);
	}

}


#import "Basic";
