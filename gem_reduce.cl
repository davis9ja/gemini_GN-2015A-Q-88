# made a change
# load packages

gemini
gnirs

unlearn ("gemini")
unlearn ("gnirs")

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

delete ("obj.lis,telluric.lis,arcs.lis,IRflats.lis,QHflats.lis,pinholes.lis,all.lis", verify=no)

gemlist "N20150603S" "148-159" > "obj.lis"       # science   148-159, 165-172, 177-184
gemlist "N20150603S" "140-143" > "telluric.lis"  # telluric  140-143, 210-213    
gemlist "N20150603S" "187-192" > "IRflats.lis"   # up to order 3
gemlist "N20150603S" "193-202" > "QHflats.lis"   # orders 4-8
gemlist "N20150603S" "185-186" > "arcs.lis"
gemlist "N20150603S" "276" > "pinholes.lis"  # pinholes 276-280

concat ("IRflats.lis,QHflats.lis", "allflats.lis")
concat ("allflats.lis,obj.lis,telluric.lis,arcs.lis,pinholes.lis", "all.lis")

imdelete ("n@all.lis", verify=no)
nsprepare ("@all.lis", rawpath=rawdir//"$", shiftx=INDEF, shifty=INDEF, \
	  fl_forcewcs=yes, bpm="gnirs$data/gnirsn_2012dec05_bpm.fits")

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
    process="fit",  order=10, lthresh=100., thr_flo=0.35, \
    thr_fup=1.5)
#display ("IRflats.fits[sci,1]", 1, zr=yes, zs=yes)

delete ("QHflats.fits,QHflats_bpm.pl", verify=no)
nsflat ("rn@QHflats.lis", flatfile="QHflats.fits", fl_inter=no, fl_corner=yes, \
    process="fit", order=5, lthresh=50., thr_flo=0.35, \
    thr_fup=4.0)

imdelete ("final_flat.fits", verify=no)
fxcopy ("IRflats.fits", "final_flat.fits", groups="0-3", new_file=yes)
fxinsert ("QHflats.fits", "final_flat.fits[3]", groups="4-18")

#nxdisplay ("final_flat.fits", 1)

imdelete ("rn@arcs.lis", verify=no)
nsreduce ("n@arcs.lis", fl_cut=yes, fl_nsappwave=no, fl_dark=no, fl_sky=no, \
    fl_flat=no, fl_corner=yes)

imdelete ("rn@pinholes.lis", verify=no)
nsreduce ("n@pinholes.lis", fl_cut=yes, fl_nsappwave=no, fl_dark=no, \
    fl_sky=no, fl_flat=no, fl_corner=yes)

imdelete ("pinholes.fits", verify=no)
imrename ("rn@pinholes.lis", "pinhole")

nssdist ("pinhole", coordlist="gnirs$data/pinholes-short-dense-north.lis", \
    fl_inter=no, function="legendre", order=5, minsep=5, thresh=1000, \
    nlost=0.)

imdelete ("arc_comb", verify=no)
nscombine ("rn@arcs.lis", output="arc_comb")

imdelete ("warc_comb", verify=no)
nswavelength ("arc_comb", coordlist="gnirs$data/lowresargon.dat", \
    fl_median=yes, fl_inter=yes, threshold=300., nlost=10, fwidth=5.)

imdelete ("rn@telluric.lis", verify=no)
nsreduce ("n@telluric.lis", fl_corner=yes, fl_nsappwave=no, fl_sky=yes, \
    skyrange=INDEF, fl_flat=yes, flatimage="final_flat.fits")

imdelete ("rn@obj.lis", verify=no)
nsreduce ("n@obj.lis", fl_corner=yes, fl_nsappwave=no, fl_sky=yes, \
    skyrange=INDEF, fl_flat=yes, flatimage="final_flat.fits", nodsize=3.0)

imdelete ("tell_comb.fits", verify=no)
nscombine ("rn@telluric.lis", output="tell_comb")

#nxdisplay ("tell_comb.fits", 1)

imdelete ("obj_comb.fits", verify=no)
nscombine ("rn@obj.lis", output="obj_comb")

#nxdisplay ("obj_comb.fits", 1)

imdelete ("ftell_comb.fits", verify=no)
nsfitcoords ("tell_comb.fits", lamptrans="warc_comb", sdisttrans="pinhole", \
    fl_inter=yes, lxorder=2, lyorder=3, sxorder=4, syorder=4)

imdelete ("tftell_comb.fits", verify=no)
nstransform ("ftell_comb.fits")

#nxdisplay ("tftell_comb.fits", 1)

imdelete ("fobj_comb.fits", verify=no)
nsfitcoords ("obj_comb.fits", lamptrans="warc_comb", sdisttrans="pinhole", \
    fl_inter=yes, lxorder=2, lyorder=3, sxorder=4, syorder=4)

imdelete ("tfobj_comb.fits", verify=no)
nstransform ("fobj_comb.fits")

#nxdisplay ("tfobj_comb.fits", 1)

imdelete ("xtftell_comb.fits", verify=no)
nsextract ("tftell_comb.fits", line=750, nsum=20, upper=6, low=-6, \
    fl_inter=no, fl_apall=yes, fl_trace=yes)

imdelete ("xtfobj_comb.fits", verify=no)
nsextract ("tfobj_comb.fits", line=750, nsum=20, upper=6, low=-6, \
    fl_inter=no, fl_trace=yes, tr_nsum=5, tr_step=2)