using GDWeave;
using GDWeave.Godot;
using GDWeave.Godot.Variants;
using GDWeave.Modding;

namespace TackleBox;

public class Mod : IMod {
    public Mod(IModInterface modInterface) {
        modInterface.RegisterScriptMod(new TackleBox(modInterface.LoadedMods));
    }

    public void Dispose() {
        // Cleanup anything you do here
    }
}

public class TackleBox(string[] loadedMods) : IScriptMod
{
    private string[] LoadedMods { get; } = loadedMods;
    public bool ShouldRun(string path) => path == "res://Scenes/Singletons/globals.gdc";

    public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
    {
        var extendsWaiter = new MultiTokenWaiter([
            t => t.Type is TokenType.PrExtends,
            t => t.Type is TokenType.Newline
        ], allowPartialMatch: true);
        
        foreach (var token in tokens)
        {
            yield return token;

            if (!extendsWaiter.Check(token)) continue;
            
            yield return new Token(TokenType.PrVar);
            yield return new IdentifierToken("loaded_mods");
            yield return new Token(TokenType.OpAssign);
            yield return new Token(TokenType.BracketOpen);

            var i = 0;
            foreach (var mod in LoadedMods)
            {
                yield return new ConstantToken(new StringVariant(mod));
                if (i++ < LoadedMods.Length)
                {
                    yield return new Token(TokenType.Comma);
                }
            }
                
            yield return new Token(TokenType.BracketClose);
            yield return new Token(TokenType.Newline);
        }
    }
}