foreach(x actor actor-autorestart
        activity-lifecycle
        comm-pt2pt wait-any-for
        cloud-interrupt-migration cloud-sharing
        concurrent_rw storage_client_server listen_async pid )
  add_executable       (${x}  EXCLUDE_FROM_ALL ${x}/${x}.cpp)
  target_link_libraries(${x}  simgrid)
  set_target_properties(${x}  PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${x})
  add_dependencies(tests ${x})

  set(teshsuite_src ${teshsuite_src} ${CMAKE_CURRENT_SOURCE_DIR}/${x}/${x}.cpp)
endforeach()

## Add the tests.
## Some need to be run with all factories, some need not tesh to run
foreach(x actor actor-autorestart
        activity-lifecycle wait-any-for
	cloud-interrupt-migration concurrent_rw) # TODO: actor-autorestart is disabled for now
  set(tesh_files    ${tesh_files}    ${CMAKE_CURRENT_SOURCE_DIR}/${x}/${x}.tesh)
  ADD_TESH_FACTORIES(tesh-s4u-${x} "thread;ucontext;raw;boost" --setenv bindir=${CMAKE_BINARY_DIR}/teshsuite/s4u/${x} --setenv srcdir=${CMAKE_HOME_DIRECTORY}/teshsuite/s4u/${x} --setenv platfdir=${CMAKE_HOME_DIRECTORY}/examples/platforms --cd ${CMAKE_BINARY_DIR}/teshsuite/s4u/${x} ${CMAKE_HOME_DIRECTORY}/teshsuite/s4u/${x}/${x}.tesh)
endforeach()

foreach(x listen_async pid storage_client_server cloud-sharing)
  set(tesh_files    ${tesh_files}    ${CMAKE_CURRENT_SOURCE_DIR}/${x}/${x}.tesh)
  ADD_TESH(tesh-s4u-${x} --setenv srcdir=${CMAKE_HOME_DIRECTORY}/teshsuite/s4u/${x} --setenv platfdir=${CMAKE_HOME_DIRECTORY}/examples/platforms --cd ${CMAKE_BINARY_DIR}/teshsuite/s4u/${x} ${CMAKE_HOME_DIRECTORY}/teshsuite/s4u/${x}/${x}.tesh)
endforeach()

# The output is not relevant
ADD_TEST(tesh-s4u-comm-pt2pt    ${CMAKE_BINARY_DIR}/teshsuite/s4u/comm-pt2pt/comm-pt2pt    ${CMAKE_HOME_DIRECTORY}/examples/platforms/cluster_backbone.xml)

# NS-3 specific tests
if(SIMGRID_HAVE_NS3)
  foreach(x ns3-simultaneous-send-rcv)
    add_executable       (${x}  EXCLUDE_FROM_ALL ${x}/${x}.cpp)
    target_link_libraries(${x}  simgrid)
    set_target_properties(${x}  PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${x})
    add_dependencies(tests ${x})
    ADD_TESH(tesh-s4u-${x} --setenv srcdir=${CMAKE_HOME_DIRECTORY}/teshsuite/s4u/${x} --setenv platfdir=${CMAKE_HOME_DIRECTORY}/examples/platforms --cd ${CMAKE_BINARY_DIR}/teshsuite/s4u/${x} ${CMAKE_HOME_DIRECTORY}/teshsuite/s4u/${x}/${x}.tesh)
  endforeach()
endif()

foreach(x ns3-simultaneous-send-rcv)
  set(teshsuite_src ${teshsuite_src} ${CMAKE_CURRENT_SOURCE_DIR}/${x}/${x}.cpp)
  set(tesh_files    ${tesh_files}    ${CMAKE_CURRENT_SOURCE_DIR}/${x}/${x}.tesh)
endforeach()

set(teshsuite_src ${teshsuite_src}  PARENT_SCOPE)
set(tesh_files    ${tesh_files}     PARENT_SCOPE)
set(xml_files     ${xml_files}      ${CMAKE_CURRENT_SOURCE_DIR}/activity-lifecycle/testing_platform.xml PARENT_SCOPE)
