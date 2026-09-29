package utils;

class CustomModules {
    public static var registry:Map<String, Void -> String> = new Map();

    public static function registerModule(name: String, functionString: Void -> String): Void {
        registry.set(name, functionString);
    }
}