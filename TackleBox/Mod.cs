using GDWeave;

namespace TackleBox;

public class Mod : IMod {
    public Mod(IModInterface modInterface) {
        modInterface.Logger.Information("Hello, world!");
    }

    public void Dispose() {
        // Cleanup anything you do here
    }
}
