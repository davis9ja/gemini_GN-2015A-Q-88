###################################
# Title:   specplot
# Author:  Jacob Davison
# Version: 18 Jul 2017
###################################

import matplotlib.pyplot as plt
from matplotlib.widgets import MultiCursor

from astropy.io import fits
from specutils import Spectrum1D
from specutils.wcs import specwcs

# find the average flux in a spectrum
def mean(val_list):
    return float(sum(val_list)) / max(float(len(val_list)), 1)

# find the minimum mean flux in a list of spectra
def find_min_mean(spectra):
    min_mean = float('inf')
    for spectrum in spectra:
        this_mean = mean(spectrum.flux)
        if this_mean < min_mean:
            min_mean = this_mean

    return min_mean

# containers relevant for plotting
plt_tup = ()
spectra = []
fits_files = ['fits/AUG_TELL_K_HIP93691NS.fits',
              'fits/AUG_TELL_K_HIP79881NS.fits',
              'fits/AUG_OBJ_K.fits',
              'fits/AUG_OBJ_K_clean_HIP79881.fits',
              'fits/AUG_OBJ_K_clean_HIP93691.fits']
figure = plt.figure(1, figsize=(14,8))

# put all Spectrum1D objects created from fits files into container
for raw_file in fits_files:
    fits_file = fits.open(raw_file)[0]
    fits_wcs = specwcs.Spectrum1DPolynomialWCS(degree=1,
                                               unit='angstrom',
                                               c0=fits_file.header['CRVAL1'],
                                               c1=fits_file.header['CD1_1'])
    fits_spec = Spectrum1D(flux=fits_file.data, wcs=fits_wcs)
    spectra.append((fits_spec, raw_file))

# get the value of the minimum mean (used for scaling)
min_mean = find_min_mean([x[0] for x in spectra])
i=0

# plot each spectrum in the "spectra" container
for spectrum in spectra:
    
    fits_spec = spectrum[0]
    fits_name = spectrum[1]
    
    # before plotting, calculate spectrum scale relative to spectrum with smallest avg flux
    fits_mean = mean(fits_spec.flux)
    fits_scale = min_mean/fits_mean if fits_mean > min_mean else 1

    # calculate offset using minimum mean
    threshold = 0.5 #arbitrary
    offset = min_mean + threshold

    # plot scaled, offset flux versus dispersion
    plt.plot(fits_spec.dispersion, fits_spec.flux*fits_scale+offset*i,
             label=fits_name,
             linewidth=0.5)

    # add absorption/emission feature flag
    plt.axvline(x=21069, c='k', ls='--', lw=0.5)     # He(?) or Mg I
    plt.axvline(x=21658.4, c='blue', ls='--', lw=0.5)  # H Br gamma
    plt.axvline(x=21175.7, c='k', ls='--', lw=0.5)     #Al I
    plt.axvline(x=22017, c='k', ls='--', lw=0.5)       #Ti I
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
multi = MultiCursor(figure.canvas, plt_tup, color='k', lw=0.1, ls='-.')
plt.show()
