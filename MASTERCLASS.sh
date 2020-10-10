cd build/
make tests
cd ..

#/mnt/1tb/simgrid-v3.25/build/examples/s4u/app-masterworkers/s4u-app-masterworkers-fun /mnt/1tb/simgrid-v3.25/examples/platforms/cluster_and_one_host.xml.IB /mnt/1tb/simgrid-v3.25/build/examples/s4u/app-masterworkers/deployment3.xml --cfg=network/model:IB --cfg=tracing:yes --cfg=tracing/msg/process:yes --cfg=surf/precision:2e-06

/mnt/1tb/simgrid-v3.25/build/examples/s4u/app-masterworkers/s4u-app-masterworkers-fun /mnt/1tb/simgrid-v3.25/examples/platforms/cluster_and_one_host.xml /mnt/1tb/simgrid-v3.25/build/examples/s4u/app-masterworkers/deployment3.xml --cfg=network/model:LV08 --cfg=tracing:yes --cfg=tracing/msg/process:yes --cfg=surf/precision:500e-09

#Rscript /mnt/1tb/simgrid-v3.25/docs/source/tuto_s4u/draw_gantt.R simgrid.trace
