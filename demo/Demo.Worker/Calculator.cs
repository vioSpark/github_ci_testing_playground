namespace Demo.Worker;

public static class Calculator
{
    public static int Add(int a, int b) => a + b;

    // Shows which target framework this code was compiled for.
    public static string Flavor =>
#if WINDOWS
        "net8.0-windows";
#else
        "net8.0 (portable)";
#endif
}
