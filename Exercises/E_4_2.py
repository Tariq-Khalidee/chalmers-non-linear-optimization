import numpy as np 
import itertools
A = np.array([[1,1,-1,0,0,0,0],
              [1,-1,0,1,0,0,0],
              [-1,1,0,0,1,0,0],
              [1,0,0,0,0,1,0],
              [0,1,0,0,0,0,1]], float)
b = np.array([1,1,1,2,2], float)
names = ['x1','x2','s1','s2','s3','s4','s5']
base = [0,1,2,3,4]
for enter in [5,6]:
    for leave in base:
        cols = [c for c in base if c != leave] + [enter]
        B = A[:, cols]
        if abs(np.linalg.det(B)) < 1e-9:
            print(names[enter], 'in,', names[leave], 'out: singular'); continue
        xB = np.linalg.solve(B, b)
        print(names[enter], 'in,', names[leave], 'out:', np.round(xB,3),
              'BFS' if (xB >= -1e-9).all() else 'infeasible')