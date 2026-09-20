--!strict
-- Generic opt-in Secret backtracking must not rewind the required route.
local Dungeon=game:GetService("ServerScriptService"):WaitForChild("Dungeon")
local Sequencer=require(Dungeon:WaitForChild("DungeonEncounterSequencer"))
local n=0
local function check(ok: boolean, reason: string)
    n+=1
    assert(ok, "[Deferred Secret Backtrack Tests] "..reason)
end
local plan={
    {Id="Room1",Kind="Combat",CompletionRequired=true},
    {Id="Room2",Kind="Combat",CompletionRequired=true},
    {Id="Secret",Kind="SecretBoss",CompletionRequired=false},
    {Id="Final",Kind="Boss",CompletionRequired=true},
}
local seq=Sequencer.new(plan)
check(seq:start_skipped_secret("Secret").reason=="SecretNotDeferred",
    "cannot activate an undiscovered or pending secret out of order")
check(seq:start("Room1").ok and seq:clear("Room1").ok,"Room1 clears")
check(seq:start("Room2").ok and seq:clear("Room2").ok,"Room2 clears")
check(seq:next_id()=="Secret","secret is next until bypassed")
check(seq:skip("Secret").ok,"passing the side door can bypass the optional secret")
check(seq:next_id()=="Final","bypassing secret unlocks the next required room")
check(seq:start_skipped_secret("Final").reason=="NotDeferredSecretBoss",
    "deferred path cannot bypass required final boss")
check(seq:start_skipped_secret("Secret").ok,"backtracking starts secret after Room2")
check(seq:start("Final").reason=="AnotherEncounterActive",
    "required boss cannot overlap deferred secret boss")
check(seq:start_skipped_secret("Secret").reason=="AnotherEncounterActive",
    "double-entry cannot duplicate secret boss")
local interrupted=seq:snapshot()
check(interrupted.DeferredSecretActiveEncounterId=="Secret",
    "active deferred boss explicitly marked for reconnect recovery")
local recovered=Sequencer.new(plan,interrupted)
check(recovered:state_of("Secret")=="Skipped"
    and recovered:next_id()=="Final",
    "interrupted deferred boss restores as bypassed, not a main-route blocker")
check(seq:cancel_active("Secret").ok and seq:state_of("Secret")=="Skipped",
    "failed deferred boss start returns to bypassed and keeps main route")
check(seq:next_id()=="Final","rollback never rewinds Room2")
check(seq:start_skipped_secret("Secret").ok,"deferred secret can be retried")
check(seq:clear("Secret").ok and seq:next_id()=="Final",
    "defeating deferred secret preserves main route")
check(seq:start_skipped_secret("Secret").reason=="SecretNotDeferred",
    "cleared secret cannot grant a duplicate encounter/reward")
check(seq:start("Final").ok and seq:clear("Final").ok,"required boss remains playable")
check(seq:is_complete(),"normal completion remains independent of secret")
-- If persistence rejects a backtracked boss start, gameplay may still
-- proceed. Only a server-committed Active state can lock the main route.
local Controller=require(Dungeon:WaitForChild("DungeonEncounterRuntimeController"))
local failure_seq=Sequencer.new(plan,{
    EncounterStates={Room1="Cleared",Room2="Cleared",Secret="Skipped",Final="Pending"},
})
local failed_save_controller=setmetatable({
    _sequencer=failure_seq,
    _persist=function() return {ok=false,reason="SimulatedStoreOutage"} end,
},Controller)
local failed_start=failed_save_controller:start_skipped_secret("Secret")
check(failed_start.ok==false
    and failed_start.reason=="SimulatedStoreOutage"
    and failure_seq:state_of("Secret")=="Skipped"
    and failure_seq:next_id()=="Final",
    "failed optional start persistence cannot strand the required route")
local skipped=Sequencer.new(plan,{
    EncounterStates={Room1="Cleared",Room2="Cleared",Secret="Skipped",Final="Cleared"},
})
check(skipped:start_skipped_secret("Secret").reason=="DeferredSecretRunNotActive",
    "side boss cannot be started after completed dungeon")
local required=Sequencer.new({
    {Id="Required",Kind="SecretBoss",CompletionRequired=true},
    {Id="Final",Kind="Boss",CompletionRequired=true},
})
check(required:start_skipped_secret("Required").reason=="NotDeferredSecretBoss",
    "required secret cannot use deferred side path")
print(string.format("[Deferred Secret Backtrack Tests] PASS: %d assertions.",n))
