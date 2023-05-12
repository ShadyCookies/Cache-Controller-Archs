# Cache-Controller-Archs
Implementation of various cache controller architectures. Currently consists of a main memory unit, and:
1)  A direct mapped L1 cache with write-back scheme. Read and Write hits take 1 cc each, while Read and Write misses take 2 cc each. Not a proper implementation, will update later. 
2)  A direct mapped L1 cache with write-though scheme. Implemented using a proper state machine. Read hits take 2 cc, Write hits take 3 cc, Read misses take 3 cc, and Write misses take 4 cc. Will be used as a foundation for more elaborate cache architectures.
3)  
Will continue to update the repository with caches of various associativities and later multilevel caches.
