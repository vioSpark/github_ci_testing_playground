using Demo.Worker;
using Xunit;
using Xunit.Abstractions;

namespace Demo.Worker.Tests;

public class CalculatorTests(ITestOutputHelper output)
{
    [Fact]
    public void Add_ReturnsSum()
    {
        output.WriteLine($"Tested code was compiled for: {Calculator.Flavor}");
        Assert.Equal(5, Calculator.Add(2, 3));
    }
}
