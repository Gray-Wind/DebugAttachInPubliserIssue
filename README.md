# DebugAttachInPublisherIssue

** Fixed in Xcode 15.3 beta 2 **

The project demonstrates the issue with debugger attach to `sink` method of publisher.

In case if the first line of the callback contains `guard let strongRef = weakRef...` the debugger cannot be attached on a breakpoint of such callback.

The issue is reproducible in both macOS and iOS applications.

Reproduced with:
* macOS 14.0 (23A344)
* Xcode 15.0 (15A240d)
* Xcode 15.1 beta (15C5028h)

Feedback ticket: FB13232348

## A Bit Of Investigation

On my host the lldb cannot catch anything apart from `ModelTracker.swift:35` from the first reproduction case (see lldb logs for details).

Interestingly enough, on a host of my colleague breakpoints on `*0x100007de0`, `*0x100007e10` (and `ModelTracker.swift:35` of course) work fine.

`ModelTracker.swift:32` doesn't work for both of us.

We both have the same version of macOS and tools (but he has disabled SIP).
```
> xcode-select -v
xcode-select version 2399.
```

```
> lldb --version
lldb-1500.0.22.8
Apple Swift version 5.9 (swiftlang-5.9.0.128.108 clang-1500.0.40.1)
```

```
lldb PubliserSubscriptionIssue.app/Contents/MacOS/PubliserSubscriptionIssue
(lldb) target create "PubliserSubscriptionIssue.app/Contents/MacOS/PubliserSubscriptionIssue"
Current executable set to '/Users/test/Library/Developer/Xcode/DerivedData/PubliserSubscriptionIssue-djndqljvolqzmbedwaykzwcpevnk/Build/Products/Debug/PubliserSubscriptionIssue.app/Contents/MacOS/PubliserSubscriptionIssue' (arm64).
(lldb) b *0x100007de0
Breakpoint 1: address = 0x0000000100007de0
(lldb) b ModelTracker.swift:32
Breakpoint 2: where = PubliserSubscriptionIssue`closure #1 (Swift.Bool) -> () in PubliserSubscriptionIssue.ModelTracker.model.didset : Swift.Optional<PubliserSubscriptionIssue.Model> + 144 at ModelTracker.swift:32:39, address = 0x0000000100007df4
(lldb) b *0x100007e10
Breakpoint 3: address = 0x0000000100007e10
(lldb) b ModelTracker.swift:35
Breakpoint 4: where = PubliserSubscriptionIssue`closure #1 (Swift.Bool) -> () in PubliserSubscriptionIssue.ModelTracker.model.didset : Swift.Optional<PubliserSubscriptionIssue.Model> + 180 at ModelTracker.swift:35:13, address = 0x0000000100007e18
(lldb) r
Process 55714 launched: '/Users/test/Library/Developer/Xcode/DerivedData/PubliserSubscriptionIssue-djndqljvolqzmbedwaykzwcpevnk/Build/Products/Debug/PubliserSubscriptionIssue.app/Contents/MacOS/PubliserSubscriptionIssue' (arm64)
triggerStatus: false, from: weakGuard
Process 55714 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 4.1
    frame #0: 0x0000000100007e18 PubliserSubscriptionIssue`closure #1 in ModelTracker.model.didset(triggerStatus=false, self=0x00006000009c13c0) at ModelTracker.swift:35:13
   32  	                guard let self else { return }
   33  	                // Cannot attach with debugger here, the breakpoint is ignored
   34  	                react(on: triggerStatus, from: .weakGuard)
-> 35  	            }
   36  	            .store(in: &modelSubscriptions)
   37  	            model.$publisherTrigger.sink { [weak self] triggerStatus in
   38  	                guard let self = self else { return }
Target 0: (PubliserSubscriptionIssue) stopped.
(lldb) c
Process 55714 resuming
triggerStatus: false, from: weakGuard
triggerStatus: false, from: weak
triggerStatus: false, from: unowned
triggerStatus: false, from: otherGuardFirst
triggerStatus: false, from: otherWeakFirst
triggerStatus: false, from: weakGuardBefore
triggerStatus: false, from: weakGuardAfter
reacting on publisher...
triggerStatus: false, from: weakGuardAfter
triggerStatus: true, from: weakGuard
triggerStatus: true, from: unowned
triggerStatus: true, from: weakGuard
Process 55714 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 4.1
    frame #0: 0x0000000100007e18 PubliserSubscriptionIssue`closure #1 in ModelTracker.model.didset(triggerStatus=true, self=0x00006000009c13c0) at ModelTracker.swift:35:13
   32  	                guard let self else { return }
   33  	                // Cannot attach with debugger here, the breakpoint is ignored
   34  	                react(on: triggerStatus, from: .weakGuard)
-> 35  	            }
   36  	            .store(in: &modelSubscriptions)
   37  	            model.$publisherTrigger.sink { [weak self] triggerStatus in
   38  	                guard let self = self else { return }
Target 0: (PubliserSubscriptionIssue) stopped.
(lldb) c
Process 55714 resuming
triggerStatus: true, from: otherGuardFirst
triggerStatus: true, from: weak
reacting on publisher...
triggerStatus: true, from: weakGuardAfter
triggerStatus: true, from: otherWeakFirst
triggerStatus: true, from: weakGuardBefore
triggerStatus: true, from: weakGuardAfter
```
