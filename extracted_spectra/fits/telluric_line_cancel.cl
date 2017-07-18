gemini
gnirs

unlearn ("gemini")
unlearn ("gnirs")

##############################################################
#
# normalize telluric spectrum and use to clean AUG_OBJ data
#
###############################################################
imdelete ("AUG_TELL_K_HIP79881N.fits", verify="no")
continuum ("AUG_TELL_K_HIP79881.fits", "AUG_TELL_K_HIP79881N.fits",
          function="spline3", order=4, low_reject=2,
          high_reject=4, niterate=10)

imdelete ("AUG_TELL_K_HIP93691N.fits", verify="no")
continuum ("AUG_TELL_K_HIP93691.fits", "AUG_TELL_K_HIP93691N.fits",
          function="spline3", order=4, low_reject=2,
          high_reject=4, niterate=10)

##############################################################
#
# use splot to clean continuum (remove large spikes at edges)
# also, remove H-Br gamma at ~21660 Ang
#
###############################################################
imdelete ("AUG_TELL_K_HIP79881NS.fits", verify="no")
splot ("AUG_TELL_K_HIP79881N.fits", new_image="AUG_TELL_K_HIP79881NS.fits",
      overwrite=yes)

imdelete ("AUG_TELL_K_HIP93691NS.fits", verify="no")
splot ("AUG_TELL_K_HIP93691N.fits", new_image="AUG_TELL_K_HIP93691NS.fits",
      overwrite=yes)


##############################################################
#
# use appropriate telluric spectrum to clean OBJ data
#
###############################################################

imdelete ("AUG_OBJ_K_clean_HIP79881.fits", verify="no")
telluric ("AUG_OBJ_K.fits", "AUG_OBJ_K_clean_HIP79881.fits",
         "AUG_TELL_K_HIP79881NS.fits")

imdelete ("AUG_OBJ_K_clean_HIP93691.fits", verify="no")
telluric ("AUG_OBJ_K.fits", "AUG_OBJ_K_clean_HIP93691.fits",
         "AUG_TELL_K_HIP93691NS.fits")

##############################################################
#
# inspect results of telluric line cancellation
#
###############################################################
splot ("AUG_OBJ_K_clean_HIP79881.fits")

splot ("AUG_OBJ_K_clean_HIP93691.fits")