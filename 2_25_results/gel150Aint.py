# showing raw integrated signal valuse for gel at 150V

import re
import numpy as np # type: ignore
from scipy.optimize import curve_fit # type: ignore

data = """

ttp =

    1.0000
    0.4942
    0.3475
    0.3187
    0.3470
    0.3333
    0.3357
    0.3253
    0.3237
    0.3358

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.7480
    0.4133
    0.3915
    0.3806
    0.3844
    0.3777
    0.4008
    0.3774
    0.3737

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}
    {[16:52:25.761000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.3785
    0.2601
    0.2433
    0.2319
    0.2252
    0.2196
    0.2235
    0.2256
    0.2223

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}
    {[16:52:25.761000]}    {10×1 double}
    {[16:52:29.819000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.4415
    0.1610
    0.1941
    0.1992
    0.1944
    0.1952
    0.1931
    0.1909
    0.1927

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}
    {[16:52:25.761000]}    {10×1 double}
    {[16:52:29.819000]}    {10×1 double}
    {[16:52:33.875000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.2433
    0.1967
    0.1793
    0.1848
    0.1913
    0.1876
    0.1859
    0.1952
    0.1853

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}
    {[16:52:25.761000]}    {10×1 double}
    {[16:52:29.819000]}    {10×1 double}
    {[16:52:33.875000]}    {10×1 double}
    {[16:52:37.956000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.2433
    0.1967
    0.1793
    0.1848
    0.1913
    0.1876
    0.1859
    0.1952
    0.1853

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}
    {[16:52:25.761000]}    {10×1 double}
    {[16:52:29.819000]}    {10×1 double}
    {[16:52:33.875000]}    {10×1 double}
    {[16:52:37.956000]}    {10×1 double}
    {[16:52:41.996000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.4675
    0.2108
    0.2115
    0.2098
    0.2097
    0.2102
    0.2079
    0.2139
    0.2045

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}
    {[16:52:25.761000]}    {10×1 double}
    {[16:52:29.819000]}    {10×1 double}
    {[16:52:33.875000]}    {10×1 double}
    {[16:52:37.956000]}    {10×1 double}
    {[16:52:41.996000]}    {10×1 double}
    {[16:52:46.046000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.5003
    0.2148
    0.2316
    0.2339
    0.2345
    0.2447
    0.2439
    0.2282
    0.2323

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}
    {[16:52:25.761000]}    {10×1 double}
    {[16:52:29.819000]}    {10×1 double}
    {[16:52:33.875000]}    {10×1 double}
    {[16:52:37.956000]}    {10×1 double}
    {[16:52:41.996000]}    {10×1 double}
    {[16:52:46.046000]}    {10×1 double}
    {[16:52:50.100000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.4099
    0.1882
    0.1851
    0.1884
    0.1867
    0.1937
    0.1948
    0.2023
    0.1866

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}
    {[16:52:25.761000]}    {10×1 double}
    {[16:52:29.819000]}    {10×1 double}
    {[16:52:33.875000]}    {10×1 double}
    {[16:52:37.956000]}    {10×1 double}
    {[16:52:41.996000]}    {10×1 double}
    {[16:52:46.046000]}    {10×1 double}
    {[16:52:50.100000]}    {10×1 double}
    {[16:52:54.131000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.4213
    0.2024
    0.2040
    0.1971
    0.2059
    0.2086
    0.2023
    0.2128
    0.2120

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}
    {[16:52:25.761000]}    {10×1 double}
    {[16:52:29.819000]}    {10×1 double}
    {[16:52:33.875000]}    {10×1 double}
    {[16:52:37.956000]}    {10×1 double}
    {[16:52:41.996000]}    {10×1 double}
    {[16:52:46.046000]}    {10×1 double}
    {[16:52:50.100000]}    {10×1 double}
    {[16:52:54.131000]}    {10×1 double}
    {[16:52:58.170000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.4130
    0.1938
    0.1862
    0.1961
    0.1947
    0.1765
    0.1960
    0.1793
    0.1808

Dictionary of [Time, ttp]:
    {[16:52:21.681000]}    {10×1 double}
    {[16:52:25.761000]}    {10×1 double}
    {[16:52:29.819000]}    {10×1 double}
    {[16:52:33.875000]}    {10×1 double}
    {[16:52:37.956000]}    {10×1 double}
    {[16:52:41.996000]}    {10×1 double}
    {[16:52:46.046000]}    {10×1 double}
    {[16:52:50.100000]}    {10×1 double}
    {[16:52:54.131000]}    {10×1 double}
    {[16:52:58.170000]}    {10×1 double}
    {[16:53:02.216000]}    {10×1 double}


"""

pattern = re.compile(r"ttp\s*=\s*\n((?:\s*[\d\.]+\s*\n){10})", re.MULTILINE)
matches = pattern.findall(data)

for i, match in enumerate(matches, start=1):
    numbers = [float(x) for x in match.strip().split()]
    globals()[f"IntSig{i}"] = numbers

signals = [IntSig1, IntSig2, IntSig3, IntSig4, IntSig5, IntSig6,  # type: ignore
           IntSig7, IntSig8, IntSig9, IntSig10, IntSig11] # type: ignore

x = np.arange(1, 11)

def power_law(x, a, b):
    return a * (x ** b)

powerlaw_fits = {}

for i, signal in enumerate(signals, start=1):
    popt, _ = curve_fit(power_law, x, signal)
    powerlaw_fits[f"IntSig{i}"] = popt