// Workspace: Target Program
foo_x2 :: (a: [2] s32, b: [2] s32) -> ([2] s32, r_2: [2] s32) {
    return_value_0: [2] s32;
    r_2: [2] s32;
    r: [2] s32 = .[3 + a[0], 3 + a[1]];
    {
        {
            return_value_0[0] = b[0] * r[0] + 1;
            return_value_0[1] = b[1] * r[1] + 1;
        }
        {
            r_2[0] = 0;
            r_2[1] = 0;
        }
    }
    return return_value_0, r_2;
}@"WidenedFrom(foo,2)" 

foo_x4 :: (a: [4] s32, b: [4] s32) -> ([4] s32, r_2: [4] s32) {
    return_value_0: [4] s32;
    r_2: [4] s32;
    r: [4] s32 = .[3 + a[0], 3 + a[1], 3 + a[2], 3 + a[3]];
    {
        {
            return_value_0[0] = b[0] * r[0] + 1;
            return_value_0[1] = b[1] * r[1] + 1;
            return_value_0[2] = b[2] * r[2] + 1;
            return_value_0[3] = b[3] * r[3] + 1;
        }
        {
            r_2[0] = 0;
            r_2[1] = 0;
            r_2[2] = 0;
            r_2[3] = 0;
        }
    }
    return return_value_0, r_2;
}@"WidenedFrom(foo,4)" 

foo_x8 :: (a: [8] s32, b: [8] s32) -> ([8] s32, r_2: [8] s32) {
    return_value_0: [8] s32;
    r_2: [8] s32;
    r: [8] s32 = .[3 + a[0], 3 + a[1], 3 + a[2], 3 + a[3], 3 + a[4], 3 + a[5], 3 + a[6], 3 + a[7]];
    {
        {
            return_value_0[0] = b[0] * r[0] + 1;
            return_value_0[1] = b[1] * r[1] + 1;
            return_value_0[2] = b[2] * r[2] + 1;
            return_value_0[3] = b[3] * r[3] + 1;
            return_value_0[4] = b[4] * r[4] + 1;
            return_value_0[5] = b[5] * r[5] + 1;
            return_value_0[6] = b[6] * r[6] + 1;
            return_value_0[7] = b[7] * r[7] + 1;
        }
        {
            r_2[0] = 0;
            r_2[1] = 0;
            r_2[2] = 0;
            r_2[3] = 0;
            r_2[4] = 0;
            r_2[5] = 0;
            r_2[6] = 0;
            r_2[7] = 0;
        }
    }
    return return_value_0, r_2;
}@"WidenedFrom(foo,8)" 
