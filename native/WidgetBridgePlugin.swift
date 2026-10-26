import Capacitor
import WidgetKit

// Передаёт баланс из веб-части приложения в виджет через App Group.
@objc(WidgetBridgePlugin)
public class WidgetBridgePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "WidgetBridgePlugin"
    public let jsName = "WidgetBridge"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "setBalance", returnType: CAPPluginReturnPromise)
    ]

    @objc func setBalance(_ call: CAPPluginCall) {
        let value = call.getDouble("balance") ?? 0
        UserDefaults(suiteName: "group.com.example.finance")?.set(value, forKey: "balance")
        WidgetCenter.shared.reloadAllTimelines()
        call.resolve()
    }
}
