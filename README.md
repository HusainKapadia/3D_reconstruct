# 3D_reconstruct

This project is is associated with the COmputer Vision course at TU Delft. We implemented a 3D reconstruction algorithm given a dataset of castle images. This was accomplished by detecting Hessian and Harris affine and SIFT features, matching these features using 8-point RANSAC, creating a point view matrix, estimating the 3D co-ordinates using Tomasi Kanade algorithm and then stitching the 3D points using Procrustes analysis.
