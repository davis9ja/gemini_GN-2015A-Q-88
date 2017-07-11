import matplotlib.pyplot as plt
from matplotlib.widgets import MultiCursor

from astropy.io import fits
from specutils import Spectrum1D
from specutils.wcs import specwcs

def mean(val_list):
    return float(sum(val_list)) / max(float(len(val_list)), 1)

def to_wn(ang):
    return 1/(ang/10.**8)

#extracted_spectra = ['xtfobj_N20150802S_88-95_HIP79881.fits',
#                     'xtftell_N20150802S_88-95_HIP79881.fits',
#                     'xtfobj_N20150802S_88-95_HIP93691.fits',
#                     'xtftell_N20150802S_88-95_HIP93691.fits',
#                     'xtfobj_N20150802S_102-109_HIP79881.fits',
#                     'xtftell_N20150802S_102-109_HIP79881.fits',
#                     'xtfobj_N20150802S_102-109_HIP93691.fits',
#                     'xtftell_N20150802S_102-109_HIP93691.fits']
#sci_fits = extracted_spectra[::2]
#tel_fits = extracted_spectra[1::2]
#pairs = [(sci_fits[i], tel_fits[i]) for i in range(len(sci_fits))]
pairs = [("N20150802S_obj_all.fits", "N20150802S_tel_all.fits"), ("N20150603S_obj_all.fits", "N20150603S_tel_all.fits"), ("obj_all.fits", "tel_all.fits")]
#pairs = [("obj_all.fits", "tel_all.fits")]
plt_tup = ()

figure = plt.figure(1, figsize=(14,8))

i=0
for pair in pairs:
    print pair
    # generate science data spectrum
#    sci_file = fits.open(pair[0])[1]
    sci_file = fits.open(pair[0])[0]
    sci_wcs = specwcs.Spectrum1DPolynomialWCS(degree=1,
                                              unit='angstrom',
                                              c0=sci_file.header['CRVAL1'],
                                              c1=sci_file.header['CD1_1'])
    sci_spec = Spectrum1D(flux=sci_file.data, wcs=sci_wcs)

    # generate standard star spectrum
#    tel_file = fits.open(pair[1])[1]
    tel_file = fits.open(pair[1])[0]
    tel_wcs = specwcs.Spectrum1DPolynomialWCS(degree=1,
                                              unit='angstrom',
                                              c0=tel_file.header['CRVAL1'],
                                              c1=tel_file.header['CD1_1'])
    tel_spec = Spectrum1D(flux=tel_file.data, wcs=tel_wcs)
    
    # before plotting, scale spectra relative to spectrum with smaller avg flux
    sci_mean = mean(sci_spec.flux)
    tel_mean = mean(tel_spec.flux)
    sci_scale = (tel_mean/sci_mean if sci_mean > tel_mean else 1) 
    tel_scale = (sci_mean/tel_mean if tel_mean > sci_mean else 1)

    # calculate offset, assuming science is always on top of standard star spectrum
    sci_min = min(sci_spec.flux)*sci_scale
    tel_max = max(tel_spec.flux)*tel_scale
    threshold = 0.0*tel_max #arbitrary
    offset = abs(tel_max) + abs(sci_min) + threshold

#    plt.subplot(4,1,i+1)
    plt.subplot(3,1,i+1)
    plt.plot(sci_spec.dispersion, sci_spec.flux*sci_scale+offset,
             label=pair[0],
             color='red',
             linewidth=0.5)

    plt.plot(tel_spec.dispersion, tel_spec.flux*tel_scale,
             label=pair[1],
             linewidth=0.5)


    # add absorption/emission feature flag
    plt.axvline(x=21070.8, c='k', ls='--', lw=0.5)     # He(?) or Mg I
    plt.axvline(x=21658.4, c='blue', ls='--', lw=0.5)  # H Br gamma
    plt.axvline(x=21175.7, c='k', ls='--', lw=0.5)     #Al I
    #plt.axvline(x=22349.6, c='k', ls='--', lw=0.5)     #Fe I(?)
    #plt.axvline(x=22614.7, c='k', ls='--', lw=0.5)     #Ca I 
    plt.axvline(x=23174.7, c='blue', ls='--', lw=0.5)  # CO-12 3-1
    plt.axvline(x=23709.7, c='blue', ls='--', lw=0.5)  # CO-12        

    # plot configuration
    plt.xlim(19500,24000)
    plt.gca().axes.set_yticklabels([])
    plt.gca().axes.set_xlabel("Wavelength (Angstroms)")
    plt.legend(loc='best')
    i += 1
    plt_tup += (plt.gca().axes,)
multi = MultiCursor(figure.canvas, plt_tup, color='k', lw=0.3)
plt.show()
