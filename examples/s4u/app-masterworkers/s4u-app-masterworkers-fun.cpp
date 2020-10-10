/* Copyright (c) 2010-2020. The SimGrid Team. All rights reserved.          */

/* This program is free software; you can redistribute it and/or modify it
 * under the terms of the license (GNU LGPL) which comes with this package. */

/****************************************************************************
 *
 *     This is our solution to the third lab of the S4U tutorial
 * (available online at https://simgrid.frama.io/simgrid/tuto_s4u.html)
 *
 *    Reading this further before taking the tutorial will SPOIL YOU!!!
 *
 ****************************************************************************/

#include <simgrid/s4u.hpp>

XBT_LOG_NEW_DEFAULT_CATEGORY(s4u_app_masterworker, "Messages specific for this example");

#define PS_MAILBOX_NAME "PS_MAXILBOX"

double communication_cost = 0;

static void worker()
{
  const std::string mailbox_name   = std::string("worker-") + std::to_string(simgrid::s4u::this_actor::get_pid());
  simgrid::s4u::Mailbox* mailbox   = simgrid::s4u::Mailbox::by_name(mailbox_name);
  simgrid::s4u::Mailbox* psMailbox = simgrid::s4u::Mailbox::by_name(PS_MAILBOX_NAME);
  double train_epoch_cost = 0;
  
  while (true) { // Master forcefully kills the workers by the end of the simulation
    /* blocking: wait until global weights are received --- SHOULD MAKE WITH TIMEOUT!!!!!!! */
    double* msg  = static_cast<double*>(mailbox->get());
    train_epoch_cost = *msg;
    delete msg;

    /* compute local weights */
    simgrid::s4u::this_actor::execute(train_epoch_cost);
    
    /* send local weights to Parameter Server */
    //XBT_INFO("Worker %ld sending task to mailbox '%s'", simgrid::s4u::this_actor::get_pid(), psMailbox->get_cname());
    double sync_cost = 500;
    psMailbox->put(new double(sync_cost), communication_cost);
  }
}

static void master(std::vector<std::string> args)
{
  xbt_assert(args.size() == 5, "The master function expects 4 arguments");

  double task_count          = std::stod(args[1]);
  double train_epoch_cost    = std::stod(args[2]);
  communication_cost         = std::stod(args[3]); // global variable
  double sync_cost           = std::stod(args[4]);

  std::vector<simgrid::s4u::ActorPtr> actors;

  simgrid::s4u::Engine* e = simgrid::s4u::Engine::get_instance();
  simgrid::s4u::Mailbox* psMailbox = simgrid::s4u::Mailbox::by_name(PS_MAILBOX_NAME);
  
  XBT_INFO("Asked to run %.1f tasks", task_count);

  for (auto* host : e->get_all_hosts()) {
    simgrid::s4u::ActorPtr act = simgrid::s4u::Actor::create(std::string("Worker-") + host->get_name(), host, worker);
    actors.push_back(act);
  }

  /* INITIAL send global weights to workers */
  for (unsigned long i = 0; i < actors.size(); i++) {
    aid_t worker_pid                 = actors.at(i)->get_pid();
    std::string mailbox_name         = std::string("worker-") + std::to_string(worker_pid);
    simgrid::s4u::Mailbox* mailbox   = simgrid::s4u::Mailbox::by_name(mailbox_name);

    mailbox->put(new double(train_epoch_cost), communication_cost);
  }
  
  for (int task_id = 1; task_id < task_count; task_id++) { // (e->get_clock() < task_count) { /* For each task: */
    
    XBT_INFO("Epoch %d", task_id);
    
    /* Check psMailbox before updating global weights */
    unsigned long mailcount = 0;
    while (mailcount < actors.size()) {
      double* msg  = static_cast<double*>(psMailbox->get());
      //double compute_cost_temp = *msg;
      delete msg;
      mailcount++;
    }

    /* Compute global weights */
    simgrid::s4u::this_actor::execute(sync_cost);
    
    /* Send global weights to workers */
    for (unsigned long i = 0; i < actors.size(); i++) {
      aid_t worker_pid                 = actors.at(i)->get_pid();
      std::string mailbox_name         = std::string("worker-") + std::to_string(worker_pid);
      simgrid::s4u::Mailbox* mailbox   = simgrid::s4u::Mailbox::by_name(mailbox_name);
    
      /* - Send the computation cost to that worker */
      /*
      if (true) //(task_id % 100 == 0)
	XBT_INFO("Sending task %d to mailbox '%s'", task_id, mailbox->get_cname());
      else
	XBT_DEBUG("Sending task %d to mailbox '%s'", task_id, mailbox->get_cname());
      */
      mailbox->put(new double(train_epoch_cost), communication_cost);
    }
  }

  XBT_INFO("No more tasks. Forcefully kill all workers.");
  for (unsigned long i = 0; i < actors.size(); i++) {
    actors.at(i)->kill();
  }
}

int main(int argc, char* argv[])
{
  simgrid::s4u::Engine e(&argc, argv);
  xbt_assert(argc > 2, "Usage: %s platform_file deployment_file\n", argv[0]);

  /* Register the functions representing the actors */
  e.register_function("master", &master);

  /* Load the platform description and then deploy the application */
  e.load_platform(argv[1]);
  e.load_deployment(argv[2]);

  /* Run the simulation */
  e.run();

  XBT_INFO("Simulation is over");

  return 0;
}
