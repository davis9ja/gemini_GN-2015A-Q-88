# made a change
# load packages
#
# Current version of  
#

##########
# STEP 1 #
##########


gemini
gnirs

unlearn ("gemini")
unlearn ("gnirs")

##########
# STEP 2 #
##########

string rawdir, image
struct *scanfile

gnirs.logfile = "gemini_GN-2015A-Q-88_reduction-run.log"

delete (gnirs.logfile, verify=no)

gnirs.database = "gnirs_xd_database/"


if (access(gnirs.database)) {

   delete (gnirs.database//"*", verify=no)

}
;

rawdir = "../"
printf("raw data is in %s\n",rawdir)

nsheaders ("gnirs")

set stdimage=imt1024

##########
# STEP 3 #
##########
#
# 20150603S --
#
# science  ::  148-159, 165-172, 177-184
# telluric ::  140-143(night), 210-213(night)
# IRflats  ::  187-192
# QHflats  ::  193-202
# arcs     ::  185-186
# pinholes ::  276-280
#
# N20150802S --
#
# science  ::  88-95, 102-109
# telluric ::  80-83(night), 132-135(day)
# IRflats  ::  112-117
# QHflats  ::  118-127
# arcs     ::  110-111
# pinholes ::  264-268
#
#
# separate IRflats, QHflats, and pinholes --
# hselect <data_prefix>*[0] field=$I,GCALLAMP,SLIT expr='OBSTYPE=="FLAT"'
# hselect <data_prefix>*[0] field=$I,OBJECT,OBSTYPE,OBSCLASS expr=yes

delete ("obj.lis,telluric.lis,arcs.lis,IRflats.lis,QHflats.lis,pinholes.lis,all.lis", verify=no)

gemlist "N20150603S" "148-159" > "obj.lis"
gemlist "N20150603S" "212-213" > "telluric.lis"
gemlist "N20150603S" "187-192" > "IRflats.lis"
gemlist "N20150603S" "193-202" > "QHflats.lis"
gemlist "N20150603S" "185-186" > "arcs.lis"
gemlist "N20150603S" "276" > "pinholes.lis"

concat ("IRflats.lis,QHflats.lis", "allflats.lis")
concat ("allflats.lis,obj.lis,telluric.lis,arcs.lis,pinholes.lis", "all.lis")

##########
# STEP 4 #
##########

# image display and visual analysis currently not in use

##########
# STEP 5 #
##########

imdelete ("n@all.lis", verify=no)
nsprepare ("@all.lis", rawpath=rawdir//"$", shiftx=INDEF, shifty=INDEF, \
	  fl_forcewcs=yes, bpm="gnirs$data/gnirsn_2012dec05_bpm.fits")

##########
# STEP 6 #
##########

imdelete ("rn@allflats.lis", verify=no)
nsreduce ("n@allflats.lis", fl_sky=no, fl_cut=yes, fl_flat=no, fl_dark=no, \
	 fl_nsappwave=no, fl_corner=yes)

printlog ("-------------------------------------------- ", gnirs.logfile, \
    verbose=yes)
delete ("tmpflat", verify=no)

gemextn "rn@IRflats.lis" proc="expand" extname="SCI" extver="1" > "tmpflat"
printlog ("Order 3 Flats: ", gnirs.logfile, verbose=yes)
imstatistic "@tmpflat" | tee (gnirs.logfile, append=yes)
delete ("tmpflat", verify=no)

gemextn "rn@QHflats.lis" proc="expand" extname="SCI" extver="2" > "tmpflat"
printlog ("Order 5 Flats: ", gnirs.logfile, verbose=yes)
imstatistic "@tmpflat" | tee (gnirs.logfile, append=yes)
delete ("tmpflat", verify=no)

delete ("IRflats.fits,IRflats_bpm.pl", verify=no)
nsflat ("rn@IRflats.lis", flatfile="IRflats.fits", fl_inter=no, fl_corner=yes, \
    process="fit", fitsec="MDF", order=10, lthresh=100., thr_flo=0.35, \
    thr_fup=1.5)
#display ("IRflats.fits[sci,1]", 1, zr=yes, zs=yes)

delete ("QHflats.fits,QHflats_bpm.pl", verify=no)
nsflat ("rn@QHflats.lis", flatfile="QHflats.fits", fl_inter=no, fl_corner=yes, \
    process="fit", fitsec="MDF", order=5, lthresh=50., thr_flo=0.35, \
    thr_fup=4.0)

imdelete ("final_flat.fits", verify=no)
fxcopy ("IRflats.fits", "final_flat.fits", groups="0-3", new_file=yes)
fxinsert ("QHflats.fits", "final_flat.fits[3]", groups="4-18")

#nxdisplay ("final_flat.fits", 1)

##########
# STEP 7 #
##########

imdelete ("rn@arcs.lis", verify=no)
nsreduce ("n@arcs.lis", fl_cut=yes, fl_nsappwave=no, fl_dark=no, fl_sky=no, \
    fl_flat=no, fl_corner=yes)

imdelete ("rn@pinholes.lis", verify=no)
nsreduce ("n@pinholes.lis", fl_cut=yes, fl_nsappwave=no, fl_dark=no, \
    fl_sky=no, fl_flat=no, fl_corner=yes)

imdelete ("pinholes.fits", verify=no)
imrename ("rn@pinholes.lis", "pinhole")

##########
# STEP 8 #
##########

nssdist ("pinhole", coordlist="gnirs$data/pinholes-short-dense-north.lis", \
        fl_inter=no, function="legendre", order=5, minsep=5, thresh=1000, \
        nlost=0.)

##########
# STEP 9 #
##########

imdelete ("arc_comb", verify=no)
nscombine ("rn@arcs.lis", output="arc_comb")

imdelete ("warc_comb", verify=no)
nswavelength ("arc_comb", coordlist="gnirs$data/lowresargon.dat", \
             fl_median=yes, fl_inter=no, threshold=300., nlost=10, fwidth=5.)

###########
# STEP 10 #
###########

imdelete ("rn@telluric.lis", verify=no)
nsreduce ("n@telluric.lis", fl_corner=yes, fl_nsappwave=no, fl_sky=yes, \
    skyrange=INDEF, fl_flat=yes, flatimage="final_flat.fits")

imdelete ("rn@obj.lis", verify=no)
nsreduce ("n@obj.lis", fl_corner=yes, fl_nsappwave=no, fl_sky=yes, \
         skyrange=INDEF, fl_flat=yes, flatimage="final_flat.fits", nodsize=3.0)

###########
# STEP 11 #
###########

imdelete ("tell_comb.fits", verify=no)
nscombine ("rn@telluric.lis", output="tell_comb")

#nxdisplay ("tell_comb.fits", 1)

imdelete ("obj_comb.fits", verify=no)
nscombine ("rn@obj.lis", output="obj_comb")

#nxdisplay ("obj_comb.fits", 1)

###########
# STEP 12 #
###########

imdelete ("ftell_comb.fits", verify=no)
nsfitcoords ("tell_comb.fits", lamptrans="warc_comb", sdisttrans="pinhole", \
    fl_inter=no, lxorder=2, lyorder=3, sxorder=4, syorder=4)

imdelete ("tftell_comb.fits", verify=no)
nstransform ("ftell_comb.fits")

#nxdisplay ("tftell_comb.fits", 1)

imdelete ("fobj_comb.fits", verify=no)
nsfitcoords ("obj_comb.fits", lamptrans="warc_comb", sdisttrans="pinhole", \
    fl_inter=no, lxorder=2, lyorder=3, sxorder=4, syorder=4)

imdelete ("tfobj_comb.fits", verify=no)
nstransform ("fobj_comb.fits")

#nxdisplay ("tfobj_comb.fits", 1)

###########
# STEP 13 #
###########

imdelete ("xtftell_comb.fits", verify=no)
#imdelete ("N20150802S_tel_all.fits", verify=no)
nsextract ("tftell_comb.fits", line=750, nsum=20, upper=6, low=-6, \
          fl_inter=no, fl_apall=yes, fl_trace=yes)

imdelete ("xtfobj_comb.fits", verify=no)
#imdelete ("N20150802S_obj_all.fits", verify=no)
nsextract ("tfobj_comb.fits", line=750, nsum=20, upper=6, low=-6, \
          fl_inter=no, fl_trace=yes, tr_nsum=5, tr_step=2)

###########
# STEP 14 #
###########

#imdelete ("axtfobj_comb.fits", verify=no)
#nstelluric ("xtfobj_comb.fits", "xtftell_comb.fits")

