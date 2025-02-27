# same as gel150Aint, but new sample on fresh gel space

import re
import numpy as np # type: ignore
from scipy.optimize import curve_fit # type: ignore

data = """

ttp =

    1.0000
    0.0806
    0.0830
    0.0784
    0.0785
    0.0763
    0.0791
    0.0779
    0.0791
    0.0827

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.1294
    0.1043
    0.1023
    0.1050
    0.0984
    0.1039
    0.1054
    0.1053
    0.1019

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0647
    0.0605
    0.0585
    0.0590
    0.0610
    0.0585
    0.0607
    0.0598
    0.0624

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.1038
    0.0997
    0.0974
    0.0927
    0.0926
    0.0950
    0.0934
    0.0935
    0.1019

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0800
    0.0848
    0.0720
    0.0773
    0.0761
    0.0753
    0.0748
    0.0738
    0.0779

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0800
    0.0924
    0.0880
    0.0919
    0.0868
    0.0936
    0.0913
    0.0906
    0.0915

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0955
    0.0949
    0.0903
    0.0943
    0.0891
    0.0961
    0.0937
    0.0930
    0.0940

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0899
    0.0845
    0.0776
    0.0795
    0.0806
    0.0762
    0.0764
    0.0764
    0.0765

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0909
    0.1005
    0.0969
    0.0978
    0.0966
    0.1004
    0.0975
    0.0946
    0.0975

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0859
    0.1104
    0.0934
    0.0941
    0.0984
    0.0913
    0.0978
    0.0979
    0.0980

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0964
    0.0930
    0.0863
    0.0882
    0.0847
    0.0872
    0.0840
    0.0878
    0.0868

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.1018
    0.0954
    0.0955
    0.0902
    0.0898
    0.0942
    0.0931
    0.0933
    0.0907

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.1119
    0.0844
    0.0807
    0.0788
    0.0812
    0.0804
    0.0826
    0.0797
    0.0806

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0905
    0.1019
    0.1018
    0.0936
    0.0988
    0.0936
    0.1007
    0.0928
    0.0909

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}
    {[17:01:46.852000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0813
    0.0616
    0.0640
    0.0629
    0.0617
    0.0672
    0.0652
    0.0655
    0.0663

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}
    {[17:01:46.852000]}    {10×1 double}
    {[17:01:50.908000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0961
    0.0903
    0.0885
    0.0882
    0.0844
    0.0948
    0.0864
    0.0915
    0.0912

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}
    {[17:01:46.852000]}    {10×1 double}
    {[17:01:50.908000]}    {10×1 double}
    {[17:01:54.973000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0849
    0.0898
    0.0823
    0.0825
    0.0802
    0.0810
    0.0793
    0.0803
    0.0832

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}
    {[17:01:46.852000]}    {10×1 double}
    {[17:01:50.908000]}    {10×1 double}
    {[17:01:54.973000]}    {10×1 double}
    {[17:01:59.023000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.1125
    0.0884
    0.0895
    0.0845
    0.0826
    0.0846
    0.0853
    0.0853
    0.0824

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}
    {[17:01:46.852000]}    {10×1 double}
    {[17:01:50.908000]}    {10×1 double}
    {[17:01:54.973000]}    {10×1 double}
    {[17:01:59.023000]}    {10×1 double}
    {[17:02:03.083000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0807
    0.0694
    0.0673
    0.0673
    0.0722
    0.0677
    0.0643
    0.0689
    0.0711

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}
    {[17:01:46.852000]}    {10×1 double}
    {[17:01:50.908000]}    {10×1 double}
    {[17:01:54.973000]}    {10×1 double}
    {[17:01:59.023000]}    {10×1 double}
    {[17:02:03.083000]}    {10×1 double}
    {[17:02:07.148000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0792
    0.0655
    0.0642
    0.0675
    0.0637
    0.0649
    0.0649
    0.0646
    0.0665

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}
    {[17:01:46.852000]}    {10×1 double}
    {[17:01:50.908000]}    {10×1 double}
    {[17:01:54.973000]}    {10×1 double}
    {[17:01:59.023000]}    {10×1 double}
    {[17:02:03.083000]}    {10×1 double}
    {[17:02:07.148000]}    {10×1 double}
    {[17:02:11.217000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.1096
    0.0889
    0.0892
    0.0852
    0.0831
    0.0904
    0.0919
    0.0916
    0.0903

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}
    {[17:01:46.852000]}    {10×1 double}
    {[17:01:50.908000]}    {10×1 double}
    {[17:01:54.973000]}    {10×1 double}
    {[17:01:59.023000]}    {10×1 double}
    {[17:02:03.083000]}    {10×1 double}
    {[17:02:07.148000]}    {10×1 double}
    {[17:02:11.217000]}    {10×1 double}
    {[17:02:15.273000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.0897
    0.0874
    0.0778
    0.0826
    0.0799
    0.0775
    0.0797
    0.0782
    0.0778

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}
    {[17:01:46.852000]}    {10×1 double}
    {[17:01:50.908000]}    {10×1 double}
    {[17:01:54.973000]}    {10×1 double}
    {[17:01:59.023000]}    {10×1 double}
    {[17:02:03.083000]}    {10×1 double}
    {[17:02:07.148000]}    {10×1 double}
    {[17:02:11.217000]}    {10×1 double}
    {[17:02:15.273000]}    {10×1 double}
    {[17:02:19.342000]}    {10×1 double}

runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.
runAcq/recon: Timeout waiting for next acquisition frame. Re-processing previous.

ttp =

    1.0000
    0.1055
    0.0868
    0.0920
    0.0900
    0.0898
    0.0966
    0.0918
    0.0919
    0.0931

Dictionary of [Time, ttp]:
    {[17:00:54.093000]}    {10×1 double}
    {[17:00:58.148000]}    {10×1 double}
    {[17:01:02.201000]}    {10×1 double}
    {[17:01:06.286000]}    {10×1 double}
    {[17:01:10.362000]}    {10×1 double}
    {[17:01:14.421000]}    {10×1 double}
    {[17:01:18.474000]}    {10×1 double}
    {[17:01:22.512000]}    {10×1 double}
    {[17:01:26.569000]}    {10×1 double}
    {[17:01:30.624000]}    {10×1 double}
    {[17:01:34.679000]}    {10×1 double}
    {[17:01:38.728000]}    {10×1 double}
    {[17:01:42.782000]}    {10×1 double}
    {[17:01:46.852000]}    {10×1 double}
    {[17:01:50.908000]}    {10×1 double}
    {[17:01:54.973000]}    {10×1 double}
    {[17:01:59.023000]}    {10×1 double}
    {[17:02:03.083000]}    {10×1 double}
    {[17:02:07.148000]}    {10×1 double}
    {[17:02:11.217000]}    {10×1 double}
    {[17:02:15.273000]}    {10×1 double}
    {[17:02:19.342000]}    {10×1 double}
    {[17:02:23.412000]}    {10×1 double}

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