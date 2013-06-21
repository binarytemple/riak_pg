%% @author Christopher Meiklejohn <christopher.meiklejohn@gmail.com>
%% @copyright 2013 Christopher Meiklejohn.
%% @doc Application supervisor.

-module(riak_pg_sup).
-author('Christopher Meiklejohn <christopher.meiklejohn@gmail.com>').

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init(_Args) ->
    VMaster = {riak_pg_vnode_master,
               {riak_core_vnode_master, start_link, [riak_pg_vnode]},
                permanent, 5000, worker, [riak_core_vnode_master]},

    MessageProxy = {riak_pg_message_proxy_vnode_master,
                    {riak_core_vnode_master, start_link, [riak_pg_message_proxy_vnode]},
                     permanent, 5000, worker, [riak_core_vnode_master]},

    Messaging = {riak_pg_messaging_vnode_master,
                 {riak_core_vnode_master, start_link, [riak_pg_messaging_vnode]},
                  permanent, 5000, worker, [riak_core_vnode_master]},

    Memberships = {riak_pg_memberships_vnode_master,
                   {riak_core_vnode_master, start_link, [riak_pg_memberships_vnode]},
                    permanent, 5000, worker, [riak_core_vnode_master]},

    SendFSM = {riak_pg_send_fsm_sup,
               {riak_pg_send_fsm_sup, start_link, []},
                permanent, infinity, supervisor, [riak_pg_send_fsm_sup]},

    CreateFSM = {riak_pg_create_fsm_sup,
                 {riak_pg_create_fsm_sup, start_link, []},
                  permanent, infinity, supervisor, [riak_pg_create_fsm_sup]},

    DeleteFSM = {riak_pg_delete_fsm_sup,
                 {riak_pg_delete_fsm_sup, start_link, []},
                  permanent, infinity, supervisor, [riak_pg_delete_fsm_sup]},

    JoinFSM = {riak_pg_join_fsm_sup,
               {riak_pg_join_fsm_sup, start_link, []},
                permanent, infinity, supervisor, [riak_pg_join_fsm_sup]},

    LeaveFSM = {riak_pg_leave_fsm_sup,
                {riak_pg_leave_fsm_sup, start_link, []},
                 permanent, infinity, supervisor, [riak_pg_leave_fsm_sup]},

    MembersFSM = {riak_pg_members_fsm_sup,
                  {riak_pg_members_fsm_sup, start_link, []},
                   permanent, infinity, supervisor, [riak_pg_members_fsm_sup]},

    {ok, {{one_for_one, 5, 10}, [VMaster,
                                 MessageProxy,
                                 Messaging,
                                 Memberships,
                                 SendFSM,
                                 CreateFSM,
                                 DeleteFSM,
                                 JoinFSM,
                                 LeaveFSM,
                                 MembersFSM]}}.