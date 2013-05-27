Masters Project
----------------

Started 27/05/2013

Version 0.1
------------
+This version is reformatted copy of the version which I have been working on up to this date. The idea is to tidy the code up a bit and work on the modularity of the program. To allow testing.
+ The idea is that each individual feature search should have its own funtion file of the following format.

INPUT: Everything it need to be able to find the feature it requires. Each function will be set up to only find one feature in one image. A train method will be used to produce a training set for that object if needed. Usually all that should be passed in is in image and it's estimate if needed. All input values will be in mm form and will be converted to pixel values as needed. 

OUTPUT: A location, all measurement outputs will be in mm form and converted to pixel values as needed. An optional output will be provided with detected points marked on the image if needed.