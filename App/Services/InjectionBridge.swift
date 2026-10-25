import Foundation

/// Injection bridge — INTERFACE + STUB ONLY.
///
/// Live injection is intentionally omitted from this project:
///  - it would violate the Roblox Terms of Use;
///  - the original mechanism (dylib-insertion tooling, code-signature stripping, an unsigned
///    dylib injected into RobloxPlayer) is a malware-indicator pattern
///    (see docs/research/04-malware-trust-check.md);
///  - no Roblox process is ever touched by this codebase.
///
/// Every live method returns `.notImplemented`. Callers must surface that
/// state in the UI rather than pretending an attach succeeded.
enum InjectionResult: Equatable {
    case notImplemented(reason: String)
    case attached
    case failed(reason: String)
}

protocol InjectionBridgeProtocol {
    func attach() async -> InjectionResult
    func execute(script: String) async -> InjectionResult
    func detach() async -> InjectionResult
}

struct InjectionBridgeStub: InjectionBridgeProtocol {
    static let notImplementedReason =
        "Live injection is intentionally omitted from this clean-room rebuild: " +
        "it violates the Roblox Terms of Use and is out of scope. See docs/modules/09-injection-bridge.md."

    func attach() async -> InjectionResult { .notImplemented(reason: Self.notImplementedReason) }
    func execute(script: String) async -> InjectionResult { .notImplemented(reason: Self.notImplementedReason) }
    func detach() async -> InjectionResult { .notImplemented(reason: Self.notImplementedReason) }
}
