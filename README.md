# DebugAttachInPublisherIssue

The project demonstrates the issue with debugger attach to `sink` method of publisher.

In case if the first line of the callback contains `guard let strongRef = weakRef...` the debugger cannot be attached on a breakpoint of such callback.

The issue is reproducible in both macOS and iOS applications.

Reproduced with:
* macOS 14.0 (23A344)
* Xcode 15.0 (15A240d)
* Xcode 15.1 beta (15C5028h)

Feedback ticket: FB13232348
