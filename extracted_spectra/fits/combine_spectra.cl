
# combine science data
imdelete ("*_OBJ_K_*", verify="no")
scombine ("jun_obj_*_HIP79881.fits[1]", "JUN_OBJ_K_HIP79881", scale="median", sample="21000:21500")
scombine ("jun_obj_*_HIP93691.fits[1]", "JUN_OBJ_K_HIP93691", scale="median", sample="21000:21500")
scombine ("aug_obj_*_HIP79881.fits[1]", "AUG_OBJ_K_HIP79881", scale="median", sample="21000:21500")
scombine ("aug_obj_*_HIP93691.fits[1]", "AUG_OBJ_K_HIP93691", scale="median", sample="21000:21500")

scombine ("JUN_OBJ_K*", "JUN_OBJ_K", scale="median", sample="21000:21500")
scombine ("AUG_OBJ_K*", "AUG_OBJ_K", scale="median", sample="21000:21500")

# combine telluric data
imdelete ("*_TELL_K_*", verify="no")
scombine ("jun_tell_*_HIP79881.fits[1]", "JUN_TELL_K_HIP79881", scale="median",
         sample="21000:21500")
scombine ("jun_tell_*_HIP93691.fits[1]", "JUN_TELL_K_HIP93691", scale="median",
         sample="21000:21500")
scombine ("aug_tell_*_HIP79881.fits[1]", "AUG_TELL_K_HIP79881", scale="median",
         sample="21000:21500")
scombine ("aug_tell_*_HIP93691.fits[1]", "AUG_TELL_K_HIP93691", scale="median",
         sample="21000:21500")