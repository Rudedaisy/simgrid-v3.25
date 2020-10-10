cd build/
make tests
cd ..

#`pwd`/build/examples/s4u/app-masterworkers/s4u-app-masterworkers-fun `pwd`/examples/platforms/cluster_and_one_host.xml.IB `pwd`/build/examples/s4u/app-masterworkers/deployment3.xml --cfg=network/model:IB --cfg=tracing:yes --cfg=tracing/msg/process:yes --cfg=surf/precision:2e-06

`pwd`/build/examples/s4u/app-masterworkers/s4u-app-masterworkers-fun `pwd`/examples/platforms/cluster_and_one_host.xml `pwd`/examples/s4u/app-masterworkers/deployment3.xml --cfg=network/model:LV08 --cfg=tracing:yes --cfg=tracing/msg/process:yes --cfg=surf/precision:500e-09

#Rscript /mnt/1tb/simgrid-v3.25/docs/source/tuto_s4u/draw_gantt.R simgrid.trace
